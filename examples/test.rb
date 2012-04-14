#!/usr/bin/env ruby

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
$:.unshift File.expand_path(File.dirname(__FILE__))

require 'dcpu16'
require 'programs'

cpu = DCPU16::CPU.new
cpu.memory.load(Programs::FACT_5)
cpu.run(false, 300)
puts cpu.dump
puts cpu.cycles


cpu = DCPU16::CPU.new
cpu.memory.load(Programs::FIB)
cpu.run(false, 300)
puts cpu.dump
puts cpu.cycles
