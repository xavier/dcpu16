#!/usr/bin/env ruby

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
$:.unshift File.expand_path(File.dirname(__FILE__))

require 'dcpu16'
require 'programs'

class TestObserver

  include DCPU16::Instrumentation::Observer

  def before_step(cpu)
    printf("[%8d]%s\n", cpu.cycles, "-" * 80)
    puts cpu.dump
    puts cpu.stack
  end

  def after_step(cpu)
    #gets
  end

  def before_execution(cpu, inst, a, b)
    puts cpu.trace_instruction(inst.mnemonic, a, b)
  end

  def skipped_instruction(cpu, inst, a, b)
    puts "*Skipped* (" + cpu.trace_instruction(inst.mnemonic, a, b) + ")"
  end

end

cpu = DCPU16::CPU.new
cpu.add_observer(TestObserver.new)

#cpu.memory.load(Programs::FACT_5)
cpu.memory.load(      [
        # SYS opcode
        ((0x33<<4) | ((0x12|0x20)<<10)),
        0x7dc1,
        0x0001
      ])
cpu.run(50)

# cpu.reset!
# cpu.memory.wipe!
# cpu.memory.load(Programs::FIB)
# cpu.run(300)