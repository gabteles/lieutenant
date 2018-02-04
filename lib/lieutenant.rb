# frozen_string_literal: true

require 'forwardable'
require 'active_model'

# Lieutenant namespace
module Lieutenant
  autoload :Aggregate,           'lieutenant/aggregate'
  autoload :AggregateRepository, 'lieutenant/aggregate_repository'
  autoload :Command,             'lieutenant/command'
  autoload :CommandHandler,      'lieutenant/command_handler'
  autoload :CommandSender,       'lieutenant/command_sender'
  autoload :Config,              'lieutenant/config'
  autoload :Event,               'lieutenant/event'
  autoload :EventBus,            'lieutenant/event_bus'
  autoload :EventStore,          'lieutenant/event_store'
  autoload :Exception,           'lieutenant/exception'
  autoload :Message,             'lieutenant/message'
  autoload :Projection,          'lieutenant/projection'
  autoload :VERSION,             'lieutenant/version'

  module_function

  @config = Config.new

  def config
    block_given? ? yield(@config) : @config
  end
end
