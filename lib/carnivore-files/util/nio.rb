require 'nio'

module Carnivore
  module Files
    module Util
      class Fetcher

        # NIO based fetcher
        class Nio < Fetcher

          # @return [NIO::Monitor]
          attr_accessor :monitor
          # @return [NIO::Selector]
          attr_accessor :selector

          # Create new instance
          #
          # @param args [Hash] initialization arguments (unused)
          def initialize(args={})
            super
            @selector = NIO::Selector.new
            every(5) do
              check_file
            end
          end

          # Start the fetcher
          def start_fetcher
            defer do
              loop do
                build_io
                messages = nil
                selector.select.each do |mon|
                  self.messages += retrieve_lines
                end
                notify_actor.signal(:new_log_lines) unless self.messages.empty?
              end
            end
          end

          private

          # Check for file and destroy monitor if file has changed
          def check_file
            if(io)
              begin
                unless(io.stat.ino == ::File.stat(path).ino)
                  destroy_io
                end
              rescue Errno::ENOENT
                destroy_io
              end
            end
          end

          # Build the IO instance if found
          #
          # @return [TrueClass]
          def build_io
            unless(monitor)
              if(::File.exists?(path))
                unless(io)
                  @io = ::File.open(path, 'r')
                  @io.seek(0, ::IO::SEEK_END) # fast-forward to EOF
                end
                @monitor = selector.register(io, :r)
              else
                wait_for_file
                build_io
              end
            end
            true
          end

          # Destroy the IO instance and monitor
          #
          # @return [TrueClass]
          def destroy_io
            if(monitor)
              selector.deregister(monitor)
              @monitor = nil
            end
            if(io)
              io.close
              @io = nil
            end
            true
          end

          # Wait helper for file to appear (5 sleep second intervals)
          #
          # @return [TrueClass]
          def wait_for_file
            warn "Waiting for file to appear (#{path})"
            until(::File.exists?(path))
              sleep(5)
            end
            info "File has appeared (#{path})!"
          end

        end
      end
    end
  end
end
