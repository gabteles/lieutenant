# frozen_string_literal: true

RSpec.describe Lieutenant::AggregateRepository do
  let(:instance) { described_class.new(store) }
  let(:store) { double(:store) }

  describe '.new' do
    subject { instance }

    it 'does not raise exceptions' do
      expect { subject }.to_not raise_error
    end
  end

  describe '.unit_of_work' do
    subject { instance.unit_of_work }

    it { is_expected.to be_a(described_class::AggregateRepositoryUnit) }
  end

  describe described_class::AggregateRepositoryUnit do
    let(:instance) { described_class.new(store) }
    let(:store) { double(:store) }

    describe '.new' do
      subject { instance }

      it 'does not raise exceptions' do
        expect { subject }.to_not raise_error
      end
    end

    describe '#add_aggregate' do
      subject { instance.add_aggregate(aggregate) }
      let(:aggregate) { double(:aggregate, id: 1) }

      it "checks aggregate's id" do
        expect(aggregate).to receive(:id)
        subject
      end
    end

    describe '#load_aggregate' do
      subject { instance.load_aggregate(type, id) }
      let(:type) { double(:aggregate_type) }
      let(:id) { 1 }
      let(:aggregate) { double(:aggregate) }
      let(:stream) { double(:stream) }

      before do
        allow(store).to receive(:event_stream_for).and_return(stream)
        allow(type).to receive(:load_from_history).and_return(aggregate)
      end

      it 'loads stream from store' do
        expect(store).to receive(:event_stream_for).with(id)
        subject
      end

      it "rebuilds aggregate's state from event stream" do
        expect(type).to receive(:load_from_history).with(id, stream)
        subject
      end

      it 'returns loaded aggregate' do
        is_expected.to be(aggregate)
      end

      context 'when aggregate already was loaded in same unit' do
        let!(:previously_loaded_instance) { instance.load_aggregate(type, id) }

        it 'does not consult store' do
          expect(store).to_not receive(:event_stream_for)
          subject
        end

        it 'returns loaded instance' do
          is_expected.to be(previously_loaded_instance)
        end
      end
    end

    describe '#execute' do
      context 'when block execution does not create any aggregate' do
        it 'does not call store to persist events' do
          expect(store).to_not receive(:save_events)
          instance.execute {}
        end
      end

      context 'when block execution creates an aggregate' do
        let(:aggregate) { double(:aggregate, id: aggregate_id, uncommitted_events: events, version: version) }
        let(:aggregate_id) { 1 }
        let(:events) { [] }
        let(:version) { -1 }

        before do
          allow(store).to receive(:save_events)
          allow(store).to receive(:transaction).and_yield
          allow(aggregate).to receive(:mark_as_committed)
        end

        it 'persists events using store inside a transaction' do
          expect(store).to receive(:transaction)
          expect(store).to receive(:save_events).with(aggregate_id, events, version)
          instance.execute { |repository| repository.add_aggregate(aggregate) }
        end

        it 'mark aggregate as commited' do
          expect(aggregate).to receive(:mark_as_committed)
          instance.execute { |repository| repository.add_aggregate(aggregate) }
        end

        context 'when block fails and retry' do
          it 'persist events only once' do
            expect(store).to receive(:save_events).once

            begin
              instance.execute do |repository|
                repository.add_aggregate(aggregate)
                raise
              end
            rescue StandardError
              instance.execute { |repository| repository.add_aggregate(aggregate) }
            end
          end
        end
      end
    end
  end
end
