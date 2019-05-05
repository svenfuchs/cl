require 'cl/format/table'
require 'cl/format/usage'
# Usage: gem release [gem_name] [options]
#
#   Options:
#         --host HOST                  Push to a compatible host other than rubygems.org
#     -k, --key KEY                    Use the API key from ~/.gem/credentials
#     -t, --tag                        Shortcut for running the `gem tag` command
#     -p, --push                       Push tag to the remote git repository
#         --recurse                    Recurse into directories that contain gemspec files
#         --[no-]color
#         --pretend
#
#
#   Common Options:
#     -h, --help                       Get help on this command
#     -V, --[no-]verbose               Set the verbose level of output
#     -q, --quiet                      Silence command progress meter
#         --silent                     Silence rubygems output
#         --config-file FILE           Use this config file instead of default
#         --backtrace                  Show stack backtrace on errors
#         --debug                      Turn on Ruby debugging
#         --norc                       Avoid loading any .gemrc file
#
#   Arguments:
#     gem_name - name of the gem (optional, will use the first gemspec, or all gemspecs if --recurse is given)
#
#   Summary:
#     Releases one or all gems in this directory.
#
#   Description:
#     Builds one or many gems from the given gemspec(s), pushes them to
#     rubygems.org (or another, compatible host), and removes the left over
#     gem file.
#
#     Optionally invoke `gem tag`.
#
#     If no argument is given the first gemspec's name is assumed as the gem
#     name. If one or many arguments are given then these will be used. If
#     `--recurse` is given then all gem names from all gemspecs in this
#     directory or any of its subdirectories will be used.

module Cl
  class Format
    class Cmd < Struct.new(:cmd)
      def format
        [usage, arguments, options, summary, description].compact.join("\n\n")
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

      def args
        @args ||= Table.new(cmd.args.map { |arg| [arg.name, format_opts(arg)] })
      end

      def width
        [opts.width, args.width].max
      end

      def opts
        @opts ||= begin
          strs = Table.new(rjust(cmd.opts.map { |opt| [*opt.strs] }))
          opts = cmd.opts.map { |opt| format_opts(opt) }
          Table.new(strs.rows.zip(opts))
        end
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
