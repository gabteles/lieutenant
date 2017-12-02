# frozen_string_literal: true

RSpec.describe Lieutenant::Message do
  subject do
    Class.new do
      include Lieutenant::Message
    end
  end

  it 'includes ActiveModel::Validations' do
    is_expected.to be < ActiveModel::Validations
  end

  describe '.with' do
    let(:target_class) do
      Class.new do
        include Lieutenant::Message
        attr_accessor :foo
      end
    end

    subject { target_class.with(params) }

    let(:params) { { foo: 1 } }

    it 'creates a new instance' do
      expect(target_class).to receive(:new).and_call_original
      subject
    end

    it "sets it's attributes" do
      expect_any_instance_of(target_class).to receive(:foo=).with(1)
      subject
    end

    context 'when there are unknown keys' do
      let(:params) { { foo: 1, bar: 2 } }

      it 'ignores them' do
        expect { subject }.to_not raise_error
      end
    end
  end
end
