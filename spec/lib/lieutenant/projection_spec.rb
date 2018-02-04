# frozen_string_literal: true

RSpec.describe Lieutenant::Projection do
  subject { base_class }

  let(:base_class) do
    Class.new do
      include Lieutenant::Projection
    end
  end

  describe '.on' do
    subject { base_class.on(event_class, &block) }
    let(:event_class) { double(:event_class) }
    let(:block) { -> {} }

    it 'subscribes to event bus' do
      expect(Lieutenant.config.event_bus).to receive(:subscribe).with(event_class)
      subject
    end
  end
end
