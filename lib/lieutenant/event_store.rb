# frozen_string_literal: true

module Lieutenant
  # Event stores handles pushing and pulling events from the event store.
  module EventStore
    autoload :AbstractEventStore, 'lieutenant/event_store/abstract_event_store'
    autoload :InMemory,           'lieutenant/event_store/in_memory'
  end
end
