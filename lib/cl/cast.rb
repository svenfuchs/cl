class Cl
  module Cast
    class Cast < Struct.new(:type, :value, :opts)
      TRUE  = /^(true|yes|on)$/
      FALSE = /^(false|no|off)$/

      def apply
        return send(type) if respond_to?(type, true)
        raise ArgumentError, "Unknown type: #{type}"
      rescue ::ArgumentError => e
        raise ArgumentError.new(:wrong_type, value.inspect, type)
      end

      private

        def array
          Array(value).compact.flatten.map { |value| split(value) }.flatten
        end

        def string
          value.to_s unless value.to_s.empty?
        end
        alias str string

        def boolean
          return true  if value.to_s =~ TRUE
          return false if value.to_s =~ FALSE
          !!value
        end
        alias bool boolean
        alias flag boolean

        def int
          Integer(value)
        end
        alias integer int

        def float
          Float(value)
        end

        def split(value)
          separator ? value.to_s.split(separator) : value
        end

        def separator
          opts[:separator]
        end
    end

    def cast(value)
      value.nil? ? value : Cast.new(type, value, separator: separator).apply
    end
  end
end
