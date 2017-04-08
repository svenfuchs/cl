require 'cli/format/cmd'
require 'cli/format/list'

module Cli
  class Help < Struct.new(:args, :opts)
    include Cli::Cmd

    register :help

    def run
      puts help
    end

    def help
      cmd ? Format::Cmd.new(cmd).format : Format::List.new(cmds).format
    end

    private

      def cmds
        cmds = Cli.cmds.reject { |cmd| cmd.registry_key == :help }
        key  = args.join(':') if args
        cmds = cmds.select { |cmd| cmd.registry_key.to_s.start_with?(key) } if key
        cmds
      end

      def cmd
        args && Cli[args.join(':')]
      end
  end
end
