require 'cl/cast'
require 'cl/errors'

class Cl
  class Opt < Struct.new(:strs, :opts, :block)
    include Cast, Regex

    OPTS = %i(
      alias default deprecated description downcase eg enum example format
      internal max min negate note required requires secret see sep type upcase
    )

    OPT = /^--(?:\[.*\])?(.*)$/

    TYPES = {
      int: :integer,
      str: :string,
      bool: :flag,
      boolean: :flag
    }

    attr_reader :short, :long

    def initialize(strs, *)
      super
      @short, @long = Validator.new(strs, opts).apply
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
      name = long.split(' ').first.match(OPT)[1] if long
      @name = name.sub('-', '_').to_sym if name
    end

    def type
      @type ||= TYPES[opts[:type]] || opts[:type] || infer_type
    end

    def infer_type
      strs.any? { |str| str.split(' ').size > 1 } ? :string : :flag
    end

    def help?
      name == :help
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

    def deprecated?(name = nil)
      return !!opts[:deprecated] if name.nil?
      names = [name.to_s.gsub('_', '-').to_sym, name.to_s.gsub('-', '_').to_sym]
      deprecated? && names.include?(deprecated.first)
    end

    def deprecated
      # If it's a string then it's a deprecation message and the option itself
      # is considered deprecated. If it's a symbol it refers to a deprecated
      # alias, and the option's name is the deprecation message.
      return [name, opts[:deprecated]] unless opts[:deprecated].is_a?(Symbol)
      opts[:deprecated] ? [opts[:deprecated], name] : []
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

    def unknown(value)
      return value.reject { |value| known?(value) } if value.is_a?(Array)
      known?(value) ? [] : Array(value)
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
      !!negate
    end

    def negate
      ['no'] + Array(opts[:negate]) if flag?
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

    def assign(opts, type, _, value)
      [name, *aliases].each do |name|
        if array?
          opts[name] ||= []
          opts[name] << value
        else
          opts[name] = value
        end
      end
    end

    def long?(str)
      str.start_with?('--')
    end

    class Validator < Struct.new(:strs, :opts)
      SHORT = /^-\w( \w+)?$/
      LONG  = /^--[\w\-\[\]]+( \[?\w+\]?)?$/

      MSGS = {
        missing_strs: 'No option strings given. Pass one short -s and/or one --long option string.',
        wrong_strs:   'Wrong option strings given. Pass one short -s and/or one --long option string.',
        invalid_strs: 'Invalid option strings given: %p',
        unknown_opts: 'Unknown options: %s'
      }

      def apply
        error :missing_strs if strs.empty?
        error :wrong_strs if short.size > 1 || long.size > 1
        error :invalid_strs, invalid unless invalid.empty?
        error :unknown_opts, unknown.map(&:inspect).join(', ') unless unknown.empty?
        [short.first, long.first]
      end

      def unknown
        @unknown ||= opts.keys - Opt::OPTS
      end

      def invalid
        @invalid ||= strs.-(valid).join(', ')
      end

      def valid
        strs.grep(Regexp.union(SHORT, LONG))
      end

      def short
        strs.grep(SHORT)
      end

      def long
        strs.grep(LONG)
      end

      def error(key, *args)
        raise Cl::Error, MSGS[key] % args
      end
    end
  end
end
