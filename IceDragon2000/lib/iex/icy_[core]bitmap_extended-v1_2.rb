#==============================================================================#
# ** ICY-CORE - Bitmap Extended
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Version       : 1.2
# ** Date Modified : 06/21/2011
#------------------------------------------------------------------------------#
#  03/31/2011 Changed from WindowBase Extended to Bitmap Extended
#==============================================================================#
$imported = {} if $imported == nil
$imported["ICY_WindowBase_Xtended"] = true
$imported["ICY_Bitmap_Xtended"] = true

#==============================================================================#
# BitmapXTended
#==============================================================================#
module BitmapXtended
# // Redefine - This part is made to rewrite some of the core methods  
  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  WLH       = Window_Base::WLH
  CRISIS_HP = 15
  CRISIS_MP = 15
  
  BMP_XTND_MODULE_INCL = %Q(
  unless $imported["CoreFixesUpgradesMelody"]
    # The following hash allows you to change the text colour values used for
    # various common interface
    S_COLORS ={
    # Used For   => Colour ID
      :normal    =>  0,  # Normal text colour.
      :system    => 16,  # System use. Namely vocab.
      :crisis    => 17,  # Low HP colour.
      :lowmp     => 17,  # Low MP colour.
      :knockout  => 18,  # Knocked out text colour.
      :gaugeback => 19,  # Generic gauge back.
      :exhaust   =>  7,  # Exhausted HP and MP bars.
      :hp_back   => 19,  # HP gauge back.
      :hp_gauge1 => 20,  # HP gradient no 1.
      :hp_gauge2 => 21,  # HP gradient no 2.
      :mp_back   => 19,  # MP gauge back.
      :mp_gauge1 => 22,  # MP gradient no 1.
      :mp_gauge2 => 23,  # MP gradient no 2.
      :power_up  => 24,  # Boosted stat colour.
      :power_dn  => 25,  # Nerfed stat colour.
    } # Do not remove.
  else
    S_COLORS = YEM::UPGRADE::COLOURS
  end  
  
  #--------------------------------------------------------------------------#
  # * new method :drawing_bitmap
  #--------------------------------------------------------------------------#    
  def drawing_bitmap ; return Bitmap.new(32, 32)   end
    
  #--------------------------------------------------------------------------#
  # * new method :pallete_bitmap
  #--------------------------------------------------------------------------#    
  def pallete_bitmap ; return Bitmap.new(128, 128) end 
    
  #--------------------------------------------------------------------------#
  # * Get Text Color
  #     n : Text color number  (0-31)
  #--------------------------------------------------------------------------#
  def text_color(n)
    x = 64 + (n % 8) * 8
    y = 96 + (n / 8) * 8
    return pallete_bitmap.get_pixel(x, y)
  end
  
  #--------------------------------------------------------------------------#
  # * overwrite methods :*_colors
  #--------------------------------------------------------------------------#
  def normal_color()    ; return text_color(S_COLORS[:normal]);    end
  def system_color()    ; return text_color(S_COLORS[:system]);    end
  def crisis_color()    ; return text_color(S_COLORS[:crisis]);    end
  def lowmp_color()     ; return text_color(S_COLORS[:lowmp]);     end
  def knockout_color()  ; return text_color(S_COLORS[:knockout]);  end
  def gauge_back_color(); return text_color(S_COLORS[:gaugeback]); end
  def exhaust_color()   ; return text_color(S_COLORS[:exhaust]);   end
  def hp_back_color()   ; return text_color(S_COLORS[:hp_back]);   end
  def hp_gauge_color1() ; return text_color(S_COLORS[:hp_gauge1]); end
  def hp_gauge_color2() ; return text_color(S_COLORS[:hp_gauge2]); end
  def mp_back_color()   ; return text_color(S_COLORS[:mp_back]);   end
  def mp_gauge_color1() ; return text_color(S_COLORS[:mp_gauge1]); end
  def mp_gauge_color2() ; return text_color(S_COLORS[:mp_gauge2]); end
  def power_up_color()  ; return text_color(S_COLORS[:power_up]);  end
  def power_down_color(); return text_color(S_COLORS[:power_dn]);  end
    
  #--------------------------------------------------------------------------#
  # * overwrite method :hp_color
  #--------------------------------------------------------------------------#
  def hp_color( actor )
    return knockout_color if actor.hp == 0
    return crisis_color if actor.hp < ( actor.maxhp*CRISIS_HP/100 )
    return normal_color
  end
  
  #--------------------------------------------------------------------------#
  # * overwrite method :mp_color
  #--------------------------------------------------------------------------#
  def mp_color( actor )
    return lowmp_color if actor.mp < ( actor.maxmp*CRISIS_MP/100 )
    return normal_color
  end
  
  #--------------------------------------------------------------------------#
  # * Draw Icon
  #     icon_index : Icon number
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     enabled    : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------#
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    drawing_bitmap.blt(x, y, bitmap, rect, enabled ? 255 : 128)
  end
  
# // End Redefine  

  #--------------------------------------------------------------------------#
  # * Crop From Index (Works like spritesheet dissambler)
  #     index   - Index of crop
  #     bitmap  - Bitmap Object
  #     columns - Columns
  #     cwidth  - Crop Width
  #     cheight - Crop Height
  #--------------------------------------------------------------------------#
  def crop_from_index( index, bitmap, columns, cwidth, cheight )
    retbit = Bitmap.new( cwidth, cheight )
    rect = Rect.new( index % columns * cwidth, index / columns * cheight, cheight, cheight)
    retbit.blt( 0, 0, bitmap, rect )
    return retbit
  end
  
  #--------------------------------------------------------------------------#
  # * Draw Actor Sprite = This a X, Y accurate version of the draw_actor_graphic
  #   actor   : actor 
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate 
  #   enabled : half opacity?
  #--------------------------------------------------------------------------#
  def draw_actor_sprite(actor, x, y, enabled = true)
    character_name = actor.character_name
    character_index = actor.character_index
    return if character_name == nil
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    trim_bitmap = Bitmap.new(cw, ch)
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    trim_bitmap.blt(0, 0, bitmap, src_rect)
    dy = y - (ch - 32)
    dx = x - (cw - 32)
    drawing_bitmap.blt(dx, dy, trim_bitmap, trim_bitmap.rect, enabled ? 255 : 128)
  end
  
  #--------------------------------------------------------------------------#
  # * Draw Format Text
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : draw_text width
  #    height : draw_text height
  #     text  : draw_text
  #    align  : draw_text align
  #    font   : font size
  #    color  : text color
  #   enabled : half opacity?
  #--------------------------------------------------------------------------# 
  # x, y, width, height, text, align, font, color, enabled 
  # rect, text, align, font, color, enabled 
  #--------------------------------------------------------------------------#
  def draw_format_text(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    text    = pasn[pos] ; pos += 1 ; align = pasn[pos].nil? ? 0 : pasn[pos] 
    pos     += 1         ; df = Font.default_size
    font    = pasn[pos].nil? ? df : pasn[pos] ; pos += 1  
    color   = pasn[pos].nil? ? normal_color : pasn[pos] ; pos += 1 
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #
    old_font_color = drawing_bitmap.font.color
    old_font_size  = drawing_bitmap.font.size
    drawing_bitmap.font.color = color
    drawing_bitmap.font.color.alpha = enabled ? 255 : 128
    drawing_bitmap.font.size = font
    drawing_bitmap.draw_text(x, y, width, height, text, align)
    drawing_bitmap.font.color = old_font_color
    drawing_bitmap.font.size = old_font_size
  end
  #--------------------------------------------------------------------------#
  # * Draw Icon Format Text
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : draw_text width
  #    height : draw_text height
  #     text  : draw_text
  #     icon  : draw_icon
  #    align  : draw_text align
  #    font   : font size
  #    color  : text color
  #   enabled : half opacity?
  #--------------------------------------------------------------------------#    
  # x, y, width, height, text, icon, align, font, color, enabled 
  # rect, text, icon, align, font, color, enabled 
  #--------------------------------------------------------------------------#
  def draw_icon_format_text(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    text    = pasn[pos] ; pos += 1 ; icon = pasn[pos] ; pos += 1
    align   = pasn[pos].nil? ? 0 : pasn[pos] 
    pos     += 1         ; df = Font.default_size
    font    = pasn[pos].nil? ? df : pasn[pos] ; pos += 1  
    color   = pasn[pos].nil? ? normal_color : pasn[pos] ; pos += 1 
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #
    off_set = 0
    if icon != nil
      draw_icon(icon, x, y) if outlined == false
      draw_outlined_icon(icon, x, y, 32, 32, 4) if outlined
      off_set = 32
    end    
    draw_format_text(x + off_set, y, width, height, text, align, font, color, enabled)
  end
  
  #--------------------------------------------------------------------------#
  # * Draw Filled Rect
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    color  : Rect Color
  #   enabled : half opacity?
  #--------------------------------------------------------------------------# 
  # x, y, width, height, border, color, enabled 
  # rect, border, color, enabled
  #--------------------------------------------------------------------------#
  def draw_filled_rect(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    color   = pasn[pos].nil? ? system_color : pasn[pos] ; pos += 1 
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #
    outline = Rect.new(0, 0, width, height)
    outline_sprite = Bitmap.new(outline.width, outline.height)
    outline_sprite.fill_rect(outline, color)
    drawing_bitmap.blt(x, y, outline_sprite, outline, enabled ? 255 : 128)
  end
  
  #--------------------------------------------------------------------------#
  # * Draw Border Rect
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    border : Border Size
  #    color  : Rect Color
  #   enabled : half opacity?
  #--------------------------------------------------------------------------#  
  # x, y, width, height, border, color, enabled 
  # rect, border, color, enabled
  #--------------------------------------------------------------------------#
  def draw_border_rect(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    border  = pasn[pos].nil? ? 4 : pasn[pos]            ; pos += 1 
    color   = pasn[pos].nil? ? system_color : pasn[pos] ; pos += 1 
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #
    outline = Rect.new(0, 0, width, height)
    sub_rect = Rect.new((border / 2), (border / 2), (outline.width - border), (outline.height - border))
    outline_sprite = Bitmap.new(outline.width, outline.height)
    outline_sprite.fill_rect(outline, color)
    outline_sprite.clear_rect(sub_rect)
    drawing_bitmap.blt(x, y, outline_sprite, outline, enabled ? 255 : 128)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Filled Border Rect
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    border : Border Size
  #    color1 : Fill Color
  #    color2 : Border Color
  #   enabled : half opacity?
  #-------------------------------------------------------------------------- 
  # x, y, width, height, border, color1, color2, enabled 
  # rect, border, color1, color2, enabled
  #-------------------------------------------------------------------------- 
  def draw_fill_border_rect(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    border  = pasn[pos].nil? ? 4 : pasn[pos]            ; pos += 1 
    color1  = pasn[pos].nil? ? system_color : pasn[pos] ; pos += 1 
    color2  = pasn[pos].nil? ? normal_color : pasn[pos] ; pos += 1
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #
    border_halv = border / 2
    draw_border_rect(x, y, width, height, border, color2, enabled)
    draw_filled_rect(x + border_halv, y + border_halv, width - border, height - border, color1, enabled)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Outlined Icon 
  # icon_index: Icon Index
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    border : Border Size
  #    color  : Rect Color
  #   enabled : half opacity?
  #--------------------------------------------------------------------------  
  # icon_index, x, y, width, height, border, color, enabled 
  # icon_index, rect, border, color, enabled
  #--------------------------------------------------------------------------
  def draw_outlined_icon(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; icon_index = pasn[pos] ; pos += 1
    if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos += 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos += 4
    end  
    border  = pasn[pos].nil? ? 4 : pasn[pos]            ; pos += 1 
    color   = pasn[pos].nil? ? system_color : pasn[pos] ; pos += 1 
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #
    draw_border_rect(x, y, width, height, border, color, enabled)
    draw_icon(icon_index, x + ((width - 24) / 2), y + ((height - 24) / 2), enabled = true)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Outlined Item 
  #    item   : Item
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    border : Border Size
  #    color  : Rect Color
  #   enabled : half opacity?
  #--------------------------------------------------------------------------  
  # item, x, y, width, height, border, color, enabled 
  # item, rect, border, color, enabled
  #--------------------------------------------------------------------------
  def draw_outlined_item(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; item = pasn[pos] ; pos += 1
    if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos += 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos += 4
    end  
    border  = pasn[pos].nil? ? 4 : pasn[pos]            ; pos += 1 
    color   = pasn[pos].nil? ? system_color : pasn[pos] ; pos += 1 
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #
    draw_outlined_icon(item.icon_index, x, y, width, height, border, color, enabled = true)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Outlined Actor 
  #    actor  : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    border : Border Size
  #    color  : Rect Color
  #   enabled : half opacity?
  #--------------------------------------------------------------------------  
  # actor, x, y, width, height, border, color, enabled 
  # actor, rect, border, color, enabled
  #--------------------------------------------------------------------------
  def draw_outlined_actor(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; actor = pasn[pos] ; pos += 1
    if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos += 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos += 4
    end  
    border  = pasn[pos].nil? ? 4 : pasn[pos]            ; pos += 1 
    color   = pasn[pos].nil? ? system_color : pasn[pos] ; pos += 1 
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #
    draw_border_rect(x, y, width, height, border, color)
    draw_actor_sprite(actor, x + ((width - 32) / 2), y + ((height - 32) / 2), enabled = true)
  end
    
  #--------------------------------------------------------------------------
  # * Draw Horizontal Gradation Bar
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    value  : Value of Bar - Always forced to positive
  #    max    : Max value of Bar - Always forced to positive
  #    color1 : Bar Color1
  #    color2 : Bar Color2
  #    color3 : Border Color
  #    border : Border Size
  #   enabled : half opacity?
  #--------------------------------------------------------------------------
  # x, y, width, height, value, max, color1, color2, color3, border, enabled
  # rect, value, max, color1, color2, color3, border, enabled
  #--------------------------------------------------------------------------
  def draw_horizontal_grad_bar(*args) ; draw_grad_bar(*args) end
  def draw_grad_bar(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    grey = Color.new(20, 20, 20)
    value   = pasn[pos].abs                        ; pos += 1
    max     = pasn[pos].abs                        ; pos += 1
    color1  = pasn[pos].nil? ? normal_color : pasn[pos] ; pos += 1 
    color2  = pasn[pos].nil? ? system_color : pasn[pos] ; pos += 1
    color3  = pasn[pos].nil? ? grey         : pasn[pos] ; pos += 1
    border  = pasn[pos].nil? ? 4            : pasn[pos] ; pos += 1 
    enabled = pasn[pos].nil? ? true         : pasn[pos]
    # ------------------------------------------------------------------------ #
    bb = border * 2 #4
    hb = bb / 2
    draw_border_rect(x, y, width, height, border, color3, enabled)
    barwidth = (width - bb) * value / max
    unless enabled
      color1.alpha = 128
      color2.alpha = 128
    end  
    drawing_bitmap.gradient_fill_rect(x+hb, y+hb, barwidth, height-bb, color1, color2)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Vertical Gradation Bar
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    value  : Value of Bar - Always forced to positive
  #    max    : Max value of Bar - Always forced to positive
  #    color1 : Bar Color1
  #    color2 : Bar Color2
  #    color3 : Border Color
  #    border : Border Size
  #    invert : Bar Drawn in reverse
  #   enabled : half opacity?
  #--------------------------------------------------------------------------
  # x, y, width, height, value, max, color1, color2, color3, border, invert, enabled
  # rect, value, max, color1, color2, color3, border, invert, enabled
  #--------------------------------------------------------------------------
  def draw_vertical_grad_bar(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    grey = Color.new(20, 20, 20)
    value   = pasn[pos]                             ; pos += 1
    max     = pasn[pos]                             ; pos += 1
    color1  = pasn[pos].nil? ? normal_color : pasn[pos] ; pos += 1 
    color2  = pasn[pos].nil? ? system_color : pasn[pos] ; pos += 1
    color3  = pasn[pos].nil? ? grey         : pasn[pos] ; pos += 1
    border  = pasn[pos].nil? ? 4 : pasn[pos]            ; pos += 1 
    invert  = pasn[pos].nil? ? true : pasn[pos]         ; pos += 1
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #    
    bb = border * 2 #4
    hb = bb / 2
    draw_border_rect(x, y, width, height, 2, color3, enabled)
    barheight = (height - bb) * value / max
    if invert
      y += (height - bb) - barheight
      colorx = color1.clone
      color1 = color2.clone
      color2 = colorx.clone
      colorx = nil
    end  
    drawing_bitmap.gradient_fill_rect(x+hb, y+hb, width-bb, barheight, color1, color2, enabled)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Vertical Gradation Bar 2 # (Solid Undercolor)
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    value  : Value of Bar - Always forced to positive
  #    max    : Max value of Bar - Always forced to positive
  #    color1 : Bar Color1
  #    color2 : Bar Color2
  #    color3 : Border Color
  #    border : Border Size
  #    invert : Bar Drawn in reverse
  #   enabled : half opacity?
  #--------------------------------------------------------------------------
  # x, y, width, height, value, max, color1, color2, color3, border, invert, enabled
  # rect, value, max, color1, color2, color3, border, invert, enabled
  #--------------------------------------------------------------------------
  def draw_vertical_grad_bar2(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    grey = Color.new(20, 20, 20)
    value   = pasn[pos]                             ; pos += 1
    max     = pasn[pos]                             ; pos += 1
    color1  = pasn[pos].nil? ? normal_color : pasn[pos] ; pos += 1 
    color2  = pasn[pos].nil? ? system_color : pasn[pos] ; pos += 1
    color3  = pasn[pos].nil? ? grey         : pasn[pos] ; pos += 1
    border  = pasn[pos].nil? ? 4 : pasn[pos]            ; pos += 1 
    invert  = pasn[pos].nil? ? true : pasn[pos]         ; pos += 1
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #
    bb = border * 2 #4
    hb = bb / 2
    drawing_bitmap.fill_rect(x, y, width, height, color3)
    barheight = (height - bb) * value / max
    if invert
      y += (height - bb) - barheight
      colorx = color1.clone
      color1 = color2.clone
      color2 = colorx.clone
      colorx = nil
    end  
    drawing_bitmap.gradient_fill_rect(x+hb, y+hb, width-bb, barheight, color1, color2, enabled)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Round Gradation Bar
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    value  : Value of Bar - Always forced to positive
  #    max    : Max value of Bar - Always forced to positive
  #    color1 : Bar Color1
  #    color2 : Bar Color2
  #    color3 : Border Color
  #    border : Border Size
  #   enabled : half opacity?
  #--------------------------------------------------------------------------
  # x, y, width, height, value, max, color1, color2, color3, border, enabled
  # rect, value, max, color1, color2, color3, border, enabled
  #--------------------------------------------------------------------------
  def draw_round_grad_bar(*args) 
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    grey = Color.new(20, 20, 20)
    value   = pasn[pos].abs                        ; pos += 1
    max     = pasn[pos].abs                        ; pos += 1
    color1  = pasn[pos].nil? ? grey         : pasn[pos] ; pos += 1 
    color2  = pasn[pos].nil? ? grey         : pasn[pos] ; pos += 1
    color3  = pasn[pos].nil? ? normal_color : pasn[pos] ; pos += 1
    border  = pasn[pos].nil? ? 4            : pasn[pos] ; pos += 1 
    enabled = pasn[pos].nil? ? true         : pasn[pos]
    # ------------------------------------------------------------------------ #
    bb = 2#border * 2 #4
    hb = 1
    #hb = bb / 2
    draw_border_rect(x, y, width, height, border, color3, enabled)
    barwidth = (width - bb) * value / max
    unless enabled
      color1.alpha = 128
      color2.alpha = 128
    end  
    drawing_bitmap.gradient_fill_rect(x+hb, y+hb, barwidth, height-bb, color1, color2)
    drawing_bitmap.clear_rect(x, y, 1, 1)
    drawing_bitmap.clear_rect(x+width-1, y, 1, 1)
    drawing_bitmap.clear_rect(x, y+height-1, 1, 1)
    drawing_bitmap.clear_rect(x+width-1, y+height-1, 1, 1)
  end

  #--------------------------------------------------------------------------
  # * Draw Filled Rect - Spaced
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    spacing: Spacing
  #    color1 : Bar Color1
  #    color2 : Base Color
  #--------------------------------------------------------------------------
  # x, y, width, height, spacing, color1, color2, vertical
  # rect, spacing, color1, color2, vertical
  #--------------------------------------------------------------------------
  def fill_rect_spaced(*args) 
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    spacing = pasn[pos].nil? ? 2                : pasn[pos] ; pos += 1 
    color1  = pasn[pos].nil? ? hp_gauge_color1  : pasn[pos] ; pos += 1 
    color2  = pasn[pos].nil? ? gauge_back_color : pasn[pos] ; pos += 1
    vertical= pasn[pos].nil? ? false            : pasn[pos] ; pos += 1
    drawing_bitmap.fill_rect( x, y, width, height, color2 ) 
    if vertical
      for i in 0...height
        drawing_bitmap.fill_rect( x+i, y, width, 1, color1 ) if i % spacing == 0
      end  
    else
      for i in 0...width
        drawing_bitmap.fill_rect( x+i, y, 1, height, color1 ) if i % spacing == 0
      end  
    end  
  end  
  
  #--------------------------------------------------------------------------
  # * Draw Gradient Rect - Spaced
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    spacing: Spacing
  #    color1 : Bar Color 1
  #    color2 : Bar Color 2
  #    color3 : Base Color
  #--------------------------------------------------------------------------
  # x, y, width, height, spacing, color1, color2, color3, vertical
  # rect, spacing, color1, color2, color3, vertical
  #--------------------------------------------------------------------------
  def gradient_rect_spaced(*args) 
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    spacing = pasn[pos].nil? ? 2                : pasn[pos] ; pos += 1 
    color1  = pasn[pos].nil? ? hp_gauge_color1  : pasn[pos] ; pos += 1 
    color2  = pasn[pos].nil? ? hp_gauge_color2  : pasn[pos] ; pos += 1
    color3  = pasn[pos].nil? ? gauge_back_color : pasn[pos] ; pos += 1
    vertical= pasn[pos].nil? ? false            : pasn[pos] ; pos += 1
    drawing_bitmap.fill_rect( x, y, width, height, color3 ) 
    bitm = ::Bitmap.new( width, height )
    bitm.gradient_fill_rect( 0,0,width,height, color1, color2 )
    if vertical
      for i in 0..height
        bitm.clear_rect( i, 0, width, 1 ) if i % spacing == 0
      end  
    else  
      for i in 0..width
        bitm.clear_rect( i, 0, 1, height ) if i % spacing == 0
      end  
    end  
    drawing_bitmap.blt( x, y, bitm, bitm.rect )
    bitm.dispose()
  end
  
  #--------------------------------------------------------------------------
  # * Draw System Tile
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------  
  def draw_system_tile( tile_id, x, y, width=32, height=32 )
    set_number = tile_id / 256
    bmp = Cache.system("TileB") if set_number == 0
    bmp = Cache.system("TileC") if set_number == 1
    bmp = Cache.system("TileD") if set_number == 2
    bmp = Cache.system("TileE") if set_number == 3
    return if bmp.nil?()
    sx = (tile_id / 128 % 2 * 8 + tile_id % 8) * 32;
    sy = tile_id % 256 / 8 % 16 * 32;
    rect = Rect.new( sx, sy, width, height )
    drawing_bitmap.blt( x, y, bmp, rect )
  end
  
  # // ----------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # * Draw Jagged Rect
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #     spac  : Spacing
  #    border : Border Size
  #    color  : Border Color
  #    color2 : Jagged Color
  #   enabled : half opacity?
  #--------------------------------------------------------------------------
  def draw_jagged_rect(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    spac    = pasn[pos].nil? ? 2 : pasn[pos]            ; pos += 1
    border  = pasn[pos].nil? ? 4 : pasn[pos]            ; pos += 1 
    color   = pasn[pos].nil? ? system_color : pasn[pos] ; pos += 1 
    color2  = pasn[pos].nil? ? normal_color : pasn[pos] ; pos += 1 
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #
    draw_border_rect(x, y, width, height, border, color, enabled = true)
    draw_dotted_rect(x, y, width, height, spac, border, color2, enabled = true)
    border_halv = border / 2
    bitmap_bite_out(x + border_halv, y + border_halv, width - border, height - border)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Dotted Rect
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #     spac  : Spacing
  #    border : Border Size
  #    color  : Jagged Color
  #   enabled : half opacity?
  #--------------------------------------------------------------------------
  def draw_dotted_rect(*args)
    # ------------------------------------------------------------------------ #
    pos = 0
    pasn = *args ; if pasn[pos].is_a?(Rect)
      rect = pasn[pos]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      pos = 1
    else 
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
      pos = 4
    end  
    spac    = pasn[pos].nil? ? 2 : pasn[pos]            ; pos += 1
    border  = pasn[pos].nil? ? 4 : pasn[pos]            ; pos += 1 
    color   = pasn[pos].nil? ? normal_color : pasn[pos] ; pos += 1 
    enabled = pasn[pos].nil? ? true : pasn[pos]
    # ------------------------------------------------------------------------ #
    color.alpha = enabled ? 255 : 128
    border_hal = border / 2
    restx = x - border_hal ; resty = y - border_hal
    spotx = restx ; spoty = resty
    coun = 0
    max_spotter = (width / spac) + border_hal
    aew = width + border_hal
    aeh = height + border_hal
    ae = aew * aeh
    for i in 0..ae
      drawing_bitmap.set_pixel(spotx, spoty, color)
      spotx += spac
      coun += 1
      if coun == max_spotter
        coun = 0
        spotx = restx
        spoty += spac
      end
      break if spoty > height
    end   
  end 
  
  #--------------------------------------------------------------------------
  # * Draw Jagged Rect
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #--------------------------------------------------------------------------
  def bitmap_bite_out(*args) 
    pos = 0
    pasn = *args
    if pasn.is_a?(Rect)
      x, y, width, height = pasn[pos].x, pasn[pos].y, pasn[pos].width, pasn[pos].height
    else
      x, y, width, height = pasn[pos], pasn[pos+1], pasn[pos+2], pasn[pos+3]
    end  
    bite = Rect.new(x, y, width, height)
    drawing_bitmap.clear_rect(bite)
  end
  
  def draw_short_hp(actor, x, y, width = 64, bar=true)
    draw_actor_hp_gauge(actor, x, y, width) if bar
    drawing_bitmap.draw_text(x, y, width, WLH, Vocab.hp, 0)
    drawing_bitmap.draw_text(x, y, width, WLH, actor.hp, 2)
  end
   
  def draw_short_mp(actor, x, y, width = 64, bar=true)
    draw_actor_mp_gauge(actor, x, y, width) if bar
    drawing_bitmap.draw_text(x, y, width, WLH, Vocab.mp, 0)
    drawing_bitmap.draw_text(x, y, width, WLH, actor.mp, 2)
  end
   
  def draw_command_icon_box(x, y, commandi, icon_index, boxsize = 32, border = 4, color = system_color, enabled = true)
    draw_border_rect(x, y, boxsize, boxsize, border, color)
    draw_icon(icon_index, x + ((boxsize - 24) / 2), y + ((boxsize - 24) / 3), enabled)
    draw_format_text(x, y + (boxsize - 24), boxsize, 16, commandi, 1, 16)
  end
   
  def draw_command_actor_box(x, y, commandi, actor, boxsize = 32, border = 4, color = system_color, enabled = true)
    draw_border_rect(x, y, boxsize, boxsize, border, color)
    draw_actor_sprite(actor, x + ((boxsize - 32) / 2), y + ((boxsize - 32) / 3), enabled)
    draw_format_text(x, y + (boxsize - 24), boxsize, 16, commandi, 1, 16)
  end
   
  def draw_text_fraction_style(x, y, text1, text2, enabled = true)
    old_font_color = drawing_bitmap.font.color
    old_font_size = drawing_bitmap.font.size
    drawing_bitmap.font.color = normal_color
    drawing_bitmap.font.color.alpha = enabled ? 255 : 128
    drawing_bitmap.font.size = 14
    drawing_bitmap.draw_text(x - 8, y - 4, 32, WLH, text1)
    drawing_bitmap.font.size = 18
    drawing_bitmap.draw_text(x + 8, y + 4, 32, WLH, "/")
    drawing_bitmap.font.size = 14
    drawing_bitmap.draw_text(x + 16, y + 8, 32, WLH, text2)
    drawing_bitmap.font.color = old_font_color
    drawing_bitmap.font.size = old_font_size
  end
  
  #--------------------------------------------------------------------------
  # * Draw Extended Parameter
  #    actor  : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    type   : type_of stat
  #--------------------------------------------------------------------------
  def draw_extended_actor_parameter(actor, x, y, type)
    case type
    when 0
      icon = 1
    when 1
      icon = 53
    when 2
      icon = 20 
    when 3
      icon = 137
    end
    draw_icon(icon, x, y)
    draw_actor_parameter(actor, x + 32, y, type)
  end
  
  def draw_all_actor_parameters(actor, x, y)
    for i in 0..3
      draw_extended_actor_parameter(actor, x, y, i)
      y += 32
    end
  end
)  
end

#==============================================================================#
# Bitmap
#==============================================================================#
class Bitmap
  
  include BitmapXtended
  module_eval( BMP_XTND_MODULE_INCL )
  
  def drawing_bitmap ; return self                   end
  def pallete_bitmap ; return Cache.system("Window") end
    
end 
  
#==============================================================================#
# Sprite
#==============================================================================#
class Sprite
  
  include BitmapXtended
  module_eval( BMP_XTND_MODULE_INCL )
  
  def drawing_bitmap ; return self.bitmap            end
  def pallete_bitmap ; return Cache.system("Window") end
    
end  
  
#==============================================================================#
# Window_Base
#==============================================================================#
class Window_Base < Window
  
  include BitmapXtended
  module_eval( BMP_XTND_MODULE_INCL )
  
  def drawing_bitmap ; return self.contents end
  def pallete_bitmap ; return windowskin    end
  
end  
  
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#