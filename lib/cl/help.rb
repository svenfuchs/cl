module Cl
  class Help < Cl::Cmd
    register :help

    def run
      ctx.puts help
    end

    def help
      args.any? ? Cmd.new(cmd).format : Cmds.new(cmds).format
    end

    private

      def cmds
        cmds = Cl.cmds.reject { |cmd| cmd.registry_key == :help }
        key  = args.join(':') if args
        cmds = cmds.select { |cmd| cmd.registry_key.to_s.start_with?(key) } if key
        cmds
      end

      def cmd
        Cl[args.join(':')] || ctx.abort("Unknown command: #{args.join(':')}")
      end
  end
end

require 'cl/help/cmd'
require 'cl/help/cmds'
