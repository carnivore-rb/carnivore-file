eval File.read(File.expand_path('carnivore-files.gemspec', File.dirname(__FILE__)))

if(RUBY_PLATFORM == 'java')
  spec.platform = 'java'
  spec.dependencies.delete_if do |dep|
    dep.name == 'sleepy_penguin'
  end
end

spec
