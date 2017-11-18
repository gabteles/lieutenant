# frozen_string_literal: true

module Lieutenant
  module EventStore
    module AbstractEventStore
      def save_events(aggregate_id, events, expected_version)
        if aggregate_sequence_number(aggregate_id) != expected_version
          raise(Exception::ConcurrencyConflict)
        end

        around_persistence do
          events.reduce(expected_version + 1) do |sequence_number, event|
            append_event(aggregate_id, sequence_number, event)
          end
        end
      end

      def event_stream_for(aggregate_id)
        AggregateNotFound.new(aggregate_id)
      end

      private

      def append_event(aggregate_id, sequence_number, event)
        event.aggregate_id = aggregate_id
        event.sequence_number = sequence_number
        persist(event)
        Lieutenant.config.event_bus.publish(event)
        sequence_number + 1
      end

      def around_persistence
        yield
      end
    end
  end
end
