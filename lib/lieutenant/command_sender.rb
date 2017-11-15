module Lieutenant
  class CommandSender
    def send(command)
      command_class = command.class

      handlers
        .fetch(command_class) { raise Exception::NoRegisteredHandler.new("No registered handler for #{command_class}") }
        .call(command)
    end

    def register(command_class, handler)
      raise ArgumentError.new("Expected #{command_class} to include Lieutenant::Command") unless command_class < Command
      raise ArgumentError.new("Expected #{handler} to respond to #call") unless handler.respond_to?(:call)
      raise RuntimeError.new("Handler for #{command_class} already registered") if handlers.key?(command_class)

      handlers[command_class] = handler
    end

    private

    def handlers
      @handlers ||= {}
    end
  end
end
