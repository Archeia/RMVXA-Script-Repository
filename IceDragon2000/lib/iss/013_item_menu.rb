#encoding:UTF-8
# ISS013 - ItemMenu
class Window_Help

  def set_obj(obj, align=0)
    set_text(obj.nil? ? "" : obj.description, align)
  end

end

class Window_ItemHelp < Window_Base

  def initialize(x, y, width, height)
    super(x, y, width, height)
    @text = -1
    @obj  = -1
    @align= -1
  end

  def set_obj(obj, align=0)
    if obj != @obj or align != @align
      @obj = obj ; @align = align
      self.contents.clear()
      return if @obj.nil?()
      self.contents.font.color = normal_color
      rc = gauge_back_color ; rc.alpha = 128
      self.contents.fill_rect(0, 0, 32, 32, rc)
      draw_icon(@obj.icon_index, 4, 4)
      self.contents.font.color = system_color
      self.contents.font.bold = true
      self.contents.draw_text(38, 8, self.width - 40, WLH, @obj.name, 0)
      self.contents.font.color = normal_color
      self.contents.font.bold = false
      self.contents.draw_text(8, 32, self.width - 40, WLH, @obj.description)
    end
  end

  def set_text(text, align = 0)
    if text != @text or align != @align
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 40, WLH, text, align)
      @text = text
      @align = align
    end
  end

end

class Window_Item < Window_Selectable

  def initialize(x, y, width, height)
    super(x, y, width, height)
    @__scrollheight = 32
    @spacing = 2
    self.index = 0
    refresh()
  end

  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = 32 #
    rect.height = 32
    xo = (rect.width + @spacing) * @column_max#(contents.width + @spacing) / @column_max - @spacing
    xo = (contents.width - xo) / 2
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * rect.height
    return rect
  end

  def refresh()
    @data = []
    for item in $game_party.items
      next unless include?(item)
      @data.push(item)
      if item.is_a?(RPG::Item) and item.id == $game_party.last_item_id
        self.index = @data.size - 1
      end
    end
    @data.push(nil) if include?(nil)
    @item_max = 160 #@data.size
    @column_max = self.contents.width / (32)#+@spacing)
    create_contents()
    for i in 0...@item_max
      draw_item(i)
    end
  end

  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    drect = rect.clone
    rect.width -= 4
    drect.x += 1 ; drect.y += 1 ; drect.width -= 2 ; drect.height -= 2
    rc = gauge_back_color ; rc.alpha = 128
    self.contents.fill_rect(drect, rc)
    if item != nil
      number = $game_party.item_number(item)
      enabled = enable?(item)
      draw_icon(item.icon_index, rect.x+((rect.width-24)/2), rect.y+((rect.height-24)/2))
      #draw_item_name(item, rect.x, rect.y, enabled)
      self.contents.font.color = normal_color
      self.contents.font.size  = Font.default_size - 4
      rect.width = 32
      rect.height = 24
      rect.y += 8
      self.contents.draw_text(rect, sprintf("x%2d", number), 2)
    end
  end

  def update_help()
    @help_window.set_obj(self.item)
  end

  def top_row
    return self.oy / @__scrollheight
  end

  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    if self.active && $imported["IEO-BugFixesUpgrades"]
      @__target_oy = row * @__scrollheight
    else
      self.oy = @__current_oy = @__target_oy = row * @__scrollheight
    end
  end

  def page_row_max
    return (self.height - 32) / @__scrollheight
  end

end

class Scene_Item < Scene_Base

  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start()
    super()
    create_menu_background()
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @help_window = Window_ItemHelp.new(0, Graphics.height-96, Graphics.width, 96)
    @help_window.viewport = @viewport
    @item_window = Window_Item.new(0, 0, Graphics.width, Graphics.height-96)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.active = false
    @target_window = Window_MenuStatus.new(0, 0)
    hide_target_window
  end

  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate()
    super()
    dispose_menu_background()
    @viewport.dispose
    @help_window.dispose
    @item_window.dispose
    @target_window.dispose
  end

  #--------------------------------------------------------------------------
  # * Update Frame
  #--------------------------------------------------------------------------
  def update()
    super()
    update_menu_background()
    @help_window.update
    @item_window.update
    @target_window.update
    if @item_window.active
      update_item_selection
    elsif @target_window.active
      update_target_selection
    end
  end


  def show_target_window(right)
    @item_window.active = false
    width_remain = Graphics.width - @target_window.width
    @target_window.x = right ? width_remain : 0
    @target_window.visible = true
    @target_window.active = true
    if right
      @viewport.rect.set(0, 0, width_remain, Graphics.height)
      @viewport.ox = 0
    else
      @viewport.rect.set(@target_window.width, 0, width_remain, Graphics.height)
      @viewport.ox = @target_window.width
    end
  end

  def hide_target_window
    @item_window.active = true
    @target_window.visible = false
    @target_window.active = false
    @viewport.rect.set(0, 0, Graphics.width, Graphics.height)
    @viewport.ox = 0
  end

end
