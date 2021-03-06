module DCPU16

  class Value

    def initialize(cpu, argument = nil)
      @cpu, @argument = cpu, argument
    end

    def get
      raise NotImplementedError
    end

    def set(word)
      raise NotImplementedError
    end

    def to_s
      self.class.name
    end

  end

  class RegisterValue < Value

    def get
      @cpu.regget(register)
    end

    def set(word)
      @cpu.regset(register, word)
    end

    def register
      @argument
    end

    def to_s
      "RegisterValue: #{register}"
    end

  end

  class StackValue < Value

    def get
      @value ||= @cpu.pop
    end

    def set(word)
      @cpu.push(word)
    end

  end

  class ImmutableStackValue < Value

    def get
      @cpu.peek
    end

    def set(word)
      # Noop
    end

  end

  class LiteralValue < Value

    def get
      value
    end

    def set(word)
      # Noop
    end

    def value
      @argument
    end

    def to_s
      "LiteralValue: #{value.to_hex}"
    end

  end

  class AddressValue < Value

    def get
      @cpu.memory[offset]
    end

    def set(word)
      @cpu.memory[offset] = word
    end

    def offset
      @argument
    end

    def to_s
      "AddressValue: [#{offset.to_hex}]"
    end

  end

end