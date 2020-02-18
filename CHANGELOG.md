# Changelog

## 1.2.4 (2020-01-18)

* Make auto-registration optional, but on by default

## 1.2.3 (2020-01-17)

* Bring back auto regisration (broke dpl)

## 1.2.2 (2020-01-17)

* Do not auto-register commands by default

## 1.2.1 (2020-01-14)

* Fix calling const.include on older Ruby versions

## 1.2.0 (2020-01-14)

* Enforce declaring arguments
* Allow optional strings on long opts
* Define arg accessor on an included module so it can be overwritten
* Inherit args from parent commands
* Do not raise on empty splats
* Allow args to have defaults
* Allow args to be enums
* Define predicate methods for args
* Make flag values an optional feature
* List multiple usage lines if a command has multiple registry keys
* Sort options by class hierarchie
* Do not try to cast nil values to integers

## 1.1.3 (2019-09-02)

* Rescue OptionParser::InvalidOption, suggest known options

## 1.1.2 (2019-09-02)

* Fix deprecations for underscored keys

## 1.1.1 (2019-08-26)

* Fix an issue in opt.deprecated?(name)

## 1.1.0 (2019-08-26)

* Add suggestions on unknown cmds and enums
* Validate option options

## 1.0.5 (2019-08-18)

### Fixed

* Fix an issue with alias names that contain the aliased name

## 1.0.4 (2019-08-15)

### Fixed

* Fix enum when used with `type: :array`

## 1.0.3 (2019-08-11)

### Added

* Allow clients to configure Ctx so that it does not abort but raise on errors

## 1.0.2 (2019-08-11)

### Fixed

* Fix that validation for `opt '--one STR', requires: :other, default: 'one'` would fail if the option was not given

## 1.0.1 (2019-08-11)

### Added

* Add `opt '--one STR', upcase: true`

## 1.0.0 (2019-08-10)

### Added

* Add config, reading from env vars and yml files (inspired by gem-release)
* Add `abstract` in order to signal a cmd is a base class that is not meant to be executed
* Add `examples` in order to add examples for the command to the help output
* Add `required :one, [:two, :three]` (DNF, i.e: either `:one` or both `:two` and `:three` must be given)
* Add `opt '--one STR', type: :array` for options that can be given multiple times
* Add `opt '--one STR', default: 'one'`
* Add `opt '--one STR', requires :two` or `[:two, :three]` for options that depend on other options
* Add `opt '--one', alias: :other`
* Add `opt '--one', deprecated: 'message'`, and `cmd.deprected_opts`, so clients can look up which deprecated options were used
* Add `opt '--one', alias: :other, deprecated: :other`, so that `cmd.deprecated_opts` returns the alias name if it was used
* Add `opt '--int INT', min: 10, type: :integer`
* Add `opt '--int INT', max: 10, type: :integer`
* Add `opt '--one STR', format: /.+/`
* Add `opt '--one STR', enum: ['one', /\w+/]`
* Add `opt '--one STR', downcase: true`
* Add `opt '--one STR', internal: true`, hide internal options from help output
* Add `opt '--one STR', example: 'foo'`
* Add `opt '--one STR', negate: %w(skip)`
* Add `opt '--one STR', note: 'note'`
* Add `opt '--one STR', see: 'https://provider.com/docs'
* Add `opt '--one STR', secret: true`

### Changed

* Much improved help output, modeled after rubygems' help output
* Cl is now a class
* Use the regstry gem, remove the local Registry implementation
* If a flag (boolean option) has a default `true` automatically add `[no-]` to it, allowing to opt out
* Runners are now registered in order to make them more easily extendable

### Removed

* Removed cmd.defaults, options have default: [value] now

## 0.0.4 (2017-08-02)

* Ancient history

## 0.0.3 (2017-08-02)

* Ancient history

## 0.0.2 (2017-04-09)

* Ancient history

## 0.0.1 (2017-04-08)

* Ancient history

