require 'cl/cast'

class Cl
  class Opt < Struct.new(:strs, :opts, :block)
    include Cast

    OPT = /^--(?:\[.*\])?(.*)$/

    def define(const)
      return unless __key__ = name
      const.send(:define_method, name) { opts[__key__] }
      const.send(:define_method, :"#{name}?") { !!opts[__key__] }
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

    def description
      opts[:description]
    end

    def required?
      !!opts[:required]
    end

    def default?
      !!default
    end

    def default
      opts[:default]
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
