
require 'spec_helper'

describe DCPU16::Instrumentation do

  let(:cpu)      { DCPU16::CPU.new }

  class Observer

    include DCPU16::Instrumentation::Observer

    def after_step(*args)
    end

  end

  let(:observer) { Observer.new }

  describe "Observer module" do

    describe "#update" do

      it "dispatches the call to the method if it exists" do
        observer.should_receive(:after_step)
        observer.update(:after_step)
      end

      it "does nothing if the method does not exists" do
        expect {
          observer.update(:some_undefined_method)
        }.not_to raise_error
      end

    end

  end

  context "when an observer has been added" do

    before do
      cpu.add_observer(observer)
    end

    describe '#fire_callback' do

      it "invokes the callbacks for the given event with no argument" do
        observer.should_receive(:after_step)
        cpu.fire_callback(:after_step)
      end

      it "invokes the callbacks for the given event and passes one argument" do
        observer.should_receive(:after_step).with(cpu)
        cpu.fire_callback(:after_step, cpu)
      end

      it "invokes the callbacks for the given event and passes multiple arguments" do
        observer.should_receive(:after_step).with(cpu, "ABC", 123)
        cpu.fire_callback(:after_step, cpu, "ABC", 123)
      end

      it "does nothing if the event has no callback" do
        observer.should_not_receive(:after_step)
        cpu.fire_callback(:before_step)
      end

    end

  end

end