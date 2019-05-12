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

### Changed

* Much improved help output, modeled after rubygems' help output
* Cl is now a class


## 0.0.4 (2017-08-02)
## 0.0.3 (2017-08-02)
## 0.0.2 (2017-04-09)
## 0.0.1 (2017-04-08)
