# frozen_string_literal: true

module Lieutenant
  # Projector helper. Allows clean syntax to subscribe to events:
  #
  #   class FooProjector
  #     include Lieutenant::Projector
  #
  #     on CreatedBarEvent do
  #        # `event` is accessible
  #        # ...
  #     end
  #   end
  #
  # Methods can also be used in order to improve legibility:
  #
  #   class FooProjector
  #     include Lieutenant::Projector
  #
  #     on DeletedBarEvent, handler: :handle_delete
  #
  #     def handle_delete
  #       # `event` is accessible
  #       # ...
  #     end
  #   end
  #
  # By default Lieutenant::Projector defines +initialize+ method, receiving the
  # configuration, that it will use to find desired event bus to subscribe.
  # If overriding this method is necessary, there's +initialize_projector+
  # method that can be called in order to do this job, as shown:
  #
  #   class FooProjector
  #     include Lieutenant::Projector
  #
  #     def initialize(needed_parameter)
  #       @needed_parameter = needed_parameter
  #       initialize_projector # assumes that this class will always use default
  #                            # lieutenant configuration since we're passing no
  #                            # parameters to `initialize_projector`
  #     end
  #   end
  module Projector
    def self.included(base)
      base.class_eval do
        extend Lieutenant::Projector::ClassMethods
      end
    end

    # Define common class methods to projectors
    module ClassMethods
      def on(*event_classes, handler: nil, &block)
        subscriptions << { event_classes: event_classes, handler: handler, block: block }
      end

      def subscriptions
        @subscriptions ||= []
      end
    end

    protected

    def handle_event(event, handler:, block:)
      @event = event
      effect = handler ? method(handler) : block
      instance_exec(&effect)
    end

    def initialize_projector(config = Lieutenant.config)
      @projector_config = config
      subscribe_to_events
    end

    alias initialize initialize_projector unless method_defined? :initialize

    private

    attr_reader :event, :projector_config

    def subscribe_to_events
      self.class.subscriptions.each do |event_classes:, **kwargs|
        subscribe_to_event(event_classes, kwargs)
      end
    end

    def subscribe_to_event(event_classes, kwargs)
      projector_config.event_bus.subscribe(*event_classes) do |event|
        clone.handle_event(event, kwargs)
      end
    end
  end
end
