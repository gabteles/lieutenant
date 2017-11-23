# frozen_string_literal: true

module Lieutenant
  # Manages the repository logic to persist and retrieve aggregates
  class AggregateRepository
    def initialize(store)
      @store = store
    end

    def unit_of_work
      AggregateRepositoryUnit.new(store)
    end

    private

    attr_reader :store

    # Represents one unit of work of the repository to grant independence
    # between multiple concurrent commands being handled
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

      def execute
        yield(self)
        commit
        # rescue Exception::ConcurrencyConflict
        #   TODO: implement command retry policy
      ensure
        clean
      end

      private

      def commit
        aggregates.each_value(&method(:commit_aggregate))
        clean
      end

      def clean
        aggregates.clear
      end

      attr_reader :aggregates
      attr_reader :store

      def commit_aggregate(aggregate)
        store.save_events(aggregate.id, aggregate.uncommitted_events, aggregate.version)
        aggregate.mark_as_committed
      end
    end
  end
end
