require 'spec_helper'

describe Fixnum do

  describe '#clip_word' do

    {
      0x00000 => 0x00000,
      0x00001 => 0x00001,
      0x01234 => 0x01234,
      0x0ffff => 0x0ffff,
      0x1abcd => 0x0abcd,
    }.each do |value, clipped_value|

      it ("clips 0x%05x to 0x%05x" % [value, clipped_value]) do
        value.clip_word.should == clipped_value
      end

    end

  end

  describe "#clip_word_with_overflow" do

    it "returns the word and 0 if there's no overflow" do
      0xffff.clip_word_with_overflow.should == [0xffff, 0]
    end

    {
      0x1ffff => [0xffff, 0x0001],
      -1      => [0xffff, 0xffff],
    }.each do |word, expected|

      it "returns the clipped word and the overflow for #{word.to_hex}" do
        word.clip_word_with_overflow.should == expected
      end

    end

  end

  describe "#to_hex" do

    it "returns an hexadecimal string representation of the number" do
        0xcafe.to_hex.should == "0xcafe"
    end

    it "pads the number with zeroes if needed" do
        0x123.to_hex.should == "0x0123"
    end

    it "works with more than 4 digits" do
        0x12345.to_hex.should == "0x12345"
    end

  end

end