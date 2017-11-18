# frozen_string_literal: true

module Lieutenant
  class Exception
    # Raised when a handler to a command is not registered
    class NoRegisteredHandler < Lieutenant::Exception
    end
  end
end
