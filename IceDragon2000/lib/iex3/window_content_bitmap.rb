class Window_Base
  class ContentBitmap < Bitmap
  end

  alias_method :initialize_wo_padding, :initialize

  def initialize(*args, &block)
    initialize_wo_padding(*args, &block)
    self.padding = 16
  end

  def create_contents
    self.contents.dispose
    self.contents = ContentBitmap.new(width - 32, height - 32)
  end
end
