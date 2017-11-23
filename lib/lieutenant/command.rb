# frozen_string_literal: true

module Lieutenant
  # Syntax helper to define commands
  module Command
    def self.included(base)
      base.include(Message)
    end
  end
end
