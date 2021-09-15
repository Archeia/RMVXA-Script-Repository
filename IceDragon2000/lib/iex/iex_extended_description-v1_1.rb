#==============================================================================#
# ** IEX(Icy Engine Xelion) - Extended Item Description
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Item Scene)
# ** Script Type   : Extended Description
# ** Date Created  : 12/03/2010
# ** Date Modified : 07/24/2011
# ** Requested By  : phropheus
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This adds a little description window to the item scene, you can then
# write a larger description for the item using the specified tags.
# 
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# 1.0
#  Notetags! Placed in Item, Weapons, Armor noteboxes 
# (Anything that can be seen in the item scene)
#------------------------------------------------------------------------------#
# <ex_description>
#  Your description goes here
# </ex_description>
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
# 
# Default Item Scene 
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# 12/04/2010 - V1.0 Completed Script 
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#  
#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported ||= {} 
$imported["IEX_EX_Description"] = true

#==============================================================================#
# ** IEX::ITEM_EX_DES
#==============================================================================#
module IEX
  module ITEM_EX_DES
#==============================================================================#
#                           Start Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * DESCRIPTION_POS
  #--------------------------------------------------------------------------#
  # This is the position and opacity of the description window.
  # Its closed, so you won't see it on opening the item scene
  # DESCRIPTION_POS = [x, y, width, height, opacity]
  #--------------------------------------------------------------------------#
    DESCRIPTION_POS = [0, Graphics.height - 192, Graphics.width, 192, 255]
  #--------------------------------------------------------------------------#
  # * BUTTON
  #--------------------------------------------------------------------------#
  # This is the button which toggles the Description window open/closed
  #--------------------------------------------------------------------------#
    BUTTON    = Input::SHIFT
  #--------------------------------------------------------------------------#
  # * SCROLL_DELAY
  #--------------------------------------------------------------------------#
  # If the description size exceeds the windows height, then it will scroll
  # down, the more the delay the slower it scrolls.
  #--------------------------------------------------------------------------#
    SCROLL_DELAY = 10
  #--------------------------------------------------------------------------#
  # * SFX
  #--------------------------------------------------------------------------#
  # These are the sfx played when the window is opened/closed
  # If you don't want any SFX use this :
  # ["", 0, 100]
  #--------------------------------------------------------------------------#
    OPEN_SFX  = ["Book", 60, 100]
    CLOSE_SFX = ["Thunder3", 60, 100]
  #--------------------------------------------------------------------------#
  # * DRAW_ITEM
  #--------------------------------------------------------------------------#
  # DRAW_ITEM will write the items name
  # DRAW_ICON will draw the items icon
  # DRAW_RECT is used with DRAW_ICON to border it
  # *Common Sense, don't use DRAW_RECT without DRAW_ICON... It looks retarted.
  # RECT_SIZE = [x, y, width, height]
  # ICON_OPOS = [ox, oy]
  # TEXT_OPOS = [ox, oy]
  #--------------------------------------------------------------------------#  
    DRAW_ITEM = true
    DRAW_RECT = true
    DRAW_ICON = true
    RECT_SIZE = [4, 4, 32, 32]
    ICON_OPOS = [4, 4]
    TEXT_OPOS = [40, 12]
#==============================================================================#
#                           End Customization
#------------------------------------------------------------------------------#
#==============================================================================# 
  end
end

#==============================================================================#
# ** IEX::IString
#==============================================================================#
module IEX
  module IString
    
    # Converts a single line string into an array, with a max char per line
    # This may come out ackward at times
    def self.text_to_array(wtext, char_per_line)
      text = wtext.scan(/./).clone
      coun = 0
      rindex = 0
      arra = []
      last = 0
      arra[rindex] = ''
      allow_next = false
      text.each { |ch| 
        allow_next = false
        arra[rindex] += ch.to_s
        coun += 1
        if arra[rindex].scan(/./m).size >= char_per_line and ch.to_s == ' '
          allow_next = true
        end  
        if arra[rindex].scan(/./m).size >= char_per_line and allow_next
          rindex += 1
          arra[rindex] = ''
          coun = 0
        end  
      } 
      return arra
    end
    
  end
end

#==============================================================================#
# ** RPG::BaseItem
#==============================================================================#
class RPG::BaseItem

  #--------------------------------------------------------------------------#
  # * new-method :iex_xtend_des_cache
  #--------------------------------------------------------------------------#     
  def iex_xtend_des_cache()
    @ex_description = []
    @ds_on = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:EX_DESCRIPTION|ex description)>/i
        @ds_on = true
      when /<\/(?:EX_DESCRIPTION|ex description)>/i
        @ds_on = false
      else
        if @ds_on
          if line.to_s.scan(/\\sln/).size > 0
            @ex_description[-1] = "" if @ex_description[-1].nil?
            @ex_description[-1] += line.to_s.gsub(/\\sln/) { "" }
          else  
            @ex_description << line.to_s 
          end  
        end  
      end  
    }
    @ds_on = false
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :ex_description
  #--------------------------------------------------------------------------#  
  def ex_description()
    iex_xtend_des_cache if @ex_description.nil?()
    return @ex_description 
  end
  
end

#==============================================================================#
# ** Window_Base
#==============================================================================#
class Window_Base < Window
  
  #--------------------------------------------------------------------------#
  # * Draw Border Rect
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #    width  : Rect width
  #    height : Rect height
  #    border : Border Size
  #    color  : Rect Color
  #--------------------------------------------------------------------------#  
  def draw_border_rect(x, y, width, height, border = 4, color = system_color, enabled = true)
    outline = Rect.new(0, 0, width, height)
    sub_rect = Rect.new((border / 2), (border / 2), (outline.width - border), (outline.height - border))
    outline_sprite = Bitmap.new(outline.width, outline.height)
    outline_sprite.fill_rect(outline, color)
    outline_sprite.clear_rect(sub_rect)
    self.contents.blt(x, y, outline_sprite, outline, enabled ? 255 : 128)
  end
  
end

#==============================================================================#
# ** IEX_ExDes_Window
#==============================================================================#
class IEX_ExDes_Window < Window_Selectable
  
  #--------------------------------------------------------------------------#
  # * Include Module(s)
  #--------------------------------------------------------------------------#
  include IEX::ITEM_EX_DES
  
  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------# 
  attr_accessor :scroll_delay_max
  attr_accessor :scroll_delay
  
  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------# 
  def initialize( x, y, width, height )
    super( x, y, width, height )
    @item             = nil
    @index            = -1
    @text_set         = []
    @item_max         = 3
    @scroll_delay     = 10
    @scroll_delay_max = SCROLL_DELAY
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_item
  #--------------------------------------------------------------------------# 
  def set_item( item )
    return if @item == item
    @item = item
    @text_set = []
    @scroll_delay = @scroll_delay_max
    self.oy = 0
    self.contents.font.size = 18
    char_lim = self.contents.width / self.contents.text_size("W").width
    if @item.nil?()
      @text_set = IEX::IString.text_to_array(@item.ex_description, char_lim)
    else  
      @text_set = []
    end  
    @item_max = @text_set.size
    create_contents
    return if @item.nil?()
    if DRAW_ITEM
      if DRAW_RECT
        rect = Rect.new(RECT_SIZE[0], RECT_SIZE[1], RECT_SIZE[2], RECT_SIZE[3])
        self.contents.fill_rect(rect, Color.new(166, 124, 82, 128))
        draw_border_rect(rect.x, rect.y, rect.width, rect.height, 4, Color.new(126, 84, 42))
      end
      if DRAW_ICON
        draw_icon(@item.icon_index, RECT_SIZE[0] + ICON_OPOS[0], RECT_SIZE[1] + ICON_OPOS[1])
      end  
      self.contents.font.color = system_color  
      self.contents.font.size = 21
      self.contents.draw_text(TEXT_OPOS[0], TEXT_OPOS[1], self.contents.width - TEXT_OPOS[0], 24, @item.name)
    end  
    self.contents.font.color = normal_color
    self.contents.font.size = 18
    for i in 0..@item_max
      draw_item(i)
    end  
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :draw_item
  #--------------------------------------------------------------------------# 
  def draw_item( index )
    rect = item_rect( index )
    tx = @text_set[index]
    if DRAW_ITEM and DRAW_RECT
      rect.y += RECT_SIZE[3] + RECT_SIZE[1]
    end  
    self.contents.draw_text( rect.x, rect.y, self.width, 24, tx )
  end
  
  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#   
  def update()
    super()
    update_help_scroll()
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :update_help_scroll
  #--------------------------------------------------------------------------#   
  def update_help_scroll()
    @scroll_delay -= 1 unless @scroll_delay == 0
    if @scroll_delay == 0
      if self.contents.height > self.height - 32
        self.oy += 1
        @scroll_delay = @scroll_delay_max
        if (self.height + self.oy)-32 >= self.contents.height
          self.oy = 0
        end  
      end  
    end  
  end
  
  #--------------------------------------------------------------------------#
  # * kill-methods :cursor_*
  #--------------------------------------------------------------------------# 
  def cursor_down(wrap = false) end
  def cursor_up(wrap = false) end
  def cursor_left(wrap = false) end
  def cursor_right(wrap = false) end
  def cursor_pageup(wrap = false) end
  def cursor_pagedown(wrap = false) end   
    
end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias-method :load_database
  #--------------------------------------------------------------------------#  
  alias :iex_xtend_des_load_database :load_database unless $@
  def load_database()
    iex_xtend_des_load_database()
    load_xtend_des_cache()
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :load_bt_database
  #--------------------------------------------------------------------------#  
  alias :iex_xtend_des_load_bt_database :load_bt_database unless $@
  def load_bt_database()
    iex_xtend_des_load_bt_database()
    load_xtend_des_cache()
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :load_xtend_des_cache
  #--------------------------------------------------------------------------#  
  def load_xtend_des_cache()
    for obj in ($data_items + $data_weapons + $data_armors + $data_skills).compact
      obj.iex_xtend_des_cache()
    end  
  end
  
end

#==============================================================================#
# ** Scene_Item
#==============================================================================#
class Scene_Item < Scene_Base
  
  #--------------------------------------------------------------------------#
  # * alias-method :start
  #--------------------------------------------------------------------------#
  alias iex_xd_si_start start unless $@
  def start( *args, &block )
    op = IEX::ITEM_EX_DES::OPEN_SFX
    cl = IEX::ITEM_EX_DES::CLOSE_SFX
    @op_sfx = RPG::SE.new(op[0], op[1], op[2])
    @cl_sfx = RPG::SE.new(cl[0], cl[1], cl[2])  
    iex_xd_si_start( *args, &block )
    exdes_pos = IEX::ITEM_EX_DES::DESCRIPTION_POS
    @ex_des_window = IEX_ExDes_Window.new
    @ex_des_window.opacity = exdes_pos[4]
    @ex_des_window.openness = 0  
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :terminate
  #--------------------------------------------------------------------------#
  alias iex_xd_si_terminate terminate unless $@
  def terminate( *args, &block )
    unless @ex_des_window.nil?()
      @ex_des_window.dispose
      @ex_des_window = nil
    end 
    iex_xd_si_terminate( *args, &block ) 
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias iex_xd_si_update update unless $@
  def update( *args, &block )
    iex_xd_si_update( *args, &block )
    if @ex_des_window != nil and @item_window.active
      if Input.trigger?(IEX::ITEM_EX_DES::BUTTON)
        if @ex_des_window.openness > 0
          @ex_des_window.close()
          @cl_sfx.play()
        else
          @op_sfx.play()
          if @item_window.item != nil
            @ex_des_window.open()
            @ex_des_window.item = nil
            @ex_des_window.set_item( @item_window.item )
            @ex_des_window.openness = 1
          else
            Sound.play_buzzer()
          end  
        end          
      end
    end  
  end
  
end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#