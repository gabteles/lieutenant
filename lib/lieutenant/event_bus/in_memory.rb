# frozen_string_literal: true

module Lieutenant
  module EventBus
    # Memory implementation of the event bus. Publishes and notifies on the same memory space.
    class InMemory
      def initialize
        @handlers = {}
      end

      def subscribe(*event_classes, &handler)
        event_classes.each do |event_class|
          handlers[event_class] = handlers.fetch(event_class, []).push(handler)
        end
      end

      def publish(event)
        block = CALL_HANDLER_WITH_EVENT[event]
        handlers[:all].each(&block)
        handlers[event.class].each(&block)
      end

      CALL_HANDLER_WITH_EVENT = ->(event) { ->(handler) { handler.call(event) } }
      private_constant :CALL_HANDLER_WITH_EVENT
    end
  end
end
