require 'carnivore'

module Carnivore
  class Source
    class File < Source

      attr_reader :path, :fetcher_name

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

      def fetcher
        callback_supervisor[fetcher_name]
      end

      def connect
        fetcher.async.start_fetcher
      end

      def receive(*args)
        wait(:new_log_lines)
        fetcher.return_lines.map do |l|
          format_message(l)
        end
      end

      def transmit(payload, original_message)
        fetcher.write_line(payload)
      end

      protected

      def format_message(m)
        {:path => path, :content => m}
      end

    end
  end
end
