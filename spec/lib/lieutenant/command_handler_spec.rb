# frozen_string_literal: true

RSpec.describe Lieutenant::CommandHandler do
  subject { base_class }

  let(:base_class) do
    Class.new do
      include Lieutenant::CommandHandler
    end
  end

  describe '.on' do
    subject { base_class.on(command_class, &block) }
    let(:command_class) { double(:command_class) }
    let(:block) { ->() {} }

    it 'registers to command sender' do
      expect(Lieutenant.config.command_sender).to receive(:register).with(command_class, block)
      subject
    end
  end
end
