require 'spec_helper'

describe "Values" do

  let(:cpu) { mock() }

  describe DCPU16::RegisterValue do

    let(:value) { DCPU16::RegisterValue.new(cpu, :X) }

    describe "#get" do

      it "reads the value from a CPU register" do
        cpu.should_receive(:regget).with(:X).and_return(0x1234)
        value.get.should == 0x1234
      end

    end

    describe "#set" do

      it "sets the value into a CPU register" do
        cpu.should_receive(:regset).with(:X, 0x4567)
        value.set(0x4567)
      end

    end

    describe "#to_s" do

      it "includes the register" do
        value.to_s.should =~ /RegisterValue: X/
      end

    end

  end

  describe DCPU16::StackValue do

    let(:value) { DCPU16::StackValue.new(cpu) }

    describe "#get" do

      it "pops the value off the stack" do
        cpu.should_receive(:pop).and_return(0x1234)
        value.get.should == 0x1234
      end

      it "is idempotent" do
        cpu.should_receive(:pop).once.and_return(0x1234)
        2.times { value.get.should == 0x1234 }
      end

    end

    describe "#set" do

      it "pushes the value on the stack" do
        cpu.should_receive(:push).with(0x4567)
        value.set(0x4567)
      end

    end

    describe "#to_s" do

      it "says it's a StackValue" do
        value.to_s.should =~ /StackValue/
      end

    end

  end

  describe DCPU16::ImmutableStackValue do

    let(:value) { DCPU16::ImmutableStackValue.new(cpu) }

    describe "#get" do

      it "pops the value off the stack" do
        cpu.should_receive(:peek).and_return(0x1234)
        value.get.should == 0x1234
      end

    end

    describe "#set" do

      it "does nothing" do
        expect {
          value.set(0x4567)
        }.not_to raise_error
      end

    end

    describe "#to_s" do

      it "says it's an ImmutableStackValue" do
        value.to_s.should =~ /StackValue/
      end

    end

  end

  describe DCPU16::LiteralValue do

    let(:value) { DCPU16::LiteralValue.new(cpu, 0x1234) }

    describe "#get" do

      it "returns the given literal" do
        value.get.should == 0x1234
      end

    end

    describe "#set" do

      it "does nothing" do
        expect {
          value.set(0x4567)
        }.not_to raise_error
      end

    end

    describe "#to_s" do

      it "includes the literal" do
        value.to_s.should =~ /LiteralValue: 0x1234/
      end

    end

  end

  describe DCPU16::AddressValue do

    let(:memory) { mock() }
    let(:cpu)    { mock(:memory => memory) }
    let(:value)  { DCPU16::AddressValue.new(cpu, 0x4321) }


    describe "#get" do

      it "reads the value at the given memory address" do
        memory.should_receive(:[]).with(0x4321).and_return(0x1234)
        value.get.should == 0x1234
      end

    end

    describe "#set" do

      it "stores the value at the given memory address" do
        memory.should_receive(:[]=).with(0x4321, 0x4567)
        value.set(0x4567)
      end

    end

    describe "#to_s" do

      it "includes the address" do
        value.to_s.should =~ /AddressValue: \[0x4321\]/
      end

    end

  end

end