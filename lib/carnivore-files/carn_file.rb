require 'carnivore'

module Carnivore
  class Source
    # Carnivore source for consumption from files
    class CarnFile < Source

      # @return [String] path to file
      attr_reader :path
      # @return [Symbol] registry name of fetcher
      attr_reader :fetcher
      # @return [Queue] queue to hold messages
      attr_reader :message_queue

      # Setup source
      #
      # @param args [Hash]
      # @option args [String] :path path to file
      # @option args [Symbol] :foundation underlying file interaction library
      def setup(*_)
        @path = ::File.expand_path(args[:path])
        @message_queue = Queue.new
        unless(args[:foundation])
          args[:foundation] = RUBY_PLATFORM == 'java' ? :poll : :penguin
        end
      end

      # Start the line fetcher
      def connect
        case args[:foundation].to_sym
        when :poll
          @fetcher = Carnivore::Files::Util::Fetcher::Poll.new(args.merge(:queue => message_queue))
        else
          @fetcher = Carnivore::Files::Util::Fetcher::Penguin.new(args.merge(:queue => message_queue))
        end
        fetcher.async.start_fetcher
      end

      # @return [Array<Hash>] return messages
      def receive(*_)
        defer{ message_queue.pop }
      end

      # Send payload
      #
      # @param payload [Object] payload to transmit
      def transmit(payload, *args)
        fetcher.write_line(payload)
      end

      protected

      # Format message into customized Hash
      #
      # @param m [Object] payload
      # @return [Hash]
      def format_message(m)
        Smash.new(:path => path, :content => m)
      end

    end
  end
end
