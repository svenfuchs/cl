require 'forwardable'
require 'cl/config'
require 'cl/ui'

class Cl
  class Ctx
    extend Forwardable

    def_delegators :ui, :puts, :stdout, :announce, :info, :notice, :warn,
      :error, :success, :cmd

    attr_accessor :config, :ui

    def initialize(name, opts = {})
      @config = Config.new(name).to_h
      @ui = opts[:ui] || Ui.new(self, opts)
    end

    def abort(error, *strs)
      ui.abort(error, *strs)
    end

    def test?
      ENV['ENV'] == 'test'
    end
  end
end
