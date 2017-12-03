# frozen_string_literal: true

module Lieutenant
  # Command handler helper. Allows clean syntax to register handlers:
  #
  #   module FooCommandHandler
  #     include Lieutenant::CommandHandler
  #
  #     on(BarCommand) do |repository, command|
  #        # ...
  #     end
  #   end
  module CommandHandler
    def self.included(base)
      base.extend(self)
    end

    # :reek:UtilityFunction
    def on(command_class, &block)
      Lieutenant.config.command_sender.register(command_class, block)
    end
  end
end
