# frozen_string_literal: true

module Lieutenant
  class EventStore
    # Memory implementation of the event store. Stores events while the application is running
    class InMemory
      def initialize
        @store = {}
        @transaction_stack = []
      end

      def persist(events)
        events.each { |event| (store[event.aggregate_id] ||= []).push(event) }
      end

      def event_stream_for(aggregate_id)
        events = store[aggregate_id]
        return nil unless events
        Enumerator.new { |yielder| events.each(&yielder.method(:<<)) }
      end

      def aggregate_sequence_number(aggregate_id)
        return -1 unless store.key?(aggregate_id)
        store[aggregate_id].last.sequence_number
      end

      private

      attr_reader :store
    end
  end
end
