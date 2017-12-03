# frozen_string_literal: true

RSpec.describe Lieutenant::Aggregate do
  let(:base_class) do
    Class.new do
      include Lieutenant::Aggregate
    end
  end

  describe '.load_from_history' do
    subject { base_class.load_from_history(id, history) }
    let(:id) { 1 }
    let(:history) { [double(:event, valid?: true)] }

    it 'creates an aggregate with desired id' do
      expect(subject.id).to eq(id)
    end

    it 'creates an aggregate without uncommited changes' do
      expect(subject.uncommitted_events).to be_empty
    end

    it 'creates an aggregate with the right version' do
      expect(subject.version).to eq(history.size - 1)
    end
  end

  describe '.on' do
    subject { base_class.on(*event_classes, &handler) }
    let(:event_subclass_a) do
      Class.new do
        include Lieutenant::Event
      end
    end
    let(:event_subclass_b) { event_subclass_a.clone }
    let(:not_event_subclass) { Class.new {} }
    let(:event_classes) { [event_subclass_a] }
    let(:handler) { ->() {} }

    it 'does not raise exceptions' do
      expect { subject }.to_not raise_error
    end

    context 'when subscribing to a class that does not include Lieutenant::Event' do
      subject { base_class.on(not_event_subclass, &handler) }

      it 'does raise exception' do
        expect { subject }.to raise_error(Lieutenant::Exception)
      end
    end

    context 'when subscribing with different handlers to same event class' do
      before { base_class.on(*event_classes, &handler_b) }
      let(:handler_b) { ->() {} }

      it 'does not raise exceptions' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when subscribing to different event classes with same handler' do
      before { base_class.on(event_subclass_b, &handler) }

      it 'does not raise exceptions' do
        expect { subject }.to_not raise_error
      end
    end
  end

  describe '.handlers_for' do
    subject { base_class.handlers_for(event_class) }
    let(:event_class) { double(:event_class) }

    context 'when event class has no registered handler' do
      it { is_expected.to be_a(Array) }
      it { is_expected.to be_empty }
    end

    context 'when event class has registered handlers' do
      let(:handler) { ->() {} }

      before do
        allow(event_class).to receive(:<).and_return(true)
        base_class.on(event_class, &handler)
      end

      it { is_expected.to be_a(Array) }
      it 'includes registered handler' do
        is_expected.to eq([handler])
      end
    end
  end

  describe '#mark_as_committed' do
    let(:instance) { base_class.new }
    subject { instance.mark_as_committed }

    before do
      instance.send(:setup, 1)
    end

    context 'when there is no uncommited event' do
      it 'does not change the version' do
        expect { subject }.to_not change(instance, :version)
      end

      it 'does not change uncommited events' do
        expect { subject }.to_not change(instance, :uncommitted_events)
      end
    end

    context 'when there are uncommited events' do
      let(:mock_event_class) { double(:event_class) }
      let(:event) { double(:event, valid?: true) }

      before do
        allow(mock_event_class).to receive(:with).and_return(event)
        instance.send(:apply, mock_event_class)
        instance.send(:apply, mock_event_class)
      end

      it 'increases the version' do
        expect { subject }.to change(instance, :version).from(-1).to(1)
      end

      it 'does clear uncommited events' do
        expect { subject }.to change(instance, :uncommitted_events).to([])
      end
    end
  end

  describe '#apply' do
    let(:instance) { base_class.new }
    subject { instance.send(:apply, event_class, **params) }
    let(:event_class) { double(:event_class) }
    let(:event) { double(:event, valid?: true) }
    let(:params) { { foo: :bar } }

    before do
      instance.send(:setup, 1)
      allow(event_class).to receive(:with).and_return(event)
    end

    it "instantiates event with `.with' method on event class" do
      expect(event_class).to receive(:with).with(params).and_return(event)
      subject
    end

    it 'does not increase version' do
      expect { subject }.to_not change(instance, :version)
    end

    it 'adds the event to uncommited events' do
      expect { subject }.to change(instance, :uncommitted_events).from([]).to([event])
    end
  end
end
