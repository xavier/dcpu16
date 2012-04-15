#!/usr/bin/env ruby

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
$:.unshift File.expand_path(File.dirname(__FILE__))

require 'dcpu16'
require 'programs'

include DCPU16::InstrumentationCallbacks

dump_state = Proc.new { |cpu, _|
	printf("[%8d]%s\n", cpu.cycles, "-" * 80)
	DumpRegisters.call(cpu)
	DumpStack.call(cpu)
}

cpu = DCPU16::CPU.new
cpu.on(:before_step, &dump_state)
cpu.on(:after_step, &StepByStep)
cpu.on(:before_execution) { |cpu, inst, a, b| puts cpu.trace_instruction(inst.mnemonic, a, b) }
cpu.on(:skipped_instruction) { |cpu, inst, a, b| puts "*Skipped* (" + cpu.trace_instruction(inst.mnemonic, a, b) + ")" }

cpu.memory.load(Programs::FACT_5)
cpu.run(50)

# cpu.reset!
# cpu.memory.wipe!
# cpu.memory.load(Programs::FIB)
# cpu.run(300)