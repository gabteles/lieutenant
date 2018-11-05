# frozen_string_literal: true

module Lieutenant
  # Representation of an aggregate root
  module Aggregate
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Define common class methods to aggregates
    module ClassMethods
      def load_from_history(id, history)
        allocate.send(:load_from_history, id, history)
      end

      def on(*event_classes, &handler)
        event_classes.each do |event_class|
          unless event_class < Event
            raise(Lieutenant::Exception, "Expected #{event_class} to include Lieutenant::Event")
          end

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

    def mark_as_committed
      self.version += uncommitted_events.size
      uncommitted_events.clear
    end

    protected

    def apply(event_class, **params)
      event = event_class.with(**params)
      event.setup(@id, @version + uncommitted_events.size + 1)
      internal_apply(event)
      uncommitted_events << event
    end

    attr_writer :version

    private

    def setup(id)
      @id = id
      @uncommitted_events = []
      @version = -1
    end

    def load_from_history(id, history)
      setup(id)

      history.each do |event|
        internal_apply(event)
        self.version += 1
      end

      self
    end

    def internal_apply(event)
      raise(Lieutenant::Exception, "Invalid event: #{event.inspect}") unless event.valid?

      self.class.handlers_for(event.class).each { |handler| instance_exec(event, &handler) }
    end
  end
end
