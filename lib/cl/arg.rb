module Cl
  class Arg < Struct.new(:name, :opts)
    TRUE  = /^(true|yes|on)$/
    FALSE = /^(false|no|off)$/

    def define(const)
      name = self.name
      arg  = self

      const.send(:define_method, name) do
        ix = self.class.args.index { |arg| arg.name == name }
        value = self.args[ix]
        value
      end
    end

    def cast(value)
      case opts[:type]
      when nil
        value
      when :array
        value.to_s.split(',')
      when :string, :str
        value.to_s
      when :boolean, :bool
        return true  if value.to_s =~ TRUE
        return false if value.to_s =~ FALSE
        !!value
      when :integer, :int
        Integer(value)
      when :float
        Float(int)
      else
        raise ArgumentError, "Unknown type: #{type}" if value
      end
    end

    def to_s
      opts[:required] ? name.to_s : "[#{name}]"
    end
  end
end
