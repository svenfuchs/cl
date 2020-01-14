require 'cl/cast'

class Cl
  class Arg < Struct.new(:name, :opts)
    include Cast

    def define(const)
      mod = Module.new
      mod.send(:attr_accessor, name)
      mod.class_eval "def #{name}?; #{name}.is_a?(Array) ? !#{name}.empty? : !!#{name} end"
      const.send(:include, mod)
    end

    def set(cmd, value)
      value = cast(value)
      unknown(value) if enum? && !known?(value)
      cmd.send(:"#{name}=", value)
    end

    def type
      opts[:type] || :string
    end

    def array?
      type == :array
    end

    def description
      opts[:description]
    end

    def enum
      Array(opts[:enum])
    end

    def enum?
      opts.key?(:enum)
    end

    def default
      opts[:default]
    end

    def default?
      opts.key?(:default)
    end

    def known?(value)
      enum.include?(value)
    end

    def required?
      !!opts[:required]
    end

    def separator
      opts[:sep]
    end

    def splat?
      !!opts[:splat] && array?
    end

    def unknown(value)
      raise UnknownArgumentValue.new(value, enum.join(', '))
    end

    def to_s
      str = name
      case type
      when :array          then str = "#{str}.."
      when :boolean, :bool then str = "#{str}:bool"
      when :integer, :int  then str = "#{str}:int"
      when :float          then str = "#{str}:float"
      end
      required? ? str : "[#{str}]"
    end
  end
end
