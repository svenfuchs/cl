# CL [![Build Status](https://travis-ci.org/svenfuchs/cl.svg?branch=master)](https://travis-ci.org/svenfuchs/cl)

This library wraps Ruby's `OptionParser` in order to make it easier to use it
in an object oriented context.

It uses `OptionParser` for parsing your options, so you get all the goodness that
this true gem from Ruby's stoneage provides. But on top of that it also provides
a rich DSL for defining, validating, and normalizing options, and automatic and
gorgeous help output (modelled after Rubygem's `gem --help` output).

## Basic Usage

```ruby
module Owners
  class Add < Cl::Cmd
    summary 'Add one or more owners to an existing owner group'

    description <<~str
      Use this command to add one or more owners to an existing
      owner group.

      These will be visible in [...]
    str

    args :owners

    opt '-t', '--to TO', 'An existing owner group' do |value|
      opts[:to] = value
    end
  end
end
```

Help output:

```txt
Usage: owners add [owners] [options]

Arguments:

  owners          type: string

Options:

  -t --to TO      An existing owner group (type: string, required: true)
     --help       Get help on this command (type: flag)

Summary:

  Add one or more owners to an existing owner group

Description:

  Use this command to add one or more owners to an existing
  owner group.

  These will be visible in [...]
```
