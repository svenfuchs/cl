ENV['ENV'] = 'test'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

require 'memfs'
require 'support'
require 'cl'

RSpec.configure do |c|
  c.before { Cl::Cmd.registry.clear }
  c.after  { Cl.flag_values = false }

  c.before { MemFs.activate! }
  c.after  { MemFs.deactivate! }

  c.include Support::Cl
  c.include Support::Env
  c.include Support::File
end
