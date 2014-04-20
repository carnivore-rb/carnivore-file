require 'carnivore-files/version'
require 'carnivore'

module Carnivore
  module Files
    module Util
      autoload :Fetcher, 'carnivore-files/util/fetcher'
    end
  end
end

Carnivore::Source.provide(:file, 'carnivore-files/file')
