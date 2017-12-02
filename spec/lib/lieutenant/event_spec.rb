# frozen_string_literal: true

RSpec.describe Lieutenant::Event do
  subject { base_class }

  let(:base_class) do
    Class.new do
      include Lieutenant::Event
    end
  end

  it 'is a message' do
    is_expected.to be < Lieutenant::Message
  end

  describe '#aggregate_id' do
    subject { base_class.new.aggregate_id }

    it 'does not raise exceptions' do
      expect { subject }.to_not raise_exception
    end
  end

  describe '#sequence_number' do
    subject { base_class.new.sequence_number }

    it 'does not raise exceptions' do
      expect { subject }.to_not raise_exception
    end
  end

  describe '#prepare' do
    subject { instance.prepare(aggregate_id, sequence_number) }
    let(:instance) { base_class.new }
    let(:aggregate_id) { 1 }
    let(:sequence_number) { 1 }

    it 'changes aggregate_id' do
      expect { subject }.to change { instance.aggregate_id }.from(nil).to(aggregate_id)
    end

    it 'changes sequence_number' do
      expect { subject }.to change { instance.sequence_number }.from(nil).to(sequence_number)
    end
  end
end
