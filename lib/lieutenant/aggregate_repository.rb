# frozen_string_literal: true

module Lieutenant
  class AggregateRepository
    def unit_of_work
      AggregateRepositoryUnit.new(Lieutenant.config.event_store)
    end

    class AggregateRepositoryUnit
      def initialize(store)
        @aggregates = {}
        @store = store
      end

      def add_aggregate(aggregate)
        aggregates[aggregate.id] = aggregate
      end

      def load_aggregate(aggregate_type, aggregate_id)
        aggregates[aggregate_id] ||= begin
          history = store.event_stream_for(aggregate_id)
          aggregate_type.load_from_history(aggregate_id, history)
        end
      end

      def commit
        aggregates.each_value do |aggregate|
          store.save_events(aggregate.id, aggregate.uncommitted_events, aggregate.version)
          aggregate.mark_as_committed
        end

        clean
      end

      def clean
        aggregates.clear
      end

      private

      attr_reader :aggregates
      attr_reader :store
    end
  end
end
