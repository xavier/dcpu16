require 'spec_helper'

describe DCPU16::BinaryFile do

  let(:raw_bytes)    { [0x34, 0x12, 0x67, 0x45].map { |b| b.chr }.join }
  let(:io_stream)    { StringIO.new(raw_bytes) }
  let(:path_to_file) { File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "test.bin")) }

  let(:dump) do
%|
0000: 7c01 0030 7de1 1000 0020 7803 1000 c00d
0008: 7dc1 001a a861 7c01 2000 2161 2000 8463
0010: 806d 7dc1 000d 9031 7c10 0018 7dc1 001a
0018: 9037 61c1 7dc1 001a 0000 0000 0000 0000
|
  end

  let(:dump_with_4_words_per_line) do
%|
0000: 7c01 0030 7de1 1000
0008: 0020 7803 1000 c00d
0010: 7dc1 001a a861 7c01
0018: 2000 2161 2000 8463
0020: 806d 7dc1 000d 9031
0028: 7c10 0018 7dc1 001a
0030: 9037 61c1 7dc1 001a
0038: 0000 0000 0000 0000
|
  end


  describe ".read" do

    it "reads from an IO stream and returns an array of little-endian words" do
      DCPU16::BinaryFile.read(io_stream).should == [0x1234, 0x4567]
    end

    it "read data from the file at the given path and returns an array of little-endian words" do
      DCPU16::BinaryFile.read(path_to_file).should == [0x4142, 0x4344]
    end

  end

  describe ".parse_dump" do

    it "parse a memory dump and returns an array of little-endian words" do
      should_parse_the_dump_succesfully DCPU16::BinaryFile.parse_dump(dump)
    end

    it "parse a dump with a given number of words per line" do
      should_parse_the_dump_succesfully DCPU16::BinaryFile.parse_dump(dump_with_4_words_per_line, 4)
    end

  end

  def should_parse_the_dump_succesfully(array)
    array.size.should  == 0x20
    array[0].should    == 0x7c01
    array[7].should    == 0xc00d
    array[8].should    == 0x7dc1
    array[0x1f].should == 0x0000
  end

end