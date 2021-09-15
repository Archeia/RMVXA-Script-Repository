require_relative '../spec_helper'
require "iek/core_ext/array"

describe Array do
  context "#presence" do
    it "should return nil if empty?" do
      expect([].presence).to eq(nil)
    end

    it "should return self if not empty?" do
      ary = [1, 2, 3]
      expect(ary.presence).to equal(ary)
    end
  end

  context "#zip_map" do
    it "should " do
      result = [1, 2, 3, 4].zip_map([2, 3, 4, 5], :+)
      expect(result).to eq([3, 5, 7, 9])
    end
  end
end
