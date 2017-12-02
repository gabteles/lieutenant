# frozen_string_literal: true

RSpec.describe Lieutenant::Command do
  subject { base_class }

  let(:base_class) do
    Class.new do
      include Lieutenant::Command
    end
  end

  it 'is a message' do
    is_expected.to be < Lieutenant::Message
  end
end
