#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Custom Slip Damage
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (State, Battler)
# ** Script Type   : State Modifier
# ** Date Created  : 09/04/2011
# ** Date Modified : 09/04/2011
# ** Script Tag    : IEO-016(CustomSlipDamage)
# ** Difficulty    : Medium, Hard, Lunatic
# ** Version       : 1.0
# ** IEO ID        : 016
#-*--------------------------------------------------------------------------*-#

#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-CustomSlipDamage"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script ||= {})[[16, "CustomSlipDamage"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# ** IEO::SLIPDAMAGE
#==============================================================================#
module IEO
  module SLIPDAMAGE

    module_function()

    def stat_from_string(host, str)
      case str.upcase
      when "HP"    ; return host.hp
      when "MAXHP" ; return host.maxhp
      when "MP"    ; return host.mp
      when "MAXMP" ; return host.maxmp
      when "EN"    ; return host.en
      when "MAXEN" ; return host.maxen
      else         ; raise "Unknown stat: #{str}"
      end
    end

    def value_from_effect(host, effect)
      case effect
      when /(\w+)[ ]([\+\-]\d+)([%％])/i
        v = stat_from_string(host, $1) * $2.to_f / 100.0
      when /(\w+)[ ](\d+)([%％])/i
        v = stat_from_string(host, $1) * $2.to_f / 100.0
      when /([\+\-]\d+)/i
        v = $1.to_i
      else
        v = effect.to_i
      end
      return Integer(v)
    end

  end
end

#==============================================================================#
# ** Game_Battler * Lunatic
#==============================================================================#
class Game_Battler

  #--------------------------------------------------------------------------#
  # * new-method :slip_effect
  #--------------------------------------------------------------------------#
  def slip_effect(slip)
    # // slip == [type, effect, variance_effect]
    value = IEO::SLIPDAMAGE.value_from_effect(self, slip[1])
    varia = IEO::SLIPDAMAGE.value_from_effect(self, slip[2]).abs
    dm = apply_variance(value, varia)
    # // Damage Reset
    @hp_damage, @mp_damage, @en_damage, @ammo_damage = 0, 0, 0, 0
    case slip[0].upcase # // Type
    when "HP"
      @hp_damage = dm
      @hp_damage = self.hp - 1 if @hp_damage >= self.hp
    when "MP"
      @mp_damage = dm
    when "EN"
      @en_damage = dm
    when "AMMO"
      @ammo_damage = dm
    end
    self.hp -= @hp_damage
    self.mp -= @mp_damage
    self.en -= @en_damage
    self.change_ammo(:sub, -1, @ammo_damage)
    on_slip_damage()
  end

  #--------------------------------------------------------------------------#
  # * new-method :on_slip_damage
  #--------------------------------------------------------------------------#
  def on_slip_damage()
  end

end

#==============================================================================#
# ** IEO::REGEXP::SLIPDAMAGE::STATE
#==============================================================================#
module IEO
  module REGEXP
    module SLIPDAMAGE
      module STATE
        slips = "(?:SLIPDAMAGE|SLIP_DAMAGE|SLIP DAMAGE|SLIP)"
        SLIP_DAMAGE = /<#{slips}:[ ]*(.*),[ ]*(.*),[ ]*(.*)>/i
      end
    end
  end
end

#==============================================================================#
# ** RPG::State
#==============================================================================#
class RPG::State

  #--------------------------------------------------------------------------#
  # * new-method :ieo016_statecache
  #--------------------------------------------------------------------------#
  def ieo016_statecache()
    @slip_damages = []
    @slip_damages << ["hp", "maxhp 10%", "10"] if @slip_damage
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when IEO::REGEXP::SLIPDAMAGE::STATE::SLIP_DAMAGE
        @slip_damages << [$1,$2,$3]
        @slip_damage = true
      end
    }
    @slip_damages.compact!()
  end

  #--------------------------------------------------------------------------#
  # * new-method :slip_damage_data
  #--------------------------------------------------------------------------#
  def slip_damage_data()
    return @slip_damages
  end

end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler

  #--------------------------------------------------------------------------#
  # * new-method :slip_states
  #--------------------------------------------------------------------------#
  def slip_states()
    return states.inject([]) { |r, s| r << s if s.slip_damage; r }
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :slip_damage_effect
  #--------------------------------------------------------------------------#
  def slip_damage_effect()
    slip_states.each { |s| s.slip_damage_data.each { |slip| slip_effect(slip) } }
  end

end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias method :load_database
  #--------------------------------------------------------------------------#
  alias :ieo016_sct_load_database :load_database unless $@
  def load_database()
    ieo016_sct_load_database()
    load_ieo016_cache()
  end

  #--------------------------------------------------------------------------#
  # * alias method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :ieo016_sct_load_bt_database :load_database unless $@
  def load_bt_database()
    ieo016_sct_load_bt_database()
    load_ieo016_cache()
  end

  #--------------------------------------------------------------------------#
  # * new method :load_ieo016_cache
  #--------------------------------------------------------------------------#
  def load_ieo016_cache()
    objs = [$data_states]
    objs.each { |group| group.each { |obj| next if obj.nil?()
      obj.ieo016_statecache() if obj.is_a?(RPG::State) } }
  end

end

#==============================================================================#
IEO::REGISTER.log_script(16, "CustomSlipDamage", 1.0) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
