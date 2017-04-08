require 'cli/format/table'
require 'cli/format/usage'

module Cli
  class Format
    class List < Struct.new(:cmds)
      HEAD = %(Type "#{$0} help COMMAND [SUBCOMMAND]" for more details:\n)

      def format
        [HEAD, Format::Table.new(list).format].join("\n")
      end

      def list
        cmds.map { |cmd| format_cmd(cmd) }
      end

      def format_cmd(cmd)
        ["#{$0} #{Usage.new(cmd).format}", cmd.purpose]
      end
    end
  end
end
