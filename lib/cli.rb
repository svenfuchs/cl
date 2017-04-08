require 'cli/cmd'
require 'cli/help'
require 'cli/runner'

module Cli
  def included(const)
    const.send(:include, Cmd)
  end

  def run(*args)
    Runner.new(*args).run
  end

  def help
    Runner.new(:help).run
  end

  extend self
end
