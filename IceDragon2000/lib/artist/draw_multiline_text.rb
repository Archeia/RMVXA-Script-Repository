#
# draw_multiline_text.rb
#
class Artist
  def draw_multiline_text(rect, line_height, string, align=1)
    line_rect = rect.dup
    line_rect.height = line_height

    string.each_line do |line|
      draw_text(line_rect, line, align)
      line_rect.y += line_rect.height
    end

    return MACL::Surface::Surface2.new(rect.x, rect.y, line_rect.x2, line_rect.y2).to_rect
  end

  def draw_multiline_text_ex(rect, line_height, string, align=1)
    line_rect = rect.dup
    line_rect.height = line_height

    txstruct = Markie.prep_text(line_rect, string, align)

    string.each_line do |line|
      Markie.markie!(bitmap, txstruct)
      txstruct.rect.y += txstruct.rect.height
    end

    return MACL::Surface::Surface2.new(rect.x, rect.y, line_rect.x2, line_rect.y2).to_rect
  end
end
