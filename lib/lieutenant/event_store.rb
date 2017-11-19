# frozen_string_literal: true

module Lieutenant
  # Event stores handles pushing and pulling events from the event store.
  class EventStore
    autoload :InMemory, 'lieutenant/event_store/in_memory'

    def initialize(store, event_bus)
      @store = store
      @event_bus = event_bus
    end

    def save_events(aggregate_id, events, expected_version)
      raise(Exception::ConcurrencyConflict) if aggregate_sequence_number(aggregate_id) != expected_version

      final_events = PREPARE_EVENTS[aggregate_id, events, expected_version]

      store.around_persistence do
        final_events.each(&store.method(:persist))
      end

      final_events.each(&event_bus.method(:publish))
    end

    def event_stream_for(aggregate_id)
      store.event_stream_for(aggregate_id) || raise(AggregateNotFound, aggregate_id)
    end

    private

    attr_reader :store

    PREPARE_EVENTS = lambda do |aggregate_id, events, sequence_number|
      events.lazy.map.with_index do |event, idx|
        event.prepare(aggregate_id, sequence_number + idx + 1)
      end
    end

    private_constant :PREPARE_EVENTS
  end
end
