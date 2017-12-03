# frozen_string_literal: true

module Lieutenant
  # The basic interface to register the aggregates events
  module Event
    def self.included(base)
      base.instance_eval do
        include Lieutenant::Message
      end
    end

    attr_reader :aggregate_id, :sequence_number

    def prepare(aggregate_id, sequence_number)
      @aggregate_id = aggregate_id
      @sequence_number = sequence_number
    end
  end
end
