require 'cl'

RSpec.configure do |c|
  c.before { Cl.registry.delete_if { |key, _| key != :help } }
end

