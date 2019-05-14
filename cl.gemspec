# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'cl/version'

Gem::Specification.new do |s|
  s.name         = 'cl'
  s.version      = Cl::VERSION
  s.authors      = ['Sven Fuchs']
  s.homepage     = 'https://github.com/svenfuchs/cl'
  s.licenses     = ['MIT']
  s.summary      = 'OptionParser based CLI support'
  s.description  = 'OptionParser based CLI support.'

  s.files        = Dir.glob('{examples/**/*,lib/**/*,[A-Z]*}')
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'

  s.add_dependency 'regstry', '~> 1.0.3'
end
