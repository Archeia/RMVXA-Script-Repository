#==============================================================================#
# ** IEX(Icy Engine Xelion) - Extended Item Description
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Item Scene)
# ** Script Type   : Extended Description
# ** Date Created  : 12/03/2010
# ** Date Modified : 07/24/2011
# ** Requested By  : phropheus
# ** Version       : 2.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This adds a little description window to the item scene, you can then
# write a larger description for the item using the specified tags.
# So what has changed?
# Well the description window is now a message, therefore all the
# tags you could use with the message window should work here.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# 2.0
#  Notetags! Placed in Item, Weapons, Armor noteboxes 
# (Anything that can be seen in the item scene)
#------------------------------------------------------------------------------#
# <ex_description>
#  Your description goes here
# </ex_description>
#
# There is a small tag for the description.
# \sln, will place the current line onto the last one
# This was created to compensate for small noteboxes.
# EG
# <ex_description>
# \c[2]Yummy, yummy, cherry, sherry,
# How your taste lingers on my tongue,\sln
# your sweetness touches my heart,
# Yummy, yummy, cherry, sherry. \sln
# \c[0]
# ~IceDragon
# </ex_description>
#
# -Will produce-
# Yummy, yummy, cherry, sherry, How your taste lingers on my tongue,
# your sweetness touches my heart, Yummy, yummy, cherry, sherry.
#
# ~IceDragon
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
# (DD/MM/YYYY)
#  12/04/2010 - V1.0  Completed Script 
#  01/16/2011 - V2.0  Large change to description window, now uses the
#                     message window instead
#                     This means that any message window tag should work
#                     with it.
#  07/24/2011 - V2.1  Edited for the IEX Recall
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
  # * DESCRIPTION_POS - OBSOLETE
  #--------------------------------------------------------------------------#
  # This is the position and opacity of the description window.
  # Its closed, so you won't see it on opening the item scene
  # DESCRIPTION_POS = [x, y, width, height, opacity]
  #--------------------------------------------------------------------------#
    # Note this is not used with this version of the EX_Description
    DESCRIPTION_POS = [0, Graphics.height - 192, Graphics.width, 192, 255]
  #--------------------------------------------------------------------------#
  # * ROW_COUNT - Only works for YEM Message Melody
  #--------------------------------------------------------------------------#
  # Since this version makes use of the Message System
  #--------------------------------------------------------------------------#  
    ROW_COUNT = 6
  #--------------------------------------------------------------------------#
  # * BUTTON
  #--------------------------------------------------------------------------#
  # This is the button which toggles the Description window open/closed
  #--------------------------------------------------------------------------#
    BUTTON    = Input::SHIFT
  #--------------------------------------------------------------------------#
  # * SCROLL_DELAY - OBSOLETE
  #--------------------------------------------------------------------------#
  # If the description size exceeds the windows height, then it will scroll
  # down, the more the delay the slower it scrolls.
  #--------------------------------------------------------------------------#
    # Note this is not used with this version of the EX_Description
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
  # * USE?
  #--------------------------------------------------------------------------#
  # Should this be used for?
  #--------------------------------------------------------------------------#  
    FOR_SKILLS= true
    FOR_ITEMS = true
  #--------------------------------------------------------------------------#
  # * DRAW_ITEM - OBSOLETE
  #--------------------------------------------------------------------------#
  # DRAW_ITEM will write the items name
  # DRAW_ICON will draw the items icon
  # DRAW_RECT is used with DRAW_ICON to border it
  # *Common Sense, don't use DRAW_RECT without DRAW_ICON... It looks retarted.
  # RECT_SIZE = [x, y, width, height]
  # ICON_OPOS = [ox, oy]
  # TEXT_OPOS = [ox, oy]
  #--------------------------------------------------------------------------#  
    # Note this is not used with this version of the EX_Description
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
# ** IEX_ExDes_Window
#==============================================================================#
class IEX_ExDes_Window < Window_Message #Window_Selectable

  #--------------------------------------------------------------------------#
  # * Include Module(s)
  #--------------------------------------------------------------------------#
  include IEX::ITEM_EX_DES
  
  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#   
  attr_accessor :item
  
  #--------------------------------------------------------------------------#
  # * method :initialize
  #--------------------------------------------------------------------------# 
  def initialize() #(x, y, width, height)
    super() #(x, y, width, height)
    @stx      = x
    @sty      = y
    @stw      = width
    @sth      = height 
    @item     = nil
    @index    = -1
    @text_set = []
    @item_max = 3
    if $imported["CustomMessageMelody"]
      @old_row_count = $game_variables[YEM::MESSAGE::ROW_VARIABLE]
      $game_variables[YEM::MESSAGE::ROW_VARIABLE] = ROW_COUNT
    end  
  end

  #--------------------------------------------------------------------------#
  # * method :dispose
  #--------------------------------------------------------------------------# 
  def dispose()
    super()
    if $imported["CustomMessageMelody"]
      $game_variables[YEM::MESSAGE::ROW_VARIABLE] = @old_row_count
    end
  end
  
  #--------------------------------------------------------------------------#
  # * method :set_item
  #--------------------------------------------------------------------------# 
  def set_item( item )
    return if @item == item
    @item = item
    self.contents.clear()
    return if @item.nil?()
    $game_message.texts = @item.ex_description()
    reset_window()
    start_message()
  end
    
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

# // If Items are enabled do this
if IEX::ITEM_EX_DES::FOR_ITEMS
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
      loop do
        @ex_des_window.update()
        break if @ex_des_window.openness == 0
        Graphics.update()
        Input.update()
      end 
    end 
  end
  
end

end # FOR_ITEMS

# // If Skills are enabled do this
if IEX::ITEM_EX_DES::FOR_SKILLS
    
#==============================================================================#
# ** Scene_Skill
#==============================================================================#
class Scene_Skill < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias-method :start
  #--------------------------------------------------------------------------#   
  alias iex_xd_ss_start start unless $@
  def start( *args, &block )
    op = IEX::ITEM_EX_DES::OPEN_SFX
    cl = IEX::ITEM_EX_DES::CLOSE_SFX
    @op_sfx = RPG::SE.new(op[0], op[1], op[2])
    @cl_sfx = RPG::SE.new(cl[0], cl[1], cl[2])  
    iex_xd_ss_start( *args, &block )
    exdes_pos = IEX::ITEM_EX_DES::DESCRIPTION_POS
    @ex_des_window = IEX_ExDes_Window.new()
    @ex_des_window.opacity = exdes_pos[4]
    @ex_des_window.openness = 0  
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :terminate
  #--------------------------------------------------------------------------#   
  alias iex_xd_ss_terminate terminate unless $@
  def terminate( *args, &block )
    unless @ex_des_window.nil?()
      @ex_des_window.dispose()
      @ex_des_window = nil
    end 
    iex_xd_ss_terminate( *args, &block ) 
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#   
  alias iex_xd_ss_update update unless $@
  def update( *args, &block )
    iex_xd_ss_update( *args, &block )
    if @ex_des_window != nil && @skill_window.active()
      if Input.trigger?(IEX::ITEM_EX_DES::BUTTON)
        if @ex_des_window.openness > 0
          @ex_des_window.close()
          @cl_sfx.play()
        else
          @op_sfx.play()
          if @skill_window.skill != nil
            @ex_des_window.open()
            @ex_des_window.item = nil
            @ex_des_window.set_item( @skill_window.skill )
            @ex_des_window.openness = 1
          else
            Sound.play_buzzer()
          end  
        end          
      end  
      loop do
        @ex_des_window.update()
        break if @ex_des_window.openness == 0
        Graphics.update()
        Input.update()
      end 
    end 
  end
  
end

end # End FOR_SKILLS

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#