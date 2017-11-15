# frozen_string_literal: true

module Lieutenant
  module Event
    attr_accessor :aggregate_id, :sequence_number

    def initialize(data)
      @data = data
    end
  end
end
