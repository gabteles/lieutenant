# frozen_string_literal: true

module Lieutenant
  # Projection helper. Allows clean syntax to subscribe to events:
  #
  #   module FooProjection
  #     include Lieutenant::Projection
  #
  #     on(CreatedBarEvent) do |event|
  #        # ...
  #     end
  #   end
  module Projection
    def self.included(base)
      base.class_eval do
        extend Lieutenant::Projection
      end
    end

    # :reek:UtilityFunction
    def on(*event_classes, &block)
      Lieutenant.config.event_bus.subscribe(*event_classes, &block)
    end
  end
end
