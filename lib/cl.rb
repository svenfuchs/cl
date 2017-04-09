require 'cl/cmd'
require 'cl/help'
require 'cl/runner'

module Cl
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
