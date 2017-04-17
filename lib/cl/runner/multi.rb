require 'cl/options'

module Cl
  module Runner
    class Multi
      attr_reader :args

      def initialize(*args)
        @args = args.flatten.map(&:to_s).inject([]) do |cmds, arg|
          Cl[arg] ? cmds << [arg] : cmds.last << arg
          cmds
        end
      end

      def run
        cmds.map(&:run)
      end

      def cmds
        args.map do |(cmd, *args)|
          const = Cl[cmd]
          opts = Options.new(const.opts, args).opts
          const.new(args, opts)
        end
      end
    end
  end
end
