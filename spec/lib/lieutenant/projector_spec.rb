# frozen_string_literal: true

RSpec.describe Lieutenant::Projector do
  subject { base_class }

  let(:base_class) do
    Class.new do
      include Lieutenant::Projector
    end
  end

  describe '.on' do
    let(:instance) { base_class.new.tap { |inst| inst.send(:initialize_projector) } }

    shared_examples 'subscribing to event bus when initialize new instances' do
      it 'subscribes to event bus when initializing new instances' do
        subject
        expect(Lieutenant.config.event_bus).to receive(:subscribe).with(TestEvent)
        instance
      end
    end

    context 'when called with block' do
      subject { base_class.on(TestEvent, &block) }
      let(:block) { -> {} }

      it_behaves_like 'subscribing to event bus when initialize new instances'

      it 'calls block when event is sent' do
        expect do |blk|
          base_class.on(TestEvent, &blk)
          instance
          Lieutenant.config.event_bus.publish(TestEvent.new)
        end.to yield_control
      end
    end

    context 'when called with method parameter' do
      subject { base_class.on(TestEvent, to: :dummy) }

      it_behaves_like 'subscribing to event bus when initialize new instances'

      it 'calls method when event is sent' do
        subject
        expect(instance).to receive(:dummy)
        Lieutenant.config.event_bus.publish(TestEvent.new)
      end
    end
  end
end
