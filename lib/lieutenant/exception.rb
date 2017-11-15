# frozen_string_literal: true

module Lieutenant
  class Exception < StandardError
    autoload :ConcurrencyConflict, 'lieutenant/exception/concurrency_conflict'
    autoload :NoRegisteredHandler, 'lieutenant/exception/no_registered_handler'
  end
end
