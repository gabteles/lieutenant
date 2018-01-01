# frozen_string_literal: true

module Lieutenant
  # Manages configuration
  class Config
    def event_bus
      @event_bus ||= EventBus.new
    end

    # :reek:BooleanParameter
    def event_store(implementation = false)
      return @event_store_implementation = implementation if implementation
      @event_store_implementation ||= EventStore::InMemory
      @event_store ||= EventStore.new(@event_store_implementation, event_bus)
    end

    def aggregate_repository
      @aggregate_repository ||= AggregateRepository.new(event_store)
    end

    def command_sender
      @command_sender ||= CommandSender.new(aggregate_repository)
    end
  end
end
