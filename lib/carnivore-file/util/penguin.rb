require 'sleepy_penguin/sp'
require 'carnivore-file/util/fetcher'

module Carnivore
  module File
    module Util
      class Fetcher
        class Penguin < Fetcher

          attr_accessor :notify, :notify_descriptors

          def initialize(args={})
            super
            @notify = SP::Inotify.new
            @notify_descriptors = {}
          end

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

          def build_io
            unless(io)
              if(::File.exists?(path))
                notify_descriptors[:file_watch] = notify.add_watch(path, :ALL_EVENTS)
                @io = ::File.open(path, 'r')
              else
                wait_for_file
                build_io
              end
            end
            true
          end

          def destroy_io
            if(io)
              notify.rm_watch(notify_descriptors.delete(:file_watch))
              @io.close
              @io = nil
            end
            true
          end

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
