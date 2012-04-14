require 'spec_helper'

describe DCPU16::InstructionsTable do

  let(:cpu) { mock(:tick! => nil, :do_nothing => nil) }

  let(:instruction_table) do
    DCPU16::InstructionsTable.build do
      implement(0x123, "NOP", 3) { |cpu, a, b| cpu.do_nothing(a, b) }
    end
  end

  describe "#lookup" do

    it "returns the instruction for the corresponding opcode" do
      instruction_table.lookup(0x123).mnemonic.should == "NOP"
    end

    it "raises an exception if the opcode is unknown" do
      expect {
        instruction_table.lookup(0x12cd)
      }.to raise_error(DCPU16::UnexpectedOpcode, /0x12cd/)
    end

  end

  describe DCPU16::InstructionsTable::Instruction do

    let(:instruction) { instruction_table.lookup(0x123) }

    context "when executed" do

      it "delegates the execution to its block" do
        cpu.should_receive(:do_nothing).with(:a, :b)
        instruction.execute(cpu, :a, :b)
      end

      it "ticks its cost of CPU cycles" do
        cpu.should_receive(:tick!).with(3)
        instruction.execute(cpu, :a, :b)
      end

    end

  end


end