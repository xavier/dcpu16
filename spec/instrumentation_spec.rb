
require 'spec_helper'

describe DCPU16::Instrumentation do

  let(:cpu)      { DCPU16::CPU.new }
  let(:observer) { mock() }

  describe "#on" do

    it "registers a callback for a given event" do
      cpu.on(:after_step) {}
      cpu.instrumentation_callbacks[:after_step].should have(1).item
    end

    it "registers a callback for multiple events" do
      cpu.on(:before_step, :after_step) {}
      cpu.instrumentation_callbacks[:before_step].should have(1).item
      cpu.instrumentation_callbacks[:after_step].should have(1).item
    end

    it "registers multiple callbacks for a single event" do
      cpu.on(:before_step) {}
      cpu.on(:before_step) {}
      cpu.instrumentation_callbacks[:before_step].should have(2).items
    end

    it "raises an exception when given an invalid event symbol" do
      expect {
        cpu.on(:bogus) {}
      }.to raise_error(ArgumentError, /bogus/)
    end

  end

  context "when a callback has been registered" do

    before do
      cpu.on(:after_step) { |args| observer.after_step(*args) }
    end

    describe '#instrumentation_callbacks_for' do

      it "returns a collection of callbacks" do
        cpu.instrumentation_callbacks_for(:after_step).should_not be_empty
      end

      it "returns an empty collection if the event has no callbacks" do
        cpu.instrumentation_callbacks_for(:before_step).should be_empty
      end

      it "raises an exception when given an invalid event symbol" do
        expect {
          cpu.instrumentation_callbacks_for(:bogus)
        }.to raise_error(ArgumentError, /bogus/)
      end

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