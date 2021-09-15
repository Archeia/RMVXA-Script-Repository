module DrawExt
  ICONSET_COLS        = 16
  ICONSET_CELL_WIDTH  = 24
  ICONSET_CELL_HEIGHT = 24

  def self.translucent_alpha
    128
  end

  ##
  # draw_cell(bitmap, tx, ty, src_bitmap, index, cols, rows, w, h, alpha)
  #   @param [Bitmap] bitmap
  #   @param [Integer] tx
  #   @param [Integer] ty
  #   @param [Bitmap] src_bitmap
  #   @param [Integer] index
  #   @param [Integer] cols
  #   @param [Integer] rows
  #   @param [Integer] w
  #   @param [Integer] h
  #   @param [Integer] alpha
  def self.draw_cell(bitmap, tx, ty, src_bitmap, index, cols, rows, w, h, alpha = 255)
    if cols && cols > 0
      x = (index % cols) * w
      y = (index / cols) * h
    elsif rows && rows > 0
      x = (index / rows) * w
      y = (index % rows) * h
    else
      raise(ArgumentError, "A valid cols or rows must be given")
    end
    if block_given?
      yield bitmap, tx, ty, src_bitmap, Rect.new(x, y, w, h), alpha
    else
      bitmap.blt(tx, ty, src_bitmap, Rect.new(x, y, w, h), alpha)
    end
    Rect.new(tx, ty, w, h)
  end

  def self.draw_icon(bmp, icon, x, y, enabled = true)
    icon = RPG::BaseItem::Icon.new(icon) if icon.is_a?(Numeric)
    iconset_bmp = Cache.iconset(icon.iconset_name || "")
    alpha = enabled ? 255 : translucent_alpha
    src_rect = Rect.new(x, y, ICONSET_CELL_WIDTH, ICONSET_CELL_HEIGHT)
    return_rect = src_rect
    if @border_state
      orct = draw_border(bmp, src_rect)
      src_rect.x += (orct.width - src_rect.width) / 2
      src_rect.y += (orct.height - src_rect.height) / 2
      return_rect = orct
    end
    DrawExt.draw_cell(bmp, src_rect.x, src_rect.y,
                      iconset_bmp, icon.index,
                      ICONSET_COLS, nil, ICONSET_CELL_WIDTH, ICONSET_CELL_HEIGHT,
                      alpha)
    return_rect
  end

  def self.draw_icon_stretch(bmp, icon, trect, enabled = true)
    icon = RPG::BaseItem::Icon.new(icon) if icon.is_a?(Numeric)
    iconset_bmp = Cache.iconset(icon.iconset_name || "")
    alpha = enabled ? 255 : translucent_alpha
    ## fix border for stretched icons
    if @border_state
      ox = 32 - ICONSET_CELL_WIDTH
      oy = 32 - ICONSET_CELL_HEIGHT
      draw_border(bmp, [trect.x, trect.y, 32, 32])
      trect.x += ox
      trect.y += oy
    end
    draw_cell(bmp, trect.x, trect.y,
              iconset_bmp, icon.index,
              ICONSET_COLS, nil, ICONSET_CELL_WIDTH, ICONSET_CELL_HEIGHT,
              alpha) do |b, tx, ty, srcb, r, a|
      trg_rect = trect.dup
      trg_rect.x = tx
      trg_rect.y = ty
      b.stretch_blt(trg_rect, srcb, r, a)
    end
    trect
  end

  def self.draw_element_icon(bmp, element_id, x, y, enabled = true)
    index = Game::Icon.element(element_id)
    iconset_name = Database::Helper.iconset_name(:elements)
    icon = RPG::BaseItem::Icon.new(index, iconset_name)
    draw_icon(bmp, icon, x, y, enabled)
  end

  ##
  # draw_onyx_icon(Hazel::Onyx::Struct::Icon)
  def self.draw_onyx_icon(bitmap, icon, x ,y, opacity = 255)
    bitmap.blt(x, y, icon.bitmap, icon.rect, opacity)
  end
end
