require 'cl/helper'

class Cl
  class Opts
    module Validate
      def validate(cmd, opts, values)
        Validate.constants.each do |name|
          next if name == :Validator
          const = Validate.const_get(name)
          const.new(cmd, opts, values).apply
        end
      end

      class Validator < Struct.new(:cmd, :opts, :values)
        include Regex
        def compact(hash, *keys)
          hash.reject { |_, value| value.nil? }.to_h
        end

        def invert(hash)
          hash.map { |key, obj| Array(obj).map { |obj| [obj, key] } }.flatten(1).to_h
        end

        def only(hash, *keys)
          hash.select { |key, _| keys.include?(key) }.to_h
        end
      end

      class Required < Validator
        def apply
          # make sure we do not accept unnamed required options
          raise RequiredOpts.new(missing.map(&:name)) if missing.any?
        end

        def missing
          @missing ||= opts.select(&:required?).select { |opt| !values.key?(opt.name) }
        end
      end

      class Requireds < Validator
        def apply
          raise RequiredsOpts.new(missing) if missing.any?
        end

        def missing
          @missing ||= cmd.class.required.map do |alts|
            alts if alts.none? { |alt| Array(alt).all? { |key| values.key?(key) } }
          end.compact
        end
      end

      class Requires < Validator
        def apply
          raise RequiresOpts.new(invert(missing)) if missing.any?
        end

        def missing
          @missing ||= requires.map do |opt|
            missing = opt.requires.select { |key| !values.key?(key) }
            [opt.name, missing] if missing.any?
          end.compact
        end

        def requires
          opts.select(&:requires?).select { |opt| values.key?(opt.name) }
        end
      end

      class Format < Validator
        def apply
          raise InvalidFormat.new(invalid) if invalid.any?
        end

        def invalid
          @invalid ||= opts.select(&:format?).map do |opt|
            value = values[opt.name]
            [opt.name, opt.format] if value && !opt.formatted?(value)
          end.compact
        end
      end

      class Enum < Validator
        def apply
          raise UnknownValues.new(unknown) if unknown.any?
        end

        def unknown
          @unknown ||= opts.select(&:enum?).map do |opt|
            value = values[opt.name]
            next unless value && !opt.known?(value)
            known = opt.enum.map { |str| format_regex(str) }
            [opt.name, value, known]
          end.compact
        end
      end

      class Range < Validator
        def apply
          raise OutOfRange.new(invalid) if invalid.any?
        end

        def invalid
          @invalid ||= opts.map do |opt|
            next unless value = values[opt.name]
            range = only(opt.opts, :min, :max)
            [opt.name, compact(range)] if invalid?(range, value)
          end.compact
        end

        def invalid?(range, value)
          min, max = range.values_at(:min, :max)
          min && value < min || max && value > max
        end
      end
    end
  end
end
