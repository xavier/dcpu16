module DCPU16

  class InstructionsTable

    class Instruction

      attr_reader :mnemonic

      def initialize(mnemonic, cost, &block)
        @mnemonic, @cost, @block = mnemonic, cost, block
      end

      def execute(cpu, a, b)
        #puts("#{@mnemonic} (#{a}) (#{b})")
        cpu.tick!(@cost)
        @block.call(cpu, a, b)
      end

    end

    def self.build(&block)
      tbl = new
      tbl.instance_eval(&block)
      tbl
    end

    def initialize
      @table = {}
    end

    def implement(opcode, mnemonic, cost = 1, &block)
      @table[opcode] = Instruction.new(mnemonic, cost, &block)
    end

    def lookup(opcode)
      @table[opcode] || (raise UnexpectedOpcode, opcode.to_hex)
    end

  end

end