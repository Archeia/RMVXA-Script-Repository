$simport.r 'iek/rgss3_ext/plane', '1.0.0', 'Extends Plane Class'

class Plane
  # Planes don't have an update method, this usually causes a few 'gotchas!'
  def update
  end

  ##
  # @return [Void]
  def dispose_bitmap
    self.bitmap.dispose
  end

  ##
  # @return [Void]
  def dispose_bitmap_safe
    dispose_bitmap if self.bitmap && !self.bitmap.disposed?
  end

  ##
  # @return [Void]
  def dispose_all
    dispose_bitmap_safe
    dispose
  end
end
