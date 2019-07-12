require 'optparse'

class Cl
  class Parser < OptionParser
    attr_reader :opts

    def initialize(opts, args)
      @opts = {}

      super do
        opts.each do |opt|
          on(*underscore!(opt.strs)) do |value|
            set(opt, value)
          end

          opt.aliases.each do |name|
            on(aliased(opt, name)) do |value|
              @opts[name] = set(opt, value)
            end
          end
        end
      end

      underscore!(args)
      parse!(args)
    end

    def aliased(opt, name)
      str = opt.strs.detect { |str| str.start_with?('--') } || raise
      str.sub(opt.name.to_s, name.to_s)
    end

    # should consider negative arities (e.g. |one, *two|)
    def set(opt, value)
      args = [opts, opt.type, opt.name, value]
      args = args[-opt.block.arity, opt.block.arity]
      instance_exec(*args, &opt.block)
    end

    # OptionParser has started accepting dasherized options in 2.4.
    # We want to support them on any Ruby >= 2.0 version, so we'll
    # need to normalize things ourselves.

    PATTERN = /^(-{1,2})(\[?no-\]?)?(.*)$/

    def underscore!(strs)
      return strs if RUBY_VERSION >= '2.4'
      strs.each { |str| str.gsub!(PATTERN) { "#{$1}#{$2}#{$3.tr('-', '_')}" } }
      strs.each { |str| str.gsub!(/^--no_/, '--no-') } # ruby < 2.4
    end
  end
end
