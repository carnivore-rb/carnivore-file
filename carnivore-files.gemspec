$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'carnivore-files/version'
spec = Gem::Specification.new do |s|
  s.name = 'carnivore-files'
  s.version = Carnivore::Files::VERSION.version
  s.summary = 'Message processing helper'
  s.author = 'Chris Roberts'
  s.email = 'code@chrisroberts.org'
  s.homepage = 'https://github.com/carnivore-rb/carnivore-files'
  s.description = 'Carnivore file source'
  s.license = 'Apache 2.0'
  s.require_path = 'lib'
  s.add_runtime_dependency 'carnivore', '>= 1.0.0', '< 2.0.0'
  s.add_runtime_dependency 'sleepy_penguin', '~> 3.4'
  s.add_development_dependency 'pry'
  s.files = Dir['{lib}/**/**/*'] + %w(carnivore-files.gemspec README.md CHANGELOG.md)
end
