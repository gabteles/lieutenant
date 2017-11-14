# frozen_string_literal: true

# Lieutenant namespace
module Lieutenant
  autoload :Aggregate,      'lieutenant/aggregate'
  autoload :Bus,            'lieutenant/bus'
  autoload :Command,        'lieutenant/command'
  autoload :CommandHandler, 'lieutenant/command_handler'
  autoload :Event,          'lieutenant/event'
  autoload :EventStore,     'lieutenant/event_store'
  autoload :Message,        'lieutenant/message'
  autoload :Projection,     'lieutenant/projection'
  autoload :Saga,           'lieutenant/saga'
  autoload :VERSION,        'lieutenant/version'
end
