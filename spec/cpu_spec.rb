
require 'spec_helper'

describe DCPU16::CPU do

	let(:cpu) { DCPU16::CPU.new }

	describe "#tick!" do

		it "increases the number of cycles by 1 by default" do
			expect {
				cpu.tick!
			}.to change(cpu, :cycles).by(1)
		end

		it "increases the number of cycles by the given number" do
			expect {
				cpu.tick!(2)
			}.to change(cpu, :cycles).by(2)
		end

	end

	describe "#fetch_next_word" do

		before do
			cpu.stub!(:memory => [0x123, 0x456, 0x789])
		end

		it "returns the word currently referenced by the program counter" do
			cpu.registers[:PC] = 1
			cpu.fetch_next_word.should == 0x456
		end

		it "advances the program counter" do
			expect {
				cpu.fetch_next_word
			}.to change { cpu.registers[:PC] }.by(1)
		end

	end

	describe "#decode_instruction" do

		# SET I, 10
		let(:decoded) { cpu.decode_instruction(0xa861) }

		it "returns a triplet" do
			decoded.size.should == 3
		end

		it "extracts the opcode" do
			decoded[0].should == 0x01 # SET
		end

		it "extracts the first operand (a)" do
			decoded[1].should == 0x06 # I
		end

		it "extracts the second operand (b)" do
			decoded[2].should == 0x2a # Literal 10
		end

	end

	describe "#make_value" do

		it "raises an exception if the value code is unknown" do
			expect {
				cpu.make_value(0x123123)
			}.to raise_error(DCPU16::UnexpectedValue, /0x123123/)
		end

		DCPU16::CPU::VALUE_REGISTERS_MAP.each_with_index do |reg, idx|

			it "makes a RegisterValue for #{reg.to_s} when given #{idx.to_hex}" do
				cpu.make_value(idx).register.should == reg
			end

		end

		{
			:SP => 0x1b,
			:PC => 0x1c,
			:O  => 0x1d,
		}.each do |reg, bitmask|

			it "makes a RegisterValue for #{reg.to_s} when given #{bitmask.to_hex}" do
				cpu.make_value(bitmask).register.should == reg
			end

		end

		DCPU16::CPU::VALUE_REGISTERS_MAP.each_with_index do |reg, idx|

			bitmask = idx | 0x08

			it "makes a AddressValue based on the contents of #{reg.to_s} when given #{bitmask.to_hex}" do
				cpu.registers[reg] = 0x1234
				cpu.make_value(bitmask).offset.should == 0x1234
			end

		end

		(0x20..0x3f).each do |bitmask|

			it "makes a LiteralValue for #{bitmask.to_hex}" do
				cpu.make_value(bitmask).value.should == (bitmask - 0x20)
			end

		end

	end

	describe "Microcode" do

		describe "Registers manipulation" do

			before do
				cpu.registers[:X] = 0x123
				cpu.registers[:Y] = 0x456
			end

			describe "#regget" do

				it "returns the current value of the register" do
					cpu.regget(:X).should == 0x123
				end

			end

			describe "#regset" do

				it "returns the current value of the register" do
					cpu.regset(:X, 0x789)
					cpu.registers[:X].should == 0x789
				end

			end

			describe "#reginc" do

				it "increments the value of the register by 1" do
					expect {
						cpu.reginc(:X)
					}.to change { cpu.registers[:X] }.by(1)
				end

			end

			describe "#regdec" do

				it "decrements the value of the register by 1" do
					expect {
						cpu.regdec(:X)
					}.to change { cpu.registers[:X] }.by(-1)
				end

			end


			describe "#retain_overflow" do

				it "returns the word while setting O to zero when no overflow occurs" do
					cpu.retain_overflow(0x1234).should == 0x1234
					cpu.registers[:O].should == 0
				end

				it "returns the clipped word while setting O to 1 when an overflow occurs" do
					cpu.retain_overflow(0x1ffff).should == 0xffff
					cpu.registers[:O].should == 1
				end

				it "returns the clipped word while setting O to 0xffff when an underfow occurs" do
					cpu.retain_overflow(-1).should == 0xffff
					cpu.registers[:O].should == 0xffff
				end

			end

			describe "guard_against_divide_by_zero" do

			  before do
			  	cpu.registers[:O] = 123
			  end

				it "returns the evaluation of the given block if the divisor value is not zero" do
					(cpu.guard_against_divide_by_zero(111) { 12 }).should == 12
					cpu.registers[:O].should == 123
				end

				it "returns 0 and sets O to zero if the divisor is zero" do
					(cpu.guard_against_divide_by_zero(0) { 12 }).should == 0
					cpu.registers[:O].should == 0
				end

			end

		end

		describe "Stack" do

			before do
				cpu.memory[0xffff] = 0x1234
			end

			describe "#peek" do

				it "returns the value at the top of the stack" do
					cpu.peek.should == 0x1234
				end

			end

			describe "#push" do

				it "pushes a value onto the stack" do
					cpu.push(0x4567)
					cpu.peek.should == 0x4567
				end

			end

			describe "#pop" do

				it "pops a value off the stack" do
					cpu.push(0x4567)
					cpu.pop.should == 0x4567
					cpu.pop.should == 0x1234
				end

			end

		end

		describe "#execute_instruction!" do

 			# SET I, 10
			let(:opcode) { 0x01 }
			let(:a)      { 0x06 }
			let(:b)      { 0x2a }

			let(:instructions_table) { mock() }
			let(:instruction) { mock(:mnemonic => "SET") }

			before do
				instructions_table.should_receive(:lookup).with(0x01).and_return(instruction)
				cpu.stub!(:instructions_table => instructions_table)
			end

			it "executes the instruction" do
				cpu.should_receive(:make_value).with(a).and_return('ValueA')
				cpu.should_receive(:make_value).with(b).and_return('ValueB')
				instruction.should_receive(:execute).with(cpu, 'ValueA', 'ValueB')
				cpu.execute_instruction!(opcode, a, b)
			end

			context "when the skip_next_instruction flag is set" do

				before do
					cpu.should_receive(:make_value).with(a).and_return('ValueA')
					cpu.should_receive(:make_value).with(b).and_return('ValueB')
					cpu.skip_next_instruction!
				end

				it "does not execute the instruction" do
					cpu.skip_next_instruction?.should be_true
					instruction.should_not_receive(:execute)
					cpu.execute_instruction!(opcode, a, b)
				end

				it "resets the skip_next_instruction flag" do
					cpu.skip_next_instruction?.should be_true
					cpu.execute_instruction!(opcode, a, b)
					cpu.skip_next_instruction?.should be_false
				end

			end

		end

	end #

	describe "#instructions_table" do

		class MockValue

			def initialize(value = 0)
				@value = value
			end

			def get
				@value
			end

			def set(new_value)
				@value = new_value
			end

			def to_s
				"TestValue: #{@value.to_hex}"
			end

		end

		let(:a) { MockValue.new }
		let(:b) { MockValue.new }

		describe "SET" do

			let(:instruction) { cpu.instructions_table.lookup(0x01) }

			it "corresponds to opcode 0x01" do
				instruction.mnemonic.should == "SET"
			end

			it "assigns b to a" do
				b.set 0x1234
				instruction.execute(cpu, a, b)
				a.get.should == 0x1234
			end

		end

		describe "ADD" do

			let(:instruction) { cpu.instructions_table.lookup(0x02) }

			it "corresponds to opcode 0x02" do
				instruction.mnemonic.should == "ADD"
			end

			it "adds a to b and stores the result in a" do
				a.set 123
				b.set 456
				instruction.execute(cpu, a, b)
				a.get.should == 579
			end

			it "stores the overflow in O" do
				a.set 0xffff
				b.set 5
				instruction.execute(cpu, a, b)
				a.get.should == 4
				cpu.registers[:O].should == 1
			end

		end

		describe "SUB" do

			let(:instruction) { cpu.instructions_table.lookup(0x03) }

			it "corresponds to opcode 0x03" do
				instruction.mnemonic.should == "SUB"
			end

			it "subtracts b from a and stores the result in a" do
				a.set 579
				b.set 456
				instruction.execute(cpu, a, b)
				a.get.should == 123
			end

			it "stores the underflow in O" do
				a.set 5
				b.set 7
				instruction.execute(cpu, a, b)
				a.get.should == 0xfffe
				cpu.registers[:O].should == 0xffff
			end

		end

		describe "MUL" do

			let(:instruction) { cpu.instructions_table.lookup(0x04) }

			it "corresponds to opcode 0x04" do
				instruction.mnemonic.should == "MUL"
			end

			it "multiplies a by b and stores the result in a" do
				a.set 7
				b.set 6
				instruction.execute(cpu, a, b)
				a.get.should == 42
			end

			it "multiplies a by b and stores the result in a" do
				a.set 0x8001
				b.set 4
				instruction.execute(cpu, a, b)
				a.get.should == 4
				cpu.registers[:O].should == 2
			end

		end

		describe "DIV" do

			let(:instruction) { cpu.instructions_table.lookup(0x05) }

			it "corresponds to opcode 0x05" do
				instruction.mnemonic.should == "DIV"
			end

			it "divides a by b and stores the result in a" do
				a.set 42
				b.set 6
				instruction.execute(cpu, a, b)
				a.get.should == 7
			end

			it "gracefully handles a division by zero" do
				a.set 42
				b.set 0
				instruction.execute(cpu, a, b)
				a.get.should == 0
				cpu.registers[:O].should == 0
			end

		end

		describe "MOD" do

			let(:instruction) { cpu.instructions_table.lookup(0x06) }

			it "corresponds to opcode 0x06" do
				instruction.mnemonic.should == "MOD"
			end

			it "calculates the reminder of the division of a by b and stores the result in a" do
				a.set 100
				b.set 30
				instruction.execute(cpu, a, b)
				a.get.should == 10
			end

			it "gracefully handles a division by zero" do
				a.set 42
				b.set 0
				instruction.execute(cpu, a, b)
				a.get.should == 0
				cpu.registers[:O].should == 0
			end

		end

		describe "SHL" do

			let(:instruction) { cpu.instructions_table.lookup(0x07) }

			it "corresponds to opcode 0x07" do
				instruction.mnemonic.should == "SHL"
			end

			it "left shifts a by b bits" do
				a.set 0xff00
				b.set 4
				instruction.execute(cpu, a, b)
				a.get.should == 0xf000
				cpu.registers[:O].should == 0x000f
			end

		end

		describe "SHR" do

			let(:instruction) { cpu.instructions_table.lookup(0x08) }

			it "corresponds to opcode 0x08" do
				instruction.mnemonic.should == "SHR"
			end

			it "right shifts a by b bits" do
				a.set 0x0ff0
				b.set 8
				instruction.execute(cpu, a, b)
				a.get.should == 0x000f
				cpu.registers[:O].should == 0xf000
			end

		end

		describe "AND" do

			let(:instruction) { cpu.instructions_table.lookup(0x09) }

			it "corresponds to opcode 0x09" do
				instruction.mnemonic.should == "AND"
			end

			it "stores the results of a bitwise-and b into a" do
				a.set 0b1111010
				b.set 0b0101100
				instruction.execute(cpu, a, b)
				a.get.should == 0b0101000
			end

		end

		describe "BOR" do

			let(:instruction) { cpu.instructions_table.lookup(0x0a) }

			it "corresponds to opcode 0x0a" do
				instruction.mnemonic.should == "BOR"
			end

			it "stores the results of a bitwise-or b into a" do
				a.set 0b1111010
				b.set 0b0101100
				instruction.execute(cpu, a, b)
				a.get.should == 0b1111110
			end

		end

		describe "XOR" do

			let(:instruction) { cpu.instructions_table.lookup(0x0b) }

			it "corresponds to opcode 0x0b" do
				instruction.mnemonic.should == "XOR"
			end

			it "stores the results of a bitwise-xor b into a" do
				a.set 0b1111010
				b.set 0b0101100
				instruction.execute(cpu, a, b)
				a.get.should == 0b1010110
			end

		end

		describe "IFE" do

			let(:instruction) { cpu.instructions_table.lookup(0x0c) }

			it "corresponds to opcode 0x0c" do
				instruction.mnemonic.should == "IFE"
			end

			it "performs the next instruction if a and b are equal" do
				a.set 0x1234
				b.set 0x1234
				cpu.should_not_receive(:skip_next_instruction!)
				instruction.execute(cpu, a, b)
			end

			it "skips the next instruction if a and b are not equal" do
				a.set 0x1234
				b.set 0x5678
				cpu.should_receive(:skip_next_instruction!)
				instruction.execute(cpu, a, b)
			end

		end

		describe "IFN" do

			let(:instruction) { cpu.instructions_table.lookup(0x0d) }

			it "corresponds to opcode 0x0d" do
				instruction.mnemonic.should == "IFN"
			end

			it "performs the next instruction if a and b are not equal" do
				a.set 0x1234
				b.set 0x5678
				cpu.should_not_receive(:skip_next_instruction!)
				instruction.execute(cpu, a, b)
			end

			it "skips the next instruction if a and b are equal" do
				a.set 0x1234
				b.set 0x1234
				cpu.should_receive(:skip_next_instruction!)
				instruction.execute(cpu, a, b)
			end

		end

		describe "IFG" do

			let(:instruction) { cpu.instructions_table.lookup(0x0e) }

			it "corresponds to opcode 0x0e" do
				instruction.mnemonic.should == "IFG"
			end

			it "performs the next instruction if a is strictly greater than b" do
				a.set 2
				b.set 1
				cpu.should_not_receive(:skip_next_instruction!)
				instruction.execute(cpu, a, b)
			end

			it "skips the next instruction if a is equal to b" do
				a.set 2
				b.set 2
				cpu.should_receive(:skip_next_instruction!)
				instruction.execute(cpu, a, b)
			end

			it "skips the next instruction if a is less than b" do
				a.set 1
				b.set 2
				cpu.should_receive(:skip_next_instruction!)
				instruction.execute(cpu, a, b)
			end

		end

		describe "JSR" do

			let(:instruction) { cpu.instructions_table.lookup(0xff01) }

			it "corresponds to our special internal opcode 0xff01" do
				instruction.mnemonic.should == "JSR"
			end

			it "pushes the PC onto the stack and jumps to a" do
				cpu.registers[:PC] = 0x1234
				a.set 0x4567
				cpu.should_receive(:push).with(0x1234)
				instruction.execute(cpu, a, nil)
				cpu.registers[:PC].should == 0x4567
			end

		end

	end

end