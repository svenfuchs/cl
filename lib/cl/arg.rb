require 'cl/cast'

class Cl
  class Arg < Struct.new(:name, :opts)
    include Cast

    def define(const)
      mod = Module.new
      mod.send(:attr_accessor, name)
      const.include(mod)
    end

    def set(cmd, value)
      cmd.send(:"#{name}=", cast(value))
    end

    def type
      opts[:type] || :string
    end

    def description
      opts[:description]
    end

    def required?
      !!opts[:required]
    end

    def separator
      opts[:sep]
    end

    def splat?
      opts[:splat] && type == :array
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
