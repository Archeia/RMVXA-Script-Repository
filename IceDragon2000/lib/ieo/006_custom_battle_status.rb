#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Custom Battle Status
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : ReWrite (Battle Status)
# ** Script Type   : Battle Status (Visual)
# ** Date Created  : 02/21/2011
# ** Date Modified : 05/31/2011
# ** Script Tag    : IEO-006(Custom Battle Status)
# ** Difficulty    : Easy
# ** Version       : 1.0
# ** IEO ID        : 006
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
#
# You may:
# Edit and Adapt this script as long you credit aforementioned author(s).
#
# You may not:
# Claim this as your own work, or redistribute without the consent of the author.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#-*--------------------------------------------------------------------------*-#
#
# This is a rewrite of the default Battle Status window.
# Its plug 'n' play, so go wild!
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
# Plug 'n' Play
# Well has only been tested with the DBS, and Ohmerion.
# Do not use with Melody.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#-*--------------------------------------------------------------------------*-#
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
#
#-*--------------------------------------------------------------------------*-#
# Below
#   Materials
#   CBS
#
# Above
#   Main
#   Anything that makes changes to:
#     Window_BattleStatus
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   Game_System
#     alias      :initialize
#   Window_BattleStatus
#     overwrite  :initialize
#     overwrite  :refresh
#     overwrite  :draw_item
#     overwrite  :item_rect
#     alias      :update
#     alias      :dispose
#     new-method :create_state_sprite
#     new-method :setup_column_max
#     new-method :draw_states
#     new-method :update_state
#   Scene_Battle
#     alias      :start_party_command_selection
#     alias      :next_actor
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  05/31/2011 - V1.0 Finished Script
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Non Yet.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
$imported ||= {}
$imported["IEO-CustomBattleStatus"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
$ieo_script = {} if $ieo_script == nil
$ieo_script[[6, "CustomBattleStatus"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# IEO::BATTLE_STATUS
#==============================================================================#
module IEO
  module BATTLE_STATUS
#==============================================================================#
#                      Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
    # // 0 - Rectangular, 1 - Face and Vertical Bars
    DRAW_STYLE = 0
    # // State Drawing
    # // 0 - State Strip, 1 - Scrolling States
    STATESTYLE  = 1
    SCROLLSPEED = 24 # // Scroll speed, icons are 24x24, using 24 will cause icon flipping
    SCROLLDELAY = 3  # // Frames per scroll, default 3
    # // General Settings
    SPACING    = 4
#==============================================================================#
#                        End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# Game_System
#==============================================================================#
class Game_System

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :wbs_draw_style
  attr_accessor :wbs_statestyle
  attr_accessor :wbs_scrollspeed
  attr_accessor :wbs_scrolldelay

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo006_gs_initialize :initialize unless $@
  def initialize()
    ieo006_gs_initialize()
    @wbs_draw_style = IEO::BATTLE_STATUS::DRAW_STYLE
    @wbs_statestyle = IEO::BATTLE_STATUS::STATESTYLE
    @wbs_scrollspeed= IEO::BATTLE_STATUS::SCROLLSPEED
    @wbs_scrolldelay= IEO::BATTLE_STATUS::SCROLLDELAY
  end

end

#==============================================================================#
# Window_BattleStatus
#==============================================================================#
class Window_BattleStatus < Window_Selectable

  #--------------------------------------------------------------------------
  # * overwrite method :initialize
  #--------------------------------------------------------------------------
  def initialize()
    super(0, 0, (Graphics.width-128), 128) # 128
    @draw_style      = $game_system.wbs_draw_style # //
    @state_drawstyle = $game_system.wbs_statestyle # //
    @spacing         = IEO::BATTLE_STATUS::SPACING
    @members         = []
    @state_sprites   = []
    @state_drawsizes = []
    @state_viewports = []
    # // This is the scroll speed, icons are 24x24 so setting it to 24 will result
    # // in icon flipping
    @scrolling_speed = $game_system.wbs_scrollspeed
    @scrolling_delay = 0
    # // This is the frame delay between scrolling
    @scrolling_delaymax = $game_system.wbs_scrolldelay
    # //
    for i in 0...$game_party.members.size()
      create_state_sprite(i)
    end
    self.opacity = 255
    refresh()
    self.active = false
  end

  #--------------------------------------------------------------------------#
  # * new method :create_state_sprite
  #--------------------------------------------------------------------------#
  def create_state_sprite(index)
    rect = item_rect(index)
    @state_viewports[index] = Viewport.new( rect.x + 96 - 24, rect.y + 96 - 24,
      24, 24 )
    @state_sprites[index] = Plane.new()
    @state_sprites[index].bitmap = Bitmap.new(24*16, 24)
    update_state()
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    case @draw_style
    when 0 ; self.width = (Graphics.width-128)
    when 1 ; self.width = (Graphics.width-96)
    end
    create_contents()
    @members  = $game_party.members
    @item_max = @members.size
    setup_column_max()
    for i in 0...@item_max
      draw_item(i)
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :setup_column_max
  #--------------------------------------------------------------------------#
  def setup_column_max
    case @draw_style
    when 0
      @column_max = 2
    when 1
      @column_max = @item_max
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    case @draw_style
    when 0
      rect.width = (contents.width + @spacing) / @column_max - @spacing
      rect.height = WLH*2
      rect.x = index % @column_max * (rect.width + @spacing)
      rect.y = index / @column_max * WLH*2
    when 1
      rect.width = 96 + 32
      rect.height = 96
      rect.x = index % @column_max * (rect.width + @spacing)
      rect.y = index / @column_max * WLH*2
    end
    return rect
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    actor = @members[index]

    case @draw_style
    when 0
      otrect = Rect.new(rect.x+2, rect.y+2, rect.height-4, rect.height-4)
      draw_outlined_actor(actor, otrect, 2, Color.new( 0, 0, 0, 96 ))
      trect = Rect.new(otrect.x+otrect.width+32, rect.y+2, rect.width, 24)
      draw_icon(IEO::Icon.battle_action( actor, actor.action),
       trect.x-28, rect.y, actor.action.valid? )
      self.contents.font.size = 16
      draw_actor_name(actor, rect.x, rect.y+rect.height-24)
      draw_states(index, actor, trect)
      draw_actor_hp_gauge(actor, trect.x-24, trect.y+8, 96)
      draw_actor_mp_gauge(actor, trect.x-12, trect.y+20, 96)
      self.contents.font.size = 12
      self.contents.draw_text( trect.x, trect.y+12, 120, 24,
       sprintf("%s/%s", actor.hp, actor.maxhp ))
      self.contents.draw_text( trect.x+12, trect.y+24, 120, 24,
       sprintf("%s/%s", actor.mp, actor.maxmp ))
      #draw_actor_hp(actor, trect.x, trect.y+24, 120)
      #draw_actor_mp(actor, 310, rect.y, 70)
    when 1
      self.contents.font.size = 16
      draw_actor_face(actor, rect.x, rect.y)
      draw_actor_name(actor, rect.x, rect.y)
      #draw_actor_state(actor, rect.x, rect.y+96-24, 96)
      trect = rect.clone ; trect.y += 96-24
      draw_states(index, actor, trect)
      brect = rect.clone
      brect.x += rect.width - 24
      brect.width = 12
      brect.y += 16
      brect.height -= 16

      # // HP
      draw_vertical_grad_bar( brect, actor.hp, actor.maxhp,
        hp_gauge_color1, hp_gauge_color2, Color.new(20, 20, 20),
        2, false, true )
      # //
      self.contents.font.size = 16
      self.contents.draw_text(brect.x, brect.y-16, 24, 24, Vocab.hp_a)
      brect.x += 14
      # // MP
      draw_vertical_grad_bar( brect, actor.mp, actor.maxmp,
        mp_gauge_color1, mp_gauge_color2, Color.new(20, 20, 20),
        2, false, true )
      # //
      self.contents.font.size = 16
      self.contents.draw_text(brect.x, brect.y-16, 24, 24, Vocab.mp_a)
    end

  end

  #--------------------------------------------------------------------------#
  # * new method :draw_states
  #--------------------------------------------------------------------------#
  def draw_states(index, actor, rect)
    case @state_drawstyle
    when 0
      draw_actor_state(actor, rect.x, rect.y, 96)
    when 1
      c = 0
      @state_drawsizes[index] = actor.states.size()
      @state_sprites[index].bitmap.dispose
      @state_sprites[index].bitmap = Bitmap.new([24*@state_drawsizes[index], 24].max, 24)
      for st in actor.states
        @state_sprites[index].bitmap.draw_icon(st.icon_index, c*24, 0) ; c += 1
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * alias method :dispose
  #--------------------------------------------------------------------------#
  alias :ieo006_dispose :dispose unless $@
  def dispose()
    @state_sprites.compact.each { |sp| sp.dispose }
    ieo006_dispose()
  end

  #--------------------------------------------------------------------------#
  # * alias method :update
  #--------------------------------------------------------------------------#
  alias :ieo006_update :update unless $@
  def update()
    ieo006_update()
    update_state()
  end

  #--------------------------------------------------------------------------#
  # * new method :update_state
  #--------------------------------------------------------------------------#
  def update_state()
    @scrolling_delay -= 1
    for i in 0...@state_sprites.size
      rect = item_rect(i)
      st = @state_sprites[i]
      vis2 = true ; vis2 = self.viewport.visible unless self.viewport.nil?
      st.visible = (self.visible && vis2)
      if st.bitmap.width > 24 ; st.ox += @scrolling_speed
      else ; st.ox = 0 ; end if @scrolling_delay <= 0
      dx, dy = 0, 0
      unless self.viewport.nil?
        dx, dy = self.viewport.rect.x, self.viewport.rect.y
        dx -= self.viewport.ox
        dy -= self.viewport.oy
      end
      @state_viewports[i].rect.set(
        dx+ self.x + rect.x + 96-4, dy + self.y + rect.y + 96-4,
        24, 24)
      @state_viewports[i].z = self.z
      @state_viewports[i].update
      st.viewport = @state_viewports[i] if st.viewport.nil?
    end
    @scrolling_delay = @scrolling_delaymax if @scrolling_delay <= 0
  end

end

#==============================================================================#
# Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias method :start_party_command_selection
  #--------------------------------------------------------------------------#
  alias :ieo006_scb_start_party_command_selection :start_party_command_selection unless $@
  def start_party_command_selection()
    ieo006_scb_start_party_command_selection()
    @status_window.refresh()
  end

  #--------------------------------------------------------------------------#
  # * alias method :next_actor
  #--------------------------------------------------------------------------#
  alias :ieo006_scb_next_actor :next_actor unless $@
  def next_actor()
    ieo006_scb_next_actor()
    @status_window.refresh
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
