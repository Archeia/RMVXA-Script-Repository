require_relative '../spec_helper'
require "iek/time_system/time_system"
require "iek/time_system/realtime"

describe IEK::TimeSystem::RealtimeClock do
  context "#update" do
    it "should update the value using the Time" do
      time = Time.now
      sub = subject
      # since its possible that the updated value will not be equal to the
      # current time after the update
      sub.value = time.to_i
      expect(sub.sec).to eq(time.sec)
    end
  end
end
