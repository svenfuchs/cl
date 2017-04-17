require 'cl/cmd'
require 'cl/help'
require 'cl/runner'

module Cl
  def included(const)
    const.send(:include, Cmd)
  end

  def run(*args)
    runner(*args).run
  end

  def help
    runner(:help).run
  end

  attr_writer :runner
  @runner = :default

  def runner(*args)
    args = args.flatten
    runner = args.first.to_s == 'help' ? :default : @runner
    Runner.const_get(runner.to_s.capitalize).new(*args)
  end

  extend self
end
