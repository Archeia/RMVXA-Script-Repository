#==============================================================================#
# ** IEX(Icy Engine Xelion) - Equipment Scene - CMV(Cosmetic Version)
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : ReWrite + Cosmetic
# ** Date Created  : 2010/10/10
# ** Date Modified : 2016/01/06
# ** Requested by  : Kyriaki
# ** Vesrion       : 1.4
#------------------------------------------------------------------------------#
#==============================================================================#
# **INTRODUCTION
#------------------------------------------------------------------------------#
# ** This is a edit of the default Equipment scene.
# ** Giving it a bit more tastefulness.
# ** In addition to window Manipulation (I reccomend not messing with it, >,<
#                                        I spent too long arranging correctly)
# ** And Icons for basically everything
# ** There is also a skinning feature to allow quick insertion of a custom window
#    Background
#
#------------------------------------------------------------------------------#
#==============================================================================#
# **CHANGES
#------------------------------------------------------------------------------#
# ** Scene_Equip
#    alias
#      start
#      terminate
#
# ** Window_Equip, Window_EquipItem, Window_EquipStatus
#    overwrite
#      initialize
#      refresh
#
#------------------------------------------------------------------------------#
#==============================================================================#
# **COMPATABILTIES
#------------------------------------------------------------------------------#
#
# * Well its suppose to work with almost everything. Unless somethings edits
#   something mentioned in the Changes
#
#------------------------------------------------------------------------------#
#==============================================================================#
# **KNOWN ISSUES
#------------------------------------------------------------------------------#
#
# ** Non at the moment.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# **CHANGE LOG
#------------------------------------------------------------------------------#
#
#  2010/10/10 - V1.0  - Finished Script
#  2010/10/26 - V1.1  - Fixed skin problem
#  2011/01/06 - V1.2  - Quick fix your color issue
#  2011/07/10 - V1.3  - Improved window drawing. (Should load faster now)
#  2016/01/06 - 1.4.0 - Changed import system to ScriptDep
#
#------------------------------------------------------------------------------#
$simport.r 'iex/scene_equip_cmv', '1.4.0', 'A cosmetic upgrade of the Equip Scene'
#==============================================================================
# ** IEX::COSMETIC_EQUIP
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module COSMETIC_EQUIP
#------------------------------------------------------------------------------#
# ** Start Customization
#------------------------------------------------------------------------------#
    # Window Size and Positioing Information
    # If you are unsure of what to do, leave it.
    # Also DO NOT have the width or height LESS than 32.
    # But why would you do that? You couldn't see anything.
    WINDOW_POS_SIZE = {
    # :some window  => [x, y, width, height, opacity]
      :equip_window => [242, 56, 302, 152, 255],
      :help_window  => [0, 0, 544, 56, 255],
      :status_window=> [0, 56, 242, (416 - 56), 255],
      :item_window  => [242, 208, 302, 208, 255],
    } # Do not remove

    # Window Skins
    WINDOW_SKINS = {
    # These are located in your System Folder, they are expected to be the same
    # size as the window it self, but not limited to.
    # When set to nil, no skin is used for that window
    # Be sure to set the opacity of the window to 0 when using this
      :equip_window => nil,
      :help_window  => nil,
      :status_window=> nil,
      :item_window  => nil,
    } # Do not remove

    # Equipment Catergories
    USE_CATERGORY_ICONS = true
    CATERGORY_ICONS = {
    # :catergory => icon_index,
      :weapon    => 1,
      :shield    => 53,
      :head      => 32,
      :armor     => 42,
      :accessory => 33,
    } # Do not remove

    # Actor Status
    USE_STAT_ICONS = true
    STAT_ICONS = {
    # :stat => icon_index,
      :atk  => 2,
      :def  => 52,
      :spi  => 20,
      :agi  => 109,
      # These are only used if DRAW_EXTENDED_STUFF == true
      :hp   => 200,
      :mp   => 201,
      :lvl  => 131,
      :class=> 137,
    } # Do not remove

    USE_ACTOR_FACE = true # Should the actor's face be drawn?
    DRAW_EXTENDED_STUFF = true # Draw actors Lv, Hp, Mp, and class
    # Other things
    NEW_STAT_ARROW = ">"
    CLASS_TEXT = "Job"
#------------------------------------------------------------------------------#
# ** End Customization
#------------------------------------------------------------------------------#
  end
end

#==============================================================================
# ** IEX_Cosmetic_Equip_Help
#------------------------------------------------------------------------------
#==============================================================================
class IEX_Cosmetic_Equip_Help < Window_Help
  attr_accessor :back_sprite

  def initialize
    super
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super
  end

  def update
    super
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end
end

#==============================================================================
# ** Window_Equip
#------------------------------------------------------------------------------
#==============================================================================
class Window_Equip < Window_Selectable
  attr_accessor :back_sprite
  attr_accessor :skip_refresh

  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x     : window X coordinate
  #     y     : window Y corrdinate
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(x, y, actor)
    @skip_refresh = true
    super(x, y, 336, WLH * 5 + 32)
    @actor = actor
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
    refresh
    self.index = 0
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super
  end

  def update
    super
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end

  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end

  def make_item_list
    @data = @actor.equips.to_a
    @item_max = @data.size
  end

  def line_height
    WLH
  end

  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    make_item_list
    self.contents.font.size = Font.default_size
    self.contents.font.color = system_color
    text_x = 4
    cat_icons = IEX::COSMETIC_EQUIP::CATERGORY_ICONS
    if IEX::COSMETIC_EQUIP::USE_CATERGORY_ICONS
      draw_icon(cat_icons[:weapon], text_x, line_height * 0)
      if @actor.two_swords_style
        draw_icon(cat_icons[:weapon], text_x, line_height * 1)
      else
        draw_icon(cat_icons[:shield], text_x, line_height * 1)
      end
      draw_icon(cat_icons[:head], text_x, line_height * 2)
      draw_icon(cat_icons[:armor], text_x, line_height * 3)
      draw_icon(cat_icons[:accessory], text_x, line_height * 4)
      text_x += 24
    end

    if @actor.two_swords_style
      contents.draw_text(text_x, line_height * 0, 92, line_height, Vocab.weapon1)
      contents.draw_text(text_x, line_height * 1, 92, line_height, Vocab.weapon2)
    else
      contents.draw_text(text_x, line_height * 0, 92, line_height, Vocab.weapon)
      contents.draw_text(text_x, line_height * 1, 92, line_height, Vocab.armor1)
    end

    contents.draw_text(text_x, line_height * 2, 92, line_height, Vocab.armor2)
    contents.draw_text(text_x, line_height * 3, 92, line_height, Vocab.armor3)
    contents.draw_text(text_x, line_height * 4, 92, line_height, Vocab.armor4)

    off_x_sub = 12
    contents.font.size = 18
    5.times do |i|
      draw_item_name(@data[i], text_x + 96 + off_x_sub, line_height * i)
    end
  end
end

#==============================================================================
# ** Window_EquipStatus
#------------------------------------------------------------------------------
#==============================================================================
class Window_EquipStatus < Window_Base
  attr_accessor :back_sprite
  attr_accessor :skip_refresh

  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x     : window X coordinate
  #     y     : window Y corrdinate
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(x, y, actor)
    @skip_refresh = true
    super(x, y, 208, WLH * 5 + 32)
    @actor = actor
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
    refresh
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super
  end

  def update
    super
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end

  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    off_y = 0
    y_pos = 0
    if IEX::COSMETIC_EQUIP::USE_ACTOR_FACE
      y_pos = 128
      draw_actor_name(@actor, 4, 96)
      draw_actor_face(@actor, 4, 0)
    else
      off_y = 24
      y_pos = 24
      draw_actor_name(@actor, 4, 0)
    end

    if IEX::COSMETIC_EQUIP::DRAW_EXTENDED_STUFF
      off_x = 0
      off_y = 96
      wd = self.contents.width
      if IEX::COSMETIC_EQUIP::USE_STAT_ICONS
        off_x = 24

        stat_icons = IEX::COSMETIC_EQUIP::STAT_ICONS
        draw_icon(stat_icons[:class], 0, y_pos)
        draw_icon(stat_icons[:lvl], 0, y_pos + (WLH * 1))
        draw_icon(stat_icons[:hp], 0, y_pos + (WLH * 2))
        draw_icon(stat_icons[:mp], 0, y_pos + (WLH * 3))
      end
      # Draw Class
      self.contents.font.color = system_color
      self.contents.draw_text(4 + off_x, y_pos, wd, WLH, IEX::COSMETIC_EQUIP::CLASS_TEXT, 0)
      self.contents.font.color = normal_color
      self.contents.draw_text(4 + (wd / 4) + off_x, y_pos, wd, WLH, $data_classes[@actor.class_id].name, 0)

      # Draw Level
      self.contents.font.color = system_color
      self.contents.draw_text(4 + off_x, y_pos + (WLH * 1), wd, WLH, Vocab.level_a, 0)
      self.contents.font.color = normal_color
      self.contents.draw_text(4 + (wd / 4) + off_x, y_pos + (WLH * 1), wd, WLH, @actor.level, 0)

      # Draw Hp
      self.contents.font.color = system_color
      self.contents.draw_text(4 + off_x, y_pos + (WLH * 2), wd, WLH, Vocab.hp, 0)
      self.contents.font.color = normal_color
      hp_st = sprintf("%s / %s", @actor.hp, @actor.maxhp)
      self.contents.draw_text(4 + (wd / 4) + off_x, y_pos + (WLH * 2), wd, WLH, hp_st, 0)

      # Draw Mp
      self.contents.font.color = system_color
      self.contents.draw_text(4 + off_x, y_pos + (WLH * 3), wd, WLH, Vocab.mp, 0)
      self.contents.font.color = normal_color
      mp_st = sprintf("%s / %s", @actor.mp, @actor.maxmp)
      self.contents.draw_text(4 + (wd / 4) + off_x, y_pos + (WLH * 3), wd, WLH, mp_st, 0)

    end

    self.contents.font.color = normal_color
    draw_parameter(0, y_pos + (WLH * 0) + off_y, 0)
    draw_parameter(0, y_pos + (WLH * 1) + off_y, 1)
    draw_parameter(0, y_pos + (WLH * 2) + off_y, 2)
    draw_parameter(0, y_pos + (WLH * 3) + off_y, 3)
  end

  #--------------------------------------------------------------------------
  # * Draw Parameters
  #     x    : draw spot x-coordinate
  #     y    : draw spot y-coordinate
  #     type : type of parameter (0 - 3)
  #--------------------------------------------------------------------------
  def draw_parameter(x, y, type)
    case type
    when 0
      name = Vocab.atk
      value = @actor.atk
      new_value = @new_atk
    when 1
      name = Vocab.def
      value = @actor.def
      new_value = @new_def
    when 2
      name = Vocab.spi
      value = @actor.spi
      new_value = @new_spi
    when 3
      name = Vocab.agi
      value = @actor.agi
      new_value = @new_agi
    end

    if IEX::COSMETIC_EQUIP::USE_STAT_ICONS
      x_pos = x + 24
      stat_icons = IEX::COSMETIC_EQUIP::STAT_ICONS
      case type
        when 0 ; draw_icon(stat_icons[:atk], x_pos - 24, y)
        when 1 ; draw_icon(stat_icons[:def], x_pos - 24, y)
        when 2 ; draw_icon(stat_icons[:spi], x_pos - 24, y)
        when 3 ; draw_icon(stat_icons[:agi], x_pos - 24, y)
      end
    else
      x_pos = x
    end

    wid_spac = self.width / 4
    wd = self.width
    true_wd = (self.width - wid_spac) - 68

    self.contents.font.color = system_color
    self.contents.draw_text(x_pos + 4, y, wd, WLH, name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x_pos + wid_spac, y, true_wd, WLH, value, 0)
    self.contents.font.color = system_color
    self.contents.draw_text(x_pos + wid_spac, y, true_wd, WLH, IEX::COSMETIC_EQUIP::NEW_STAT_ARROW, 1)
    if new_value != nil
      self.contents.font.color = new_parameter_color(value.to_i, new_value.to_i)
      self.contents.draw_text(x_pos + wid_spac, y, true_wd, WLH, new_value.to_i, 2)
    end
  end
end

#==============================================================================
# ** Window_EquipItem
#------------------------------------------------------------------------------
#==============================================================================
class Window_EquipItem < Window_Item
  attr_accessor :back_sprite
  attr_accessor :skip_refresh

  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x          : sindow X coordinate
  #     y          : sindow Y corrdinate
  #     width      : sindow width
  #     height     : sindow height
  #     actor      : actor
  #     equip_type : equip region (0-4)
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, actor, equip_type)
    @actor = actor
    if equip_type == 1 and actor.two_swords_style
      equip_type = 0                              # Change shield to weapon
    end
    @equip_type = equip_type
    @skip_refresh = true
    @__old_size = Rect.new(0, 0, width, height)
    super(x, y, width, height)
    @__old_size = Rect.new(0, 0, self.width, self.height)
    @column_max = 1
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
    refresh
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super
  end

  def update
    super
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end

  def refresh
    return if @skip_refresh
    create_contents
    super
  end
end

#==============================================================================
# ** Scene_Equip
#------------------------------------------------------------------------------
#  This class performs the equipment screen processing.
#==============================================================================
class Scene_Equip < Scene_Base
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  alias :iex_equip_cosmet_se_start :start
  def start(*args, &block)
    iex_equip_cosmet_se_start(*args, &block)

    # Positioning for Help Window
    if @help_window != nil
      help_win_pos = IEX::COSMETIC_EQUIP::WINDOW_POS_SIZE[:help_window]
      @help_window.dispose
      @help_window = IEX_Cosmetic_Equip_Help.new
      @help_window.x = help_win_pos[0]
      @help_window.y = help_win_pos[1]
      @help_window.width = help_win_pos[2]
      @help_window.height = help_win_pos[3]
      @help_window.opacity = help_win_pos[4]
      @help_window.create_contents
      @help_window.update
    end

    # Positioning for Item Windows
    ite_win_pos = IEX::COSMETIC_EQUIP::WINDOW_POS_SIZE[:item_window]
    @item_windows.each do |win|
      next if win == nil
      win.x = ite_win_pos[0]
      win.y = ite_win_pos[1]
      win.width = ite_win_pos[2]
      win.height = ite_win_pos[3]
      win.opacity = ite_win_pos[4]
      win.help_window = @help_window
      win.skip_refresh = false
      win.create_contents
      win.refresh
      win.update
    end

    # Positioning for Equip Window
    if @equip_window != nil
      equip_win_pos = IEX::COSMETIC_EQUIP::WINDOW_POS_SIZE[:equip_window]
      @equip_window.x = equip_win_pos[0]
      @equip_window.y = equip_win_pos[1]
      @equip_window.width = equip_win_pos[2]
      @equip_window.height = equip_win_pos[3]
      @equip_window.opacity = equip_win_pos[4]
      @equip_window.help_window = @help_window
      @equip_window.skip_refresh = false
      @equip_window.create_contents
      @equip_window.refresh
      @equip_window.update
      @equip_window.update_help
    end

    # Positioning for Status Window
    if @status_window != nil
      status_win_pos = IEX::COSMETIC_EQUIP::WINDOW_POS_SIZE[:status_window]
      @status_window.x = status_win_pos[0]
      @status_window.y = status_win_pos[1]
      @status_window.width = status_win_pos[2]
      @status_window.height = status_win_pos[3]
      @status_window.opacity = status_win_pos[4]
      @status_window.skip_refresh = false
      @status_window.create_contents
      @status_window.refresh
      @status_window.update
    end

    apply_windowskins
  end

  def apply_windowskins
    # Window_Skins
    window_skins = IEX::COSMETIC_EQUIP::WINDOW_SKINS
    if window_skins[:help_window] != nil
      @help_window.back_sprite.bitmap = Cache.system(window_skins[:help_window])
      @help_window.update
    end

    if window_skins[:equip_window] != nil
      @equip_window.back_sprite.bitmap = Cache.system(window_skins[:equip_window])
      @equip_window.update
    end

    if window_skins[:status_window] != nil
      @status_window.back_sprite.bitmap = Cache.system(window_skins[:status_window])
      @status_window.update
    end

    if window_skins[:item_window] != nil
      @item_windows.each do |win|
        next if win == nil
        win.back_sprite.bitmap = Cache.system(window_skins[:item_window])
        win.update
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  alias :iex_equip_cosmet_se_terminate :terminate
  def terminate(*args, &block)
    iex_equip_cosmet_se_terminate(*args, &block)
    @help_window = nil
    @equip_window = nil
    @status_window = nil
  end

  #--------------------------------------------------------------------------
  # * Dispose of Item Window
  #--------------------------------------------------------------------------
  def dispose_item_windows
    @item_windows.each { |window| window.dispose }
    @item_windows = nil
  end
end
