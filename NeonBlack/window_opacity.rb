class Window_Base < Window
  alias solidify_initialize initialize
  def initialize(x, y, width, height)
    solidify_initialize(x, y, width, height)
    self.back_opacity = 255
  end
end