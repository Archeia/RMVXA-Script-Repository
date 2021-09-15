$simport.r 'iek/content_bitmap', '1.0.0', 'Bitmap subclass to differientiate Window contents.'

class Window_Base
  class ContentBitmap < Bitmap
  end

  def dispose_contents
    contents.dispose unless contents.disposed?
  end

  def dispose
    dispose_contents
    super
  end

  def create_contents
    dispose_contents
    if contents_width > 0 && contents_height > 0
      self.contents = ContentBitmap.new(contents_width, contents_height)
    else
      self.contents = ContentBitmap.new(1, 1)
    end
  end
end
