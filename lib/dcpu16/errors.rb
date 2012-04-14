module DCPU16

	class Error < StandardError ; end
	class UnexpectedOpcode < Error ; end
	class UnexpectedValue < Error ; end

end