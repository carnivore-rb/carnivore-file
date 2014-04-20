require 'nio'
require 'carnivore-files/util/fetcher'

module Carnivore
  module File
    module Util
      class Fetcher
        class Nio < Fetcher

          attr_accessor :monitor, :selector

          def initialize(args={})
            super
            @selector = NIO::Selector.new
            every(5) do
              check_file
            end
          end

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

          def build_io
            unless(monitor)
              if(::File.exists?(path))
                unless(io)
                  @io = ::File.open(path, 'r')
                end
                @monitor = selector.register(io, :r)
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
              @monitor = nil
            end
            if(io)
              io.close
              @io = nil
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

        end
      end
    end
  end
end
