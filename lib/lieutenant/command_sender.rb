# frozen_string_literal: true

module Lieutenant
  # Command bus dispatch commands to the appropriate handler and manages the repository commit/clean
  class CommandSender
    def initialize(aggregate_repository)
      @aggregate_repository = aggregate_repository
      @handlers = {}
    end

    def dispatch(command)
      handler = handler_for(command.class)
      # TODO: Filters
      raise(Lieutenant::Exception, "Invalid command: #{command.inspect}") unless command.valid?
      aggregate_repository.unit_of_work.execute { |repository| handler.call(repository, command) }
      # rescue Exception::ConcurrencyConflict
      #   TODO: implement command retry policy
    end

    alias call dispatch

    def register(command_class, handler)
      raise(Lieutenant::Exception, "Handler for #{command_class} already registered") if handlers.key?(command_class)
      handlers[command_class] = handler
    end

    private

    attr_reader :aggregate_repository
    attr_reader :handlers

    def handler_for(command_class)
      handlers.fetch(command_class) do
        raise(Exception::NoRegisteredHandler, "No registered handler for #{command_class}")
      end
    end
  end
end
