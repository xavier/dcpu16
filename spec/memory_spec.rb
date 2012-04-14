require 'spec_helper'

describe DCPU16::Memory do

	let(:memory) { DCPU16::Memory.new }

	describe "random access" do
		{
			0      => 0x1234,
			0xff   => 0x4567,
			0xfff  => 0xCAFE,
			0xffff => 0xBABE,
		}.each do |offset, test_value|

			describe ("when we write 0x%04x at offset 0x%04x" % [offset, test_value]) do

				it ("we should read 0x%04x at offset 0x%04x" % [offset, test_value]) do
					memory[offset] = test_value
					memory[offset].should == test_value
				end

			end

		end

		describe "when writing to an offset out of bounds" do

			before do
				memory[0x10001] = 0x1234
			end

			it "wraps the offset around" do
				memory[0x10001].should == 0x1234
				memory[0x00001].should == 0x1234
			end

		end

	end

	describe "#load" do

		before do
			memory.load([0x123, 0x456, 0x789, 0xABC])
		end

		it "loads a sequence of words into memory starting from offset 0" do
			memory[0].should == 0x123
			memory[1].should == 0x456
			memory[2].should == 0x789
			memory[3].should == 0xABC
			memory[4].should == 0
		end


	end

	describe "#wipe!" do

		before do
			memory[0]      = 0xffff
			memory[0x123]  = 0x123
			memory[0x456]  = 0x456
			memory[0xffff] = 0xffff
		end

		it "fills the memory with zeroes" do
			memory.wipe!
			memory[0].should      == 0
			memory[0x123].should  == 0
			memory[0x456].should  == 0
			memory[0xffff].should == 0
		end

	end

	describe "#dump" do

		before do
			memory[0]      = 0x1234
			memory[0x7]    = 0x4567
			memory[0x8]    = 0x9898
			memory[0xfff8] = 0xCAFE
			memory[0xffff] = 0xffff
		end

		let(:dump)       { memory.dump }
		let(:dump_lines) { dump.split("\n") }

		it "returns lines of 8 words" do
			dump_lines.size.should == 8192
		end

		it "shows the offset and a hex dumps of the memory contents on each line" do
			dump_lines[0].should    == "0000: 1234 0000 0000 0000 0000 0000 0000 4567"
			dump_lines[1].should    == "0008: 9898 0000 0000 0000 0000 0000 0000 0000"
			dump_lines[8191].should == "fff8: cafe 0000 0000 0000 0000 0000 0000 ffff"
		end

	end

end