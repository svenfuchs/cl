# Changelog

## 0.1.0 (unreleased)

### Added

* Add config, reading from env vars and yml files (inspired by gem-release)
* Add `abstract` in order to signal a cmd is a base class that is not meant to be executed
* Add `opt '--path', type: :array` for options that can be given multiple times
* Add `opt '--one STR', default: 'one'`
* Add `opt '--one STR', requires :two` or `[:two, :three]` for options that depend on other options
* Add `add opt '--one', alias: :other`
* Add `add opt '--one', deprecated: true`, and `cmd.deprected_opts`, so clients can look up which deprecated options were used
* Add `add opt '--one', alias: :other, deprecated: :other`, so that `cmd.deprecated_opts` returns the alias name if it was used
* Add `add opt '--int', max: 10, type: :integer`
* Add `add opt '--one', format: /.+/`
* Add `add opt '--one', enum: ['one', 'two']`

### Changed

* Much improved help output, modeled after rubygems' help output
* Cl is now a class
* Use the regstry gem, remove the local Registry implementation

## 0.0.4 (2017-08-02)

* Ancient history

## 0.0.3 (2017-08-02)

* Ancient history

## 0.0.2 (2017-04-09)

* Ancient history

## 0.0.1 (2017-04-08)

* Ancient history

