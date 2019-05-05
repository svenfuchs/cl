ENV['ENV'] = 'test'

require 'cl'

RSpec.configure do |c|
  c.before { Cl.registry.clear }
end
