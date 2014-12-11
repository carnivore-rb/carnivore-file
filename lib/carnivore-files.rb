require 'carnivore-files/version'
require 'carnivore'

module Carnivore
  # Carnivore source module for files
  module Files
    # Utilities for files
    module Util
      autoload :Fetcher, 'carnivore-files/util/fetcher'
    end
  end
end

Carnivore::Source.provide(:carn_file, 'carnivore-files/carn_file')
