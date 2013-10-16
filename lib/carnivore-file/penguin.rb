require 'sleepy_penguin'

module Carnivore
  module File
    module Penguin

      def setup
        notify = SP::Inotify.new
        notify_descriptors = {}
      end

      def receive(*args)
        build_io
        messages = nil
        event = notify.take
        case event.events
        when :MODIFY
          messages = retreive_lines.map do |line|
            format_message(line)
          end
        when :MOVE_SELF, :DELETE_SELF
          destroy_io
        end
        messages
      end

      private

      def build_io
        unless(io)
          if(::File.exists?(path))
            notify_descriptors[:file_watch] = notify.add_watch(path, :ALL_EVENTS)
            @io = File.open(path, 'r')
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
          notify_descriptors[:file_wait] = notify.add_watch(directory, :OPEN)
          until(notified)
            warn "Waiting for file to appear (#{path})"
            directory = File.dirname(path)
            event = notify.take
            notified = File.expand_path(event.name) == path
          end
          notify.rm_watch(notify_descriptors.delete(:file_wait))
        end
        info "File has appeared (#{path})!"
      end

      def io(i=nil)
        if(i)
          @io = i
        end
        @io
      end
      alias_method :io=, :io

      def notify(i=nil)
        if(i)
          @notify = i
        end
        @notify
      end
      alias_method :notify=, :notify

      def notify_descriptors(i=nil)
        if(i)
          @notify_descriptors = i
        end
        @notify_descriptors
      end
      alias_method :notify_descriptors=, :notify_descriptors

    end
  end
end
