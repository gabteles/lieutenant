# frozen_string_literal: true

module Lieutenant
  # Manages configuration
  class Config
    extend Forwardable

    def initialize
      event_bus   = EventBus::InMemory.new
      event_store = EventStore.new(EventStore::InMemory.new, event_bus)
      aggregate_repository = AggregateRepository.new(event_store)

      @registrations = {
        command_sender: CommandSender.new,
        event_bus: event_bus,
        event_store: event_store,
        aggregate_repository: aggregate_repository
      }
    end

    def respond_to_missing?(name, *)
      registration_method?(name) || super
    end

    def method_missing(name, *args, &block)
      return super unless registration_method?(name)
      args.empty? ? get(name) : set(name, *args)
    end

    private # rubocop:disable Lint/UselessAccessModifier

    def_delegator :@registrations, :[], :get
    def_delegator :@registrations, :[]=, :set
    def_delegator :@registrations, :key?, :registration_method?
  end
end
