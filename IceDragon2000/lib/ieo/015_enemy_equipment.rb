#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Enemy Equipment
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (Enemy)
# ** Script Type   : Enemy Modifier, Addon
# ** Date Created  : 07/02/2011
# ** Date Modified : 07/09/2011
# ** Script Tag    : IEO-015(EnemyEquipment)
# ** Difficulty    : Easy
# ** Version       : 1.1
# ** IEO ID        : 015
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
# Fastest completed script so far in IEO.
# Enemy Equipment now creates the possibility for your enemies to have weapons
# and armor.
# There are a few smaller things added (like critical modding)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTRUCTIONS
#-*--------------------------------------------------------------------------*-#
# Enemy Notetags
#   <weapon idn: weapon_id>
#   Sets the weapon for the enemy
#   EG
#   <weapon id1: 1>
#   Sets the enemy's primary weapon to weapon 1
#   <weapon id2: 1>
#   Sets the enemy's secondary weapon to weapon 2, only if two_sword_style is true
#   Else, this will use the weapon_id as a armor_id
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Well has only been tested with the DBS.
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
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   RPG::Enemy
#     new-method :ieo015_enemycache
#     new-method :armor_id1
#     new-method :armor_id2
#     new-method :armor_id3
#     new-method :armor_id4
#   Game_Enemy
#     alias      :initialize
#     overwrite  :base_atk
#     overwrite  :base_def
#     overwrite  :base_spi
#     overwrite  :base_agi
#     overwrite  :hit
#     overwrite  :eva
#     overwrite  :cri
#     overwrite  :atk_animation_id
#     overwrite  :atk_animation_id2
#     overwrite  :fast_attack
#     overwrite  :dual_attack
#     overwrite  :prevent_critical
#     overwrite  :half_mp_cost
#     new-method :weapons
#     new-method :armors
#     new-method :equips
#     new-method :two_swords_style
#     new-method :auto_hp_recover
#     new-method :do_auto_recovery
#     new-method :double_exp_gain
#   Game_Troop
#     new-method :do_auto_recovery
#   Scene_Title
#     alias      :load_database
#     alias      :load_bt_database
#     new-method :load_ieo015_cache
#   Scene_Battle
#     alias      :turn_end
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  07/02/2011 - V1.0  Started and Finished Script
#  07/09/2011 - V1.1  Fixed a minor bug.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  May Cause Issues with scripts that edit the base_*stats of enemies
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-EnemyEquipment"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script = {})[[15, "EnemyEquipment"]] = 1.1
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# ** IEO::ENEMY_EQUIPMENT
#==============================================================================#
module IEO
  module ENEMY_EQUIPMENT
    DEFAULT_CRITICAL_RATE = 10
  end
end

#==============================================================================#
# ** IEO::REGEXP::ENEMY_EQUIPMENT
#==============================================================================#
module IEO
  module REGEXP
    module ENEMY_EQUIPMENT
      module ENEMY
        # // Equipment
        WEAPON_IDS       = /<(?:WEAPON_ID|WEAPON ID|WEAPONID)(\d+):[ ](\d+)>/i
        ARMOR_IDS        = /<(?:ARMOR_ID|ARMOR ID|ARMORID)(\d+):[ ](\d+)>/i
        TWO_SWORDS_STYLE = /<(?:TWO_SWORDS_STYLE|TWO SWORDS STYLE|TWOSWORDSSTYLE)>/i
        # // Other
        CRITICAL_RATE    = /<(?:CRITICAL_RATE|CRITICAL RATE|CRITICALRATE):[ ](\d+)([%％])>/i
        CRITICAL_BONUS   = /<(?:CRITICAL_BONUS|CRITICAL BONUS|CRITICALBONUS):[ ](\d+)([%％])>/i
      end
    end
  end
end

#==============================================================================#
# ** RPG::Enemy
#==============================================================================#
class RPG::Enemy

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :weapon_id
  attr_accessor :armor_ids
  attr_accessor :two_swords_style

  attr_accessor :critical_rate
  attr_accessor :critical_bonus
  #--------------------------------------------------------------------------#
  # * new method :ieo015_enemycache
  #--------------------------------------------------------------------------#
  def ieo015_enemycache()
    @weapon_id        = 0
    @armor_ids        = Array.new(4).map! { 0 }
    @two_swords_style = false
    @critical_rate    = IEO::ENEMY_EQUIPMENT::DEFAULT_CRITICAL_RATE
    @critical_bonus   = 0
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when IEO::REGEXP::ENEMY_EQUIPMENT::ENEMY::WEAPON_ID
        wid = $2.to_i
        case $1.to_i
        when 1
          @weapon_id = wid
        when 2
          @armor_ids[0] = wid
        end
      when IEO::REGEXP::ENEMY_EQUIPMENT::ENEMY::ARMOR_IDS
        @armor_ids[$1.to_i-1] = $2.to_i
      when IEO::REGEXP::ENEMY_EQUIPMENT::ENEMY::TWO_SWORDS_STYLE
        @two_swords_style = true

      when IEO::REGEXP::ENEMY_EQUIPMENT::ENEMY::CRITICAL_RATE
        @critical_rate = $1.to_i
      when IEO::REGEXP::ENEMY_EQUIPMENT::ENEMY::CRITICAL_BONUS
        @critical_bonus = $1.to_i
      end
    }
  end

  #--------------------------------------------------------------------------#
  # * new method :armor_id*
  #--------------------------------------------------------------------------#
  def armor_id1 ; return @armor_ids[0] ; end
  def armor_id2 ; return @armor_ids[1] ; end
  def armor_id3 ; return @armor_ids[2] ; end
  def armor_id4 ; return @armor_ids[3] ; end

end

#==============================================================================#
# ** Game_Enemy
#==============================================================================#
class Game_Enemy < Game_Battler

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo015_ge_initialize :initialize unless $@
  def initialize(index, enemy_id)
    ieo015_ge_initialize(index, enemy_id)
    @weapon_id = enemy.weapon_id
    @armor1_id = enemy.armor_id1
    @armor2_id = enemy.armor_id2
    @armor3_id = enemy.armor_id3
    @armor4_id = enemy.armor_id4
  end

  #--------------------------------------------------------------------------#
  # * new method :weapons
  #--------------------------------------------------------------------------#
  def weapons()
    result = []
    result.push($data_weapons[@weapon_id])
    if two_swords_style()
      result.push($data_weapons[@armor1_id])
    end
    return result
  end

  #--------------------------------------------------------------------------#
  # * new method :armors
  #--------------------------------------------------------------------------#
  def armors()
    result = []
    unless two_swords_style()
      result.push($data_armors[@armor1_id])
    end
    result.push($data_armors[@armor2_id])
    result.push($data_armors[@armor3_id])
    result.push($data_armors[@armor4_id])
    return result
  end

  #--------------------------------------------------------------------------#
  # * new method :equips
  #--------------------------------------------------------------------------#
  def equips()
    return weapons() + armors()
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :base_atk
  #--------------------------------------------------------------------------#
  def base_atk()
    n = enemy.atk
    for item in equips.compact do n += item.atk end
    return n
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :base_def
  #--------------------------------------------------------------------------#
  def base_def()
    n = enemy.def
    for item in equips.compact do n += item.def end
    return n
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :base_spi
  #--------------------------------------------------------------------------#
  def base_spi
    n = enemy.spi
    for item in equips.compact do n += item.spi end
    return n
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :base_agi
  #--------------------------------------------------------------------------#
  def base_agi
    n = enemy.agi
    for item in equips.compact do n += item.agi end
    return n
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :base_hit
  #--------------------------------------------------------------------------#
  def hit
    if two_swords_style
      n1 = weapons[0] == nil ? enemy.hit : weapons[0].hit
      n2 = weapons[1] == nil ? enemy.hit : weapons[1].hit
      n = [n1, n2].min
    else
      n = weapons[0] == nil ? enemy.hit : weapons[0].hit
    end
    return n
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :base_eva
  #--------------------------------------------------------------------------#
  def eva
    n = enemy.eva
    for item in armors.compact do n += item.eva end
    return n
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :base_cri
  #--------------------------------------------------------------------------#
  def cri()
    n = enemy.has_critical ? enemy.critical_rate : 0
    n += 4 if enemy.critical_bonus
    for weapon in weapons.compact
      n += 4 if weapon.critical_bonus
    end
    return n
  end

  #--------------------------------------------------------------------------#
  # * new method :two_swords_style
  #--------------------------------------------------------------------------#
  def two_swords_style()
    return enemy.two_swords_style
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :fast_attack
  #--------------------------------------------------------------------------#
  def fast_attack()
    for weapon in weapons.compact
      return true if weapon.fast_attack
    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :dual_attack
  #--------------------------------------------------------------------------#
  def dual_attack
    for weapon in weapons.compact
      return true if weapon.dual_attack
    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :prevent_critical
  #--------------------------------------------------------------------------#
  def prevent_critical()
    for armor in armors.compact
      return true if armor.prevent_critical
    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :half_mp_cost
  #--------------------------------------------------------------------------#
  def half_mp_cost
    for armor in armors.compact
      return true if armor.half_mp_cost
    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * new method :auto_hp_recover
  #--------------------------------------------------------------------------#
  def auto_hp_recover()
    for armor in armors.compact
      return true if armor.auto_hp_recover
    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * new method :do_auto_recovery
  #--------------------------------------------------------------------------#
  def do_auto_recovery()
    if auto_hp_recover() and not dead?
      self.hp += maxhp / 20
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :double_exp_gain
  #--------------------------------------------------------------------------#
  def double_exp_gain()
    for armor in armors.compact
      return true if armor.double_exp_gain
    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :atk_animation_id
  #--------------------------------------------------------------------------#
  def atk_animation_id()
    if two_swords_style()
      return weapons[0].animation_id if weapons[0] != nil
      return weapons[1] == nil ? 1 : 0
    else
      return weapons[0] == nil ? 1 : weapons[0].animation_id
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :atk_animation_id2
  #--------------------------------------------------------------------------#
  def atk_animation_id2()
    if two_swords_style()
      return weapons[1] == nil ? 0 : weapons[1].animation_id
    else
      return 0
    end
  end

end

#==============================================================================#
# ** Game_Troop
#==============================================================================#
class Game_Troop < Game_Unit

  #--------------------------------------------------------------------------#
  # * new method :do_auto_recovery
  #--------------------------------------------------------------------------#
  def do_auto_recovery()
    for mem in members
      mem.do_auto_recovery()
    end
  end

end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias method :load_database
  #--------------------------------------------------------------------------#
  alias :ieo015_sct_load_database :load_database unless $@
  def load_database()
    ieo015_sct_load_database()
    load_ieo015_cache()
  end

  #--------------------------------------------------------------------------#
  # * alias method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :ieo015_sct_load_bt_database :load_database unless $@
  def load_bt_database()
    ieo015_sct_load_bt_database()
    load_ieo015_cache()
  end

  #--------------------------------------------------------------------------#
  # * new method :load_ieo015_cache
  #--------------------------------------------------------------------------#
  def load_ieo015_cache()
    objs = [$data_enemies]
    objs.each { |group| group.each { |obj| next if obj.nil?
      obj.ieo015_enemycache() if obj.is_a?(RPG::Enemy) } }
  end

end

#==============================================================================#
# ** Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias method :turn_end
  #--------------------------------------------------------------------------#
  alias :ieo015_scb_turn_end :turn_end unless $@
  def turn_end()
    ieo015_scb_turn_end()
    #$game_troop.turn_ending = true
    #$game_party.slip_damage_effect()
    #$game_troop.slip_damage_effect()
    #$game_party.do_auto_recovery()
    $game_troop.do_auto_recovery() # // Added
    #$game_troop.preemptive = false
    #$game_troop.surprise = false
    #process_battle_event
    #$game_troop.turn_ending = false
    #start_party_command_selection
  end

end

#==============================================================================#
IEO::REGISTER.log_script(15, "EnemyEquipment", 1.0) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
