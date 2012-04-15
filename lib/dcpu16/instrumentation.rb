module DCPU16

  module InstrumentationCallbacks

    DumpRegisters = Proc.new { |cpu, _| puts "Registers : #{cpu.dump}\r" }
    DumpStack     = Proc.new { |cpu, _| puts "Stack     : #{cpu.stack}" }
    DumpCycles    = Proc.new { |cpu, _| puts "Cycles    : #{cpu.cycles}" }
    DumpMemory    = Proc.new { |cpu, _| puts cpu.memory.dump }
    StepByStep    = Proc.new { |cpu, _| gets }

  end

  module Instrumentation

    def instrumentation_callbacks
      @instrumentation_callbacks ||= {
        :before_step         => [],
        :after_step          => [],
        :before_execution    => [],
        :after_execution     => [],
        :skipped_instruction => [],
      }
    end

    def instrumentation_callbacks_for(event)
      instrumentation_callbacks[event] || (raise ArgumentError.new("Unknown event: #{event.inspect}, Valid events: #{instrumentation_callbacks.keys.inspect}"))
    end

    def on(*events, &block)
      events.each do |event|
        instrumentation_callbacks_for(event) << block
      end
    end

    def fire_callback(event, *args)
      instrumentation_callbacks_for(event).each do |proc|
        proc.call(args)
      end
    end

  end

end