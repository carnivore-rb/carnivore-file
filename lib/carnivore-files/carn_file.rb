require 'carnivore'

module Carnivore
  class Source
    # Carnivore source for consumption from files
    class CarnFile < Source

      # @return [String] path to file
      attr_reader :path
      # @return [Symbol] registry name of fetcher
      attr_reader :fetcher_name

      # Setup source
      #
      # @param args [Hash]
      # @option args [String] :path path to file
      # @option args [Symbol] :foundation underlying file interaction library
      # @option args [Celluloid::Actor] :notify_actor actor to notify on line receive
      def setup(args={})
        @path = ::File.expand_path(args[:path])
        @fetcher_name = "log_fetcher_#{name}".to_sym
        unless(args[:foundation])
          args[:foundation] = RUBY_ENGINE == 'jruby' ? :nio4r : :penguin
        end
        case args[:foundation].to_sym
        when :nio, :nio4r
          callback_supervisor.supervise_as(fetcher_name, Carnivore::Files::Util::Fetcher::Nio,
            args.merge(:notify_actor => current_actor)
          )
        else
          callback_supervisor.supervise_as(fetcher_name, Carnivore::Files::Util::Fetcher::Penguin,
            args.merge(:notify_actor => current_actor)
          )
        end
      end

      # @return [Carnivore::Files::Util::Fetcher] line fetcher
      def fetcher
        callback_supervisor[fetcher_name]
      end

      # Start the line fetcher
      def connect
        fetcher.async.start_fetcher
      end

      # @return [Array<Hash>] return messages
      def receive(*args)
        wait(:new_log_lines)
        fetcher.return_lines.map do |l|
          format_message(l)
        end
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
