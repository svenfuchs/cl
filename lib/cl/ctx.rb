require 'forwardable'
require 'cl/config'
require 'cl/ui'

class Cl
  class Ctx
    extend Forwardable

    def_delegators :ui, :puts, :stdout, :announce, :info, :notice, :warn,
      :error, :success, :cmd

    attr_accessor :config, :name, :opts

    def initialize(name, opts = {})
      @config = Config.new(name).to_h
      @opts = opts
      @name = name
    end

    def ui
      @ui ||= opts[:ui] || Ui.new(self, opts)
    end

    def abort(error, *strs)
      abort? ? ui.abort(error, *strs) : raise(error)
    end

    def abort?
      !opts[:abort].is_a?(FalseClass)
    end

    def test?
      ENV['ENV'] == 'test'
    end
  end
end
