# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'keep_running/version'

Gem::Specification.new do |s|
  s.name         = "keep_running"
  s.version      = KeepRunning::VERSION
  s.authors      = ["Niko Dittmann"]
  s.email        = "mail+git@niko-dittmann.com"
  s.homepage     = "http://github.com/niko/keep_running"
  s.summary      = "a script to restart other scripts whenever they crash, stop, get killed."
  s.description  = "a script to restart other scripts whenever they crash, stop, get killed. It sends emails, when restart occurs."
  
  s.files        = Dir.glob('lib/**/*')
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.executables  = ['keep_running']
  
  # s.rubyforge_project = 'keep_running'
  
  s.add_runtime_dependency "pony"
end
