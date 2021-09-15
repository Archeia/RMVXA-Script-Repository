require_relative '../spec_helper'
require "iek/time_system/time_system"

describe IEK::TimeSystem do

end

describe IEK::TimeSystem::Clock do
  context "#value=" do
    it "should modify the internal value" do
      subject.value = 12 # 12
      expect(subject.value).to eq(12)
    end
  end

  context "#sec" do
    it "should report the number of seconds" do
      subject.value = 128 # 120 seconds (abs), 8 seconds
      expect(subject.sec).to eq(8)
    end
  end

  context "#sec_abs" do
    it "should report the absolute number of seconds" do
      subject.value = 128 # 128 seconds
      expect(subject.sec_abs).to eq(128)
    end
  end

  context "#min" do
    it "should report the number of minutes" do
      subject.value = 256 # 4 minutes, 16 seconds
      expect(subject.min).to eq(4)
    end
  end

  context "#min_abs" do
    it "should report the absolute number of minutes" do
      subject.value = 60 * 60 + 256 # 1 hour + 4 minutes
      expect(subject.min_abs).to eq(64)
    end
  end

  context "#hour" do
    it "should report the number of hours" do
      subject.value = 60 * 60 * 3 + 12 # s * m * h + s
      expect(subject.hour).to eq(3)
    end

    it "should report the number of hours (modulo)" do
      subject.value = 60 * 60 * 30 + 12 # s * m * h + s
      expect(subject.hour).to eq(6)
    end
  end

  context "#hour_abs" do
    it "should report the number of minutes" do
      subject.value = 60 * 60 * 27  # s * m * h + s
      expect(subject.hour_abs).to eq(27)
    end
  end
end
