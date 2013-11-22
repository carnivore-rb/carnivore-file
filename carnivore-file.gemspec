$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'carnivore-file/version'
Gem::Specification.new do |s|
  s.name = 'carnivore-file'
  s.version = Carnivore::File::VERSION.version
  s.summary = 'Message processing helper'
  s.author = 'Chris Roberts'
  s.email = 'chrisroberts.code@gmail.com'
  s.homepage = 'https://github.com/carnivore-rb/carnivore-file'
  s.description = 'Carnivore file source'
  s.require_path = 'lib'
  s.add_dependency 'carnivore', '>= 0.1.8'
#  s.add_dependency 'nio4r'          # suggested depends since we
  #  support both but don't want to install both
#  s.add_dependency 'sleepy_penguin'
  s.files = Dir['**/*']
end
