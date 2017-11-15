module Lieutenant
  module CommandHandler
    def on(command_class, &block)
      Lieutenant.config.command_sender.register(command_class, block)
    end
  end
end
