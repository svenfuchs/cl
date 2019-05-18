class Cl
  class Error < StandardError
    MSGS = {
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
    def initialize(opts)
      opts = opts.map { |(key, value, known)| "#{key}=#{value} (known values: #{known.join(', ')})" }.join(', ')
      super(:unknown_values, opts)
    end
  end
end
