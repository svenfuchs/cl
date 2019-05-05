require 'cl/help/table'
require 'cl/help/usage'

module Cl
  class Help
    class Cmd < Struct.new(:cmd)
      def format
        [usage, arguments, options, common, summary, description].compact.join("\n\n")
      end

      def usage
        "Usage: #{Usage.new(cmd).format}"
      end

      def summary
        ['Summary:', indent(cmd.summary)] if cmd.summary
      end

      def description
        ['Description:', indent(cmd.description)] if cmd.description
      end

      def arguments
        ['Arguments:', indent(args.to_s(width - args.width + 5))] if args.any?
      end

      def options
        ['Options:', indent(opts.to_s(width - opts.width + 5))] if opts.any?
      end

      def common
        ['Common Options:', indent(cmmn.to_s(width - opts.width + 5))] if common?
      end

      def args
        @args ||= begin
          Table.new(cmd.args.map { |arg| [arg.name, format_opts(arg)] })
        end
      end

      def opts
        @opts ||= begin
          opts = cmd.opts.to_a
          opts = opts - cmd.superclass.opts.to_a if common?
          strs = Table.new(rjust(opts.map { |opt| [*opt.strs] }))
          opts = opts.map { |opt| format_opts(opt) }
          Table.new(strs.rows.zip(opts))
        end
      end

      def cmmn
        @cmmn ||= begin
          opts = cmd.superclass.opts
          strs = Table.new(rjust(opts.map { |opt| [*opt.strs] }))
          opts = opts.map { |opt| format_opts(opt) }
          Table.new(strs.rows.zip(opts))
        end
      end

      def common?
        cmd.superclass < Cl::Cmd
      end

      def width
        [opts.width, args.width].max
      end

      def format_opts(obj)
        opts = []
        opts << obj.type unless obj.type == :string
        opts << 'required' if obj.required?
        opts = "(#{opts.join(', ')})" if opts.any?
        opts = [obj.description, opts]
        opts.compact.join(' ')
      end

      def rjust(objs)
        width = objs.max_by(&:size).size
        objs.map { |objs| [*Array.new(width - objs.size) { '' }, *objs] }
      end

      def indent(str)
        str.lines.map { |line| "  #{line}" }.join
      end
    end
  end
end
