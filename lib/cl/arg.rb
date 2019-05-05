module Cl
  class Arg < Struct.new(:name, :opts)
    TRUE  = /^(true|yes|on)$/
    FALSE = /^(false|no|off)$/

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

    def cast(value)
      case type
      when nil
        value
      when :array
        Array(value).flatten.map { |value| value.split(',') }.flatten
      when :string, :str
        value.to_s
      when :boolean, :bool
        return true  if value.to_s =~ TRUE
        return false if value.to_s =~ FALSE
        !!value
      when :integer, :int
        Integer(value)
      when :float
        Float(value)
      else
        raise ArgumentError, "Unknown type: #{type}" if value
      end
    rescue ::ArgumentError => e
      raise ArgumentError.new(:wrong_type, value.inspect, type)
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
