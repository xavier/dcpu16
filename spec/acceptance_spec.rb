require 'spec_helper'

describe "Acceptance Tests" do

  let(:cpu) { DCPU16::CPU.new }

  describe "Factorial" do

    let(:factorial_5) do
      [
        0x8431,
        0x9421,
        0x0834,
        0x8423,
        0x802d,
        0x7dc1,
        0x0002,
        0x7dc1,
        0x0007,
      ]
    end

    it "stores the result of fact(5) in X" do
      cpu.memory.load(factorial_5)
      cpu.run(150)
      cpu.registers[:X].should == 120
    end

  end

  describe "Fibonacci" do

    let(:fibonacci) do
      [
        0x6c21,
        0x7c23,
        0x0100,
        0x7c10,
        0x003c,
        0x7dc1,
        0x0005,
        0xb023,
        0x0d21,
        0x000a,
        0x8521,
        0x0008,
        0x8521,
        0x0006,
        0x8121,
        0x0004,
        0x0d21,
        0x0000,
        0x4871,
        0x0004,
        0x4851,
        0x000a,
        0x7dd1,
        0xffff,
        0x147c,
        0x81d1,
        0x147e,
        0x85d1,
        0x7ddd,
        0xffff,
        0x7dc1,
        0x0038,
        0x7dc1,
        0x0022,
        0x4871,
        0x0008,
        0x4851,
        0x0006,
        0x1472,
        0x1d21,
        0x0002,
        0x4871,
        0x0008,
        0x1d21,
        0x0006,
        0x4871,
        0x0002,
        0x1d21,
        0x0008,
        0x4871,
        0x0004,
        0x8472,
        0x1d21,
        0x0004,
        0x7dc1,
        0x0012,
        0x4831,
        0x0008,
        0xb022,
        0x61c1,
        0x8823,
        0x8121,
        0x0000,
        0x9431,
        0x7c10,
        0x0007,
        0x8822,
        0x61c1,
      ]
    end

    it "stores the result of fib(7) in X" do
      cpu.memory.load(fibonacci)
      cpu.run(300)
      cpu.registers[:X].should == 13
    end

  end

end