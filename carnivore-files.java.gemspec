eval File.read(File.expand_path('carnivore-rabbitmq.gemspec', File.dirame(__FILE__)))

if(RUBY_PLATFORM == 'java')
  spec.platform = 'java'
  spec.dependencies.delete_if do |dep|
    dep.name == 'sleepy_penguin'
  end
  spec.add_dependency 'nio4r'
end

spec
