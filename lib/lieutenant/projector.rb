# frozen_string_literal: true

module Lieutenant
  # Projector helper. Allows clean syntax to subscribe to events:
  #
  #   class FooProjector
  #     include Lieutenant::Projector
  #
  #     on CreatedBarEvent do |event|
  #        # ...
  #     end
  #
  #     on DeletedBarEvent, to: :handle_delete
  #
  #     def handle_delete
  #       # `event` is accessible
  #       # ...
  #     end
  #   end
  module Projector
    def self.included(base)
      base.class_eval do
        extend Lieutenant::Projector::ClassMethods
        # TODO: Register classes including this
      end
    end

    # Define common class methods to projectors
    module ClassMethods
      def on(*event_classes, to: nil, &block)
        subscriptions << { event_classes: event_classes, to: to, block: block }
      end

      def subscriptions
        @subscriptions ||= []
      end
    end

    protected

    def handle_event(event, to:, block:)
      @event = event
      effect = to ? method(to) : block
      instance_exec(&effect)
    end

    private

    attr_reader :event, :projector_config

    def initialize_projector(config = Lieutenant.config)
      @projector_config = config
      subscribe_to_events
    end

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
