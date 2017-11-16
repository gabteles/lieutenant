# frozen_string_literal: true

module Lieutenant
  class Config
    extend Forwardable

    def initialize
      @registrations = {
        aggregate_repository: AggregateRepository.new,
        command_sender: CommandSender.new,
        event_bus: EventBus::InMemory.new,
        event_store: EventStore::InMemory.new
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
