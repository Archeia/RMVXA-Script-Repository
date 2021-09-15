#encoding:UTF-8
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   Game_BattleAction
#     new-method :battle_vocab
#     new-method :battle_commands
#   Window_ActorCommand
#     new-method :draw_command
#     overwrite  :initialize
#     overwrite  :setup
#     overwrite  :refresh
#     overwrite  :draw_item
#   Scene_Battle
#     overwrite  :execute_action_skill
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
$imported ||= {}
$imported["IEO-Ohmerion"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
$ieo_script = {} if $ieo_script == nil
$ieo_script[[5, "Ohmerion"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# Game_System
#==============================================================================#
class Game_System

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :wpc_displaymode

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo005_gs_initialize :initialize unless $@
  def initialize
    ieo005_gs_initialize
    @wpc_displaymode = 1
  end

end

#==============================================================================#
# Game_Battler
#==============================================================================#
class Game_Battler

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :character
  attr_reader   :character_name
  attr_reader   :character_index

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo005_gmb_initialize :initialize unless $@
  def initialize
    @battle_index    = 0
    @character_name  = ""
    @character_index = 0
    ieo005_gmb_initialize
    @character = Game_CharacterBattler.new(self)
  end

  #--------------------------------------------------------------------------#
  # * new method :battle_index
  #--------------------------------------------------------------------------#
  def battle_index     ; @battle_index end
  def battle_index=(val) ; @battle_index = val end

  #--------------------------------------------------------------------------#
  # * new method :battle_speed
  #--------------------------------------------------------------------------#
  def battle_speed
    return action.speed
  end

  #--------------------------------------------------------------------------#
  # * new method :update_character_graphics
  #--------------------------------------------------------------------------#
  def update_character_graphics ; return end

end

#==============================================================================#
# Game_Enemy
#==============================================================================#
class Game_Enemy < Game_Battler
end

#==============================================================================#
# Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * overwrite method :use_sprite?
  #--------------------------------------------------------------------------#
  def use_sprite?
    return true
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_character_graphics
  #--------------------------------------------------------------------------#
  def update_character_graphics
    @character.set_graphic(@character_name, @character_index)
    @character.update
  end

  #--------------------------------------------------------------------------#
  # * new method :screen_x
  #--------------------------------------------------------------------------#
  def screen_x
    return @character.screen_x
  end
  #--------------------------------------------------------------------------#
  # * new method :screen_y
  #--------------------------------------------------------------------------#
  def screen_y
    return @character.screen_y
  end
  #--------------------------------------------------------------------------#
  # * new method :screen_z
  #--------------------------------------------------------------------------#
  def screen_z
    return @character.screen_z
  end
  #--------------------------------------------------------------------------#
  # * new method :battle_index
  #--------------------------------------------------------------------------#
  def battle_index ; $game_party.battle_order.index(@actor_id) end

end

#==============================================================================#
# Game_Unit
#==============================================================================#
class Game_Unit

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :battle_layout

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo005_gu_initialize :initialize unless $@
  def initialize
    ieo005_gu_initialize
    @battle_order = []
    @battle_layout = {
      0 => [0,0],
      1 => [0,0],
      2 => [0,0],
      3 => [0,0],
    }
  end

  #--------------------------------------------------------------------------#
  # * new method :battle_order
  #--------------------------------------------------------------------------#
  def battle_order
    return @battle_order
  end

  #--------------------------------------------------------------------------#
  # * new method :shift_battleorder
  #--------------------------------------------------------------------------#
  def shift_battleorder(direction)
    case direction
    when :forward
      @battle_order.rotate!(1)
    when :backward
      @battle_order.rotate!(-1)
    when :invert
      @battle_order.rotate!(@battle_order.size/2)
    when :reverse
      @battle_order.reverse!
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :shifting?
  #--------------------------------------------------------------------------#
  def shifting?
    members.each { |mem| return true if mem.character.moving? }
    return false
  end

  #--------------------------------------------------------------------------#
  # * new method :do_mass_move
  #--------------------------------------------------------------------------#
  def do_mass_move(*args)
    case args[0]
    when :formation
      shift_battleorder(args[1])
      members.each { |mem| mem.character.update_battleindex }
    when :run
      case args[1]
      when :failed
        members.each { |mem|
          mem.character.setup_orginmovement(:failedrun)
          mem.character.return_to_origin }
      when :success
        members.each { |mem|
          mem.character.setup_orginmovement(:run)
          mem.character.return_to_origin }
      end
    when :enter
      members.each { |mem|
        mem.character.setup_orginmovement(:startup)
        mem.character.return_to_origin }
    when :origin
      members.each { |mem|
        mem.character.setup_orginmovement(:base)
        mem.character.return_to_origin }
    end
  end

end

#==============================================================================#
# Game_Party
#==============================================================================#
class Game_Party < Game_Unit

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :last_command

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo005_gpt_initialize :initialize unless $@
  def initialize
    ieo005_gpt_initialize
    @last_command  = nil
    @battle_layout = {
      0 => [0, 0],
      1 => [0, 2],
      2 => [2, 2],
      3 => [2, 0],
    }
  end

  #--------------------------------------------------------------------------#
  # * new method :setup_battle_order
  #--------------------------------------------------------------------------#
  def setup_battle_order
    @battle_order = []
    members.compact.each { |mem| @battle_order << mem.id }
  end

  #--------------------------------------------------------------------------#
  # * new method :party_vocab
  #--------------------------------------------------------------------------#
  def party_vocab(obj)
    case obj
    when :fight       ; return Vocab.fight
    when :escape      ; return Vocab.escape
    when :formation   ; return "Formation"
    when :for_forward ; return "Clockwise"
    when :for_backward; return "A.Clockwise"
    when :for_invert  ; return "Invert"
    when :for_reverse ; return "Reverse"
    end
  end

end

#==============================================================================#
# Game_CharacterBattler
#==============================================================================#
class Game_CharacterBattler < Game_Character

  #--------------------------------------------------------------------------#
  # * super method :initialize
  #--------------------------------------------------------------------------#
  def initialize(parent)
    super()
    @battler = parent
    @step_anime = true

    @target_x = 0
    @target_y = 0
    # // Move
    @move_x = 0
    @move_y = 0
    @move_z = 0
    @move_speed_x = 0
    @move_speed_y = 0
    # // Accel
    @accel_x       = 0
    @maxaccel_x    = 0
    @accel_xrate   = 0.0
    @accel_xstart  = 0
    @accel_y       = 0
    @maxaccel_y    = 0
    @accel_yrate   = 0.0
    @accel_ystart  = 0

    @deccel_x      = 0
    @maxdeccel_x   = 0
    @deccel_xrate  = 0.0
    @deccel_xstart = 0
    @deccel_y      = 0
    @maxdeccel_y   = 0
    @deccel_yrate  = 0.0
    @deccel_ystart = 0
    # // Dist
    @xdist = 0
    @ydist = 0
    @maxxdist = 0
    @maxydist = 0
    # // Timing
    @framex        = 0
    @maxframex     = 0
    @framey        = 0
    @maxframey     = 0

    @origin_x = 0
    @origin_y = 0

    set_direction(4)
    @base_x = 0
    @base_y = 0
  end

  #--------------------------------------------------------------------------#
  # * new method :update_battleindex
  #--------------------------------------------------------------------------#
  def update_battleindex
    set_base_xy
    return_to_origin
  end
  #--------------------------------------------------------------------------#
  # * new method :return_to_origin
  #--------------------------------------------------------------------------#
  def return_to_origin
    move_target_xy(@origin_x, @origin_y, 2)
  end
  #--------------------------------------------------------------------------#
  # * new method :startup
  #--------------------------------------------------------------------------#
  def startup
    setup_orginmovement(:startup)
  end
  #--------------------------------------------------------------------------#
  # * new method :party
  #--------------------------------------------------------------------------#
  def party
    if @battler.actor?
      return $game_party
    else
      return $game_troop
    end
  end
  #--------------------------------------------------------------------------#
  # * new method :setup_orginmovement
  #--------------------------------------------------------------------------#
  def setup_orginmovement(type)
    case type
    when :base
      lay = party.battle_layout[@battler.battle_index]
      gw = Graphics.width/32
      @origin_x = (gw - 5 + lay[0]) * 32
      @origin_y = (6 + lay[1]) * 32
      @base_x = 0
      @base_y = 0
    when :startup
      set_base_xy
      @move_x = Graphics.width + 32
      @move_y = @origin_y
      return_to_origin
    when :run
      lay = party.battle_layout[@battler.battle_index]
      gw = Graphics.width/32
      @origin_x = (gw + 3 + lay[0]) * 32
      @origin_y = (6 + lay[1]) * 32
      @base_x = 0
      @base_y = 0
    when :failedrun
      lay = party.battle_layout[@battler.battle_index]
      gw = Graphics.width/32
      @origin_x = (gw - 2 + lay[0]) * 32
      @origin_y = (6 + lay[1]) * 32
      @base_x = 0
      @base_y = 0
    end
  end
  #--------------------------------------------------------------------------#
  # * new method :set_base_xy
  #--------------------------------------------------------------------------#
  def set_base_xy
    setup_orginmovement(:base)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :screen_x
  #--------------------------------------------------------------------------#
  def screen_x
    return 0 if @battler.battle_index == nil
    return @base_x + @move_x
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :screen_y
  #--------------------------------------------------------------------------#
  def screen_y
    return 0 if @battler.battle_index == nil
    return @base_y + @move_y
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :screen_z
  #--------------------------------------------------------------------------#
  def screen_z
    return 0 if @battler.battle_index == nil
    return @battler.battle_index + @base_y + @move_y + @move_z + 200
  end

  #--------------------------------------------------------------------------#
  # * new method :move_target_xy
  #--------------------------------------------------------------------------#
  def move_target_xy(x, y, speed=1)
    @target_x      = x
    @target_y      = y
    @move_speed_x  = speed
    @move_speed_y  = speed

    @xdist         = 0
    @ydist         = 0
    @maxxdist      = (@move_x - @target_x).abs
    @maxydist      = (@move_y - @target_y).abs

    @framex        = 0
    @framey        = 0

    @accel_x       = 0
    @maxaccel_x    = 2
    @accel_xrate   = 0.2
    @accel_xstart  = 0
    @accel_y       = 0
    @maxaccel_y    = 2
    @accel_yrate   = 0.2
    @accel_ystart  = 0

    @deccel_x      = 0
    @maxdeccel_x   = 2
    @deccel_xrate  = 0.5
    @deccel_xstart = @maxdeccel_x / @deccel_xrate
    @deccel_y      = 0
    @maxdeccel_y   = 2
    @deccel_yrate  = 0.5
    @deccel_ystart = @maxdeccel_y / @deccel_yrate

    @maxframex = @maxxdist / (@move_speed_x+@maxaccel_x) #@maxdeccel_x
    @maxframey = @maxydist / (@move_speed_y+@maxaccel_y) #@maxdeccel_y
    @deccel_xstart = @maxframex - @deccel_xstart.to_i
    @deccel_ystart = @maxframey - @deccel_ystart.to_i
  end

  #--------------------------------------------------------------------------#
  # * new method :moving?
  #--------------------------------------------------------------------------#
  def moving?
    return true if [@move_speed_x != 0, @move_speed_y != 0].any?
    return false
  end

  #--------------------------------------------------------------------------#
  # * new method :update
  #--------------------------------------------------------------------------#
  def update
    super
    update_bat_move
  end

  #--------------------------------------------------------------------------#
  # * new method :update_bat_move
  #--------------------------------------------------------------------------#
  def update_bat_move
    # // Calculations
    if @framex < @deccel_xstart
      @accel_x = [@accel_x + @accel_xrate, @maxaccel_x].min
    else
      @deccel_x = [@deccel_x + @deccel_xrate, @maxdeccel_x].min
    end
    if @framey < @deccel_ystart
      @accel_y = [@accel_y + @accel_yrate, @maxaccel_y].min
    else
      @deccel_y = [@deccel_y + @deccel_yrate, @maxdeccel_y].min
    end
    movex = (@move_speed_x + @accel_x) - @deccel_x
    movey = (@move_speed_y + @accel_y) - @deccel_y
    # // Move
    if @move_x > @target_x && @move_speed_x != 0
      @move_x = [@move_x - movex.abs, @target_x].max
    elsif @move_x < @target_x && @move_speed_x != 0
      @move_x = [@move_x + movex.abs, @target_x].min
    end
    if @move_y > @target_y && @move_speed_y != 0
      @move_y = [@move_y - movey.abs, @target_y].max
    elsif @move_y < @target_y && @move_speed_y != 0
      @move_y = [@move_y + movey.abs, @target_y].min
    end
    # //
    @move_x = @move_x # Integer(@move_x)
    @move_y = @move_y # Integer(@move_y)
    @move_speed_x = 0 if @move_x == @target_x
    @move_speed_y = 0 if @move_y == @target_y
    @framex += 1
    @framey += 1
  end

end

#==============================================================================#
# Sprite_Battler
#==============================================================================#
class Sprite_Battler < Sprite_Base

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo005_spb_initialize :initialize unless $@
  def initialize(viewport, battler = nil)
    ieo005_spb_initialize(viewport, battler)
    @battler.character.startup
    create_character unless @battler.nil?
  end

  #--------------------------------------------------------------------------#
  # * new method :create_character
  #--------------------------------------------------------------------------#
  def create_character
    @character_sprite = Sprite_Character.new(self.viewport, @battler.character)
  end

  #--------------------------------------------------------------------------#
  # * alias method :dispose
  #--------------------------------------------------------------------------#
  alias :ieo005_spb_dispose :dispose unless $@
  def dispose
    dispose_character
    ieo005_spb_dispose
  end

  #--------------------------------------------------------------------------#
  # * new method :dispose_character
  #--------------------------------------------------------------------------#
  def dispose_character
    @character_sprite.dispose unless @character_sprite.nil?
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update
  #--------------------------------------------------------------------------#
  def update
    super
    if @battler == nil
      self.bitmap = nil
      dispose_character
    else
      unless @battler.nil?
        create_character if @character_sprite.nil?
      end
      if @battler.is_a?(Game_Actor)
        @character_sprite.character = @battler.character unless @character_sprite.nil?
      end
      @battler.update_character_graphics
      @use_sprite = @battler.use_sprite?
      if @use_sprite
        self.x = @battler.screen_x
        self.y = @battler.screen_y
        self.z = @battler.screen_z
        @character_sprite.update unless @character_sprite.nil?
        update_battler_bitmap
      end
      setup_new_effect
      update_effect
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :update_battler_bitmap
  #--------------------------------------------------------------------------#
  def update_battler_bitmap
    if @battler.battler_name != @battler_name or
       @battler.battler_hue != @battler_hue
      @battler_name = @battler.battler_name
      @battler_hue = @battler.battler_hue
      self.bitmap = Cache.battler(@battler_name, @battler_hue)
      @width = bitmap.width
      @height = bitmap.height
      self.ox = @width / 2
      self.oy = @height
      if @battler.dead? or @battler.hidden
        self.opacity = 0
      end
    end
  end

  #--------------------------------------------------------------------------#
  # new_method :update_move
  #--------------------------------------------------------------------------#
  def update_move
    @battler.update_bat_move
  end

end

#==============================================================================#
# Scene_Battle
#==============================================================================#
class Spriteset_Battle

  #--------------------------------------------------------------------------#
  # * overwrite method :create_actors
  #--------------------------------------------------------------------------#
  def create_actors
    @actor_sprites = []
    for mem in $game_party.members
      @actor_sprites.push(Sprite_Battler.new(@viewport1, mem))
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_actors
  #--------------------------------------------------------------------------#
  def update_actors
    for i in 0...@actor_sprites.size
      @actor_sprites[i].battler = $game_party.members[i]
    end
    for sprite in @actor_sprites
      sprite.update
    end
  end

end

#==============================================================================#
# Window_TargetEnemy
#==============================================================================#
Object.send :remove_const, :Window_TargetEnemy
class Window_TargetEnemy < Window_BattleStatus

  #--------------------------------------------------------------------------#
  # * overwrite method :initialize
  #--------------------------------------------------------------------------#
  def initialize
    super
    self.active = true
    self.index  = 0
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    @draw_style = 0
    create_contents
    @members  = [ ]
    for mem in $game_troop.members
      @members << mem if mem.exist?
    end
    @item_max = @members.size
    setup_column_max
    for i in 0...@item_max
      draw_item(i)
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :enemy
  #--------------------------------------------------------------------------#
  def enemy
    return @members[self.index]
  end

end

#==============================================================================#
# Window_PartyCommand
#==============================================================================#
Object.send :remove_const, :Window_PartyCommand
class Window_PartyCommand < Window_Selectable

  include ICY_Window_MiniCommand

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo005_wpc_initialize :initialize unless $@
  def initialize
    ieo005_wpc_initialize
    refresh
  end

  #--------------------------------------------------------------------------#
  # * new method :display_mode
  #--------------------------------------------------------------------------#
  def display_mode ; return $game_system.wpc_displaymode end

  #--------------------------------------------------------------------------#
  # * overwrite method :setup_commands
  #--------------------------------------------------------------------------#
  def setup_commands(type)
    case type
    when :standard
      s1 = :fight
      s2 = :escape
      s3 = :formation
      @commands = [s1, s2, s3]
    when :formation
      s1 = :for_forward
      s2 = :for_backward
      s3 = :for_invert
      s4 = :for_reverse
      s5 = :for_cancel
      @commands = [s1, s2, s3, s4, s5]
    end
    @last_setup   = type
    @item_max = @commands.size
    @column_max = 1
    @column_max = 3 if display_mode == 1
  end

  #--------------------------------------------------------------------------#
  # * new method :party
  #--------------------------------------------------------------------------#
  def party ; return $game_party end

  #--------------------------------------------------------------------------#
  # * new method :get_icon
  #--------------------------------------------------------------------------#
  def get_icon(obj) ; return IEO::Icon.party_command(party, obj) end
  #--------------------------------------------------------------------------#
  # * new method :get_vocab
  #--------------------------------------------------------------------------#
  def get_vocab(obj); return party.party_vocab(obj) end
  #--------------------------------------------------------------------------#
  # * new method :lastindex_command
  #--------------------------------------------------------------------------#
  def lastindex_command ; return party.last_command end
  #--------------------------------------------------------------------------#
  # * new method :set_lastcommand
  #--------------------------------------------------------------------------#
  def set_lastcommand ; party.last_command = command end

end

#==============================================================================#
# OHM_WindowTurn
#==============================================================================#
class OHM_WindowTurn < Window_Selectable

  def initialize
    super(0, Graphics.height-192, Graphics.width, 56)
    self.opacity = 0
    @turn_data = []
    @turn_index = -1
    refresh
  end

  def change_turndata(new_turndata)
    @turn_data = new_turndata
    refresh
  end

  def refresh
    @item_max = $game_party.members.size+$game_troop.members.size #@turn_data.size
    @column_max = [1, @item_max].max
    create_contents
    for i in 0...@item_max
      bat = @turn_data[i]
      draw_item(i, i=0)
    end
  end

  def draw_item(index, enabled=true)
    rect = item_rect(index)
    bat = @turn_data[index]
    self.contents.clear_rect(rect)
    case bat
    when Game_Enemy ; icon = 99
    when Game_Actor ; icon = 100
    else            ; icon = 97
    end
    draw_icon(icon, rect.x, rect.y, enabled)
    return if bat.nil?
    self.contents.font.size = 14
    #self.contents.draw_text(rect, bat.index)
    self.contents.font.size = 12
    self.contents.draw_text(rect, bat.name, 2)
  end

end

#==============================================================================#
# Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base

  #include Ohmerion

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias ieo005_initialize initialize unless $@
  def initialize
    ieo005_initialize
    $game_party.setup_battle_order
    @action_list = []
  end

  #--------------------------------------------------------------------------#
  # * alias method :start
  #--------------------------------------------------------------------------#
  alias ieo005_start start unless $@
  def start
    ieo005_start
    create_turnorder_window
    @message_window.y = 0
    @message_window.opacity = 0
  end

  #--------------------------------------------------------------------------#
  # * new method :create_turnorder_window
  #--------------------------------------------------------------------------#
  def create_turnorder_window
    #@turn_window = OHM_WindowTurn.new
  end

  #--------------------------------------------------------------------------
  # * overwrite method :make_action_orders
  #--------------------------------------------------------------------------
  def make_action_orders
    @action_battlers = []
    unless $game_troop.surprise
      @action_battlers += $game_party.members
    end
    unless $game_troop.preemptive
      @action_battlers += $game_troop.members
    end
    for battler in @action_battlers
      battler.action.make_speed
    end
    @action_battlers.sort! do |a,b|
      b.battle_speed - a.battle_speed
    end
  end

  #--------------------------------------------------------------------------#
  # * alias method :set_next_active_battler
  #--------------------------------------------------------------------------#
  alias ieo005_set_next_active_battler set_next_active_battler unless $@
  def set_next_active_battler
    ieo005_set_next_active_battler
    #@turn_window.change_turndata(@action_battlers-($game_party.dead_members+$game_troop.dead_members))
  end

  #--------------------------------------------------------------------------#
  # * alias method :start_actor_command_selection
  #--------------------------------------------------------------------------#
  alias ieo005_start_actor_command_selection start_actor_command_selection unless $@
  def start_actor_command_selection
    @actor_command_window.vis_rowcount = 5 #@active_battler.battle_commands.size
    @actor_command_window.setup_height
    @actor_command_window.y = @info_viewport.rect.height - @actor_command_window.height
    @active_battler.action.clear
    @status_window.refresh
    ieo005_start_actor_command_selection
    @actor_command_window.setindex
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :start_target_enemy_selection
  #--------------------------------------------------------------------------#
  def start_target_enemy_selection
    @target_enemy_window = Window_TargetEnemy.new
    @target_enemy_window.y = @info_viewport.rect.height - @target_enemy_window.height
    #@info_viewport.rect.x += @target_enemy_window.width
    #@info_viewport.ox += @target_enemy_window.width
    @target_enemy_window.viewport = @info_viewport
    @actor_command_window.active = false
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :end_target_enemy_selection
  #--------------------------------------------------------------------------#
  def end_target_enemy_selection
    #@info_viewport.rect.x -= @target_enemy_window.width
    #@info_viewport.ox -= @target_enemy_window.width
    @target_enemy_window.dispose
    @target_enemy_window = nil
    if @actor_command_window.index == 0
      @actor_command_window.active = true
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :start_target_actor_selection
  #--------------------------------------------------------------------------#
  def start_target_actor_selection
    @target_actor_window = Window_BattleStatus.new
    @target_actor_window.index = 0
    @target_actor_window.active = true
    @target_actor_window.y = @info_viewport.rect.height - @target_actor_window.height
    @target_actor_window.viewport = @info_viewport
    #@info_viewport.rect.x += @target_actor_window.width
    #@info_viewport.ox += @target_actor_window.width
    @actor_command_window.active = false
    @status_window.visible = false
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :end_target_actor_selection
  #--------------------------------------------------------------------------#
  def end_target_actor_selection
    #@info_viewport.rect.x -= @target_actor_window.width
    #@info_viewport.ox -= @target_actor_window.width
    @target_actor_window.active = false
    @target_actor_window.dispose
    @target_actor_window = nil
    @status_window.visible = true
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :create_info_viewport
  #--------------------------------------------------------------------------#
  def create_info_viewport
    @info_viewport = Viewport.new(0, Graphics.height-256, Graphics.width, 256) # 128
    @info_viewport.z = 100
    @status_window = Window_BattleStatus.new
    @party_command_window = Window_PartyCommand.new
    @actor_command_window = Window_ActorCommand.new
    @status_window.viewport = @info_viewport
    @party_command_window.viewport = @info_viewport
    @actor_command_window.viewport = @info_viewport
    @status_window.x = 128
    @status_window.y = @party_command_window.y = @info_viewport.rect.height - @status_window.height
    #@actor_command_window.vis_rowcount = 4
    @actor_command_window.x = Graphics.width
    @info_viewport.visible = false
  end

  #--------------------------------------------------------------------------
  # * Update Party Command Selection
  #--------------------------------------------------------------------------
  def update_party_command_selection
    if Input.trigger?(Input::C)
      case @party_command_window.command
      when :fight  # Fight
        Sound.play_decision
        @status_window.index = @actor_index = -1
        next_actor
      when :escape  # Escape
        if $game_troop.can_escape == false
          Sound.play_buzzer
          return
        end
        Sound.play_decision
        process_escape
      when :formation
        Sound.play_decision
        @party_command_window.setup_commands(:formation)
        @party_command_window.refresh
      when :for_forward
        $game_party.do_mass_move(:formation, :forward)
        @party_command_window.setup_commands(:standard)
        @party_command_window.refresh
      when :for_backward
        $game_party.do_mass_move(:formation, :backward)
        @party_command_window.setup_commands(:standard)
        @party_command_window.refresh
      when :for_invert
        $game_party.do_mass_move(:formation, :invert)
        @party_command_window.setup_commands(:standard)
        @party_command_window.refresh
      when :for_reverse
        $game_party.do_mass_move(:formation, :reverse)
        @party_command_window.setup_commands(:standard)
        @party_command_window.refresh
      when :for_cancel
        Sound.play_decision
        @party_command_window.setup_commands(:standard)
        @party_command_window.refresh
      end
    elsif Input.trigger?(Input::B)
      case @party_command_window.last_setup
      when :formation
        Sound.play_cancel
        @party_command_window.setup_commands(:standard)
        @party_command_window.refresh
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :execute_action_attack
  #--------------------------------------------------------------------------#
  def execute_action_attack
    text = sprintf(Vocab::DoAttack, @active_battler.name)
    @message_window.add_instant_text(text)
    targets = @active_battler.action.make_targets
    display_attack_animation(targets)
    wait(20)
    for target in targets
      target.attack_effect(@active_battler)
      display_action_effects(target)
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :execute_action_guard
  #--------------------------------------------------------------------------#
  def execute_action_guard
    text = sprintf(Vocab::DoGuard, @active_battler.name)
    @message_window.add_instant_text(text)
    wait(45)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :execute_action_escape
  #--------------------------------------------------------------------------#
  def execute_action_escape
    text = sprintf(Vocab::DoEscape, @active_battler.name)
    @message_window.add_instant_text(text)
    @active_battler.escape
    Sound.play_escape
    wait(45)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :execute_action_wait
  #--------------------------------------------------------------------------#
  def execute_action_wait
    text = sprintf(Vocab::DoWait, @active_battler.name)
    @message_window.add_instant_text(text)
    wait(45)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :execute_action_skill
  #--------------------------------------------------------------------------#
  def execute_action_skill
    while !@action_list.empty?
      update_action
    end
    skill = @active_battler.action.skill
    text = @active_battler.name + skill.message1
    @message_window.add_instant_text(text)
    unless skill.message2.empty?
      wait(10)
      @message_window.add_instant_text(skill.message2)
    end
    targets = @active_battler.action.make_targets
    display_animation(targets, skill.animation_id)
    @active_battler.mp -= @active_battler.calc_mp_cost(skill)
    $game_temp.common_event_id = skill.common_event_id
    for target in targets
      target.skill_effect(@active_battler, skill)
      display_action_effects(target, skill)
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :execute_action_item
  #--------------------------------------------------------------------------#
  def execute_action_item
    item = @active_battler.action.item
    text = sprintf(Vocab::UseItem, @active_battler.name, item.name)
    @message_window.add_instant_text(text)
    targets = @active_battler.action.make_targets
    display_animation(targets, item.animation_id)
    $game_party.consume_item(item)
    $game_temp.common_event_id = item.common_event_id
    for target in targets
      target.item_effect(@active_battler, item)
      display_action_effects(target, item)
    end
  end

  #--------------------------------------------------------------------------
  # * Escape Processing
  #--------------------------------------------------------------------------
  def process_escape
    @info_viewport.visible = false
    @message_window.visible = true
    text = sprintf(Vocab::EscapeStart, $game_party.name)
    $game_message.texts.push(text)
    if $game_troop.preemptive
      success = true
    else
      success = (rand(100) < @escape_ratio)
    end
    Sound.play_escape
    if success
      $game_party.do_mass_move(:run, :success)
      update_basic while $game_party.shifting? # Shifting is actually moving?
      wait_for_message
      battle_end(1)
    else
      $game_party.do_mass_move(:run, :failed)
      update_basic while $game_party.shifting? # Shifting is actually moving?
      $game_party.do_mass_move(:origin)
      @escape_ratio += 10
      $game_message.texts.push('\.' + Vocab::EscapeFailure)
      wait_for_message
      $game_party.clear_actions
      start_main
    end
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
