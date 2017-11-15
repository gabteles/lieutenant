# frozen_string_literal: true

module Lieutenant
  module EventStore
    autoload :AbstractEventStore, 'lieutenant/event_store/abstract_event_store'
    autoload :InMemory,           'lieutenant/event_store/in_memory'
  end
end
