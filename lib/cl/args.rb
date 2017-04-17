require 'cl/arg'

module Cl
  class Args
    include Enumerable

    def apply(args)
      return args unless self.args.any?
      self.args.map.with_index do |arg, ix|
        value = args[ix] || raise(ArgumentError, "Required argument missing: #{arg.name}")
        arg.cast(value)
      end
    end

    def define(const, name, opts = {})
      arg = Arg.new(name, opts)
      arg.define(const)
      args << arg
    end

    def each(&block)
      args.each(&block)
    end

    def index(*args, &block)
      self.args.index(*args, &block)
    end

    def args
      @args ||= []
    end
  end
end
