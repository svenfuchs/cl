require 'cl/help/format'
require 'cl/help/table'
require 'cl/help/usage'

class Cl
  class Help
    class Cmd < Struct.new(:ctx, :cmd)
      include Format

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
          strs = Table.new(rjust(opts.map { |opt| opt_strs(opt) }))
          opts = opts.map { |opt| format_obj(opt) }
          Table.new(strs.rows.zip(opts))
        end
      end

      def cmmn
        @cmmn ||= begin
          opts = cmd.superclass.opts
          opts = opts.reject(&:internal?)
          strs = Table.new(rjust(opts.map(&:strs)))
          opts = opts.map { |opt| format_obj(opt) }
          Table.new(strs.rows.zip(opts))
        end
      end

      def opt_strs(opt)
        return opt.strs if !opt.flag? || opt.help?
        opts = [opt.short]
        opts << negate(opt.long, opt.negate) if opt.long && opt.negate?
        opts.compact
      end

      def negate(opt, negations)
        negations = negations.map { |str| "#{str}-" }.join('|')
        opt.dup.insert(2, "[#{negations}]")
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

      def rjust(objs)
        return objs unless objs.any?
        width = objs.max_by(&:size).size
        objs.map { |objs| [*Array.new(width - objs.size) { '' }, *objs] }
      end

      def indent(str)
        str.lines.map { |line| "  #{line}".rstrip }.join("\n")
      end
    end
  end
end
