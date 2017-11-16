# frozen_string_literal: true

module Lieutenant
  module Aggregate
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def load_from_history(id, history)
        allocate.tap do |aggregate|
          aggregate.send(:setup, id)

          count = -1

          history.each { |event|
            aggregate.send(:internal_apply, event, false)
            count += 1
          }

          aggregate.send(:version=, count)
        end
      end

      def on(*event_classes, &handler)
        event_classes.each do |event_class|
          raise(ArgumentError, "Expected #{event_class} to include Lieutenant::Event") unless event_class < Event
          handlers[event_class] = handlers[event_class].push(handler)
        end
      end

      def handlers_for(event_class)
        handlers[event_class]
      end

      private

      def handlers
        @handlers ||= Hash.new { [] }
      end
    end

    attr_reader :id
    attr_reader :uncommitted_events
    attr_reader :version

    def initialize(id)
      setup(id)
    end

    def mark_as_committed
      self.version += uncommitted_events.size
      uncommitted_events.clear
    end

    protected

    def apply(event_class, *args)
      event = event_class.new(*args)
      internal_apply(event, true)
    end

    attr_writer :version

    private

    def setup(id)
      @id = id
      @uncommitted_events = []
      @version = -1
    end

    def internal_apply(event, is_new)
      self.class.handlers_for(event.class).each { |handler| instance_exec(event, &handler) }
      uncommitted_events << event if is_new
    end
  end
end
