require 'cl/options'

module Cl
  module Runner
    class Multi
      attr_reader :cmds

      def initialize(*args)
        @cmds = build(group(args))
      end

      def run
        cmds.map(&:run)
      end

      private

        def group(args, cmds = [])
          args.flatten.map(&:to_s).inject([[]]) do |cmds, arg|
            cmd = Cl[arg]
            cmd ? cmds << [cmd] : cmds.last << arg
            cmds.reject(&:empty?)
          end
        end

        def build(cmds)
          cmds.map do |(cmd, *args)|
            cmd.new(args, Options.new(cmd.opts, args).opts)
          end
        end
    end
  end
end
