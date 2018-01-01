# frozen_string_literal: true

RSpec.describe Lieutenant::CommandSender do
  let(:aggregate_repository) { double(:aggregate_repository, unit_of_work: repository_uow) }
  let(:repository_uow) { double(:repository_uow) }
  let(:instance) { described_class.new(aggregate_repository) }

  before do
    allow(repository_uow).to receive(:execute).and_yield(repository_uow)
  end

  describe '.new' do
    subject { instance }

    it 'does not raises exception' do
      expect { subject }.to_not raise_error
    end
  end

  describe '#dispatch' do
    subject { instance.dispatch(command) }
    let(:command_class) { double(:command_class) }
    let(:command) { double(:command, class: command_class, valid?: valid) }
    let(:valid) { true }
    let(:handler) { double(:handler) }

    before { instance.register(command_class, handler) }

    it 'calls handler with repository unit of work and command' do
      expect(handler).to receive(:call).with(repository_uow, command)
      subject
    end

    context 'when the command is invalid' do
      let(:valid) { false }

      it 'raises error' do
        expect { subject }.to raise_error(Lieutenant::Exception)
      end
    end

    context 'when there is no registered handler to the command' do
      let(:command) { double(:command) }

      it 'raises error' do
        expect { subject }.to raise_error(Lieutenant::Exception::NoRegisteredHandler)
      end
    end
  end

  describe '#register' do
    subject { instance.register(command_class, handler) }
    let(:command_class) { double(:command_class) }
    let(:handler) { -> {} }

    it 'does not raises exception' do
      expect { subject }.to_not raise_error
    end

    context 'when the handler is already registered' do
      let(:command_class_b) { double(:command_class_b) }
      before { instance.register(command_class_b, handler) }

      it 'does not raises exception' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when the command class already has a handler' do
      before { instance.register(command_class, handler) }

      it 'does raises exception' do
        expect { subject }.to raise_error(Lieutenant::Exception)
      end
    end
  end
end
