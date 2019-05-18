require 'registry'

class Cl
  module Runner
    include Registry
  end
end

require 'cl/runner/default'
require 'cl/runner/multi'
