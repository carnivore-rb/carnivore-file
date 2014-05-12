require 'sleepy_penguin/sp'

module Carnivore
  module Files
    module Util
      class Fetcher


        # NIO based fetcher
        class Penguin < Fetcher
          # @return [SP::Inotify]
          attr_accessor :notify
          # @return [Hash] registered file descriptors
          attr_accessor :notify_descriptors

          # Create new instance
          #
          # @param args [Hash] initialization arguments (unused)
          def initialize(args={})
            super
            @notify = SP::Inotify.new
            @notify_descriptors = {}
          end

          # Start the fetcher
          def start_fetcher
            defer do
              loop do
                build_io
                notify.each do |event|
                  event.events.each do |ev|
                    case ev
                    when :MODIFY
                      self.messages += retrieve_lines
                    when :MOVE_SELF, :DELETE_SELF, :ATTRIB
                      destroy_io
                    end
                  end
                  notify_actor.signal(:new_log_lines) unless messages.empty?
                end
              end
            end
          end

          private

          # Build the IO and monitor
          #
          # @return [TrueClass]
          def build_io
            unless(io)
              if(::File.exists?(path))
                notify_descriptors[:file_watch] = notify.add_watch(path, :ALL_EVENTS)
                @io = ::File.open(path, 'r')
                @io.seek(0, ::IO::SEEK_END) # fast-forward to EOF
              else
                wait_for_file
                build_io
              end
            end
            true
          end

          # Destroy the IO and monitor
          #
          # @return [TrueClass]
          def destroy_io
            if(io)
              notify.rm_watch(notify_descriptors.delete(:file_watch))
              @io.close
              @io = nil
            end
            true
          end


          # Wait helper for file to appear (waits for expected notification)
          #
          # @return [TrueClass]
          def wait_for_file
            until(::File.exists?(path))
              notified = false
              directory = ::File.dirname(path)
              notify_descriptors[:file_wait] = notify.add_watch(directory, :OPEN)
              until(notified)
                warn "Waiting for file to appear (#{path})"
                event = notify.take
                if(event.name)
                  notified = ::File.expand_path(event.name) == path
                end
              end
              notify.rm_watch(notify_descriptors.delete(:file_wait))
            end
            info "File has appeared (#{path})!"
          end

        end
      end
    end
  end
end
