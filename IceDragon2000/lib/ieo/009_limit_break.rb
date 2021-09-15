#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Limit & Break
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (Skills)
# ** Script Type   : Skill Modifier
# ** Date Created  : 02/25/2011
# ** Date Modified : 02/25/2011
# ** Script Tag    : IEO-009(Limit & Break)
# ** Difficulty    : Medium, Hard, Lunatic
# ** Version       : 1.0
# ** IEO ID        : 009
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-Limit&Break"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script ||= {})[[9, "Limit&Break"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# IEO::LimitBreak
#==============================================================================#
module IEO
  module LimitBreak
    def self.limit(battler, stat)
      case stat
      when :maxhp ; return 5000
      when :maxmp ; return 5000
      else        ; return 500   # // [:atk, :def, :spi, :agi]
      end
    end

    def self.post_load_database
      objs = [$data_weapons, $data_armors, $data_skills, $data_items, $data_states, $data_enemies]
      objs.each do |group|
        group.reject(&:nil?).each do |obj|
          obj.ieo009_baseitemcache   if obj.is_a?(RPG::BaseItem)
          obj.ieo009_usableitemcache if obj.is_a?(RPG::UsableItem)
          obj.ieo009_itemcache       if obj.is_a?(RPG::Item)
          obj.ieo009_enemycache      if obj.is_a?(RPG::Enemy)
          obj.ieo009_statecache      if obj.is_a?(RPG::State)
        end
      end
    end
  end
end

#==============================================================================#
# IEO::REGEXP::LimitBreak
#==============================================================================#
module IEO
  module REGEXP
    module LimitBreak
      module BaseItem
        STAT_SET   = /<(.*):[ ]*([\+\-]\d+)>/i
      end
      module UsableItem
        STAT_F     = /<(.*)(?:_F| f):[ ]*(\d+)([%％])>/i
        BASEDAMAGE = /<(?:BASEDAMAGE|BASE_DAMAGE|BASE DAMAGE):[ ]*([\+\-]\d+)>/i
        VARIANCE   = /<VARIANCE:[ ]*(\d+)>/i
        SPEED      = /<SPEED:[ ]*(\d+)>/i
      end
      module Item
        PARAM_POINTS = /<(?:PARAMETERPOINT|PARAMETER_POINT|PARAMETER POINT)s?:[ ]*([\+\-]\d+)>/i
      end
      module Enemy
        STAT_SET   = /<(.*):[ ]*(\d+)>/i
      end
      module State
        STAT_SET   = /<(.*):[ ]*([\+\-]\d+)>/i
        STAT_RATE  = /<(.*):[ ]*(\d+)([%％])>/i
      end
    end
  end
end

#==============================================================================#
# RPG::BaseItem
#==============================================================================#
class RPG::BaseItem

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :exp_p

  def ieo009_baseitemcache
    @maxhp = 0 if @maxhp.nil?
    @maxmp = 0 if @maxmp.nil?
    @exp_p = 0 if @exp_p.nil?
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when IEO::REGEXP::LimitBreak::BaseItem::STAT_SET
        stat = $1
        val  = $2.to_i
        case stat.upcase
        when "MAXHP" ; @maxhp = val
        when "MAXMP" ; @maxmp = val
        when "ATK"   ; @atk   = val
        when "DEF"   ; @def   = val
        when "SPI"   ; @spi   = val
        when "AGI"   ; @agi   = val
        when "HIT"   ; @hit   = val.abs
        when "EVA"   ; @eva   = val.abs
        when "PRICE" ; @price = val.abs
        when "EXP_P" ; @exp_p = val
        end
      end
    end
    @ieo009_baseitemcache_complete = true
  end

end

#==============================================================================#
# RPG::UsableItem
#==============================================================================#
class RPG::UsableItem


  def ieo009_usableitemcache
    @def_f = 0 if @def_f.nil?
    @agi_f = 0 if @agi_f.nil?
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEO::REGEXP::LimitBreak::UsableItem::STAT_F
      val = $2.to_i
      case $1.upcase
      when "ATK" ; @atk_f = val
      when "DEF" ; @def_f = val
      when "SPI" ; @spi_f = val
      when "AGI" ; @agi_f = val
      end
    when IEO::REGEXP::LimitBreak::UsableItem::BASEDAMAGE
      @base_damage = $1.to_i
    when IEO::REGEXP::LimitBreak::UsableItem::VARIANCE
      @variance = $1.to_i
    when IEO::REGEXP::LimitBreak::UsableItem::SPEED
      @speed = $1.to_i
    end
    }
    @ieo009_usableitemcache_complete = true
  end

end

#==============================================================================#
# RPG::Item
#==============================================================================#
class RPG::Item

  def ieo009_itemcache
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEO::REGEXP::LimitBreak::Item::PARAM_POINTS
      @parameter_points = $1.to_i
    end }
    @ieo009_itemcache_complete = true
  end

end

#==============================================================================#
# RPG::Enemy
#==============================================================================#
class RPG::Enemy

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :exp_p

  def ieo009_enemycache
    @exp_p = 0
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEO::REGEXP::LimitBreak::Enemy::STAT_SET
      stat = $1
      val  = $2.to_i
      case stat.upcase
      when "MAXHP" ; @maxhp = val
      when "MAXMP" ; @maxmp = val
      when "ATK"   ; @atk   = val
      when "DEF"   ; @def   = val
      when "SPI"   ; @spi   = val
      when "AGI"   ; @agi   = val
      when "EXP"   ; @exp   = val.abs
      when "GOLD"  ; @gold  = val.abs
      when "HIT"   ; @hit   = val.abs
      when "EVA"   ; @eva   = val.abs
      when "EXP_P" ; @exp_p = val
      end
    end }
    @ieo009_enemycache_complete = true
  end

end

#==============================================================================#
# RPG::State
#==============================================================================#
class RPG::State

  def ieo009_statecache
    @maxhp_rate = 100 if @maxhp_rate.nil?
    @maxmp_rate = 100 if @maxmp_rate.nil?
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEO::REGEXP::LimitBreak::State::STAT_RATE
      stat = $1
      val  = $2.to_i
      case stat.upcase
      when "MAXHP" ; @maxhp_rate = val
      when "MAXMP" ; @maxmp_rate = val
      when "ATK"   ; @atk_rate   = val
      when "DEF"   ; @def_rate   = val
      when "SPI"   ; @spi_rate   = val
      when "AGI"   ; @agi_rate   = val
      end
    end }
    @ieo009_statecache_complete = true
  end

end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :maxhp_limit
  attr_accessor :maxmp_limit
  attr_accessor :atk_limit
  attr_accessor :def_limit
  attr_accessor :agi_limit
  attr_accessor :spi_limit

  alias ieo009_gb_initialize initialize unless $@
  def initialize
    ieo009_gb_initialize
    @maxhp_limit = IEO::LimitBreak.limit(self, :maxhp)
    @maxmp_limit = IEO::LimitBreak.limit(self, :maxmp)
    @atk_limit   = IEO::LimitBreak.limit(self, :atk)
    @def_limit   = IEO::LimitBreak.limit(self, :def)
    @agi_limit   = IEO::LimitBreak.limit(self, :agi)
    @spi_limit   = IEO::LimitBreak.limit(self, :spi)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :maxhp
  #--------------------------------------------------------------------------#
  def maxhp
    return [[base_maxhp + @maxhp_plus, 1].max, maxhp_limit].min
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :maxmp
  #--------------------------------------------------------------------------#
  def maxmp
    return [[base_maxmp + @maxmp_plus, 0].max, maxmp_limit].min
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :atk
  #--------------------------------------------------------------------------#
  def atk
    n = [[base_atk + @atk_plus, 1].max, atk_limit].min
    for state in states do n *= state.atk_rate / 100.0 end
    n = [[Integer(n), 1].max, atk_limit].min
    return Integer(n)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :def
  #--------------------------------------------------------------------------#
  def def
    n = [[base_def + @def_plus, 1].max, def_limit].min
    for state in states do n *= state.def_rate / 100.0 end
    n = [[Integer(n), 1].max, def_limit].min
    return Integer(n)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :spi
  #--------------------------------------------------------------------------#
  def spi
    n = [[base_spi + @spi_plus, 1].max, spi_limit].min
    for state in states do n *= state.spi_rate / 100.0 end
    n = [[Integer(n), 1].max, spi_limit].min
    return Integer(n)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :agi
  #--------------------------------------------------------------------------#
  def agi
    n = [[base_agi + @agi_plus, 1].max, agi_limit].min
    for state in states do n *= state.agi_rate / 100.0 end
    n = [[Integer(n), 1].max, agi_limit].min
    return Integer(n)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :attack_effect
  #--------------------------------------------------------------------------#
  alias :ieo009_attack_effect :attack_effect unless $@
  def attack_effect(attacker)
    ieo009_attack_effect(attacker)
    attacker.gain_exp(attacker.obj_exp(:attack), false) if attacker.actor?
  end

  #--------------------------------------------------------------------------#
  # * alias-method :skill_effect
  #--------------------------------------------------------------------------#
  alias :ieo009_skill_effect :skill_effect unless $@
  def skill_effect(user, skill)
    ieo009_skill_effect(user, skill)
    user.gain_exp(user.obj_exp( :obj, skill ), false) if user.actor?
  end

  #--------------------------------------------------------------------------#
  # * alias-method :item_effect
  #--------------------------------------------------------------------------#
  alias :ieo009_item_effect :item_effect unless $@
  def item_effect(user, item)
    ieo009_item_effect(user, item)
    user.gain_exp(user.obj_exp( :obj, item ), false) if user.actor?
  end

end

#==============================================================================#
# ** Game_Enemy
#==============================================================================#
class Game_Enemy < Game_Battler

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias ieo009_ge_initialize initialize unless $@
  def initialize(*args, &block)
    ieo009_ge_initialize(*args, &block)
    @exp_p = enemy.exp_p
  end

  #--------------------------------------------------------------------------#
  # * new-method :maxhp_limit
  #--------------------------------------------------------------------------#
  def maxhp_limit ; return @maxhp_limit end

  #--------------------------------------------------------------------------#
  # * new-method :maxmp_limit
  #--------------------------------------------------------------------------#
  def maxmp_limit ; return @maxmp_limit end

  #--------------------------------------------------------------------------#
  # * new-method :obj_exp
  #--------------------------------------------------------------------------#
  def obj_exp(type, obj=nil)
    result = 0
    case type
    when :attack ; result += @exp_p
    when :obj    ; result += obj.exp_p unless obj.nil?
    end
    return result
  end

end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * new-method :maxhp_limit
  #--------------------------------------------------------------------------#
  def maxhp_limit ; return @maxhp_limit end
  #--------------------------------------------------------------------------#
  # * new-method :maxmp_limit
  #--------------------------------------------------------------------------#
  def maxmp_limit ; return @maxmp_limit end

  #--------------------------------------------------------------------------#
  # * new-method :obj_exp
  #--------------------------------------------------------------------------#
  def obj_exp(type, obj=nil)
    result = 0
    case type
    when :attack ; weapons.compact.each { |wep| result += wep.exp_p }
    when :obj    ; result += obj.exp_p unless obj.nil?
    end
    return result
  end

end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------#
  # * alias-method :load_database
  #--------------------------------------------------------------------------#
  alias :ieo009_sct_load_database :load_database unless $@
  def load_database(*args, &block)
    ieo009_sct_load_database(*args, &block)
    IEO::LimitBreak.post_load_database
  end

  #--------------------------------------------------------------------------#
  # * alias-method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :ieo009_sct_load_bt_database :load_database unless $@
  def load_bt_database(*args, &block)
    ieo009_sct_load_bt_database(*args, &block)
    IEO::LimitBreak.post_load_database
  end
end
#==============================================================================#
IEO::REGISTER.log_script(9, "Limit&Break", 1.0) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
