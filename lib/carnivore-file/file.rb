require 'carnivore'

module Carnivore
  class Source
    class File < Source

      attr_reader :path
      attr_reader :delimiter

      def initialize(args={})
        @leftover = ''
        @path = args[:file]
        @delimter = args.fetch(:delimiter, "\n")
        case args[:foundation].to_sym
        when :nio, :nio4r
          require 'carnivore-file/nio.rb'
          extend Carnivore::File::Nio
        else
          require 'carnivore-file/penguin.rb'
          extend Carnivore::File::Penguin
        end
        super
      end

      def connect
        unless(::File.exists?(path))
          warn "Provided path does not exist: #{path}"
        end
      end

      protected

      def retrieve_lines(io)
        result = nil
        while(data = io.read(4096))
          @leftover << data
        end
        result = @leftover.split(delimiter)
        @leftover.replace @leftover.end_with?(delimiter) ? '' : result.pop
        result
      end

    end
  end
end
