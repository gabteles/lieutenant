# frozen_string_literal: true

module Lieutenant
  # Command bus dispatch commands to the appropriate handler and manages the repository commit/clean
  class CommandSender
    def dispatch(command)
      handler = handler_for(command.class)
      repository = repository_uow

      begin
        handler.call(repository, command)
        repository.commit
      # rescue Exception::ConcurrencyConflict
      #   TODO: implement command retry policy
      ensure
        repository.clean
      end
    end

    alias call dispatch

    def register(command_class, handler)
      raise(ArgumentError, "Expected #{handler} to respond to #call") unless handler.respond_to?(:call)
      raise("Handler for #{command_class} already registered") if handlers.key?(command_class)

      handlers[command_class] = handler
    end

    private

    def handler_for(command_class)
      handlers.fetch(command_class) do
        raise(Exception::NoRegisteredHandler, "No registered handler for #{command_class}")
      end
    end

    def handlers
      @handlers ||= {}
    end

    def repository_uow
      Lieutenant.config.aggregate_repository.unit_of_work(Lieutenant.config.event_store)
    end
  end
end
