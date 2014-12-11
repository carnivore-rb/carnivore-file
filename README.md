# Carnivore Files

Provides File `Carnivore::Source`

# Usage

```ruby
require 'carnivore'
require 'carnivore-files'

Carnivore.configure do
  source = Carnivore::Source.build(
    :type => :carn_file, :args => {:path => '/var/log/app.log'}
  )
end
```

The `File` source is built on two "foundations", `sleepy_penguin`
and `nio4r`. The optimal foundation will be selected based on
the current Ruby in use (`nio4r` for JRuby, `sleepy_penguin` for
everything else). If you want to force the foundation:

```ruby
require 'carnivore'
require 'carnivore-files'

Carnivore.configure do
  source = Carnivore::Source.build(
    :type => :carn_file, :args => {
      :path => '/var/log/app.log',
      :foundation => :nio
    }
  )
end
```

## Important note

The underlying foundations are not installed by this gem. Be sure
include the dependency within your application dependencies (nio4r
or sleepy_penguin).

# Info
* Carnivore: https://github.com/carnivore-rb/carnivore
* Repository: https://github.com/carnivore-rb/carnivore-files
* IRC: Freenode @ #carnivore
