require_relative '../spec_helper'
require "iek/time_system/time_system"
require "iek/time_system/gametime"

describe IEK::TimeSystem::GametimeClock do
  context "#update" do
    it "should update the tick counter" do
      sub = subject
      sub.update
      expect(sub.ticks).to eq(1)
    end

    it "should update the tick counter and value" do
      sub = subject
      (sub.ticks_per_second*2).times { sub.update }
      expect(sub.value).to eq(2)
    end
  end
end
