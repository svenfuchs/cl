# CL [![Build Status](https://travis-ci.org/svenfuchs/cl.svg?branch=master)](https://travis-ci.org/svenfuchs/cl)

This library wraps Ruby's `OptionParser` in order to make it easier to use it
in an object oriented context.

It uses `OptionParser` for parsing your options, so you get all the goodness that
this gem from Ruby's stoneage provides.

But on top of that it also provides a rich DSL for defining, validating, and
normalizing options, as well as automatic and gorgeous help output (modeled
after Rubygem's `gem --help` output).

## Basic Usage

```ruby
# lib/cli/owners/add.rb
module Owners
  class Add < Cl::Cmd
    summary 'Add one or more owners to an existing owner group'

    description <<~str
      Use this command to add one or more owners to an existing
      owner group.

      [...]
    str

    args :owners

    opt '-t', '--to TO', 'An existing owner group'

    def run
      # add owners as listed in `owners` to the group given in
      # `to`, as well as `opts[:to]`.
    end
  end
end

# bin/owners
Cl.new('owners').run(ARGV)
```

Running this, e.g. using `bin/owners add one,two --to group` will instantiate the
class `Owners::Add`, and call the method `run` on it.

Help output:

```txt
Usage: owners add [owners] [options]

Summary:

  Add one or more owners to an existing owner group

Description:

  Use this command to add one or more owners to an existing
  owner group.

  These will be visible in [...]

Arguments:

  owners          type: string

Options:

  -t --to TO      An existing owner group (type: string, required: true)
     --help       Get help on this command (type: flag)
```

## DSL

The DSL is defined on the class body.

## Description, summary, examples

### Arguments

Arguments can be declared like so:

```ruby
arg :arg_name, description: 'arg description', type: :[array|string|integer|float|boolean]
```

This will define an `attr_accessor` on the `Cmd` class. I.e. in the following
example the method `ownsers` will be available on the `Cmd` instance:

```ruby
<%= example('readme/arg') %>
```

#### Types

Arguments can have a type. Known types are: `:array`, `:string`, `:integer`,
`:float`, `:boolean`.

The type `:array` makes sure the argument accessible on the `Cmd` instance is a
Ruby Array. (This currently only supports arrays of strings).

If the option `sep` is given on the argument, then the argument value is split
using this separator.

```ruby
<%= example('readme/arg_array') %>
```

Other types cast the given argument to the expected Ruby type.

```ruby
<%= example('readme/arg_type') %>
```

#### Splat

Array arguments support splats, modeled after Ruby argument splats.

For example:

```ruby
<%= example('readme/arg_type') %>
```

### Options

Declaring options can be done by calling the method `opt` on the class body.

This will add the option, if given by the user, to the hash `opts` on the `Cmd` instance.
It also defines a reader method that returns the respective value from the `opts` hash,
and a predicate that will be true if the option has been given.

For example:

```ruby
<%= example('readme/opts') %>
```

Options optionally accept a block in case custom normalization is needed.

Depending on the block's arity the following arguments are passed to the block:
option value, option name, option type, collection of all options defined on
the command.

```ruby
<%= example('readme/opts_block') %>
```

#### Aliases

Options can have one or many alias names, given as a Symbol or Array of Symbols:

```ruby
<%= example('readme/alias') %>
```

#### Defaults

Options can have a default value.

I.e. this value is going to be used if the user does not provide the option:

```ruby
<%= example('readme/default') %>
```

#### Deprecations

Options, and option alias name can be deprecated.

For a deprecated option:

```ruby
<%= example('readme/deprecated') %>
```

For a deprecated option alias name:

```ruby
<%= example('readme/deprecated_alias') %>
```

#### Downcase

Options can be declared to be downcased.

For example:

```ruby
<%= example('readme/downcase') %>
```

#### Enum

Options can be enums (i.e. have known values).

If an unknown values is given by the user the parser will reject the option,
and print the help output for this command.

For example:

```ruby
<%= example('readme/enum') %>
```

#### Example

Options can have examples that will be printed in the help output.

```ruby
<%= example('readme/example') %>
```

#### Format

Options can have a required format.

If a value is given by the user that does not match the format then the parser
will reject the option, and print the help output for this command.

For example:

```ruby
<%= example('readme/format') %>
```

#### Internal

Options can be declared to be internal, hiding the option from the help output.

For example:

```ruby
<%= example('readme/internal') %>
```

#### Min and max

Options can have mininum and/or maximum values.

If a value is given by the user that does not match the required min and/or max
values then the parser will reject the option, and print the help output for
this command.

For example:

```ruby
<%= example('readme/range') %>
```

#### See also

Options can refer to documentation using the `see` option. This will be printed
in the help output.

For example:

```ruby
<%= example('readme/see') %>
```

#### Types

Options can have a type. Known types are: `:array`, `:string`, `:integer`,
`:float`, `:boolean`.

The type `:array` allows an option to be given multiple times, and makes sure
the value accessible on the `Cmd` instance is a Ruby Array. (This currently
only supports arrays of strings).

```ruby
<%= example('readme/array') %>
```

Other types cast the given value to the expected Ruby type.

```ruby
<%= example('readme/type') %>
```

#### Required options

There are three ways options can be required:

* using `required: true` on the option: the option itself is required to be given
* using `requires: :other`on the option: the option requires another option to be given
* using `required :one, [:two, :three]` on the class: either `one` or both `two` and `three` must be given

For example, this simply requires the option `--to`:

```ruby
<%= example('readme/required') %>
```

This will make the option `--retries` depend on the option `--to`:

```ruby
<%= example('readme/requires') %>
```

This requires either the option `--api_key` or both options `--username` and
`--password` to be given:

```ruby
<%= example('readme/requireds') %>
```

### Config files and environment variables

TBD config, reading from env vars and yml files (inspired by gem-release)

### Command registry

TBD

### Runners

TBD
