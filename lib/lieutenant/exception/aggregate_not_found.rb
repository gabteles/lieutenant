# frozen_string_literal: true

module Lieutenant
  class Exception
    # Raised when eventes associated with an aggregate id are not found
    class AggregateNotFound < Lieutenant::Exception
    end
  end
end
