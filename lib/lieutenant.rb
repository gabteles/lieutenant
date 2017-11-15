# frozen_string_literal: true

require 'forwardable'

# Lieutenant namespace
module Lieutenant
  autoload :Aggregate,      'lieutenant/aggregate'
  autoload :Command,        'lieutenant/command'
  autoload :CommandHandler, 'lieutenant/command_handler'
  autoload :CommandSender,  'lieutenant/command_sender'
  autoload :Config,         'lieutenant/config'
  autoload :Event,          'lieutenant/event'
  autoload :EventPublisher, 'lieutenant/event_publisher'
  autoload :EventStore,     'lieutenant/event_store'
  autoload :Exception,      'lieutenant/exception'
  autoload :Projection,     'lieutenant/projection'
  autoload :Saga,           'lieutenant/saga'
  autoload :VERSION,        'lieutenant/version'

  module_function

  @config = Config.new

  def config
    block_given? ? yield(@config) : @config
  end
end
