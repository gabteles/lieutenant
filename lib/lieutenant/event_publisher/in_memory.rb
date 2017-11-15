module Lieutenant
  module EventPublisher
    class InMemory
      def handlers
        @handlers ||= Hash.new { [] }
      end

      def subscribe(event_class, handler)
        handlers[event_class].push(handler)
      end

      def publish(event)
        handlers[event.class].each do |handler|
          handler.(event)
        end
      end
    end
  end
end
