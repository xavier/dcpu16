module DCPU16

	class CPU

		def initialize
			reset!
		end

		def reset!
			@registers = {
				:PC => 0,
				:SP => 0xffff,
				:O  => 0,
				:A  => 0,
				:B  => 0,
				:C  => 0,
				:X  => 0,
				:Y  => 0,
				:Z  => 0,
				:I  => 0,
				:J  => 0,
			}
			@cycles = 0
		end

		def memory
			@memory ||= Memory.new
		end

		def instructions_table
			@instructions_table ||= build_instructions_table
		end

		attr_reader :registers

		attr_reader :cycles

		def tick!(n = 1)
			@cycles += n
		end

		def run(step_by_step = false, max_cycles = 20)
			loop do
				step!
				# TODO Replace with propoer instrumentation
				if step_by_step
					puts "-" * 80
					puts "Registers : #{dump}"
					puts "Stack     : #{stack}"
					puts "Cycles    : #{cycles} / #{max_cycles}"
					gets
				end
				break unless cycles < max_cycles
			end
		end

		def step!
			w = fetch_next_word
			opcode, a, b = decode_instruction(w)
			execute_instruction!(opcode, a, b)
		end

		def fetch_next_word
			w = memory[regget(:PC)]
			reginc(:PC)
			w
		end

		BITS_4 = 0b1111
		BITS_6 = 0b111111

		def decode_instruction(w)
			[w & BITS_4, (w>>4) & BITS_6, (w>>10) & BITS_6]
		end

		def execute_instruction!(opcode, a, b)
			if opcode == 0
				opcode = a | 0xff00
				a = b
				b = nil
			end
			inst = instructions_table.lookup(opcode)
			value_a = make_value(a)
			value_b = make_value(b) if b
			if skip_next_instruction?
				skip_instruction!
			else
				#puts trace_instruction(inst.mnemonic, value_a, value_b)
				inst.execute(self, value_a, value_b)
			end
		end

		def trace_instruction(mnemonic, value_a, value_b)
			sprintf("%04x: %s %s %s", regget(:PC)-1, mnemonic, value_a, value_b)
		end

		def dump
			[:A, :B, :C, :X, :Y, :Z, :I, :J, :O, :SP, :PC].map do |r|
				sprintf("%s:%04x", r, regget(r))
			end.join(' ')
		end

		def stack
			'[' + (regget(:SP)...0xffff).map { |sp| sprintf("%04x", memory[sp]) }.join(' ') + ']'
		end

		VALUE_REGISTERS_MAP = [:A, :B, :C, :X, :Y, :Z, :I, :J]

		def make_value(value)
			case value
			when 0x00..0x07
				RegisterValue.new(self, VALUE_REGISTERS_MAP[value])
			when 0x08..0x0f
				register_index = value & ~0x08
				register       = VALUE_REGISTERS_MAP[register_index]
				offset         = regget(register)
				AddressValue.new(self, offset)
			when 0x10..0x17
				self.tick!
				register_index = value & ~0x10
				register       = VALUE_REGISTERS_MAP[register_index]
				offset         = regget(register) + fetch_next_word
				AddressValue.new(self, offset)
			when 0x18, 0x1a
				StackValue.new(self)
			when 0x19
				ImmutableStackValue.new(self)
			when 0x1b
				RegisterValue.new(self, :SP)
			when 0x1c
				RegisterValue.new(self, :PC)
			when 0x1d
				RegisterValue.new(self, :O)
			when 0x1e
				self.tick!
				AddressValue.new(self, fetch_next_word)
			when 0x1f
				self.tick!
				LiteralValue.new(self, fetch_next_word)
			when 0x20..0x3f
				literal = value & ~0x20
				LiteralValue.new(self, literal)
			else
				raise UnexpectedValue, value.to_hex
			end
		end

		def skip_next_instruction!
			@skip_next_instruction = true
		end

		def skip_next_instruction?
			@skip_next_instruction
		end

		def skip_instruction!
			#puts " --- SKIPPED #{inst.mnemonic} (#{value_a}) (#{value_b})"
			self.tick!
			@skip_next_instruction = false
		end

		#
		# Microcode
		#

		#
		# Registers manipulation
		#

		def regget(reg)
			@registers[reg]
		end

		def regset(reg, word)
			@registers[reg] = word
		end

		def reginc(reg)
			regset(reg, (regget(reg) + 1).clip_word)
		end

		def regdec(reg)
			regset(reg, (regget(reg) - 1).clip_word)
		end

		#
		# Built-in stack
		#

		def push(w)
			regdec(:SP)
			memory[regget(:SP)] = w
		end

		def pop
			w = peek
			reginc(:SP)
			w
		end

		def peek
			memory[regget(:SP)]
		end

		#
		# Arithmetic
		#

		def retain_overflow(longword)
			w, o = longword.clip_word_with_overflow
			regset(:O, o)
			w
		end

		def guard_against_divide_by_zero(divisor)
			if divisor == 0
				regset(:O, 0)
				0
			else
				yield
			end
		end

		#
		#
		#

		def build_instructions_table
			InstructionsTable.build do
				implement(0x1, "SET", 1) { |cpu, a, b| a.set(b.get) }
				implement(0x2, "ADD", 2) { |cpu, a, b| a.set(cpu.retain_overflow(a.get + b.get)) }
				implement(0x3, "SUB", 2) { |cpu, a, b| a.set(cpu.retain_overflow(a.get - b.get)) }
				implement(0x4, "MUL", 2) { |cpu, a, b| a.set(cpu.retain_overflow(a.get * b.get)) }
				implement(0x5, "DIV", 3) { |cpu, a, b| a.set cpu.guard_against_divide_by_zero(b.get) { a.get / b.get } }
				implement(0x6, "MOD", 3) { |cpu, a, b| a.set cpu.guard_against_divide_by_zero(b.get) { a.get % b.get } }
				implement(0x7, "SHL", 2) { |cpu, a, b| a.set(cpu.retain_overflow(a.get << b.get)) }
				implement(0x8, "SHR", 2) { |cpu, a, b| cpu.regset(:O, (a.get << (16-b.get)).clip_word) ; a.set(a.get >> b.get) }
				implement(0x9, "AND", 1) { |cpu, a, b| a.set(a.get & b.get) }
				implement(0xa, "BOR", 1) { |cpu, a, b| a.set(a.get | b.get) }
				implement(0xb, "XOR", 1) { |cpu, a, b| a.set(a.get ^ b.get) }
				implement(0xc, "IFE", 2) { |cpu, a, b| cpu.skip_next_instruction! if a.get != b.get }
				implement(0xd, "IFN", 2) { |cpu, a, b| cpu.skip_next_instruction! if a.get == b.get }
				implement(0xe, "IFG", 2) { |cpu, a, b| cpu.skip_next_instruction! if a.get <= b.get }
				implement(0xf, "IFB", 2) { |cpu, a, b| cpu.skip_next_instruction! if (a.get & b.get) == 0 }
				# We treat non basic opcodes the same way
				implement(0xff01, "JSR", 2) do |cpu, a, b|
					cpu.push(cpu.regget(:PC))
					cpu.regset(:PC, a.get)
				end
			end
		end

	end

end