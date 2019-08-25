require 'cl/helper/suggest'

class Cl
  class Error < StandardError
    MSGS = {
      unknown_cmd:    'Unknown command: %s',
      missing_args:   'Missing arguments (given: %s, required: %s)',
      too_many_args:  'Too many arguments (given: %s, allowed: %s)',
      wrong_type:     'Wrong argument type (given: %s, expected: %s)',
      out_of_range:   'Out of range: %s',
      invalid_format: 'Invalid format: %s',
      unknown_values: 'Unknown value: %s',
      required_opt:   'Missing required option: %s',
      required_opts:  'Missing required options: %s',
      requires_opt:   'Missing option: %s',
      requires_opts:  'Missing options: %s',
    }

    def initialize(msg, *args)
      super(MSGS[msg] ? MSGS[msg] % args : msg)
    end
  end

  ArgumentError = Class.new(Error)
  OptionError = Class.new(Error)

  class UnknownCmd < Error
    attr_reader :runner, :args

    def initialize(runner, args)
      @runner = runner
      @args = args
      super(:unknown_cmd, args.join(' '))
    end

    def suggestions
      runner.suggestions(args)
    end
  end

  class RequiredOpts < OptionError
    def initialize(opts)
      msg = opts.size == 1 ? :required_opt : :required_opts
      super(msg, opts.join(', '))
    end
  end

  class RequiredsOpts < OptionError
    def initialize(opts)
      opts = opts.map { |alts| alts.map { |alt| Array(alt).join(' and ') }.join(', or ' ) }
      super(:requires_opts, opts.join('; '))
    end
  end

  class RequiresOpts < OptionError
    def initialize(opts)
      msg = opts.size == 1 ? :requires_opt : :requires_opts
      opts = opts.map { |one, other| "#{one} (required by #{other})" }.join(', ')
      super(msg, opts)
    end
  end

  class OutOfRange < OptionError
    def initialize(opts)
      opts = opts.map { |opt, opts| "#{opt} (#{opts.map { |pair| pair.join(': ') }.join(', ')})" }.join(', ')
      super(:out_of_range, opts)
    end
  end

  class InvalidFormat < OptionError
    def initialize(opts)
      opts = opts.map { |opt, format| "#{opt} (format: #{format})" }.join(', ')
      super(:invalid_format, opts)
    end
  end

  class UnknownValues < OptionError
    include Suggest

    attr_reader :opts

    def initialize(opts)
      @opts = opts
      opts = opts.map do |(opt, values, known)|
        pairs = values.map { |value| [opt, value].join('=') }.join(' ')
        "#{pairs} (known values: #{known.join(', ')})"
      end
      super(:unknown_values, opts.join(', '))
    end

    def suggestions
      opts.map { |_, value, known| suggest(known, value) }.flatten
    end
  end
end
