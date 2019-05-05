require 'optparse'

module Cl
  class Parser < OptionParser
    attr_reader :opts

    def initialize(opts, args)
      @opts = {}
      opts = opts.map { |opt| [opt.strs, opt.block] }
      super { opts.each { |args, block| on(*args) { |*args| instance_exec(*args, &block) } } }
      parse!(args)
    end
  end
end
