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
            loop do
              build_io
              notify.each do |event|
                defer{ event.events }.each do |ev|
                  case ev
                  when :MODIFY
                    retrieve_lines.each do |l|
                      self.messages << l
                    end
                  when :MOVE_SELF, :DELETE_SELF, :ATTRIB
                    info "Destroying file IO due to FS modification! (#{ev.inspect})"
                    destroy_io
                    @waited = true
                    break
                  else
                    debug "Received unhandled event: #{ev.inspect}"
                  end
                end
                break unless io
              end
            end
          end

          private

          # Build the IO and monitor
          #
          # @return [TrueClass, FalseClass]
          def build_io
            result = super
            if(result)
              notify_descriptors[:file_watch] = notify.add_watch(path, :ALL_EVENTS)
            end
            result
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
                event = defer{ notify.take }
                notified = ::File.exists?(path)
              end
              notify.rm_watch(notify_descriptors.delete(:file_wait))
            end
            @waited = true
            info "File has appeared (#{path})!"
          end

        end
      end
    end
  end
end
