class Fixnum

	def clip_word
		self & 0xffff
	end

	def overflow
		((self & ~0xffff) >> 16).clip_word
	end

	def clip_word_with_overflow
		[clip_word, overflow]
	end

	def to_hex(digits = 4)
		sprintf("0x%0#{digits}x", self)
	end

end
