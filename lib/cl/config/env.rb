module Cl
  class Config
    class Env < Struct.new(:name)
      TRUE  = /^(true|yes|on)$/
      FALSE = /^(false|no|off)$/

      def load
        opts = vars.map { |key, value| to_hash(keys_for(key), cast(value)) }
        opts = opts.inject { |one, other| deep_merge(one, other) }
        opts || {}
      end

      private

        def vars
          ENV.select { |key, _| key.start_with?(prefix) }
        end

        def keys_for(key)
          key.sub(prefix, '').split('_').map(&:downcase).map(&:to_sym)
        end

        def prefix
          @prefix ||= "#{name.upcase}_"
        end

        def to_hash(keys, value)
          keys = keys.reverse
          keys.inject(keys.shift => value) { |value, key| { key => value } }
        end

        def cast(value)
          case value
          when TRUE
            true
          when FALSE
            false
          when ''
            false
          else
            value
          end
        end
    end
  end
end
