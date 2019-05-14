require 'cl/help/table'
require 'cl/help/usage'

class Cl
  class Help
    class Cmds
      HEAD = %(Type "#{$0.split('/').last} help COMMAND [SUBCOMMAND]" for more details:\n)

      attr_reader :cmds

      def initialize(cmds)
        @cmds = cmds
      end

      def format
        [HEAD, Table.new(list).format].join("\n")
      end

      def list
        cmds.any? ? cmds.map { |cmd| format_cmd(cmd) } : [['[no commands]']]
      end

      def format_cmd(cmd)
        ["#{Usage.new(cmd).format}", cmd.summary]
      end
    end
  end
end
