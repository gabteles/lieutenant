# frozen_string_literal: true

module Lieutenant
  class CommandSender
    def dispatch(command)
      command_class = command.class

      handlers
        .fetch(command_class) { raise(Exception::NoRegisteredHandler, "No registered handler for #{command_class}") }
        .call(command)
    end

    alias :call :dispatch

    def register(command_class, handler)
      raise(ArgumentError, "Expected #{command_class} to include Lieutenant::Command") unless command_class < Command
      raise(ArgumentError, "Expected #{handler} to respond to #call") unless handler.respond_to?(:call)
      raise("Handler for #{command_class} already registered") if handlers.key?(command_class)

      handlers[command_class] = handler
    end

    private

    def handlers
      @handlers ||= {}
    end
  end
end
