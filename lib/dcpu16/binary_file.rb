module DCPU16

  class BinaryFile

    class <<self

      def read(path_or_io)
        if path_or_io.respond_to?(:read)
          unpack path_or_io.read
        else
          unpack File.read(path_or_io)
        end
      end

      def unpack(string)
        string.unpack('v*')
      end

      def read_dump(path_or_io)
        if path_or_io.respond_to?(:read)
          parse_dump path_or_io.read
        else
          parse_dump File.read(path_or_io)
        end
      end

      def parse_dump(dump, words_per_line = 8)
        words = []
        dump.strip.split(/\n/).each_with_index do |line, line_idx|
          if hexnumbers = parse_dump_line(line, words_per_line)
            hexnumbers.each { |n| words << n.hex }
          else
            raise ArgumentError.new("Invalid dump '#{line}' on line #{line_idx.succ}")
          end
        end
        words
      end

      def parse_dump_line(line, words_per_line)
        if (hexnumbers = line.scan(/[\da-f]{4}/i)).size == (words_per_line+1)
          hexnumbers.shift
        else
          hexnumbers = nil
        end
        hexnumbers
      end

    end

  end

end