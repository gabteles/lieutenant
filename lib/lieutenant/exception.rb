# frozen_string_literal: true

module Lieutenant
  # Generic class to all Lieutenant exceptions. Anything is
  # rescue-able with Lieutenant::Exception
  class Exception < StandardError
    autoload :AggregateNotFound,   'lieutenant/exception/aggregate_not_found'
    autoload :ConcurrencyConflict, 'lieutenant/exception/concurrency_conflict'
    autoload :NoRegisteredHandler, 'lieutenant/exception/no_registered_handler'
  end
end
