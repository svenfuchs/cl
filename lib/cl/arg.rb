require 'cl/cast'

module Cl
  class Arg < Struct.new(:name, :opts)
    include Cast

    def define(const)
      const.send(:attr_accessor, name)
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

    def splat?
      type == :array
    end

    def required?
      !!opts[:required]
    end

    def to_s
      str = name
      case type
      when :array          then str = "#{str}.."
      when :integer, :int  then str = "#{str}:int"
      when :boolean, :bool then str = "#{str}:bool"
      when :float          then str = "#{str}:float"
      end
      required? ? str : "[#{str}]"
    end
  end
end
