# frozen_string_literal: true

module Lieutenant
  module EventBus
    # Memory implementation of the event bus. Publishes and notifies on the same memory space.
    class InMemory
      def initialize
        @handlers = Hash.new { [] }
      end

      def subscribe(*event_classes, &handler)
        event_classes.each do |event_class|
          handlers[event_class] = handlers[event_class].push(handler)
        end
      end

      def publish(event)
        handlers[event.class].each { |handler| handler.call(event) }
      end

      private

      attr_reader :handlers
    end
  end
end
