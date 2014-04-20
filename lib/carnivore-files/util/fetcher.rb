module Carnivore
  module Files
    module Util
      class Fetcher

        autoload :Nio, 'carnivore-files/util/nio'
        autoload :Penguin, 'carnivore-files/util/penguin'

        include Celluloid
        include Carnivore::Utils::Logging

        attr_reader :path, :delimiter, :notify_actor
        attr_accessor :messages, :io

        def initialize(args={})
          @leftover = ''
          @path = ::File.expand_path(args[:path])
          @delimiter = args.fetch(:delimiter, "\n")
          @notify_actor = args[:notify_actor]
          @messages = []
        end

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


        def return_lines
          msgs = messages.dup
          messages.clear
          msgs
        end

        def write_line(line)
          if(io)
            io.puts(line)
          else
            raise 'No IO detected! Failed to write.'
          end
        end

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
