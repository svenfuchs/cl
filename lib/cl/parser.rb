require 'optparse'

class Cl
  class Parser < OptionParser
    attr_reader :opts

    def initialize(opts, args)
      @opts = {}

      super do
        opts.each do |opt|
          on(*args_for(opt, opt.strs)) do |value|
            set(opt, value)
          end

          opt.aliases.each do |name|
            on(*args_for(opt, [aliased(opt, name)])) do |value|
              @opts[name] = set(opt, value)
            end
          end
        end
      end

      args.replace(normalize(opts, args))
      parse!(args)
    end

    def args_for(opt, strs)
      args = dasherize(strs)
      args = flagerize(args) if opt.flag?
      args
    end

    def aliased(opt, name)
      str = opt.strs.detect { |str| str.start_with?('--') } || raise
      str.sub(/(#{opt.name}|#{opt.name.to_s.gsub('_', '-')})/, name.to_s)
    end

    # should consider negative arities (e.g. |one, *two|)
    def set(opt, value)
      value = true if value.nil? && opt.flag?
      args = [opts, opt.type, opt.name, value]
      args = args[-opt.block.arity, opt.block.arity]
      instance_exec(*args, &opt.block)
    end

    def normalize(opts, args)
      args = noize(opts, args)
      dasherize(args)
    end

    def noize(opts, args)
      args.map do |arg|
        str = negation(opts, arg)
        str ? arg.sub(/^--#{str}[-_]+/, '--no-') : arg
      end
    end

    def negation(opts, arg)
      opts.detect do |opt|
        str = opt.negate.detect { |str| arg =~ /^--#{str}[-_]+#{opt.name}/ }
        break str if str
      end
    end

    DASHERIZE = /^--([^= ])*/

    def dasherize(strs)
      strs.map do |str|
        str.is_a?(String) ? str.gsub(DASHERIZE) { |opt| opt.gsub('_', '-') } : str
      end
    end

    def flagerize(strs)
      strs = strs.map { |str| str.include?(' ') ? str : "#{str} [true|false|yes|no]" }
      strs << TrueClass
    end
  end
end
