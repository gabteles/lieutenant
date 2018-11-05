# frozen_string_literal: true

module Lieutenant
  class EventStore
    # Memory implementation of the event store. Stores events while the application is running
    class InMemory
      def initialize
        @store = []
        @index = {}
      end

      def persist(events)
        events.each do |event|
          (index[event.aggregate_id] ||= []).push(store.size)
          store.push(event)
        end
      end

      def event_stream_for(aggregate_id)
        aggregate_stream = index[aggregate_id]
        return nil unless aggregate_stream

        events = aggregate_stream.lazy.map(&store.method(:[]))
        Enumerator.new { |yielder| events.each(&yielder.method(:<<)) }
      end

      def aggregate_sequence_number(aggregate_id)
        return -1 unless index.key?(aggregate_id)

        store[index[aggregate_id].last].sequence_number
      end

      def transaction
        # In memory event store currently does not support transactions.
        yield
      end

      private

      attr_reader :store, :index
    end
  end
end
