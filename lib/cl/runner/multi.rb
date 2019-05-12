class Cl
  module Runner
    class Multi
      attr_reader :name, :cmds

      def initialize(name, *args)
        @name = name
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
            cmd.new(name, args)
          end
        end
    end
  end
end
