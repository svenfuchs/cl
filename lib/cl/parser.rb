require 'optparse'

module Cl
  class Parser < OptionParser
    attr_reader :opts

    def initialize(opts, args)
      @opts = {}
      super { opts.each { |opt| on(*opt.strs) { |value| set(opt, value) } } }
      parse!(args)
    end

    # should consider negative arities (e.g. |one, *two|)
    def set(opt, value)
      args = [opts, opt.name, value]
      args = args[-opt.block.arity, opt.block.arity]
      instance_exec(*args, &opt.block)
    end
  end
end
