# frozen_string_literal: true

module Lieutenant
  # Manages configuration
  class Config
    def initialize
      @event_store = nil
    end

    # :reek:Attribute
    attr_writer :event_bus

    def event_store_persistence=(implementation)
      raise "Cannot change event store's persistence after event store is initialized" if @event_store

      @event_store_persistence = implementation
    end

    def event_bus
      @event_bus ||= EventBus::InMemory.new
    end

    def event_store_persistence
      @event_store_persistence ||= EventStore::InMemory.new
    end

    def event_store
      @event_store ||= EventStore.new(event_store_persistence, event_bus)
    end

    def aggregate_repository
      @aggregate_repository ||= AggregateRepository.new(event_store)
    end

    def command_sender
      @command_sender ||= CommandSender.new(aggregate_repository)
    end
  end
end
