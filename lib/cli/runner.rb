require 'cli/cmds'

module Cli
  class Runner
    attr_reader :const, :args, :opts

    def initialize(*args)
      args = args.flatten.map(&:to_s)
      @const, @args, @opts = Cmds.new(args).lookup
    end

    def run
      cmd.run
    end

    def cmd
      const.new(args, opts)
    end
  end
end
