# frozen_string_literal: true

RSpec.describe Lieutenant::EventStore do
  let(:store) { double(:store) }
  let(:event_bus) { double(:event_bus) }

  describe '.new' do
    subject { described_class.new(store, event_bus) }

    it 'does not raise exceptions' do
      expect { subject }.to_not raise_error
    end
  end

  describe '#save_events' do
    subject { described_class.new(store, event_bus).save_events(aggregage_id, events, expected_version) }
    let(:aggregage_id) { 1 }
    let(:events) { [event_a, event_b] }
    let(:event_a) { double(:event) }
    let(:event_b) { double(:event) }
    let(:expected_version) { -1 }

    before do
      allow(store).to receive(:aggregate_sequence_number).and_return(expected_version)
      allow(store).to receive(:around_persistence).and_yield
      allow(store).to receive(:persist)
      allow(event_a).to receive(:prepare)
      allow(event_b).to receive(:prepare)
      allow(event_bus).to receive(:publish)
    end

    it 'prepares each event to persist' do
      expect(event_a).to receive(:prepare).with(aggregage_id, 0)
      expect(event_b).to receive(:prepare).with(aggregage_id, 1)
      subject
    end

    it 'persists each event by passing them to store inside a transaction' do
      expect(store).to receive(:around_persistence).and_yield
      expect(store).to receive(:persist).with(event_a)
      expect(store).to receive(:persist).with(event_b)
      subject
    end

    it 'publishes each event to the event bus' do
      expect(event_bus).to receive(:publish).with(event_a)
      expect(event_bus).to receive(:publish).with(event_b)
      subject
    end

    context 'when expected version does not match current version' do
      before { allow(store).to receive(:aggregate_sequence_number).with(aggregage_id).and_return(1) }

      it 'raises concurrency conflict' do
        expect { subject }.to raise_error(Lieutenant::Exception::ConcurrencyConflict)
      end
    end
  end

  describe '#event_stream_for' do
    subject { described_class.new(store, event_bus).event_stream_for(aggregage_id) }
    let(:aggregage_id) { 1 }

    it "calls store's #event_stream_for with receved parameter" do
      expect(store).to receive(:event_stream_for).with(aggregage_id).and_return([])
      subject
    end

    context 'when store returns a truthy value' do
      before { allow(store).to receive(:event_stream_for).and_return(stream) }
      let(:stream) { Enumerator.new {} }

      it 'returns stream from store' do
        is_expected.to be(stream)
      end
    end

    context 'when store returns a falsey value' do
      before { allow(store).to receive(:event_stream_for).and_return(stream) }
      let(:stream) { nil }

      it 'raises aggregate not found exception' do
        expect { subject }.to raise_error(Lieutenant::Exception::AggregateNotFound)
      end
    end
  end
end
