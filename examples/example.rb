#!/usr/bin/env ruby

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require 'dcpu16'

dmp_file_path = File.join(File.dirname(__FILE__), "sample.dmp")

class TestObserver

  include DCPU16::Instrumentation::Observer

  def before_step(cpu)
    printf("[%8d]%s\n", cpu.cycles, "-" * 80)
    puts cpu.dump
  # puts cpu.stack
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
cpu.memory.load(DCPU16::BinaryFile.read_dump(dmp_file_path))
cpu.run(50)
puts cpu.dump