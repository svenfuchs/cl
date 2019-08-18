require 'cl/cast'

class Cl
  class Opt < Struct.new(:strs, :opts, :block)
    include Cast, Regex

    OPT = /^--(?:\[.*\])?(.*)$/

    TYPES = {
      int: :integer,
      str: :string,
      bool: :flag,
      boolean: :flag
    }

    def initialize(*)
      super
      Validator.new(strs).apply
      noize!(strs) if type == :flag
    end

    def define(const)
      return unless __key__ = name
      const.send :include, Module.new {
        define_method (__key__) { opts[__key__] }
        define_method (:"#{__key__}?") { !!opts[__key__] }
      }
    end

    def name
      return @name if instance_variable_defined?(:@name)
      opt = strs.detect { |str| str.start_with?('--') }
      name = opt.split(' ').first.match(OPT)[1] if opt
      @name = name.sub('-', '_').to_sym if name
    end

    def type
      TYPES[opts[:type]] || opts[:type] || infer_type
    end

    def infer_type
      strs.any? { |str| str.split(' ').size > 1 } ? :string : :flag
    end

    def flag?
      type == :flag
    end

    def int?
      type == :int || type == :integer
    end

    def array?
      type == :array
    end

    def aliases?
      !!opts[:alias]
    end

    def aliases
      Array(opts[:alias])
    end

    def description
      opts[:description]
    end

    def deprecated?
      !!opts[:deprecated]
    end

    def deprecated
      return [name, opts[:deprecated]] unless opts[:deprecated].is_a?(Symbol)
      [opts[:deprecated], name] if opts[:deprecated]
    end

    def downcase?
      !!opts[:downcase]
    end

    def default?
      opts.key?(:default)
    end

    def default
      opts[:default]
    end

    def enum?
      !!opts[:enum]
    end

    def enum
      Array(opts[:enum])
    end

    def known?(value)
      return value.all? { |value| known?(value) } if value.is_a?(Array)
      enum.any? { |obj| obj.is_a?(Regexp) ? obj =~ value.to_s : obj == value }
    end

    def example?
      !!opts[:example]
    end

    def example
      opts[:example]
    end

    def format?
      !!opts[:format]
    end

    def format
      format_regex(opts[:format])
    end

    def formatted?(value)
      return value.all? { |value| formatted?(value) } if value.is_a?(Array)
      opts[:format] =~ value
    end

    def internal?
      !!opts[:internal]
    end

    def min?
      int? && !!opts[:min]
    end

    def min
      opts[:min]
    end

    def max?
      int? && !!opts[:max]
    end

    def max
      opts[:max]
    end

    def negate?
      !!opts[:negate]
    end

    def negate
      Array(opts[:negate])
    end

    def note?
      !!opts[:note]
    end

    def note
      opts[:note]
    end

    def required?
      !!opts[:required]
    end

    def requires?
      !!opts[:requires]
    end

    def requires
      Array(opts[:requires])
    end

    def secret?
      !!opts[:secret]
    end

    def see?
      !!opts[:see]
    end

    def see
      opts[:see]
    end

    def separator
      opts[:sep]
    end

    def upcase?
      !!opts[:upcase]
    end

    def block
      # raise if no block was given, and the option's name cannot be inferred
      super || method(:assign)
    end

    def assign(opts, type, name, value)
      if array?
        opts[name] ||= []
        opts[name] << value
      else
        opts[name] = value
      end
    end

    def noize!(strs)
      strs = strs.select { |str| str.start_with?('--') }
      strs = strs.reject { |str| str.include?('[no-]') }
      strs.each { |str| str.replace(str.sub('--', '--[no-]')) unless str == '--help' }
    end

    class Validator < Struct.new(:opts)
      SHORT = /^-\w( \w+)?$/
      LONG  = /^--[\w\-\[\]]+( \w+)?$/

      MSGS = {
        missing_opts: 'No option strings given. Pass one short -s and/or one --long option string.',
        wrong_opts:   'Wrong option strings given. Pass one short -s and/or one --long option string.',
        invalid_opts: 'Invalid option strings given: %p'
      }

      def apply
        error :missing_opts if opts.empty?
        error :wrong_opts if short.size > 1 || long.size > 1
        error :invalid_opts, invalid unless invalid.empty?
      end

      def invalid
        @invalid ||= opts.-(valid).join(', ')
      end

      def valid
        opts.grep(Regexp.union(SHORT, LONG))
      end

      def short
        opts.grep(SHORT)
      end

      def long
        opts.grep(LONG)
      end

      def error(key, *args)
        raise Error, MSGS[key] % args
      end
    end
  end
end
