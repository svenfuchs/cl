require 'cl/help/table'
require 'cl/help/usage'

class Cl
  class Help
    class Cmd < Struct.new(:ctx, :cmd)
      include Regex

      def format
        [usage, summary, description, arguments, options, common, examples].compact.join("\n\n")
      end

      def usage
        "Usage: #{Usage.new(ctx, cmd).format}"
      end

      def summary
        ['Summary:', indent(cmd.summary)] if cmd.summary
      end

      def description
        ['Description:', indent(cmd.description)] if cmd.description
      end

      def arguments
        ['Arguments:', table(:args)] if args.any?
      end

      def options
        ['Options:', requireds, table(:opts)].compact if opts.any?
      end

      def common
        ['Common Options:', table(:cmmn)] if common?
      end

      def examples
        ['Examples:', indent(cmd.examples)] if cmd.examples
      end

      def table(name)
        table = send(name)
        indent(table.to_s(width - table.width + 5))
      end

      def args
        @args ||= begin
          Table.new(cmd.args.map { |arg| [arg.name, format_obj(arg)] })
        end
      end

      def opts
        @opts ||= begin
          opts = cmd.opts.to_a
          opts = opts.reject(&:internal?)
          opts = opts - cmd.superclass.opts.to_a if common?
          strs = Table.new(rjust(opts.map { |opt| [*opt.strs] }))
          opts = opts.map { |opt| format_obj(opt) }
          Table.new(strs.rows.zip(opts))
        end
      end

      def cmmn
        @cmmn ||= begin
          opts = cmd.superclass.opts
          opts = opts.reject(&:internal?)
          strs = Table.new(rjust(opts.map { |opt| [*opt.strs] }))
          opts = opts.map { |opt| format_obj(opt) }
          Table.new(strs.rows.zip(opts))
        end
      end

      def requireds
        return unless cmd.required?
        opts = cmd.required
        strs = opts.map { |alts| alts.map { |alt| Array(alt).join(' and ') }.join(', or ' ) }
        strs = strs.map { |str| "Either #{str} are required." }.join("\n")
        indent(strs) unless strs.empty?
      end

      def common?
        cmd.superclass < Cl::Cmd
      end

      def width
        [args.width, opts.width, cmmn.width].max
      end

      def format_obj(obj)
        opts = []
        opts << "type: #{format_type(obj)}" unless obj.type == :flag
        opts << 'required: true' if obj.required?
        opts += format_opt(obj) if obj.is_a?(Opt)
        opts = opts.join(', ')
        opts = "(#{opts})" if obj.description && !opts.empty?
        opts = [obj.description, opts]
        opts.compact.map(&:strip).join(' ')
      end

      def format_opt(opt)
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

      def format_type(obj)
        return obj.type unless obj.is_a?(Opt) && obj.type == :array
        "array (string, can be given multiple times)"
      end

      def format_default(opt)
        opt.default.is_a?(Symbol) ? opt.default.to_s.sub('_', ' ') : opt.default
      end

      def format_deprecated(opt)
        return "deprecated (#{opt.deprecated[1]})" if opt.deprecated[0] == opt.name
      end

      def rjust(objs)
        return objs unless objs.any?
        width = objs.max_by(&:size).size
        objs.map { |objs| [*Array.new(width - objs.size) { '' }, *objs] }
      end

      def indent(str)
        str.lines.map { |line| "  #{line}" }.join
      end
    end
  end
end
