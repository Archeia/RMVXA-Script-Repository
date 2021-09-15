$simport.r 'iek/time_system/toning', '1.0.0', 'IEK TimeSystem Toning Implementation for VXA' do |h|
  h.depend 'iek/time_system'
end

module IEK
  module TimeSystem
    class Phase < Struct.new(:phase, :range, :tone)
    end

    @phases = []
    @phases << Phase.new(:dawn,  ( 0.hours)..( 6.hours), Tone.new(  17, -51,-102,   0))
    @phases << Phase.new(:day,   ( 6.hours)..(12.hours), Tone.new(  0,    0,   0,   0))
    @phases << Phase.new(:dusk,  (12.hours)..(18.hours), Tone.new(  17, -51,-102,   0))
    @phases << Phase.new(:night, (18.hours)..(24.hours), Tone.new(-187,-119, -17,  68))
  end
end
