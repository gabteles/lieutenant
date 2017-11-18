# frozen_string_literal: true

RSpec.describe Lieutenant do
  describe '.config' do
    context 'when no params are given' do
      it 'returns configuration' do
        expect(described_class.config).to be_a(Lieutenant::Config)
      end
    end

    context 'when a block is given' do
      it 'yields configuration' do
        expect { |b| described_class.config(&b) }.to yield_with_args(Lieutenant::Config)
      end
    end
  end
end
