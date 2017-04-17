require 'cl/format/table'
require 'cl/format/usage'

module Cl
  class Format
    class List < Struct.new(:cmds)
      HEAD = %(Type "#{$0.split('/').last} help COMMAND [SUBCOMMAND]" for more details:\n)

      def format
        [HEAD, Format::Table.new(list).format].join("\n")
      end

      def list
        cmds.map { |cmd| format_cmd(cmd) }
      end

      def format_cmd(cmd)
        ["#{Usage.new(cmd).format}", cmd.summary]
      end
    end
  end
end
