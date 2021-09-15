require_relative '../../spec_helper'
require "iek/time_system/core_ext/integer"

describe Integer do
  context "#seconds" do
    it "should produce a seconds increment from number" do
      expect(5.seconds).to eq(5)
    end
  end

  context "#minutes" do
    it "should produce a minutes increment from number" do
      expect(5.minutes).to eq(300)
    end
  end

  context "#hours" do
    it "should produce a hours increment from number" do
      expect(4.hours).to eq(14400)
    end
  end

  context "#days" do
    it "should produce a days increment from number" do
      expect(2.days).to eq(172800)
    end
  end

  context "#months" do
    it "should produce a months increment from number" do
      expect(3.months).to eq(2592000*3)
    end
  end

  context "#years" do
    it "should produce a months increment from number" do
      expect(1.years).to eq(31536000)
    end
  end
end
