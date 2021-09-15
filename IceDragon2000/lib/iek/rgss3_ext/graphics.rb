$simport.r 'iek/rgss3_ext/graphics', '1.0.0', 'Extension of the RGSS3 Graphics module'

module Graphics
  ###
  # @return [Rect]
  def self.rect
    Rect.new 0, 0, width, height
  end

  ###
  # @return [Float]
  def self.frame_delta
    1.0 / Graphics.frame_rate
  end

  ###
  # @return [Integer]
  def self.sec_to_frame(seconds)
    (seconds * Graphics.frame_rate).to_i
  end

  ###
  # @return [Float]
  def self.frame_to_sec(frames)
    frames.to_f / Graphics.frame_rate
  end
end
