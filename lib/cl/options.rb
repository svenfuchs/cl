module Cl
  class Options < OptionParser
    attr_reader :opts

    def initialize(opts, args)
      @opts = {}
      super { opts.each { |args, block| on(*args) { |*args| instance_exec(*args, &block) } } }
      parse!(args)
    end
  end
end
