ENV['ENV'] = 'test'

require 'cl'

RSpec.configure do |c|
  c.before { Cl.registry.clear }
  c.include Module.new {
    def self.included(base)
      base.let(:ctx) { Cl::Ctx.new('name') }
    end
  }
end
