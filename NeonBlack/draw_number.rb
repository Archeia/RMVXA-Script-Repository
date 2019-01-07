class Window_Base < Window
  def draw_number(*args)
    contents.draw_number(*args)
  end
end

class Bitmap # draw_number(x, y, width, numb, length, align, color2)
  def draw_number(x, y, width, numb, length = 0, align = 0, color2 = self.font.color)
    color1 = self.font.color.clone
    text = sprintf("%0#{length}d", numb)
    self.font.color = color2.clone
    space = self.text_size(" ").width
    x2 = x + (width - self.text_size(text).width) / 2 * align
    text.split(//).each do |c|
      self.font.color = color1 unless c == "0"
      draw_text(x2 - space, y, self.width, self.height, " #{c} ")
      x2 += self.text_size(c).width
    end
  end
end