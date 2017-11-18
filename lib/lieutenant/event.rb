# frozen_string_literal: true

module Lieutenant
  # The basic interface to register the aggregates events
  module Event
    attr_accessor :aggregate_id, :sequence_number
    attr_accessor :data # TODO: remove

    def initialize(data = {})
      @data = data
    end
  end
end
