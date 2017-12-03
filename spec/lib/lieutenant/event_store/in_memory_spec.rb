# frozen_string_literal: true

RSpec.describe Lieutenant::EventStore::InMemory do
  let(:instance) { described_class.new }

  describe '.new' do
    subject { instance }

    it 'does not raise exceptions' do
      expect { subject }.to_not raise_error
    end
  end

  describe '#persist' do
    subject { instance.persist(events) }
    let(:events) { [event] }
    let(:event) { double(:event, aggregate_id: 1) }

    it 'checks events aggregate id' do
      expect(event).to receive(:aggregate_id)
      subject
    end
  end

  describe '#event_stream_for' do
    subject { instance.event_stream_for(aggregate_id) }
    let(:aggregate_id) { 1 }

    context 'when no event was persisted to aggregate id' do
      it { is_expected.to be_nil }
    end

    context 'when there are events to aggregate id' do
      let(:event_a) { double(:event, aggregate_id: aggregate_id, sequence_number: 0) }
      let(:event_b) { double(:event, aggregate_id: aggregate_id, sequence_number: 1) }

      before do
        instance.persist([event_a, event_b])
      end

      it 'returns an enumerator' do
        is_expected.to be_a(Enumerator)
      end

      it 'yields each event' do
        expect(subject.next).to be(event_a)
        expect(subject.next).to be(event_b)
      end
    end
  end

  describe '#aggregate_sequence_number' do
    subject { instance.aggregate_sequence_number(aggregate_id) }
    let(:aggregate_id) { 1 }

    context 'when no event was persisted to aggregate id' do
      it { is_expected.to eq(-1) }
    end

    context 'when there are events to aggregate id' do
      before do
        instance.persist([
          double(:event, aggregate_id: aggregate_id, sequence_number: 0),
          double(:event, aggregate_id: aggregate_id, sequence_number: 1)
        ])
      end

      it 'returns last sequence_number' do
        is_expected.to eq(1)
      end
    end
  end

  describe '#transaction' do
    it 'yields' do
      expect { |b| instance.transaction(&b) }.to yield_control
    end
  end
end
