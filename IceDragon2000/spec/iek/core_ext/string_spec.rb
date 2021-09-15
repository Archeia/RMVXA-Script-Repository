require_relative '../spec_helper'
require "iek/core_ext/string"

describe String do
  context "#presence" do
    it "should return nil if empty?" do
      expect("".presence).to eq(nil)
    end

    it "should return self if not empty?" do
      str = "My awesomeness"
      expect(str.presence).to equal(str)
    end
  end
end
