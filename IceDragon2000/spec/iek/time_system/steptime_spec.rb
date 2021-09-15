require_relative '../spec_helper'
require "iek/time_system/time_system"
require "iek/time_system/steptime"

describe IEK::TimeSystem::SteptimeClock do
  context "#update" do
    it "should update the step counter" do
      sub = subject
      sub.update
      expect(sub.steps).to eq(1)
    end

    it "should update the step counter and value" do
      sub = subject
      (sub.steps_per_second*2).times { sub.update }
      expect(sub.value).to eq(2)
    end
  end
end
