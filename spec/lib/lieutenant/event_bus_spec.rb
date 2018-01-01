# frozen_string_literal: true

RSpec.describe Lieutenant::EventBus do
  let(:instance) { described_class.new }

  describe '.new' do
    subject { instance }

    it 'does not raise exceptions' do
      expect { subject }.to_not raise_error
    end
  end

  describe '#subscribe' do
    subject { instance.subscribe(*event_classes, &handler) }
    let(:event_classes) { [double(:event_class_a)] }
    let(:handler) { -> {} }

    it 'does not raise exceptions' do
      expect { subject }.to_not raise_error
    end

    context 'when subscribing with different handlers to same event class' do
      before { instance.subscribe(*event_classes, &handler_b) }
      let(:handler_b) { -> {} }

      it 'does not raise exceptions' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when subscribing to different event classes with same handler' do
      before { instance.subscribe(double(:event_class_b), &handler) }

      it 'does not raise exceptions' do
        expect { subject }.to_not raise_error
      end
    end
  end

  describe '#publish' do
    subject { instance.publish(event) }
    let(:event) { double(:event, class: event_class_a) }
    let(:event_class_a) { double(:event_class_a) }
    let(:event_class_b) { double(:event_class_b) }

    context 'when there are no registered subscribers to the event class' do
      before { instance.subscribe(event_class_b, &handler) }
      let(:handler) { -> {} }

      it 'does not call other handlers' do
        expect(handler).to_not receive(:call)
        subject
      end
    end
  end
end
