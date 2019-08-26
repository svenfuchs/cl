require 'optparse'
require 'cl/parser/format'

class Cl
  class Parser < OptionParser
    attr_reader :cmd, :args, :opts

    def initialize(cmd, args)
      @cmd = cmd
      @opts = {}
      opts = cmd.class.opts

      super do
        opts.each do |opt|
          Format.new(opt).strs.each do |str|
            on(str) { |value| set(opt, str, value) }
          end
        end
      end

      @args = parse!(normalize(opts, args))
    end

    # should consider negative arities (e.g. |one, *two|)
    def set(opt, str, value)
      name = long?(str) ? opt_name(str) : opt.name
      value = true if value.nil? && opt.flag?
      args = [opts, opt.type, name, value]
      args = args[-opt.block.arity, opt.block.arity]
      instance_exec(*args, &opt.block)
      cmd.deprecations[name] = opt.deprecated.last if opt.deprecated?(name)
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
      opts.select(&:flag?).detect do |opt|
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

    def long?(str)
      str.start_with?('--')
    end

    def opt_name(str)
      str.split(' ').first.sub(/--(\[no[_\-]\])?/, '').to_sym
    end
  end
end
