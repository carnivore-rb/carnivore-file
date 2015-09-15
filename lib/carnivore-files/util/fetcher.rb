require 'carnivore-files'

module Carnivore
  module Files
    # Helper utilities
    module Util
      # Fetch lines from file
      class Fetcher

        autoload :Poll, 'carnivore-files/util/poll'
        autoload :Penguin, 'carnivore-files/util/penguin'

        include Zoidberg::SoftShell
        include Zoidberg::Supervise
        include Carnivore::Utils::Logging

        # @return [String] path to file
        attr_reader :path
        # @return [String] string to split messages on
        attr_reader :delimiter

        # @return [Queue] messages
        attr_accessor :messages
        # @return [IO] underlying IO instance
        attr_accessor :io

        # Create new instance
        #
        # @param args [Hash] initialization args
        # @option args [String] :path path to file
        # @option args [String] :delimiter string delimiter to break messages
        def initialize(args={})
          @leftover = ''
          @path = ::File.expand_path(args[:path])
          @delimiter = args.fetch(:delimiter, "\n")
          @messages = args.fetch(:queue, Queue.new)
        end

        # Start the line fetcher
        def start_fetcher
          raise NotImplementedError
        end

        # Write line to IO
        #
        # @param line [String]
        # @return [Integer] bytes written
        def write_line(line)
          if(io)
            io.puts(line)
          else
            raise 'No IO detected! Failed to write.'
          end
        end

        # Retreive lines from file
        def retrieve_lines
          if(io)
            io.pos = @history_pos if @history_pos
            @leftover << io.read(4096).to_s
            while(data = io.read(4096))
              @leftover << data.to_s
            end
            @history_pos = io.pos
            result = @leftover.split(delimiter)
            @leftover.replace @leftover.end_with?(delimiter) ? '' : result.pop.to_s
            result
          else
            []
          end
        end

        # Build the IO and monitor
        #
        # @return [TrueClass, FalseClass]
        def build_io
          unless(io)
            if(::File.exists?(path))
              @history_pos = 0
              @io = ::File.open(path, 'r')
              unless(@waited)
                @io.seek(0, ::IO::SEEK_END) # fast-forward to EOF
              else
                @waited = false
                retrieve_lines.each do |l|
                  self.messages << l
                end
              end
            else
              wait_for_file
              build_io
            end
            true
          else
            false
          end
        end

      end
    end
  end
end
