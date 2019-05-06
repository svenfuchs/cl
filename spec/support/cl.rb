module Support
  module Cl
    def self.included(base)
      base.let(:ctx) { ::Cl::Ctx.new('cl') }
    end

    def runner(args = self.args)
      ::Cl.new(ctx).runner(args)
    end

    def cmd(args = self.args)
      runner(args).cmd
    end

    def run
      runner.run
    end
  end
end
