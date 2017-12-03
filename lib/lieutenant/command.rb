# frozen_string_literal: true

module Lieutenant
  # Syntax helper to define commands
  module Command
    def self.included(base)
      base.instance_eval do
        include Lieutenant::Message
      end
    end
  end
end
