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
      raise(Exception::ConcurrencyConflict) if store.aggregate_sequence_number(aggregate_id) != expected_version

      PREPARE_EVENTS[aggregate_id, events, expected_version].tap do |final_events|
        store.persist(final_events)
        final_events.each(&event_bus.method(:publish))
      end
    end

    def event_stream_for(aggregate_id)
      store.event_stream_for(aggregate_id) || raise(Exception::AggregateNotFound, aggregate_id)
    end

    private

    attr_reader :store
    attr_reader :event_bus

    PREPARE_EVENTS = lambda do |aggregate_id, events, sequence_number|
      events.lazy.with_index.map do |event, idx|
        event.prepare(aggregate_id, sequence_number + idx + 1)
        event
      end
    end

    private_constant :PREPARE_EVENTS
  end
end
