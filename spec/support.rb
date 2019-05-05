module Support
  module Ctx
    def self.included(base)
      base.let(:ctx) { Cl::Ctx.new('name') }
    end
  end
end
