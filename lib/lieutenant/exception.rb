# frozen_string_literal: true

module Lieutenant
  module Exception
    autoload :ConcurrencyConflict, 'lieutenant/exception/concurrency_conflict'
    autoload :NoRegisteredHandler, 'lieutenant/exception/no_registered_handler'
  end
end
