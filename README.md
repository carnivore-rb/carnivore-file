# Carnivore File

Provides File `Carnivore::Source`

# Usage

```ruby
require 'carnivore'
require 'carnivore-file'

Carnivore.configure do
  source = Carnivore::Source.build(
    :type => :file, :args => {:path => '/var/log/app.log'}
  )
end
```

By default this uses `sleepy_penguin`. If you want to use
`nio4r` instead:

```ruby
require 'carnivore'
require 'carnivore-file'

Carnivore.configure do
  source = Carnivore::Source.build(
    :type => :file, :args => {
      :path => '/var/log/app.log',
      :foundation => :nio
    }
  )
end
```
# Info
* Carnivore: https://github.com/carnivore-rb/carnivore
* Repository: https://github.com/carnivore-rb/carnivore-file
* IRC: Freenode @ #carnivore
