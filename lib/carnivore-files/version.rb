module Carnivore
  module Files
    # Customized version class
    class Version < Gem::Version
    end
    # Current version of library
    VERSION = Version.new('0.1.0')
  end
end
