# frozen_string_literal: true

module Lieutenant
  module EventBus
    class InMemory
      def handlers
        @handlers ||= Hash.new { [] }
      end

      def subscribe(*event_classes, &handler)
        event_classes.each do |event_class|
          handlers[event_class] = handlers[event_class].push(handler)
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
