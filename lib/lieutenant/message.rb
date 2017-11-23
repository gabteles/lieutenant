# frozen_string_literal: true

module Lieutenant
  # Helper to define messages with validation
  module Message
    def self.included(base)
      base.extend(ClassMethods)
      base.include(ActiveModel::Validations)
    end

    # Define common class methods to commands
    module ClassMethods
      def with(params)
        new.tap do |command|
          params.each_pair { |key, value| command.send("#{key}=", value) }
        end
      end
    end
  end
end
