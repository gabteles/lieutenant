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
      allow(store).to receive(:persist)
      allow(event_bus).to receive(:publish)
    end

    it 'persists events by passing them to store' do
      expect(store).to receive(:persist).with(events)
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

  describe '#transaction' do
    subject { described_class.new(store, event_bus).transaction(&block) }
    let(:block) { -> {} }

    it 'repasses transaction block to implementation' do
      expect(store).to receive(:transaction).with(no_args) do |*, &received_block|
        expect(received_block).to be(block)
      end

      subject
    end
  end
end
