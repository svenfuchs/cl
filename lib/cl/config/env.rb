require 'cl/helper'

class Cl
  class Config
    class Env < Struct.new(:name)
      include Merge

      TRUE  = /^(true|yes|on)$/
      FALSE = /^(false|no|off)$/

      def load
        vars = opts.map { |cmd, opts| vars(cmd, opts) }
        merge(*vars.flatten.compact)
      end

      private

        def vars(cmd, opts)
          opts.map { |opt| var(cmd, opt, key(cmd, opt)) }
        end

        def opts
          Cl.registry.map { |key, cmd| [key, cmd.opts.map(&:name) - [:help]] }
        end

        def var(cmd, opt, key)
          { cmd => { opt => cast(ENV[key]) } } if ENV[key]
        end

        def key(*keys)
          [name.upcase, *keys].join('_').upcase.sub('-', '_')
        end

        def only(hash, *keys)
          hash.select { |key, _| keys.include?(key) }.to_h
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
