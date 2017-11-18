# frozen_string_literal: true

module Lieutenant
  class Exception
    # Raised when expected version of the agreggate does not match the real one
    # when saving events
    class ConcurrencyConflict < Lieutenant::Exception
    end
  end
end
