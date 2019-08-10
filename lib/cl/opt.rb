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
      if type == :array
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
  end
end
