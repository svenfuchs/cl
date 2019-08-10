ENV['ENV'] = 'test'

require 'coveralls'
Coveralls.wear!

require 'memfs'
require 'support'
require 'cl'

RSpec.configure do |c|
  c.before { Cl::Cmd.registry.clear }

  c.before { MemFs.activate! }
  c.after  { MemFs.deactivate! }

  c.include Support::Cl
  c.include Support::Env
  c.include Support::File
end
