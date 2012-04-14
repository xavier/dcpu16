module DCPU16

	class Memory

		SIZE = 0x10000

		def initialize
			wipe!
		end

		def wipe!
			@words = [0] * SIZE
		end

		def [](offset)
			@words[offset.clip_word]
		end

		def []=(offset, value)
			@words[offset.clip_word] = value
		end

		def load(words)
			words.each_with_index do |word, offset|
				@words[offset] = word.clip_word
			end
		end

		def dump(words_per_line = 8)
			format_string = '%04x:' + (' %04x' * words_per_line)
			(0...(SIZE/words_per_line)).map do |line|
				offset = line * words_per_line
				args   = [offset] + @words[offset, words_per_line]
				format_string % args
			end.join("\n")
		end

	end

end