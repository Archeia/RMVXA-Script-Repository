#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Aztile Menu
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (Menu), Add (Party System)
# ** Script Type   : Menu Arrangement, Party System
# ** Date Created  : 03/25/2011
# ** Date Modified : 04/23/2011
# ** Script Tag    : IEO-030(Aztile Menu)
# ** Difficulty    : Easy, Medium, Lunatic
# ** Version       : 1.0a
# ** IEO ID        : 030
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
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
# *Crawls in* Never again will I touch Java...
# Anyway, this here script is a small change to the default menu system,
# along with a Integrated Party system (optional)
# So yeah have fuuuuuun.
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTRUCTIONS
#-*--------------------------------------------------------------------------*-#
#
# Plug 'n' Play
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Breaks a lot of the return_scene methods so beeeee careful..
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
#
# Above
#   Main
#   Everything else
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# * If IPS enabled
# Classes
#   Game_Actor
#     alias-method :setup
#     new-method   :reserve_member?
#   *Game_Party
#     new-method   :battle_members
#     new-method   :all_battle_members
#     new-method   :party_members
#     new-method   :all_members
#     new-method   :battle_party_size
#     new-method   :add_actor
#     new-method   :set_battlers
#     new-method   :change_battler_at
#     new-method   :swap_battler_at
#     new-method   :get_battler_at
#     new-method   :get_empty_index
#     new-method   :battle_members_full?
#     alias-method :remove_actor
#     overwrite    :members
#   Window_MenuStatus
#     super-method :initialize
#     new-method   :change_item_max_mode
#     overwrite    :refresh
#     overwrite    :top_row
#     overwrite    :top_row=
#     overwrite    :page_row_max
#     overwrite    :update_cursor
#   Scene_Title
#     alias-method :create_game_objects
#     new-method   :load_ieo030_objects
#   Scene_Menu
#     new-Cmethod  :hide_command?
#     new-Cmethod  :need_actor_selection?
#     new-Cmethod  :command_index
#     new-method   :menu_command
#     new-method   :before_actor_selection
#     new-method   :start_swap_window
#     new-method   :update_swap_window
#     new-method   :end_swap_window
#     overwrite    :update
#     overwrite    :create_command_window
#     overwrite    :update_command_selection
#     alias-method :start_actor_selection
#     alias-method :update_actor_selection
#   Scene_Item
#   Scene_Skill
#   Scene_Equip
#   Scene_Status
#   Scene_File
#   Scene_End
#     overwrite    :return_scene
#   Scene_Battle
#     overwrite    :display_level_up
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  03/25/2011 - V1.0  Started Script
#  04/08/2011 - V1.0  Finished Script
#  04/23/2011 - V1.0a Fixed a EXP bug, regarding reserve members
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Breaks stuff, lots of stuff with the menu and scene ties.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-AztileMenu"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script = {})[[30, "AztileMenu"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# IEO::MENU_SYSTEM
#==============================================================================#
module IEO
  module MENU_SYSTEM
#==============================================================================#
#                      Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * MENU_LAYOUT
  #--------------------------------------------------------------------------#
  # This controls the order in which commands appear in the menu
  # Default commands
  # :item, :skill, :equip, :status, :save, :system (AKA end)
  #--------------------------------------------------------------------------#
    MENU_LAYOUT = [
      :item,    # // Default Item Scene
      :skill,   # // Default Skill Scene
      :equip,   # // Default Equip Scene
      :status,  # // Default Status Scene
      :swap,    # // Used for IPS
      :save,    # // Default Save Scene
      :system   # // Default End Scene
    ]
  #--------------------------------------------------------------------------#
  # * MS_
  #--------------------------------------------------------------------------#
  # These constants control the MenuStatus window
  # MS_RECT... is the selection size
  #--------------------------------------------------------------------------#
    MS_YSPACING   = 96 #128 #96
    # // Selection Width
    MS_RECTWIDTH  = 96
    # // Selection Height
    MS_RECTHEIGHT = 96
  #--------------------------------------------------------------------------#
  # * IPS // Intergrated Party System
  #--------------------------------------------------------------------------#
  # Allows you to quickly add and remove actors from the party.
  #--------------------------------------------------------------------------#
    USE_IPS = true # If this is false REMOVE the :swap command from the MENU_LAYOUT
    # // 0 Normal Sprites, 1 Wide Frame Sprite, 2 Faces
    PARTY_DRAW_STYLE = 2 #2
    # // Maximum members on the active party
    MAX_MEMBERS   = 4
    # // Total members, thats the reserve + the party
    TOTAL_MEMBERS = 8 #5
    # // Should the players be able to remove actors from the party?
    SWITCH_ONLY = true
    # // IPS_WINDOW_SIZE
    IPS_WINX      = 0
    IPS_WINY      = (Graphics.height - 160) / 2
    IPS_WINWIDTH  = Graphics.width
    IPS_WINHEIGHT = 160
    # // This is the in-game variable associated with the EXP rate, so you can
    # // change it during the game
    RESERVE_EXP_VAR  = 4
    RESERVE_EXP_RATE = 60

#==============================================================================#
#                        End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# Scene_Menu - IEO030-Lunatic
#==============================================================================#
class Scene_Menu < Scene_Base
  #--------------------------------------------------------------------------#
  # * new method :menu_command
  #--------------------------------------------------------------------------#
  def menu_command(command)
    menulay = $game_system.menu_layout
    case command
    when :item
      $scene = Scene_Item.new
    when :skill
      $scene = Scene_Skill.new(@status_window.index)
    when :equip
      $scene = Scene_Equip.new(@status_window.index)
    when :status
      if $imported["IEO-LotusStatus"]
        $scene = Scene_Status.new(@status_window.index, :menu, Scene_Menu.command_index(:status))
      else
        $scene = Scene_Status.new(@status_window.index)
      end
    when :save
      $scene = Scene_File.new(true, false, false)
    when :system
      $scene = Scene_End.new
    # // Party swapping
    when :swap
      start_swap_window()
      @status_window.active = false
    end
  end

  #--------------------------------------------------------------------------#
  # * new class method :hide_command?
  #--------------------------------------------------------------------------#
  def self.hide_command?(com)
    case com
    when :item   ; return $game_party.members.size == 0
    when :skill  ; return $game_party.members.size == 0
    when :equip  ; return $game_party.members.size == 0
    when :status ; return $game_party.members.size == 0
    when :save   ; return $game_system.save_disabled
    when :system ; return false
    # // Party swapping
    when :swap   ; return $game_party.all_members.size <= IEO::MENU_SYSTEM::MAX_MEMBERS

    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * new class method :need_actor_selection?
  #--------------------------------------------------------------------------#
  def self.need_actor_selection?(com)
    case com
    when :item   ; return false
    when :skill  ; return true
    when :equip  ; return true
    when :status ; return true
    when :save   ; return false
    when :system ; return false
    # // Party swapping
    when :swap   ; return true
    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * new class method :command_index
  #--------------------------------------------------------------------------#
  def self.command_index(com)
    return $game_system.menu_layout.index(com)
  end

  #--------------------------------------------------------------------------#
  # * new method :before_actor_selection
  #--------------------------------------------------------------------------#
  def before_actor_selection(lastcommand = :nil)
    case lastcommand
    when :swap
      @status_window.change_item_max_mode(:party_select)
    else
      @status_window.change_item_max_mode(:normal)
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :start_swap_window
  #--------------------------------------------------------------------------#
  def start_swap_window
    @partyswap_window = Window_MenuPartySwap.new(0, 0)
    @partyswap_window.x = (Graphics.width - @partyswap_window.width) / 2
    @partyswap_window.y = (Graphics.height - @partyswap_window.height) / 2
    @partyswap_window.active = true
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update
  #--------------------------------------------------------------------------#
  def update
    super
    update_menu_background
    @command_window.update
    @gold_window.update
    @status_window.update
    if @command_window.active
      update_command_selection
    elsif @status_window.active
      update_actor_selection
    else
      update_swap_window unless @partyswap_window.nil?
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :update_swap_window
  #--------------------------------------------------------------------------#
  def update_swap_window
    unless @partyswap_window.nil?
      @partyswap_window.update
      sindex = @status_window.index
      raid = @partyswap_window.current_actor
      raid = raid.nil? ? nil : raid.id
      if Input.trigger?(Input::C)
        Sound.play_equip
        old = $game_party.swap_battler_at(sindex, raid)
        end_swap_window
        @status_window.active = true
        @status_window.refresh
      elsif Input.trigger?(Input::B)
        Sound.play_cancel
        end_swap_window
        @status_window.active = true
        @status_window.refresh
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :end_swap_window
  #--------------------------------------------------------------------------#
  def end_swap_window
    @partyswap_window.dispose unless @partyswap_window.nil?
  end
end

#==============================================================================#
# IEO::Vocab
#==============================================================================#
module IEO
  module Vocab
    def self.menu(command)
      case command
      when :item    ; return ::Vocab.item
      when :skill   ; return ::Vocab.skill
      when :equip   ; return ::Vocab.equip
      when :status  ; return ::Vocab.status
      when :save    ; return ::Vocab.save
      when :system  ; return ::Vocab.game_end
      # // Party swapping
      when :swap    ; return "Party"
      else          ; return ""
      end
    end
  end
end

#==============================================================================#
# IEO::Icon
#==============================================================================#
module IEO
  module Icon
    def self.menu(command)
      return 0
    end
  end
end

#==============================================================================#
# ** Game_System
#==============================================================================#
class Game_System
  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_writer :menu_layout
  attr_accessor :ips_windowsize
  attr_accessor :party_draw_style
  attr_accessor :reserve_exprate_var

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo030_gs_initialize :initialize unless $@
  def initialize
    ieo030_gs_initialize()
    a = IEO::MENU_SYSTEM
    @ips_windowsize = Rect.new(a::IPS_WINX, a::IPS_WINY, a::IPS_WINWIDTH, a::IPS_WINHEIGHT)
    @party_draw_style = a::PARTY_DRAW_STYLE
    @reserve_exprate_var = a::RESERVE_EXP_VAR
  end

  def menu_layout
    @menu_layout ||= IEO::MENU_SYSTEM::MENU_LAYOUT.clone
  end
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :party_lock

  #--------------------------------------------------------------------------#
  # * alias method :setup
  #--------------------------------------------------------------------------#
  alias ieo030_setup setup unless $@
  def setup(actor_id)
    @party_lock = false
    ieo030_setup(actor_id)
  end

  #--------------------------------------------------------------------------#
  # * new method :reserve_member?
  #--------------------------------------------------------------------------#
  def reserve_member?
    return ($game_party.all_members - $game_party.battle_members).include?(self)
  end

end # Game_Actor

if IEO::MENU_SYSTEM::USE_IPS
#==============================================================================#
# ** Game_Party
#==============================================================================#
class Game_Party < Game_Unit

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  TOTAL_MEMBERS = IEO::MENU_SYSTEM::TOTAL_MEMBERS
  MAX_MEMBERS   = IEO::MENU_SYSTEM::MAX_MEMBERS

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :actors
  attr_accessor :battlers

  #--------------------------------------------------------------------------#
  # * overwrite method :members
  #--------------------------------------------------------------------------#
  def members ; return battle_members end

  #--------------------------------------------------------------------------#
  # * new method :battle_members
  #--------------------------------------------------------------------------#
  def battle_members
    if @battlers == nil
      @battlers = Array.new(MAX_MEMBERS).map! { |ele| ele = nil}
      for i in 0..([@actors.size, MAX_MEMBERS].min - 1)
        @battlers[i] = @actors[i]
      end
    end
    result = []
    @battlers.compact!
    for id in @battlers
      result.push($game_actors[id]) unless $game_actors[id] == nil
    end
    return result
  end

  #--------------------------------------------------------------------------#
  # * new method :all_battle_members
  #--------------------------------------------------------------------------#
  def all_battle_members
    battle_members if @battlers == nil
    result = []
    for id in @battlers
      result.push($game_actors[id])
    end
    return result
  end

  #--------------------------------------------------------------------------#
  # * new method :party_members
  #--------------------------------------------------------------------------#
  def party_members
    result = []
    for member in battle_members
      result.push(member)
    end
    for member in all_members
      result.push(member) unless result.include?(member)
    end
    return result
  end

  #--------------------------------------------------------------------------#
  # * new method :all_members
  #--------------------------------------------------------------------------#
  def all_members
    result = []
    @actors.each { |aid| result << $game_actors[aid] if aid > 0}
    return result
  end

  #--------------------------------------------------------------------------#
  # * new method :battle_party_size
  #--------------------------------------------------------------------------#
  def battle_party_size ; return MAX_MEMBERS end

  #--------------------------------------------------------------------------#
  # * overwrite method :add_actor
  #--------------------------------------------------------------------------#
  def add_actor(actor_id)
    last_size = @actors.size
    if @actors.size < TOTAL_MEMBERS and !@actors.include?(actor_id)
      @actors.push(actor_id)
      $game_player.refresh
    end
    if last_size < @actors.size
      battle_members if @battlers == nil
      for i in 0..(@battlers.size-1)
        if @battlers[i] == nil
          @battlers[i] = actor_id unless battle_members.size == battle_party_size
          break
        end
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :set_battlers
  #--------------------------------------------------------------------------#
  def set_battlers(*args)
    battle_members if @battlers == nil
    old_bats = @battlers.clone
    @battlers.clear
    bats = *args
    for i in 0...battle_party_size
      bat = old_bats[i]
      @battlers[i] = nil
      @battlers[i] = old_bats[bat] if @actors.include?(bat)
    end
    $game_player.refresh
  end

  #--------------------------------------------------------------------------#
  # * new method :change_battler_at
  #--------------------------------------------------------------------------#
  def change_battler_at(index, aid)
    battle_members if @battlers == nil
    @battlers[index] = aid
  end

  #--------------------------------------------------------------------------#
  # * new method :swap_battler_at
  #--------------------------------------------------------------------------#
  def swap_battler_at(index, aid)
    battle_members if @battlers == nil
    oldbat = @battlers[index] ; @battlers[index] = aid
    return oldbat
  end

  #--------------------------------------------------------------------------#
  # * new method :get_battler_at
  #--------------------------------------------------------------------------#
  def get_battler_at(index)
    battle_members if @battlers == nil
    return @battlers[index]
  end

  #--------------------------------------------------------------------------#
  # * new method :get_empty_index
  #--------------------------------------------------------------------------#
  def get_empty_index
    for i in 0...battle_party_size
      return i if @battlers[i] == nil
    end
    return nil
  end

  #--------------------------------------------------------------------------#
  # * alias method :remove_actor
  #--------------------------------------------------------------------------#
  alias ieo030_remove_actor remove_actor unless $@
  def remove_actor(actor_id)
    battle_members if @battlers == nil
    @battlers[@battlers.index(actor_id)] = nil if @battlers.include?(actor_id)
    ieo030_remove_actor(actor_id)
  end

  #--------------------------------------------------------------------------#
  # * new method :battle_members_full?
  #--------------------------------------------------------------------------#
  def battle_members_full?
    return battle_members.compact.size >= battle_party_size
  end

end

end

#==============================================================================#
# Window_MenuStatus
#==============================================================================#
class Window_MenuStatus < Window_Selectable

  #--------------------------------------------------------------------------#
  # * super method :initialize
  #--------------------------------------------------------------------------#
  def initialize(x, y)
    super(x, y, 384, 416)
    @y_spacing   = IEO::MENU_SYSTEM::MS_YSPACING
    @rect_width  = IEO::MENU_SYSTEM::MS_RECTWIDTH
    @rect_height = IEO::MENU_SYSTEM::MS_RECTHEIGHT
    @last_itemmax_mode = :normal
    refresh
    self.active = false
    self.index = -1
  end

  #--------------------------------------------------------------------------#
  # * new method :change_item_max_mode
  #--------------------------------------------------------------------------#
  def change_item_max_mode(mode)
    case mode
    when :normal
      @item_max = $game_party.members.size
    when :party_select
      @item_max = Game_Party::MAX_MEMBERS
    end
    @last_itemmax_mode = mode
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    self.contents.clear
    change_item_max_mode(@last_itemmax_mode)
    for actor in $game_party.members
      self.contents.font.size = Font.default_size
      draw_actor_face(actor, 2, actor.index * @y_spacing + 2, 92)
      x = 104
      y = actor.index * @y_spacing + WLH / 2
      draw_actor_name(actor, x, y)
      draw_actor_class(actor, x + 120, y)
      draw_actor_level(actor, x, y + WLH * 1)
      draw_actor_state(actor, x, y + WLH * 2)
      draw_actor_hp(actor, x + 120, y + WLH * 1)
      draw_actor_mp(actor, x + 120, y + WLH * 2)
      if $imported["IEO-SkillLevelSystem"]
        rect = Rect.new(x+24, y, 96, 24)
        draw_actor_skl_p(actor, rect)
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :top_row
  #--------------------------------------------------------------------------#
  def top_row
    return self.oy / @y_spacing
  end
  #--------------------------------------------------------------------------#
  # * overwrite method :top_row=
  #--------------------------------------------------------------------------#
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * @y_spacing
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :page_row_max
  #--------------------------------------------------------------------------#
  def page_row_max
    return (self.height - 32) / @y_spacing
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_cursor
  #--------------------------------------------------------------------------#
  def update_cursor
    if @index < 0               # No cursor
      self.cursor_rect.empty
    elsif @index < @item_max    # Normal
      self.cursor_rect.set(0, @index * @y_spacing, @rect_width, @rect_height)
    elsif @index >= 100         # Self
      self.cursor_rect.set(0, (@index - 100) * @y_spacing, @rect_width, @rect_height)
    else                        # All
      self.cursor_rect.set(0, 0, contents.width, self.height-32)
    end
  end

end

#==============================================================================#
# ** Window_MenuCommand
#==============================================================================#
class Window_MenuCommand < Window_Command

  #--------------------------------------------------------------------------#
  # * new method :get_current_command
  #--------------------------------------------------------------------------#
  def get_current_command ; return @commands[self.index] end

  #--------------------------------------------------------------------------#
  # * overwrite method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i, !Scene_Menu.hide_command?(@commands[i]))
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index, adapt=true)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = (index / @column_max * WLH)
    if $imported["IEO-BugFixesUpgrades"]
      if IEO::UPGRADE::ADAPTIVE_CURSOR
        if adapt
          tx = IEO::Vocab.menu(@commands[index])
          rect.width = self.contents.text_size(tx).width+12
          icon = IEO::Icon.menu(@commands[index])
          rect.width += 24 if icon > 0
        end
      end
    end
    return rect
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled = true)
    self.contents.font.size = Font.default_size
    rect = item_rect(index, false)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    icon = IEO::Icon.menu(@commands[index])
    if icon > 0
      draw_icon(icon, rect.x, rect.y)
      rect.x += 24 ; rect.width -= 24
    end
    self.contents.draw_text(rect, IEO::Vocab.menu( @commands[index] ))
  end
end

#==============================================================================#
# Window_MenuPartySwap
#==============================================================================#
class Window_MenuPartySwap < Window_Selectable
  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  HEIGHT_PUSH = 72

  #--------------------------------------------------------------------------#
  # * super method :initialize
  #--------------------------------------------------------------------------#
  def initialize(px, py)
    @character_rect = Rect.new(0, 0, 32, 32)
    @draw_style = $game_system.party_draw_style
    @widthadd = 32
    @heightadd= 32
    @widthadd = 64 if [1, 2].include?(@draw_style)
    @height_push = HEIGHT_PUSH
    @height_push += 46 if [2].include?(@draw_style)
    #tt = Game_Party::TOTAL_MEMBERS - (Game_Party::MAX_MEMBERS-1)
    #(@character_rect.width+@widthadd) * tt, @height_push+@heightadd
    px, py, pw, ph = $game_system.ips_windowsize.x, $game_system.ips_windowsize.y,
                     $game_system.ips_windowsize.width, $game_system.ips_windowsize.height
    super(px, py, pw, ph)
    @actors = $game_party.battle_members
    @item_max = $game_party.battle_party_size
    self.index = 0
    @smindex = nil
    refresh if init_refresh?
  end

  #--------------------------------------------------------------------------#
  # * new method :init_refresh?
  #--------------------------------------------------------------------------#
  def init_refresh? ; return true end
  #--------------------------------------------------------------------------#
  # * new method :current_actor
  #--------------------------------------------------------------------------#
  def current_actor ; return @actors[self.index] end
  #--------------------------------------------------------------------------#
  # * new method :get_actor_at
  #--------------------------------------------------------------------------#
  def get_actor_at(index) ; return @actors[index] end

  #--------------------------------------------------------------------------#
  # * new method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    self.contents.clear
    @actors = []
    for mem in $game_party.all_members.compact
      @actors.push(mem) unless $game_party.battle_members.include?(mem)
    end
    @actors.push(nil) unless IEO::MENU_SYSTEM::SWITCH_ONLY
    @item_max = @actors.size
    @column_max = [1, @item_max].max
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    actor = @actors[index]
    unless actor.nil?
      aname  = actor.name
      aclass = actor.class.name
      alevel = actor.level
      ash = (rect.height-@character_rect.height)/2
      locked = actor.party_lock
      ch = @character_rect.height
      if [0, 1].include?(@draw_style)
        draw_actor_graphic(actor, rect.x+16, rect.y+@character_rect.height+ash+4, !locked)
        self.contents.font.color.alpha = locked ? 128 : 255
        self.contents.font.size = 12
        self.contents.draw_text(rect.x+3,rect.y - 4,rect.width,24,aname)
        self.contents.draw_text(rect.x,rect.y+18,rect.width-2,24,"Lv.",2)
        self.contents.draw_text(rect.x,rect.y+28,rect.width-2,24,alevel,2)
        self.contents.draw_text(rect.x,rect.y+17+ch,rect.width-3,24,aclass,2)
      elsif [2].include?(@draw_style)
        draw_actor_face(actor, rect.x, rect.y)
        self.contents.font.color.alpha = locked ? 128 : 255
        self.contents.font.size = 18
        self.contents.draw_text(rect.x,rect.y+96-20,rect.width-2,24,"Lv.",0)
        self.contents.draw_text(rect.x+24,rect.y+96-20,rect.width-2,24,alevel,0)
        self.contents.draw_text(rect.x, rect.y+96, rect.width, 24, aname, 1)
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = @character_rect.width + @widthadd
    rect.height = @character_rect.height + (@height_push-@heightadd)
    rect.x = index * (rect.width + 10)
    rect.y = 0
    return rect
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_actor_graphic
  #--------------------------------------------------------------------------#
  def draw_actor_graphic(actor, x, y, enabled=true)
    draw_character(actor.character_name, actor.character_index, x, y, enabled)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_character
  #--------------------------------------------------------------------------#
  def draw_character(character_name, character_index, x, y, enabled=true)
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
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect, enabled ? 255 : 128)
  end
end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------#
  # * alias-method :create_game_object
  #--------------------------------------------------------------------------#
  alias :ieo030_create_game_objects create_game_objects unless $@
  def create_game_objects()
    ieo030_create_game_objects
    load_ieo030_objects
  end

  #--------------------------------------------------------------------------#
  # * new-method :load_ieo030_object
  #--------------------------------------------------------------------------#
  def load_ieo030_objects
    $game_variables[$game_system.reserve_exprate_var] = IEO::MENU_SYSTEM::RESERVE_EXP_RATE
  end
end

#==============================================================================#
# ** Scene_Menu
#==============================================================================#
class Scene_Menu < Scene_Base
  #--------------------------------------------------------------------------#
  # * overwrite method :create_command_window
  #--------------------------------------------------------------------------#
  def create_command_window
    coms = $game_system.menu_layout
    @command_window = Window_MenuCommand.new(160, coms)
    @command_window.index = @menu_index
  end

  #--------------------------------------------------------------------------#
  # * new method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    $scene = Scene_Map.new
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_command_selection
  #--------------------------------------------------------------------------#
  def update_command_selection()
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene()
    elsif Input.trigger?(Input::C)
      com = @command_window.get_current_command
      if com == nil
        Sound.play_buzzer
        return
      end
      if Scene_Menu.hide_command?(com)
        Sound.play_buzzer
        return
      end
      Sound.play_decision()
      if Scene_Menu.need_actor_selection?(com)
        before_actor_selection(com)
        start_actor_selection()
      else
        menu_command(com)
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * alias method :update_actor_selection
  #--------------------------------------------------------------------------#
  alias ieo030_start_actor_selection start_actor_selection unless $@
  def start_actor_selection()
    ieo030_start_actor_selection()
    imx = @status_window.item_max()
    @status_window.index = imx if @status_window.index > imx
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_actor_selection
  #--------------------------------------------------------------------------#
  def update_actor_selection()
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_actor_selection
    elsif Input.trigger?(Input::C)
      $game_party.last_actor_index = @status_window.index
      com = @command_window.get_current_command()
      Sound.play_decision
      menu_command(com)
    end
  end
end

#==============================================================================#
# Scene_Item
#==============================================================================#
class Scene_Item < Scene_Base
  #--------------------------------------------------------------------------#
  # * overwrite method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    $scene = Scene_Menu.new(Scene_Menu.command_index(:item))
  end
end

#==============================================================================#
# Scene_Skill
#==============================================================================#
class Scene_Skill < Scene_Base
  #--------------------------------------------------------------------------#
  # * overwrite method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    $scene = Scene_Menu.new(Scene_Menu.command_index(:skill))
  end
end

#==============================================================================#
# Scene_Equip
#==============================================================================#
class Scene_Equip < Scene_Base
  #--------------------------------------------------------------------------#
  # * overwrite method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    $scene = Scene_Menu.new(Scene_Menu.command_index(:equip))
  end
end

#==============================================================================#
# Scene_Status
#==============================================================================#
class Scene_Status < Scene_Base
  #--------------------------------------------------------------------------#
  # * overwrite method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    $scene = Scene_Menu.new(Scene_Menu.command_index(:status))
  end
end

#==============================================================================#
# Scene_File
#==============================================================================#
class Scene_File < Scene_Base
  #--------------------------------------------------------------------------#
  # * overwrite method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    if @from_title
      $scene = Scene_Title.new
    elsif @from_event
      $scene = Scene_Map.new
    else
      $scene = Scene_Menu.new(Scene_Menu.command_index(:save))
    end
  end
end

#==============================================================================#
# Scene_End
#==============================================================================#
class Scene_End < Scene_Base
  #--------------------------------------------------------------------------#
  # * overwrite method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    $scene = Scene_Menu.new(Scene_Menu.command_index(:system))
  end
end

#==============================================================================#
# Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------#
  # * overwrite method :display_level_up
  #--------------------------------------------------------------------------#
  def display_level_up
    exp = $game_troop.exp_total
    mems = $game_party.members
    mems = $game_party.all_members
    for actor in mems
      next if actor.dead?
      last_level = actor.level   ; last_skills = actor.skills
      nexp = exp
      nexp = exp.to_f * $game_variables[$game_system.reserve_exprate_var] / 100.0 if actor.reserve_member?
      actor.gain_exp(Integer(nexp), true)
    end
    wait_for_message
  end
end
