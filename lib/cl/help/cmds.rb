require 'cl/help/table'
require 'cl/help/usage'

class Cl
  class Help
    class Cmds < Struct.new(:ctx, :cmds)
      HEAD = %(Type "%s help COMMAND [SUBCOMMAND]" for more details:\n)

      def format
        [head, Table.new(list).format].join("\n")
      end

      def head
        HEAD % ctx.name
      end

      def list
        cmds.any? ? cmds.map { |cmd| format_cmd(cmd) } : [['[no commands]']]
      end

      def format_cmd(cmd)
        ["#{Usage.new(ctx, cmd).format.first}", cmd.summary]
      end
    end
  end
end
