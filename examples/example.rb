#!/usr/bin/env ruby

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require 'dcpu16'

dmp_file_path = File.join(File.dirname(__FILE__), "sample.dmp")

class TestObserver

  include DCPU16::Instrumentation::Observer

  def before_step(cpu)
    puts
    puts "Cycle  : #{cpu.cycles}"
    puts "Before : #{cpu.dump}"
  end

  def after_step(cpu)
    puts " After : #{cpu.dump}"
  end

  def before_execution(cpu, inst, a, b)
    puts "  Exec : #{inst.mnemonic} #{a} #{b}"
  end

  def skipped_instruction(cpu, inst, a, b)
    puts "  Skip : (#{inst.mnemonic} #{a} #{b})"
  end

end




cpu = DCPU16::CPU.new
cpu.add_observer(TestObserver.new)
#cpu.memory.load(DCPU16::BinaryFile.read_dump(dmp_file_path))
cpu.memory.load([0xa861, 0x7c01, 0x1000, 0x2161, 0x2000, 0x8463, 0x806d, 0x7dc1, 0x0003])
cpu.run(83)
