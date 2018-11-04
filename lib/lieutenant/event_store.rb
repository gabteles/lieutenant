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

      store.persist(events)
      events.each(&event_bus.method(:publish))
    end

    def event_stream_for(aggregate_id)
      store.event_stream_for(aggregate_id) || raise(Exception::AggregateNotFound, aggregate_id)
    end

    def transaction(&blk)
      store.transaction(&blk)
    end

    private

    attr_reader :store
    attr_reader :event_bus
  end
end
