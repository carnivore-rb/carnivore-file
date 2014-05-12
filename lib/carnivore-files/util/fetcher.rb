module Carnivore
  module Files
    # Helper utilities
    module Util
      # Fetch lines from file
      class Fetcher

        autoload :Nio, 'carnivore-files/util/nio'
        autoload :Penguin, 'carnivore-files/util/penguin'

        include Celluloid
        include Carnivore::Utils::Logging

        # @return [String] path to file
        attr_reader :path
        # @return [String] string to split messages on
        attr_reader :delimiter
        # @return [Celluloid::Actor] actor to notify on new messages
        attr_reader :notify_actor

        # @return [Array] messages
        attr_accessor :messages
        # @return [IO] underlying IO instance
        attr_accessor :io

        # Create new instance
        #
        # @param args [Hash] initialization args
        # @option args [String] :path path to file
        # @option args [String] :delimiter string delimiter to break messages
        # @option args [Celluloid::Actor] :notify_actor actor to be notified on new messages
        def initialize(args={})
          @leftover = ''
          @path = ::File.expand_path(args[:path])
          @delimiter = args.fetch(:delimiter, "\n")
          @notify_actor = args[:notify_actor]
          @messages = []
        end

        # Start the line fetcher
        def start_fetcher
          defer do
            loop do
              build_socket
              messages = nil
              selector.select.each do |mon|
                self.messages += retrieve_lines
              end
              notify_actor.signal(:new_logs_lines) unless self.messages.empty?
            end
          end
        end

        # @return [Array<String>] current lines
        def return_lines
          msgs = messages.dup
          messages.clear
          msgs
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
            while(data = io.read(4096))
              @leftover << data
            end
            result = @leftover.split(delimiter)
            @leftover.replace @leftover.end_with?(delimiter) ? '' : result.pop.to_s
            result
          else
            []
          end
        end

      end
    end
  end
end
