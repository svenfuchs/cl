# CLI

This library wraps Ruby's `OptionParser` in order to make it easier to use it in an object oriented context.

## Usage

```
module Owners
  class Add < Struct.new(:args, :opts)
    include Cli::Cmd

    register 'owners:add'

    purpose 'Add one or more owners to an existing owner group'

    args :owners

    on '-t', '--to TO', 'An owner in an existing group' do |value|
      opts[:to] = value
    end
  end
end
```
