class Cl
  module Cast
    TRUE  = /^(true|yes|on)$/
    FALSE = /^(false|no|off)$/

    def cast(value)
      case type
      when nil
        value
      when :array
        Array(value).compact.flatten.map { |value| split(value) }.flatten
      when :string, :str
        value.to_s unless value.to_s.empty?
      when :flag, :boolean, :bool
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

    def split(value)
      separator ? value.to_s.split(separator) : value
    end
  end
end
