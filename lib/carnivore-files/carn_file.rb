require 'carnivore'

module Carnivore
  class Source
    # Carnivore source for consumption from files
    class CarnFile < Source

      # @return [String] path to file
      attr_reader :path
      # @return [Symbol] registry name of fetcher
      attr_reader :fetcher

      trap_exit :fetcher_failure
      finalizer :fetcher_destroyer

      # Setup source
      #
      # @param args [Hash]
      # @option args [String] :path path to file
      # @option args [Symbol] :foundation underlying file interaction library
      # @option args [Celluloid::Actor] :notify_actor actor to notify on line receive
      def setup(*_)
        @path = ::File.expand_path(args[:path])
        unless(args[:foundation])
          args[:foundation] = RUBY_PLATFORM == 'java' ? :poll : :penguin
        end
      end

      # Start the line fetcher
      def connect
        @fetcher_name = "log_fetcher_#{name}".to_sym
        case args[:foundation].to_sym
        when :poll
          @fetcher = Carnivore::Files::Util::Fetcher::Poll.new(args)
        else
          @fetcher = Carnivore::Files::Util::Fetcher::Penguin.new(args)
        end
        self.link fetcher
        fetcher.async.start_fetcher
      end

      # Restart file collector if unexpectedly failed
      #
      # @param object [Actor] crashed actor
      # @param reason [Exception, NilClass]
      def fetcher_failure(object, reason)
        if(reason && object == fetcher)
          error "File message collector unexpectedly failed: #{reason} (restarting)"
          connect
        end
      end

      def fetcher_destroyer
        if(fetcher && fetcher.alive?)
          fetcher.terminate
        end
      end

      # @return [Array<Hash>] return messages
      def receive(*args)
        format_message(Celluloid::Future.new{ fetcher.messages.pop }.value)
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
