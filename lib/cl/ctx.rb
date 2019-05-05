require 'cl/config'
require 'cl/ui'

module Cl
  class Ctx
    attr_accessor :config, :ui

    def initialize(name, opts = {})
      @config = Config.new(name)
      @ui = Ui.new(opts)
    end

    # def abort(str)
    #   ui.error(str)
    #   exit 1
    # end
  end
end
