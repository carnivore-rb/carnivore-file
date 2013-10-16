require 'nio'

module Carnivore
  module File
    module Nio

      def setup
        selector = NIO::Selector.new
      end

      def receive(*args)
        build_io
        messages = nil
        selector.select.each do |mon|
          messages = retrieve_lines(mon.io).map do |line|
            format_message(line)
          end
        end
        messages
      end

      private

      def build_io
        unless(monitor)
          if(::File.exists?(path))
            monitor = selector.register(path, :r)
          else
            wait_for_file
            build_io
          end
        end
        true
      end

      def destroy_io
        if(monitor)
          selector.deregister(monitor)
          monitor = nil
        end
        true
      end

      def wait_for_file
        warn "Waiting for file to appear (#{path})"
        until(::File.exists?(path))
          sleep(5)
        end
        info "File has appeared (#{path})!"
      end

      def selector(i=nil)
        if(i)
          @selector = i
        end
        @selector
      end
      alias_method :selector=, :selector

      def monitor(i=nil)
        if(i)
          @monitor = i
        end
        @monitor
      end
      alias_method :monitor=, :monitor

    end
  end
end
