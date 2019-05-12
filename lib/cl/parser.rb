require 'optparse'

class Cl
  class Parser < OptionParser
    attr_reader :opts

    def initialize(opts, args)
      @opts = {}
      super { opts.each { |opt| on(*strs(opt)) { |value| set(opt, value) } } }
      parse!(args)
    end

    def strs(opt)
      opt.strs + aliases(opt)
    end

    def aliases(opt)
      opt.aliases.map { |name| "--#{name}" }
    end

    # should consider negative arities (e.g. |one, *two|)
    def set(opt, value)
      args = [opts, opt.type, opt.name, value]
      args = args[-opt.block.arity, opt.block.arity]
      instance_exec(*args, &opt.block)
    end
  end
end
