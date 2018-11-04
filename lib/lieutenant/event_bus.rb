# frozen_string_literal: true

module Lieutenant
  # Publishes and receives messages from the aggregates updates
  module EventBus
    autoload :InMemory, 'lieutenant/event_bus/in_memory'
  end
end
