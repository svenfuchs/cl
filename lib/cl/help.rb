require 'cl/format/cmd'
require 'cl/format/list'

module Cl
  class Help < Cl::Cmd
    register :help

    def run
      puts help
    end

    def help
      cmd ? Format::Cmd.new(cmd).format : Format::List.new(cmds).format
    end

    private

      def cmds
        cmds = Cl.cmds.reject { |cmd| cmd.registry_key == :help }
        key  = args.join(':') if args
        cmds = cmds.select { |cmd| cmd.registry_key.to_s.start_with?(key) } if key
        cmds
      end

      def cmd
        args.inject([[], []]) do |(args, cmds), arg|
          args << arg
          cmds << Cl[args.join(':')]
          [args, cmds.compact]
        end.last.last
      end
  end
end
