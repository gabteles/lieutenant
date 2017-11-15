# frozen_string_literal: true

module Lieutenant
  module Aggregate
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def load_from_history(history)
        allocate.tap do |aggregate|
          history.each { |event| aggregate.send(:internal_apply, event, false) }
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
    attr_reader :uncommited_events
    attr_reader :version

    def initialize(id)
      @id = id
      @uncommited_events = []
      @version = -1
    end

    def mark_as_commited
      self.version += uncommited_events.size
      uncommited_events.clear
    end

    protected

    def apply(event_class, *args)
      event = event_class.new(args)
      internal_apply(event, true)
    end

    attr_writer :version

    private

    def internal_apply(event, is_new)
      self.class.handlers_for(event.class).each { |handler| instance_exec(event, &handler) }
      uncommited_events << event if is_new
    end
  end
end
