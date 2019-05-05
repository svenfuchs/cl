ENV['ENV'] = 'test'

require 'cl'
require 'support'

RSpec.configure do |c|
  c.before { Cl.registry.clear }
  c.include Support
end
