#
# DrawExt/src/draext/outline.rb
#   by IceDragon (mistdragon100@gmail.com)
#   dc 15/06/2013
#   dm 15/06/2013
# vr 1.0.0
module DrawExt
  ##
  # ::draw_rect_outline(Bitmap bmp, Rect rect, Color color)
  # ::draw_rect_outline(Bitmap bmp, Rect rect, Color color, Integer weight)
  # ::draw_rect_outline(Bitmap bmp, Rect rect, Color color, Integer weight, ALIGN align)
  def self.draw_rect_outline(bmp, rect, color, weight=1, align=1)
    ## top
    rect_top = Rect.new(rect.x, 0, rect.width, weight)
    case align
    when 0 then rect_top.y = rect.y - weight
    when 1 then rect_top.y = rect.y - weight / 2
    when 2 then rect_top.y = rect.y #+ weight
    end
    ## left
    rect_left = Rect.new(0, rect.y, weight, rect.height)
    case align
    when 0 then rect_left.x = rect.x - weight
    when 1 then rect_left.x = rect.x - weight / 2
    when 2 then rect_left.x = rect.x
    end
    ## right
    rect_right = Rect.new(0, rect.y, weight, rect.height)
    case align
    when 0 then rect_right.x = rect.x + rect.width
    when 1 then rect_right.x = rect.x + rect.width - weight / 2
    when 2 then rect_right.x = rect.x + rect.width - weight
    end
    ## bottom
    rect_bottom = Rect.new(rect.x, 0, rect.width, weight)
    case align
    when 0 then rect_bottom.y = rect.y + rect.height
    when 1 then rect_bottom.y = rect.y + rect.height - weight / 2
    when 2 then rect_bottom.y = rect.y + rect.height - weight
    end
    bmp.fill_rect(rect_top, color)
    bmp.fill_rect(rect_bottom, color)
    bmp.fill_rect(rect_left, color)
    bmp.fill_rect(rect_right, color)
    return self
  end
end
