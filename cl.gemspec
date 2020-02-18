# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'cl/version'

Gem::Specification.new do |s|
  s.name         = 'cl'
  s.version      = Cl::VERSION
  s.authors      = ['Sven Fuchs']
  s.homepage     = 'https://github.com/svenfuchs/cl'
  s.licenses     = ['MIT']
  s.summary      = 'Object-oriented OptionParser based CLI support'
  s.description  = <<-str.strip.gsub(/^ +/, '')
    OptionParser based CLI support for rapid CLI development in an object-oriented
    context.

    This library wraps Ruby's OptionParser for parsing your options under the hood,
    so you get all the goodness that the Ruby standard library provides.

    On top of that it adds a rich and powerful DSL for defining, validating, and
    normalizing options, as well as automatic and gorgeous help output (modeled
    after `gem --help`).
  str

  s.files        = Dir.glob('{examples/**/*,lib/**/*,[A-Z]*}')
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'

  s.add_dependency 'regstry', '~> 1.0'
end
