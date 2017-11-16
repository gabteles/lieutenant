# frozen_string_literal: true

module Lieutenant
  module EventStore
    class InMemory
      include AbstractEventStore

      def initialize
        @store = {}
      end

      def persist(event)
        (store[event.aggregate_id] ||= []).push(event)
      end

      def event_stream_for(aggregate_id)
        events = store[aggregate_id]
        return super unless events
        Enumerator.new { |y| events.each(&y.method(:<<)) }
      end

      def aggregate_sequence_number(aggregate_id)
        return -1 unless store.key?(aggregate_id)
        last_event = store[aggregate_id].last
        last_event ? last_event.sequence_number : -1
      end

      private

      attr_reader :store
    end
  end
end
