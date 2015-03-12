require 'carnivore-files'

module Carnivore
  module Files
    module Util
      class Fetcher

        # Polling fetcher
        class Poll < Fetcher

          # Start the fetcher
          def start_fetcher
            loop do
              build_io
              ino = io.stat.ino
              retrieve_lines.each do |line|
                self.messages << line
              end
              pos = io.pos
              sleep(1)
              begin
                if(io.size < pos || ino != File.stat(path).ino)
                  destroy_io
                  @waited = true
                end
              rescue Errno::ENOENT
                destroy_io
                @waited = true
              end
            end
          end

          # Destroy the IO instance and monitor
          #
          # @return [TrueClass]
          def destroy_io
            if(io)
              io.close
              @io = nil
            end
            true
          end

          # Wait helper for file to appear (2 second intervals)
          #
          # @return [TrueClass]
          def wait_for_file
            warn "Waiting for file to appear (#{path})"
            until(::File.exists?(path))
              @waited = true
              sleep(2)
            end
            info "File has appeared (#{path})!"
          end

        end
      end
    end
  end
end
