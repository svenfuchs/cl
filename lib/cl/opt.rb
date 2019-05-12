require 'cl/cast'

class Cl
  class Opt < Struct.new(:strs, :opts, :block)
    include Cast

    OPT = /^--(?:\[.*\])?(.*)$/

    def define(const)
      return unless __key__ = name
      const.include Module.new {
        define_method (__key__) { opts[__key__] }
        define_method (:"#{__key__}?") { !!opts[__key__] }
      }
      const.default name, default if default?
    end

    def name
      return @name if instance_variable_defined?(:@name)
      opt = strs.detect { |str| str.start_with?('--') }
      name = opt.split(' ').first.match(OPT)[1] if opt
      @name = name&.sub('-', '_')&.to_sym
    end

    def type
      opts[:type]
    end

    def infer_type
      strs.any? { |str| str.split(' ').size > 1 } ? :string : :flag
    end

    def int?
      type == :int || type == :integer
    end

    def description
      opts[:description]
    end

    def aliases
      Array(opts[:alias])
    end

    def deprecated
      return [name] if opts[:deprecated].is_a?(TrueClass)
      Array(opts[:deprecated]) if opts[:deprecated]
    end

    def default?
      !!default
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
      enum.include?(value)
    end

    def format?
      !!opts[:format]
    end

    def format
      opts[:format].to_s.sub('(?-mix:', '').sub(/\)$/, '')
    end

    def formatted?(value)
      opts[:format] =~ value
    end

    def max?
      int? && !!opts[:max]
    end

    def max
      opts[:max]
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
  end
end
