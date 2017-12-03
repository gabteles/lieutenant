# frozen_string_literal: true

module Lieutenant
  class EventStore
    # Memory implementation of the event store. Stores events while tha application is running
    class InMemory
      def initialize
        @store = {}
        @transaction_stack = []
      end

      def persist(event)
        @transaction_stack.last.push(event)
      end

      def event_stream_for(aggregate_id)
        events = store[aggregate_id]
        return nil unless events
        Enumerator.new { |yielder| events.each(&yielder.method(:<<)) }
      end

      def aggregate_sequence_number(aggregate_id)
        return -1 unless store.key?(aggregate_id)
        last_event = store[aggregate_id].last
        last_event ? last_event.sequence_number : -1
      end

      def around_persistence
        @transaction_stack.push([])

        yield

        @transaction_stack.pop.each do |event|
          (store[event.aggregate_id] ||= []).push(event)
        end
      end

      private

      attr_reader :store
    end
  end
end
