# frozen_string_literal: true

module Lieutenant
  # Helper to define messages with validation
  module Message
    def self.included(base)
      base.instance_eval do
        extend Lieutenant::Message::ClassMethods
        include ActiveModel::Validations
      end
    end

    # Define common class methods to commands
    module ClassMethods
      def with(params)
        new.tap do |command|
          params.each_pair do |key, value|
            begin
              command.send("#{key}=", value)
            rescue NoMethodError # rubocop:disable Lint/HandleExceptions
              # DO NOTHING
            end
          end
        end
      end
    end
  end
end
