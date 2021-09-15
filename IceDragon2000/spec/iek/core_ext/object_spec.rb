require_relative '../spec_helper'
require "iek/core_ext/object"

describe Object do
  context "#presence" do
    it "should return nil if object is nil" do
      expect(nil.presence).to eq(nil)
    end

    it "should return nil if object is false" do
      expect(false.presence).to eq(nil)
    end

    it "should return given object if true" do
      obj = Object.new
      expect(obj).to equal(obj)
    end
  end
end
