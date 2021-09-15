$simport.r 'iek/rgss3_ext/tilemap', '1.0.0', 'Extends Tilemap Class'

class Tilemap
  def bitmaps=(bitmaps)
    9.times do |i|
      self.bitmaps[i] = bitmaps[i]
    end
  end
end
