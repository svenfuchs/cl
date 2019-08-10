class Cl
  class Help
    module Format
      def format_obj(obj)
        Obj.new(obj).format
      end

      class Obj < Struct.new(:obj)
        def format
          opts = []
          opts << "type: #{type(obj)}" unless obj.type == :flag
          opts << 'required: true' if obj.required?
          opts += Opt.new(obj).format if obj.is_a?(Cl::Opt)
          opts = opts.join(', ')
          opts = "(#{opts})" if obj.description && !opts.empty?
          opts = [obj.description, opts]
          opts.compact.map(&:strip).join(' ')
        end

        def type(obj)
          return obj.type unless obj.is_a?(Cl::Opt) && obj.type == :array
          "array (string, can be given multiple times)"
        end
      end

      class Opt < Struct.new(:opt)
        include Regex

        def format
          opts = []
          opts << "alias: #{format_aliases(opt)}" if opt.aliases?
          opts << "requires: #{opt.requires.join(', ')}" if opt.requires?
          opts << "default: #{format_default(opt)}" if opt.default?
          opts << "known values: #{format_enum(opt)}" if opt.enum?
          opts << "format: #{opt.format}" if opt.format?
          opts << "downcase: true" if opt.downcase?
          opts << "min: #{opt.min}" if opt.min?
          opts << "max: #{opt.max}" if opt.max?
          opts << "e.g.: #{opt.example}" if opt.example?
          opts << "note: #{opt.note}" if opt.note?
          opts << "see: #{opt.see}" if opt.see?
          opts << format_deprecated(opt) if opt.deprecated?
          opts.compact
        end

        def format_aliases(opt)
          opt.aliases.map do |name|
            strs = [name]
            strs << "(deprecated, please use #{opt.name})" if opt.deprecated[0] == name
            strs.join(' ')
          end.join(', ')
        end

        def format_enum(opt)
          opt.enum.map { |value| format_regex(value) }.join(', ')
        end

        def format_default(opt)
          opt.default.is_a?(Symbol) ? opt.default.to_s.sub('_', ' ') : opt.default
        end

        def format_deprecated(opt)
          return "deprecated (#{opt.deprecated[1]})" if opt.deprecated[0] == opt.name
        end
      end
    end
  end
end
