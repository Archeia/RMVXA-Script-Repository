$simport.r 'iek/rgss3_ext/numeric', '1.0.0', 'Extends Numeric Class'

class Numeric
  # Converts seconds to frames
  #
  # @return [Integer]
  def to_frames
    (self * Graphics.frame_rate).to_i
  end
end
