# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'cli/version'

Gem::Specification.new do |s|
  s.name         = "cl"
  s.version      = Cli::VERSION
  s.authors      = ["Sven Fuchs"]
  s.email        = "me@svenfuchs.com"
  s.homepage     = "https://github.com/svenfuchs/cl"
  s.licenses     = ['MIT']
  s.summary      = "OptionParser based CLI support"
  s.description  = "OptionParser based CLI support."

  s.files        = Dir.glob("{lib/**/*,[A-Z]*}")
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
end
