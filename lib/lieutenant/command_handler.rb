# frozen_string_literal: true

module Lieutenant
  module CommandHandler
    def self.included(base)
      base.extend(self)
    end

    def on(command_class, &block)
      Lieutenant.config.command_sender.register(command_class, block)
    end
  end
end
