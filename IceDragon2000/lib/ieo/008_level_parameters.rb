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
$imported['IEO-LevelParameters'] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, 'ScriptName']]
$ieo_script = {} if $ieo_script == nil
$ieo_script[[8, 'LevelParameters']] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** IEO::LevelParameters
#==============================================================================#
module IEO
  module LevelParameters
    #STATS = [:maxhp, :maxmp, :atk, :def, :spi, :agi]
    STATS = [:maxhp, :maxmp, :maxen, :atk, :def, :spi, :agi]

    def self.default_levels(actor)
      {
        :maxhp => [1, 99],
        :maxmp => [1, 99],
        :atk   => [1, 99],
        :def   => [1, 99],
        :spi   => [1, 99],
        :agi   => [1, 99],

        :maxen => [1, 30]
      }
    end

    def self.post_load_database
      [$data_weapons, $data_armors, $data_states].each do |group|
        group.reject(&:nil?).each do |obj|
          obj.ieo008_baseitemcache if obj.kind_of?(RPG::BaseItem)
          obj.ieo008_statecache if obj.kind_of?(RPG::State)
        end
      end
    end
  end
end

module Vocab
  class << self
    def maxhp ; return self.hp ; end
    def maxmp ; return self.mp ; end
    def maxhp_a ; return self.hp_a ; end
    def maxmp_a ; return self.mp_a ; end
  end
end

#==============================================================================#
# ** IEO::REGEX::RIVIERA_MAPNAVIGATION
#==============================================================================#
module IEO
  module REGEXP
    module LevelParameters
      module BASEITEM
        STAT_SET = /<(.*):[ ]*([\+\-](\d+))>/i
      end
      module STATE
        LEVEL_MOD = /<(.*)(?:_LEVEL| LEVEL|LEVEL):[ ]*([\+\-](\d+))>/i
      end
    end
  end
end

#==============================================================================#
# ** RPG::BaseItem
#==============================================================================#
class RPG::BaseItem
  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_writer :maxhp
  attr_writer :maxmp

  def maxhp
    @maxhp ||= 0
  end

  def maxmp
    @maxmp ||= 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :ieo008_baseitemcache
  #--------------------------------------------------------------------------#
  def ieo008_baseitemcache
    @maxhp ||= 0
    @maxmp ||= 0
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when IEO::REGEXP::LevelParameters::BASEITEM::STAT_SET
        stat = $1
        val  = $2.to_i
        case stat.upcase
        when 'MAXHP' ; @maxhp = val
        when 'MAXMP' ; @maxmp = val
        when 'ATK'   ; @atk   = val
        when 'DEF'   ; @def   = val
        when 'SPI'   ; @spi   = val
        when 'AGI'   ; @agi   = val
        else         ; custom_stat_set(stat, val)
        end
      end
    end
    @ieo008_baseitemcache_complete = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :custom_stat_set
  #--------------------------------------------------------------------------#
  def custom_stat_set(stat, val)
    return 0
  end
end

#==============================================================================#
# ** RPG::State
#==============================================================================#
class RPG::State
  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :maxhp_level_mod
  attr_accessor :maxmp_level_mod
  attr_accessor :atk_level_mod
  attr_accessor :def_level_mod
  attr_accessor :spi_level_mod
  attr_accessor :agi_level_mod

  #--------------------------------------------------------------------------#
  # * new-method :ieo008_statecache
  #--------------------------------------------------------------------------#
  def ieo008_statecache
    @maxhp_level_mod ||= 0
    @maxmp_level_mod ||= 0
    @atk_level_mod ||= 0
    @def_level_mod ||= 0
    @spi_level_mod ||= 0
    @agi_level_mod ||= 0
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when IEO::REGEXP::LevelParameters::STATE::LEVEL_MOD
        stat = $1
        val  = $2.to_i
        case stat.upcase
        when "MAXHP" ; @maxhp_level_mod = val
        when "MAXMP" ; @maxmp_level_mod = val
        when "ATK"   ; @atk_level_mod   = val
        when "DEF"   ; @def_level_mod   = val
        when "SPI"   ; @spi_level_mod   = val
        when "AGI"   ; @agi_level_mod   = val
        else         ; custom_stat_lvl_mod(stat, val)
        end
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :custom_stat_lvl_mod
  #--------------------------------------------------------------------------#
  def custom_stat_lvl_mod(stat, val)
    return 0
  end
end

#==============================================================================#
# ** IEO::LevelParameters::ParameterMix
#==============================================================================#
module IEO::LevelParameters::ParameterMix
  IEO::LevelParameters::STATS.each do |k|
    attr_reader k.to_s + '_level'
    attr_accessor k.to_s + '_maxlevel'

    module_eval(%Q(
      def #{k.to_s}_level_mod
        0
      end

      def #{k.to_s}_level_plus
        states.inject(0) { |r, s| r + s.#{k.to_s}_level_mod }
      end

      def #{k.to_s}_level_p
        [#{k.to_s}_level + #{k.to_s}_level_plus, 1, #{k.to_s}_maxlevel].clamp
      end

      def #{k.to_s}_level=(value)
        old_level = @#{k.to_s}_level
        @#{k.to_s}_level = [[value, 1].max, #{k.to_s}_maxlevel].min
        @cached_#{k.to_s} = nil if old_level != @#{k.to_s}_level
      end

      def #{k.to_s}_level_max?
        #{k.to_s}_level == #{k.to_s}_maxlevel
      end

      def #{k.to_s}_level_value(level = self.#{k.to_s}_level_p)
        0
      end
    ), "ieo/008_level_parameters/stats/#{k}", 1)
  end

  def maxhp_level_value(level=self.maxhp_level_p)
    return actor.parameters[0, level]
  end

  def maxmp_level_value(level=self.maxmp_level_p)
    return actor.parameters[1, level]
  end

  def atk_level_value(level=self.atk_level_p)
    return actor.parameters[2, level]
  end

  def def_level_value(level=self.def_level_p)
    return actor.parameters[3, level]
  end

  def spi_level_value(level=self.spi_level_p)
    return actor.parameters[4, level]
  end

  def agi_level_value(level=self.agi_level_p)
    return actor.parameters[5, level]
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_parameter_levels
  #--------------------------------------------------------------------------#
  def setup_parameter_levels
    IEO::LevelParameters::STATS.each do |key|
      self.send(key.to_s + "_maxlevel=", 99)
      self.send(key.to_s + "_level=", 1)
    end
  end
end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler
  include IEO::LevelParameters::ParameterMix

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo008_gmb_initialize :initialize
  def initialize(*args, &block)
    setup_parameter_levels
    ieo008_gmb_initialize(*args, &block)
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_parameter_levels
  #--------------------------------------------------------------------------#
  def create_parameter_levels
    IEO::LevelParameters.default_levels(self).each_pair do |key, v|
      self.send(key.to_s + '_maxlevel=', v[1])
      self.send(key.to_s + '_level=', v[0])
    end
  end
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :ieo008_gma_setup :setup
  def setup(actor_id)
    ieo008_gma_setup(actor_id)
    create_parameter_levels
  end

  #--------------------------------------------------------------------------#
  # * overwrite-methods :base_*
  #--------------------------------------------------------------------------#
  IEO::LevelParameters::STATS.each do |statname|
    module_eval(%Q(
      def equips_#{statname}
        equips.reject(&:nil?).inject(0) do |n, item|
          n + item.#{statname}
        end
      end

      def base_#{statname}
        (equips_#{statname} + #{statname}_level_value).to_i
      end
    ), "ieo/008_level_parameters/game_actor/stats/#{statname}", 1)
  end
end

#==============================================================================#
# ** Game_Enemy
#==============================================================================#
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------#
  # * overwrite-methods :base_*
  #--------------------------------------------------------------------------#
  (IEO::LevelParameters::STATS -
   [:maxhp, :maxmp, :atk, :def, :spi, :agi]).each do |statname|
    module_eval(%Q(
      def base_#{statname.to_s}
        return Integer(#{statname.to_s}_level_value)
      end
    ), "ieo/008_level_parameters/game_enemy/stats/#{statname}", 1 )
  end
end

#==============================================================================#
# ** Window_Parameter
#==============================================================================#
class Window_Parameter < Window_Selectable
  WLH = 20

  def initialize(actor, x, y)
    super(x, y, Graphics.width/2, Graphics.height-56)
    @actor = actor
    self.index = 0
    refresh
  end

  def stat(index = self.index)
    return @stats[index]
  end

  def refresh
    @stats = ::IEO::LevelParameters::STATS
    @item_max = @stats.size
    create_contents
    for i in 0...@stats.size
      draw_item(i)
    end
  end

  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = (index / @column_max * WLH)
    return rect
  end

  def draw_item(index)
    draw_parameter(0, WLH*index, @stats[index])
  end

  def draw_parameter(x, y, stat)
    rect     = Rect.new(x, y, self.contents.width, WLH)
    self.contents.clear_rect(rect)

    vocab    = Vocab.send(stat)
    icon     = IEO::Icon.stat(stat)
    value    = @actor.send(stat)
    level    = @actor.send(stat.to_s+"_level")
    maxlevel = @actor.send(stat.to_s+"_maxlevel")

    leveltxt = sprintf("%s: %s", Vocab.level_a, level)

    if icon > 0
      draw_stretched_icon(icon, rect.x, rect.y, 20, 20)
      #draw_icon(icon, rect.x, rect.y)
      rect.x += 24 ; rect.width -= 28
    end

    self.contents.font.size = Font.default_size - 4
    brect = rect.clone ; brect.y += 12 ;
    brect.width /= 1.5 ; brect.height = 6 # 42
    draw_round_grad_bar(
      brect, level, maxlevel,
      Color.new(200, 208, 192), mp_gauge_color2, gauge_back_color,
      2, true
    )
    rect.y -= 2
    self.contents.font.color = system_color
    self.contents.draw_text(rect, vocab)
    self.contents.font.color = normal_color
    self.contents.draw_text(rect, value, 2)
    self.contents.font.size = Font.default_size - 6
    rect.width /= 1.5 ; rect.width += 32
    self.contents.draw_text(rect, leveltxt, 2)
  end

  def update
    super
    update_stat_changes if self.active
  end

  def update_stat_changes
    if Input.trigger?(Input::C)
      Sound.play_decision
      level = @actor.send(stat.to_s+"_level")
      @actor.send(stat.to_s+"_level=", level+1)
      draw_item(self.index)
    end
  end
end

#==============================================================================#
# ** Window_ParameterStatus
#==============================================================================#
class Window_ParameterStatus < Window_Base
  def initialize(actor, x, y)
    @actor = actor
    super(x, y, Graphics.width, 56)
    disable_cursor
    refresh
  end

  def refresh
    draw_actor_name(@actor, 0, 0)
    draw_actor_hp(@actor, 128, 0)
    draw_actor_mp(@actor, 128+128, 0)
  end
end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------#
  # * alias-method :load_database
  #--------------------------------------------------------------------------#
  alias :ieo008_load_database :load_database
  def load_database
    ieo008_load_database
    IEO::LevelParameters.post_load_database
  end

  #--------------------------------------------------------------------------#
  # * alias-method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :ieo008_load_bt_database :load_database
  def load_bt_database
    ieo008_load_bt_database
    IEO::LevelParameters.post_load_database
  end
end

#==============================================================================#
# ** Scene_LevelParameter
#==============================================================================#
class Scene_LevelParameter < Scene_Base
  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(actor, called=:map, return_index=0)
    super
    # ---------------------------------------------------- #
    @actor = nil
    @act_index = 0
    @index_call = false
    # ---------------------------------------------------- #
    if actor.kind_of?(Game_Battler)
      @actor = actor
    elsif actor != nil
      @actor = $game_party.members[actor]
      @act_index = actor
      @index_call = true
    end
    # ---------------------------------------------------- #
    @calledfrom = called
    @return_index = return_index
    # ---------------------------------------------------- #
  end

  def start
    super
    create_menu_background
    @help_window      = Window_Help.new
    @status_window    = Window_ParameterStatus.new(@actor, 0, 56)
    @parameter_window = Window_Parameter.new(@actor, 0, 112)
    @parameter_window.help_window = @help_window
  end

  #--------------------------------------------------------------------------#
  # * new-method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    case @calledfrom
    when :map
      $scene = Scene_Map.new
    when :menu
      $scene = Scene_Menu.new(@return_index)
    end
  end

  def terminate
    super
    dispose_menu_background
    @status_window.dispose unless @status_window.nil?
    @parameter_window.dispose unless @status_window.nil?
    @help_window.dispose unless @help_window.nil?
    @status_window    = nil
    @parameter_window = nil
    @help_window      = nil
  end

  def update
    super
    update_menu_background
    @parameter_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    end
  end
end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
