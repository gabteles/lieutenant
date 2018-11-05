# frozen_string_literal: true

RSpec.describe Lieutenant::Projector do
  subject { base_class }

  let(:base_class) do
    Class.new do
      include Lieutenant::Projector
    end
  end

  let(:instance) { base_class.new }

  describe '.on' do
    shared_examples 'subscribing to event bus when initialize new instances' do
      it 'subscribes to event bus when initializing new instances' do
        expect(Lieutenant.config.event_bus).to receive(:subscribe).with(TestEvent)
        instance
      end
    end

    context 'when called with block' do
      before { base_class.on(TestEvent) {} }

      it_behaves_like 'subscribing to event bus when initialize new instances'

      it 'calls block when event is sent' do
        expect do |blk|
          base_class.on(TestEvent, &blk)
          instance
          Lieutenant.config.event_bus.publish(TestEvent.new)
        end.to yield_control
      end
    end

    context 'when called with method parameter' do
      before { base_class.on(TestEvent, handler: :dummy) }

      it_behaves_like 'subscribing to event bus when initialize new instances'

      it 'calls method when event is sent' do
        expect(instance).to receive(:dummy)
        Lieutenant.config.event_bus.publish(TestEvent.new)
      end
    end
  end

  describe '#initialize_projector' do
    before { base_class.on(TestEvent) }

    context 'when base class overrides initialize without calling initialize_project' do
      let(:base_class) do
        Class.new do
          include Lieutenant::Projector
          def initialize; end
        end
      end

      it 'will not automatically subscribe to event bus in any configuration' do
        expect_any_instance_of(Lieutenant::Config).to_not receive(:event_bus)
        instance
      end
    end

    context 'when base class does not override initialize' do
      context 'and passing a parameter to it' do
        let(:instance) { base_class.new(config) }
        let(:config) { Lieutenant::Config.new }

        it 'will use as lieutenant configuration' do
          expect(config).to receive(:event_bus).and_return(double(subscribe: nil))
          instance
        end
      end

      context 'and passing no parameters to it' do
        it 'will use default lieutenant configuration' do
          expect(Lieutenant.config).to receive(:event_bus).and_return(double(subscribe: nil))
          instance
        end
      end
    end
  end
end
