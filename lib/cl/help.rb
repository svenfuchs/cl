class Cl
  class Help < Cl::Cmd
    register :help

    arg :args, splat: true

    def run
      ctx.puts help
    end

    def help
      args.any? ? Cmd.new(ctx, cmd).format : Cmds.new(ctx, cmds).format
    end

    private

      def cmds
        cmds = Cl::Cmd.cmds.reject { |cmd| cmd.registry_key == :help }
        key  = args.join(':') if args
        cmds = cmds.select { |cmd| cmd.registry_key.to_s.start_with?(key) } if key
        cmds
      end

      def cmd
        key = args.join(':')
        return Cl::Cmd[key] if Cl::Cmd.registered?(key)
        ctx.abort("Unknown command: #{key}")
      end
  end
end

require 'cl/help/cmd'
require 'cl/help/cmds'
