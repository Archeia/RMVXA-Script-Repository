# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Reader Functions for Features/Effects                 │ v1.4 │ (4/14/13) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# This is a scripter's tool. This means programming knowledge and Ruby 
# knowledge are required to understand and utilize this script. This script 
# does nothing by itself.
#
# If you are a regular user using this script for another existing script,
# you don't need to do anything with this script. Just install it in your
# script editor and leave it alone.
#
# All RPG::BaseItem objects have an array of RPG::BaseItem::Feature objects 
# that contain all Feature properties defined by the developer in the 
# database. Unfortunately, the way Feature objects is coded makes it not 
# immediately understandable by humans. It requires checking the methods in 
# Game_BattlerBase and Game_Battler to decipher what the values in a Feature 
# mean. This makes trying to display a specific object's features difficult 
# to accomplish.
#
# This script is essentially a collection of wrapper functions based off the 
# methods defined in Game_BattlerBase and Game_Battler. This was mostly a 
# copy and paste job and most of the return values are similar to the ones 
# from those original classes.
#
# For example, if you have a $data_items object, you can do
#   
#   $data_items[id].hp_recovery
#
# to directly get that item's total HP recovery value. There are many 
# other usable methods.
#
# RPG::UsableItem objects do not have Features, but have a similar inner 
# class called RPG::UsableItem::Effect which have their own reader 
# functions.
#
# This script was made for my own use, but other scripters can use it
# if they want.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.4 : Bugfix: Added the Game_Party constants. Oops. (4/14/2013)
# v1.3 : Bugfix: "add_debuffs" and "remove_debuffs" now return
#      : the correct value instead of an array. (4/06/2013)
# v1.2 : "tp_gain" has changed to "tp_recovery". (9/04/2012)
# v1.1 : Bugfix: Arrays no longer return an array of arrays. (8/23/2012)
# v1.0 : Initial release. (8/20/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Methods ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following methods are for any RPG::BaseItem object:
#
# param(param_id)
#   param_id is a value between 0~7. Not to be confused with the standard 
#   param methods, this method returns the rate modifier for the given 
#   parameter. Param rates start at 1.0 by default.
#
# xparam(xparam_id)
#   xparam_id is a value between 0~9. Ex-Parameters start at 0.0 by default.
#
# sparam(sparam_id)
#   sparam_id is a value between 0~9. Sp-Parameters start at 1.0 by default.
#
# mhp               # MHP  Maximum Hit Points
# mmp               # MMP  Maximum Magic Points
# atk               # ATK  ATtacK power
# def               # DEF  DEFense power
# mat               # MAT  Magic ATtack power
# mdf               # MDF  Magic DeFense power
# agi               # AGI  AGIlity
# luk               # LUK  LUcK
#   In general, anything that is not an RPG::EquipItem object will return 0.
#
# hit               # HIT  HIT rate
# eva               # EVA  EVAsion rate
# cri               # CRI  CRItical rate
# cev               # CEV  Critical EVasion rate
# mev               # MEV  Magic EVasion rate
# mrf               # MRF  Magic ReFlection rate
# cnt               # CNT  CouNTer attack rate
# hrg               # HRG  Hp ReGeneration rate
# mrg               # MRG  Mp ReGeneration rate
# trg               # TRG  Tp ReGeneration rate
#   Ex-Parameters start at 0.0 by default.
#
# tgr               # TGR  TarGet Rate
# grd               # GRD  GuaRD effect rate
# rec               # REC  RECovery effect rate
# pha               # PHA  PHArmacology
# mcr               # MCR  Mp Cost Rate
# tcr               # TCR  Tp Charge Rate
# pdr               # PDR  Physical Damage Rate
# mdr               # MDR  Magical Damage Rate
# fdr               # FDR  Floor Damage Rate
# exr               # EXR  EXperience Rate
#   Sp-Paramters start at 1.0 by default.
#
# mhp_rate          # MHP  Maximum Hit Points rate
# mmp_rate          # MMP  Maximum Magic Points rate
# atk_rate          # ATK  ATtacK power rate
# def_rate          # DEF  DEFense power rate
# mat_rate          # MAT  Magic ATtack power rate
# mdf_rate          # MDF  Magic DeFense power rate
# agi_rate          # AGI  AGIlity rate
# luk_rate          # LUK  LUcK rate
#   Not to be confused with the standard param methods, these methods 
#   return the rate modifier for the given parameter. Param rates start 
#   at 1.0 by default.
#
# dual_wield?
# auto_battle?
# guard?
# substitute?
# preserve_tp?
# encounter_half?
# encounter_none?
# cancel_surprise?
# raise_preemptive?
# gold_double?
# drop_item_double?
#   Returns true if that specified Feature flag is found. Otherwise, false.
#
# get_feature_flags
#   Returns an array of keys that each represent a Feature flag. If the 
#   key is included in the array, it means the flag is true. Possible keys
#   are:
#       :dual_wield
#       :auto_battle
#       :guard 
#       :substitute
#       :preserve_tp
#       :encounter_half
#       :encounter_none
#       :cancel_surprise
#       :raise_preemptive
#       :gold_double
#       :drop_item_double
#
# element_rate(element_id)
#   Returns the element modifier rate for a given element_id. A value 
#   of 1.0 means no change.
#
# debuff_rate(param_id)
#   Returns the debuff modifier rate for a given param_id. A value of 
#   1.0 means no change.
#
# state_rate(state_id)
#   Returns the state modifier rate for a given state_id. A value of 1.0
#   means no change.
#
# state_resist_set
#   Returns an array of resist state ID numbers.
#
# atk_elements
#   Returns an array of attack element ID numbers.
#
# atk_states
#   Returns an array of attack state ID numbers.
#
# atk_states_rate(state_id)
#   Returns the total attack state rate for a given state_id.
#
# atk_speed
#   Returns the attack speed value.
#
# atk_times_add
#   Returns the number of consecutive attacks granted.
#
# added_skill_types
#   Returns an array of added skill type ID numbers.
#
# sealed_skill_types
#   Returns an array of sealed skill type ID numbers.
#
# added_skills
#   Returns an array of added skill ID numbers.
#
# sealed_skills
#   Returns an array of sealed skill ID numbers.
#
# equip_wtypes
#   Returns an array of granted equip weapon types ID numbers
#
# equip_atypes
#   Returns an array of granted equip armor types ID numbers
#
# fixed_equips
#   Returns an array of fixed equipment index numbers. Each index 
#   corresponds to an existing equip slot. 
#   (0:Weapon, 1:Shield, 2:Helmet, 3:Armor, 4:Accessory)
#
# sealed_equips
#   Returns an array of sealed equipment index numbers. Each index 
#   corresponds to an existing equip slot. 
#   (0:Weapon, 1:Shield, 2:Helmet, 3:Armor, 4:Accessory)
#
# action_plus_set
#   Returns an array of Action Times+ chances.
#
#--------------------------------------------------------------------------
# The following methods are for any RPG::UsableItem object:
#
# hp_recovery
#   Returns a flat HP recovery value.
#
# hp_recovery_rate
#   Returns the rate of HP recovery.
#
# mp_recovery
#   Returns a flat MP recovery value.
#
# mp_recovery_rate
#   Returns the rate of MP recovery.
#
# tp_recovery
#   Returns a flat TP recovery value.
#
# add_states
#   Returns an array of state IDs that are added to the target.
#
# remove_states
#   Returns an array of state IDs that are removed from the target.
#
# add_states_with_rates
#   Returns a multi-dimensional array where [index][0] is a state_id 
#   number and [index][1] is the success rate.
#   [[state_id, rate],[state_id, rate],[state_id, rate], ...]
#   state_id 0 represents 'Normal Attack'.
#
# remove_states_with_rates
#   Returns a multi-dimensional array where [index][0] is a state_id 
#   number and [index][1] is the remove rate.
#   [[state_id, rate],[state_id, rate],[state_id, rate], ...]
#
# add_buffs
#   Returns an array buffs represented by param_id numbers.
#
# add_debuffs
#   Returns an array debuffs represented by param_id numbers.
#
# add_buffs_with_turns
#   Returns a multi-dimensional array where [index][0] is a param_id 
#   number and [index][1] is the buff turn duration.
#   [[param_id, turn],[param_id, turn],[param_id, turn], ...]
#
# add_debuffs_with_turns
#   Returns a multi-dimensional array where [index][0] is a param_id 
#   number and [index][1] is the debuff turn duration.
#   [[param_id, turn],[param_id, turn],[param_id, turn], ...]
#
# remove_buffs
#   Returns an array of removed buffs represented by param_id numbers.
#
# remove_debuffs
#   Returns an array of removed debuffs represented by param_id numbers.
#
# escape?
#   Returns true or false if the skill/item provides escape from battle.
#
# grow(param_id)
#   Returns the total amount of param growth for the given param_id.
#
# learn_skills
#   Returns an array of skill IDs that the skill/item teaches.
#
# common_event
#   Returns a common event ID number. Otherwise, it returns nil.
#
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# There are no default method overwrites.
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#   ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#==============================================================================
$imported ||= {}
$imported["BubsFeaturesReader"] = true
#==========================================================================
# ++ This script contains no customization module ++
#==========================================================================

#==============================================================================
# ++ RPG::EquipItem
#==============================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # * Constants (Features)
  #--------------------------------------------------------------------------
  FEATURE_ELEMENT_RATE  = 11              # Element Rate
  FEATURE_DEBUFF_RATE   = 12              # Debuff Rate
  FEATURE_STATE_RATE    = 13              # State Rate
  FEATURE_STATE_RESIST  = 14              # State Resist
  FEATURE_PARAM         = 21              # Parameter
  FEATURE_XPARAM        = 22              # Ex-Parameter
  FEATURE_SPARAM        = 23              # Sp-Parameter
  FEATURE_ATK_ELEMENT   = 31              # Atk Element
  FEATURE_ATK_STATE     = 32              # Atk State
  FEATURE_ATK_SPEED     = 33              # Atk Speed
  FEATURE_ATK_TIMES     = 34              # Atk Times+
  FEATURE_STYPE_ADD     = 41              # Add Skill Type
  FEATURE_STYPE_SEAL    = 42              # Disable Skill Type
  FEATURE_SKILL_ADD     = 43              # Add Skill
  FEATURE_SKILL_SEAL    = 44              # Disable Skill
  FEATURE_EQUIP_WTYPE   = 51              # Equip Weapon
  FEATURE_EQUIP_ATYPE   = 52              # Equip Armor
  FEATURE_EQUIP_FIX     = 53              # Lock Equip
  FEATURE_EQUIP_SEAL    = 54              # Seal Equip
  FEATURE_SLOT_TYPE     = 55              # Slot Type
  FEATURE_ACTION_PLUS   = 61              # Action Times+
  FEATURE_SPECIAL_FLAG  = 62              # Special Flag
  FEATURE_COLLAPSE_TYPE = 63              # Collapse Effect
  FEATURE_PARTY_ABILITY = 64              # Party Ability
  #--------------------------------------------------------------------------
  # * Constants (Feature Flags)
  #--------------------------------------------------------------------------
  FLAG_ID_AUTO_BATTLE   = 0               # auto battle
  FLAG_ID_GUARD         = 1               # guard
  FLAG_ID_SUBSTITUTE    = 2               # substitute
  FLAG_ID_PRESERVE_TP   = 3               # preserve TP
  #--------------------------------------------------------------------------
  # * Constants (Game_Party)
  #--------------------------------------------------------------------------
  ABILITY_ENCOUNTER_HALF    = 0           # halve encounters
  ABILITY_ENCOUNTER_NONE    = 1           # disable encounters
  ABILITY_CANCEL_SURPRISE   = 2           # disable surprise
  ABILITY_RAISE_PREEMPTIVE  = 3           # increase preemptive strike rate
  ABILITY_GOLD_DOUBLE       = 4           # double money earned
  ABILITY_DROP_ITEM_DOUBLE  = 5           # double item acquisition rate
  #--------------------------------------------------------------------------
  # * Access Method by Parameter Abbreviations
  #--------------------------------------------------------------------------
  def mhp;  param(0);   end               # MHP  Maximum Hit Points
  def mmp;  param(1);   end               # MMP  Maximum Magic Points
  def atk;  param(2);   end               # ATK  ATtacK power
  def def;  param(3);   end               # DEF  DEFense power
  def mat;  param(4);   end               # MAT  Magic ATtack power
  def mdf;  param(5);   end               # MDF  Magic DeFense power
  def agi;  param(6);   end               # AGI  AGIlity
  def luk;  param(7);   end               # LUK  LUcK
  def hit;  xparam(0);  end               # HIT  HIT rate
  def eva;  xparam(1);  end               # EVA  EVAsion rate
  def cri;  xparam(2);  end               # CRI  CRItical rate
  def cev;  xparam(3);  end               # CEV  Critical EVasion rate
  def mev;  xparam(4);  end               # MEV  Magic EVasion rate
  def mrf;  xparam(5);  end               # MRF  Magic ReFlection rate
  def cnt;  xparam(6);  end               # CNT  CouNTer attack rate
  def hrg;  xparam(7);  end               # HRG  Hp ReGeneration rate
  def mrg;  xparam(8);  end               # MRG  Mp ReGeneration rate
  def trg;  xparam(9);  end               # TRG  Tp ReGeneration rate
  def tgr;  sparam(0);  end               # TGR  TarGet Rate
  def grd;  sparam(1);  end               # GRD  GuaRD effect rate
  def rec;  sparam(2);  end               # REC  RECovery effect rate
  def pha;  sparam(3);  end               # PHA  PHArmacology
  def mcr;  sparam(4);  end               # MCR  Mp Cost Rate
  def tcr;  sparam(5);  end               # TCR  Tp Charge Rate
  def pdr;  sparam(6);  end               # PDR  Physical Damage Rate
  def mdr;  sparam(7);  end               # MDR  Magical Damage Rate
  def fdr;  sparam(8);  end               # FDR  Floor Damage Rate
  def exr;  sparam(9);  end               # EXR  EXperience Rate
  #--------------------------------------------------------------------------
  # * Access Method by Parameter Abbreviations (Rates)
  #--------------------------------------------------------------------------
  def mhp_rate;  param_rate(0);   end     # MHP  Maximum Hit Points rate
  def mmp_rate;  param_rate(1);   end     # MMP  Maximum Magic Points rate
  def atk_rate;  param_rate(2);   end     # ATK  ATtacK power rate
  def def_rate;  param_rate(3);   end     # DEF  DEFense power rate
  def mat_rate;  param_rate(4);   end     # MAT  Magic ATtack power rate
  def mdf_rate;  param_rate(5);   end     # MDF  Magic DeFense power rate
  def agi_rate;  param_rate(6);   end     # AGI  AGIlity rate
  def luk_rate;  param_rate(7);   end     # LUK  LUcK rate
  #--------------------------------------------------------------------------
  # * Get Feature Object Array (Feature Codes Limited)
  #--------------------------------------------------------------------------
  # features_with_id, features_sum_all, action_plus_set, special_flag, 
  # party_ability
  def get_features(code)
    features.select {|ft| ft.code == code }
  end
  #--------------------------------------------------------------------------
  # * Get Feature Object Array (Feature Codes and Data IDs Limited)
  #--------------------------------------------------------------------------
  # features_pi, features_sum, features_set
  def features_with_id(code, id)
    get_features(code).select {|ft| ft.code == code && ft.data_id == id }
  end
  #--------------------------------------------------------------------------
  # * Calculate Complement of Feature Values
  #--------------------------------------------------------------------------
  # sparam, element_rate, debuff_rate, state_rate
  def features_pi(code, id)
    features_with_id(code, id).inject(1.0) {|r, ft| r *= ft.value }
  end
  #--------------------------------------------------------------------------
  # * Calculate Sum of Feature Values (Specify Data ID)
  #--------------------------------------------------------------------------
  # xparam, atk_states_rate
  def features_sum(code, id)
    features_with_id(code, id).inject(0.0) {|r, ft| r += ft.value }
  end
  #--------------------------------------------------------------------------
  # * Calculate Sum of Feature Values (Data ID Unspecified)
  #--------------------------------------------------------------------------
  # atk_speed, atk_times_add
  def features_sum_all(code)
    get_features(code).inject(0.0) {|r, ft| r += ft.value }
  end
  #--------------------------------------------------------------------------
  # * Calculate Set Sum of Features
  #--------------------------------------------------------------------------
  # state_resists, atk_elements, atk_states, added_skill_types, 
  # skill_type_sealed?, sealed_skill_types, added_skills, skill_sealed?, 
  # sealed_skills, equip_wtype_ok?, equip_wtypes, equip_atype_ok?, 
  # equip_atypes, equip_type_fixed?, fixed_equips, equip_type_sealed?, 
  # sealed_equips, slot_type, collapse_type
  def features_set(code)
    get_features(code).inject([]) {|r, ft| r |= [ft.data_id]}
  end
  #--------------------------------------------------------------------------
  # * Get Rate of Parameter Change
  #--------------------------------------------------------------------------
  def param_rate(param_id)
    features_pi(FEATURE_PARAM, param_id)
  end
  #--------------------------------------------------------------------------
  # * Get Ex-Parameter
  #--------------------------------------------------------------------------
  def xparam(xparam_id)
    features_sum(FEATURE_XPARAM, xparam_id)
  end
  #--------------------------------------------------------------------------
  # * Get Sp-Parameter
  #--------------------------------------------------------------------------
  def sparam(sparam_id)
    features_pi(FEATURE_SPARAM, sparam_id)
  end
  #--------------------------------------------------------------------------
  # * Get Element Rate
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    features_pi(FEATURE_ELEMENT_RATE, element_id)
  end
  #--------------------------------------------------------------------------
  # * Get Debuff Rate
  #--------------------------------------------------------------------------
  def debuff_rate(param_id)
    features_pi(FEATURE_DEBUFF_RATE, param_id)
  end
  #--------------------------------------------------------------------------
  # * Get State Rate
  #--------------------------------------------------------------------------
  def state_rate(state_id)
    features_pi(FEATURE_STATE_RATE, state_id)
  end
  #--------------------------------------------------------------------------
  # * Get Array of States to Resist
  #--------------------------------------------------------------------------
  def state_resist_set
    features_set(FEATURE_STATE_RESIST)
  end
  #--------------------------------------------------------------------------
  # * Determine if State Is Resisted
  #--------------------------------------------------------------------------
  def state_resist?(state_id)
    state_resist_set.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # * Get Attack Element
  #--------------------------------------------------------------------------
  def atk_elements
    features_set(FEATURE_ATK_ELEMENT)
  end
  #--------------------------------------------------------------------------
  # * Get Attack State
  #--------------------------------------------------------------------------
  def atk_states
    features_set(FEATURE_ATK_STATE)
  end
  #--------------------------------------------------------------------------
  # * Get Attack State Invocation Rate
  #--------------------------------------------------------------------------
  def atk_states_rate(state_id)
    features_sum(FEATURE_ATK_STATE, state_id)
  end
  #--------------------------------------------------------------------------
  # * Get Attack Speed
  #--------------------------------------------------------------------------
  def atk_speed
    features_sum_all(FEATURE_ATK_SPEED)
  end
  #--------------------------------------------------------------------------
  # * Get Additional Attack Times
  #--------------------------------------------------------------------------
  def atk_times_add
    [features_sum_all(FEATURE_ATK_TIMES), 0].max
  end
  #--------------------------------------------------------------------------
  # * Get Added Skill Types
  #--------------------------------------------------------------------------
  def added_skill_types
    features_set(FEATURE_STYPE_ADD)
  end
  #--------------------------------------------------------------------------
  # * Determine if Skill Type Is Disabled
  #--------------------------------------------------------------------------
  def skill_type_sealed?(stype_id)
    features_set(FEATURE_STYPE_SEAL).include?(stype_id)
  end
  #--------------------------------------------------------------------------
  # * Get Disabled Skill Type ID Array
  #--------------------------------------------------------------------------
  def sealed_skill_types
    features_set(FEATURE_STYPE_SEAL)
  end
  #--------------------------------------------------------------------------
  # * Get Added Skills ID Array
  #--------------------------------------------------------------------------
  def added_skills
    features_set(FEATURE_SKILL_ADD)
  end
  #--------------------------------------------------------------------------
  # * Determine if Skill Is Disabled
  #--------------------------------------------------------------------------
  def skill_sealed?(skill_id)
    features_set(FEATURE_SKILL_SEAL).include?(skill_id)
  end
  #--------------------------------------------------------------------------
  # * Get Sealed Skills ID Array
  #--------------------------------------------------------------------------
  def sealed_skills
    features_set(FEATURE_SKILL_SEAL)
  end
  #--------------------------------------------------------------------------
  # * Determine if Weapon Can Be Equipped
  #--------------------------------------------------------------------------
  def equip_wtype_ok?(wtype_id)
    features_set(FEATURE_EQUIP_WTYPE).include?(wtype_id)
  end
  #--------------------------------------------------------------------------
  # * Get Equip Weapon Types ID Array
  #--------------------------------------------------------------------------
  def equip_wtypes
    features_set(FEATURE_EQUIP_WTYPE)
  end
  #--------------------------------------------------------------------------
  # * Determine if Armor Can Be Equipped
  #--------------------------------------------------------------------------
  def equip_atype_ok?(atype_id)
    features_set(FEATURE_EQUIP_ATYPE).include?(atype_id)
  end
  #--------------------------------------------------------------------------
  # * Get Equip Armor Types ID Array
  #--------------------------------------------------------------------------
  def equip_atypes
    features_set(FEATURE_EQUIP_ATYPE)
  end
  #--------------------------------------------------------------------------
  # * Determine if Equipment Is Locked
  #--------------------------------------------------------------------------
  def equip_type_fixed?(etype_id)
    features_set(FEATURE_EQUIP_FIX).include?(etype_id)
  end
  #--------------------------------------------------------------------------
  # * Get Fixed Equips Index Array
  #--------------------------------------------------------------------------
  def fixed_equips
    features_set(FEATURE_EQUIP_FIX)
  end
  #--------------------------------------------------------------------------
  # * Determine if Equipment Is Sealed
  #--------------------------------------------------------------------------
  def equip_type_sealed?(etype_id)
    features_set(FEATURE_EQUIP_SEAL).include?(etype_id)
  end
  #--------------------------------------------------------------------------
  # * Get Sealed Equips Index Array
  #--------------------------------------------------------------------------
  def sealed_equips
    features_set(FEATURE_EQUIP_SEAL)
  end
  #--------------------------------------------------------------------------
  # * Get Slot Type
  #--------------------------------------------------------------------------
  def slot_type
    features_set(FEATURE_SLOT_TYPE).max || 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Dual Wield
  #--------------------------------------------------------------------------
  def dual_wield?
    slot_type == 1
  end
  #--------------------------------------------------------------------------
  # * Get Array of Additional Action Time Probabilities
  #--------------------------------------------------------------------------
  def action_plus_set
    get_features(FEATURE_ACTION_PLUS).collect {|ft| ft.value }
  end
  alias action_times_plus action_plus_set
  #--------------------------------------------------------------------------
  # * Determine if Special Flag
  #--------------------------------------------------------------------------
  def special_flag(flag_id)
    get_features(FEATURE_SPECIAL_FLAG).any? {|ft| ft.data_id == flag_id }
  end
  #--------------------------------------------------------------------------
  # * Get Collapse Effect
  #--------------------------------------------------------------------------
  def collapse_type
    features_set(FEATURE_COLLAPSE_TYPE).max || 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Auto Battle
  #--------------------------------------------------------------------------
  def auto_battle?
    special_flag(FLAG_ID_AUTO_BATTLE)
  end
  #--------------------------------------------------------------------------
  # * Determine if Guard
  #--------------------------------------------------------------------------
  def guard?
    special_flag(FLAG_ID_GUARD)
  end
  #--------------------------------------------------------------------------
  # * Determine if Substitute
  #--------------------------------------------------------------------------
  def substitute?
    special_flag(FLAG_ID_SUBSTITUTE)
  end
  #--------------------------------------------------------------------------
  # * Determine if Preserve TP
  #--------------------------------------------------------------------------
  def preserve_tp?
    special_flag(FLAG_ID_PRESERVE_TP)
  end
  #--------------------------------------------------------------------------
  # * Determine Party Ability
  #--------------------------------------------------------------------------
  def party_ability(ability_id)
    get_features(FEATURE_PARTY_ABILITY).any? {|ft| ft.data_id == ability_id}
  end
  #--------------------------------------------------------------------------
  # * Halve Encounters?
  #--------------------------------------------------------------------------
  def encounter_half?
    party_ability(ABILITY_ENCOUNTER_HALF)
  end
  #--------------------------------------------------------------------------
  # * Disable Encounters?
  #--------------------------------------------------------------------------
  def encounter_none?
    party_ability(ABILITY_ENCOUNTER_NONE)
  end
  #--------------------------------------------------------------------------
  # * Disable Surprise?
  #--------------------------------------------------------------------------
  def cancel_surprise?
    party_ability(ABILITY_CANCEL_SURPRISE)
  end
  #--------------------------------------------------------------------------
  # * Increase Preemptive Strike Rate?
  #--------------------------------------------------------------------------
  def raise_preemptive?
    party_ability(ABILITY_RAISE_PREEMPTIVE)
  end
  #--------------------------------------------------------------------------
  # * Double Money Earned?
  #--------------------------------------------------------------------------
  def gold_double?
    party_ability(ABILITY_GOLD_DOUBLE)
  end
  #--------------------------------------------------------------------------
  # * Double Item Acquisition Rate?
  #--------------------------------------------------------------------------
  def drop_item_double?
    party_ability(ABILITY_DROP_ITEM_DOUBLE)
  end
  #--------------------------------------------------------------------------
  # * Get Feature Flag Keys
  #--------------------------------------------------------------------------
  def get_feature_flags
    array = []
    array.push(:dual_wield)       if dual_wield?
    array.push(:auto_battle)      if auto_battle?
    array.push(:guard)            if guard?
    array.push(:substitute)       if substitute?
    array.push(:preserve_tp)      if preserve_tp?
    array.push(:encounter_half)   if encounter_half?
    array.push(:encounter_none)   if encounter_none?
    array.push(:cancel_surprise)  if cancel_surprise?
    array.push(:raise_preemptive) if raise_preemptive?
    array.push(:gold_double)      if gold_double?
    array.push(:drop_item_double) if drop_item_double?
    return array
  end
  
  #--------------------------------------------------------------------------
  # * Get Feature By Key
  #--------------------------------------------------------------------------
  def feature_by_key(key)
    case key
    when :mhp
      mhp
    when :mmp
      mmp
    when :atk
      atk
    when :def
      self.def
    when :mat 
      mat
    when :mdf
      mdf
    when :agi
      agi
    when :luk
      luk
    when :mhp
      mhp
    when :mmp
      mmp
    when :atk
      atk
    when :def
      self.def
    when :mat 
      mat
    when :mdf 
      mdf
    when :agi 
      agi
    when :luk 
      luk
    when :mhp_rate 
      mhp_rate
    when :mmp_rate 
      mmp_rate
    when :atk_rate 
      atk_rate
    when :def_rate 
      def_rate
    when :mat_rate 
      mat_rate
    when :mdf_rate 
      mdf_rate
    when :agi_rate 
      agi_rate
    when :luk_rate 
      luk_rate
    when :hit 
      hit
    when :eva 
      eva
    when :cri 
      cri
    when :cev 
      cev
    when :mev 
      mev
    when :mrf 
      mrf
    when :cnt
      cnt
    when :hrg
      hrg
    when :mrg 
      mrg
    when :trg 
      trg
    when :tgr 
      tgr
    when :grd 
      grd
    when :rec 
      rec
    when :pha
      pha
    when :mcr 
      mcr
    when :tcr 
      tcr
    when :pdr 
      pdr
    when :mdr 
      mdr
    when :fdr 
      fdr
    when :exr 
      exr
    when :element_rate 
      element_rate
    when :debuff_rate 
      debuff_rate
    when :state_rate 
      state_rate
    when :state_resist_set
      state_resist_set
    when :atk_elements
      atk_elements
    when :atk_states 
      atk_states
    when :atk_speed 
      atk_speed
    when :atk_times_add 
      atk_times_add
    when :added_skill_types 
      added_skill_types
    when :added_skills 
      added_skills
    when :sealed_skill_types 
      sealed_skill_types
    when :sealed_skills 
      sealed_skills
    when :equip_wtypes 
      equip_wtypes
    when :equip_atypes 
      equip_atypes
    when :fixed_equips 
      fixed_equips
    when :sealed_equips 
      sealed_equips
    when :dual_wield 
      dual_wield?
    when :action_times_plus 
      action_times_plus
      
    when :auto_battle 
      auto_battle?
    when :guard 
      guard?
    when :substitute 
      substitute?
    when :preserve_tp 
      preserve_tp?
    when :collapse_effect 
      collapse_effect
    when :encounter_half 
      encounter_half?
    when :encounter_none 
      encounter_none?
    when :cancel_surprise 
      cancel_surprise?
    when :raise_preemptive 
      raise_preemptive?
    when :gold_double 
      gold_double?
    when :drop_item_double 
      drop_item_double?
    end
  end
end # class RPG::BaseItem

#==============================================================================
# ++ RPG::UsableItem
#==============================================================================
class RPG::UsableItem
  #--------------------------------------------------------------------------
  # * Constants (Effects)
  #--------------------------------------------------------------------------
  EFFECT_RECOVER_HP     = 11              # HP Recovery
  EFFECT_RECOVER_MP     = 12              # MP Recovery
  EFFECT_GAIN_TP        = 13              # TP Gain
  EFFECT_ADD_STATE      = 21              # Add State
  EFFECT_REMOVE_STATE   = 22              # Remove State
  EFFECT_ADD_BUFF       = 31              # Add Buff
  EFFECT_ADD_DEBUFF     = 32              # Add Debuff
  EFFECT_REMOVE_BUFF    = 33              # Remove Buff
  EFFECT_REMOVE_DEBUFF  = 34              # Remove Debuff
  EFFECT_SPECIAL        = 41              # Special Effect
  EFFECT_GROW           = 42              # Raise Parameter
  EFFECT_LEARN_SKILL    = 43              # Learn Skill
  EFFECT_COMMON_EVENT   = 44              # Common Events
  #--------------------------------------------------------------------------
  # * Constants (Special Effects)
  #--------------------------------------------------------------------------
  SPECIAL_EFFECT_ESCAPE = 0               # Escape
  #--------------------------------------------------------------------------
  # * Get Effect Object Array (Effect Codes Limited)
  #--------------------------------------------------------------------------
  def get_effects(code)
    effects.select {|ef| ef.code == code }
  end
  #--------------------------------------------------------------------------
  # * Get Effect Object Array (Effect Codes and Data IDs Limited)
  #--------------------------------------------------------------------------
  def effects_with_id(code, id)
    get_effects(code).select {|ef| ef.code == code && ef.data_id == id }
  end
  #--------------------------------------------------------------------------
  # * Calculate Complement of Effect Value1
  #--------------------------------------------------------------------------
  def effects_pi_value1(code, id)
    effects_with_id(code, id).inject(1.0) {|r, ef| r *= ef.value1 }
  end
  #--------------------------------------------------------------------------
  # * Calculate Sum of Effect Value 1 (Specify Data ID)
  #--------------------------------------------------------------------------
  def effects_sum_value1(code, id)
    effects_with_id(code, id).inject(0.0) {|r, ef| r += ef.value1 }
  end
  #--------------------------------------------------------------------------
  # * Calculate Sum of Effect Value 2 (Specify Data ID)
  #--------------------------------------------------------------------------
  def effects_sum_value2(code, id)
    effects_with_id(code, id).inject(0.0) {|r, ef| r += ef.value2 }
  end
  #--------------------------------------------------------------------------
  # * Calculate Sum of Effect Value 1 (Data ID Unspecified)
  #--------------------------------------------------------------------------
  def effects_sum_all_value1(code)
    get_effects(code).inject(0.0) {|r, ef| r += ef.value1 }
  end
  #--------------------------------------------------------------------------
  # * Calculate Sum of Effect Value 2 (Data ID Unspecified)
  #--------------------------------------------------------------------------
  def effects_sum_all_value2(code)
    get_effects(code).inject(0.0) {|r, ef| r += ef.value2 }
  end
  #--------------------------------------------------------------------------
  # * Calculate Set Sum of Effects
  #--------------------------------------------------------------------------
  def effects_set(code)
    get_effects(code).inject([]) {|r, ef| r.push(ef.data_id) }
  end
  #--------------------------------------------------------------------------
  # * Get Effect ID with Value1
  #--------------------------------------------------------------------------
  def effects_set_with_value1(code)
    get_effects(code).inject([]) {|r, ef| r.push([ef.data_id, ef.value1]) }
  end
  #--------------------------------------------------------------------------
  # * Get HP Recovery Value
  #--------------------------------------------------------------------------
  def hp_recovery
    effects_sum_all_value2(EFFECT_RECOVER_HP)
  end
  #--------------------------------------------------------------------------
  # * Get HP Recovery Rate
  #--------------------------------------------------------------------------
  def hp_recovery_rate
    effects_sum_all_value1(EFFECT_RECOVER_HP)
  end
  #--------------------------------------------------------------------------
  # * Get MP Recovery Value
  #--------------------------------------------------------------------------
  def mp_recovery
    effects_sum_all_value2(EFFECT_RECOVER_MP)
  end
  #--------------------------------------------------------------------------
  # * Get MP Recovery Rate
  #--------------------------------------------------------------------------
  def mp_recovery_rate
    effects_sum_all_value1(EFFECT_RECOVER_MP)
  end
  #--------------------------------------------------------------------------
  # * Get TP Recovery Value
  #--------------------------------------------------------------------------
  def tp_recovery
    effects_sum_all_value1(EFFECT_GAIN_TP)
  end
  #--------------------------------------------------------------------------
  # * Get Add States IDs Array
  #--------------------------------------------------------------------------
  # state_id 0 represents 'Normal Attack'.
  def add_states
    effects_set(EFFECT_ADD_STATE)
  end
  #--------------------------------------------------------------------------
  # * Get Remove States IDs Array
  #--------------------------------------------------------------------------
  def remove_states
    effects_set(EFFECT_REMOVE_STATE)
  end
  #--------------------------------------------------------------------------
  # * Get Add States IDs with Rates Array
  #--------------------------------------------------------------------------
  # returns a multi-dimensional array where [index][0] is a
  # state_id number and [index][1] is the success rate.
  # [[state_id, rate],[state_id, rate],[state_id, rate], ...]
  #
  # state_id 0 represents 'Normal Attack'.
  def add_states_with_rates
    effects_set_with_value1(EFFECT_ADD_STATE)
  end
  #--------------------------------------------------------------------------
  # * Get Remove States IDs with Rates Array
  #--------------------------------------------------------------------------
  # returns a multi-dimensional array where [index][0] is a
  # state_id number and [index][1] is the success rate.
  # [[state_id, rate],[state_id, rate],[state_id, rate], ...]
  def remove_states_with_rates
    effects_set_with_value1(EFFECT_REMOVE_STATE)
  end
  #--------------------------------------------------------------------------
  # * Get Add Buffs Param Index Array
  #--------------------------------------------------------------------------
  def add_buffs
    effects_set(EFFECT_ADD_BUFF)
  end
  #--------------------------------------------------------------------------
  # * Get Add Debuffs Param Index Array
  #--------------------------------------------------------------------------
  def add_debuffs
    effects_set(EFFECT_ADD_DEBUFF)
  end
  #--------------------------------------------------------------------------
  # * Get Add Buffs Param Index with Turns Array
  #--------------------------------------------------------------------------
  # returns a multi-dimensional array where [index][0] is a
  # param_id value and [index][1] is the turn duration.
  # [[param_index, turn],[param_index, turn],[param_index, turn], ...]
  def add_buffs_with_turns
    effects_set_with_value1(EFFECT_ADD_BUFF)
  end
  #--------------------------------------------------------------------------
  # * Get Add Debuffs Param Index with Turns Array
  #--------------------------------------------------------------------------
  # returns a multi-dimensional array where [index][0] is a
  # param_id value and [index][1] is the turn duration.
  # [[param_index, turn],[param_index, turn],[param_index, turn], ...]
  def add_debuffs_with_turns
    effects_set_with_value1(EFFECT_ADD_DEBUFF)
  end
  #--------------------------------------------------------------------------
  # * Get Remove Buffs Param Index
  #--------------------------------------------------------------------------
  def remove_buffs
    effects_set(EFFECT_REMOVE_BUFF)
  end
  #--------------------------------------------------------------------------
  # * Get Remove Debuffs Param Index
  #--------------------------------------------------------------------------
  def remove_debuffs
    effects_set(EFFECT_REMOVE_DEBUFF)
  end
  #--------------------------------------------------------------------------
  # * Determine Escape Item/Skill
  #--------------------------------------------------------------------------
  def escape?
    !effects_set(EFFECT_SPECIAL).empty?
  end
  #--------------------------------------------------------------------------
  # * Get Param Growth with Values
  #--------------------------------------------------------------------------
  def grow(param_id)
    effects_sum_value1(EFFECT_GROW, param_id)
  end
  #--------------------------------------------------------------------------
  # * Get Learn Skills IDs Array
  #--------------------------------------------------------------------------
  def learn_skills
    effects_set(EFFECT_LEARN_SKILL)
  end
  #--------------------------------------------------------------------------
  # * Get Common Event ID
  #--------------------------------------------------------------------------
  def common_event
    effects_set(EFFECT_COMMON_EVENT).last
  end
  #--------------------------------------------------------------------------
  # * Get Effect By Key
  #--------------------------------------------------------------------------
  def effect_by_key(key)
    case key
    when :hp_recovery
      hp_recovery
    when :hp_recovery_rate
      hp_recovery_rate
    when :mp_recovery
      mp_recovery
    when :mp_recovery_rate
      mp_recovery_rate
    when :tp_recovery
      tp_recovery
    when :add_states
      add_states
    when :remove_states
      remove_states
    when :add_states_with_rates
      add_states_with_rates
    when :remove_states_with_rates
      remove_states_with_rates
    when :add_buffs
      add_buffs
    when :add_debuffs
      add_debuffs
    when :add_buffs_with_turns
      add_buffs_with_turns
    when :add_debuffs_with_turns
      add_debuffs_with_turns
    when :remove_buffs
      remove_buffs
    when :remove_debuffs
      remove_debuffs
    when :escape
      escape?
    when :learn_skills
      learn_skills
    when :comment_event
      common_event
    end
  end
end # class RPG::UsableItem

#==============================================================================
# ++ RPG::EquipItem
#==============================================================================
class RPG::EquipItem
  #--------------------------------------------------------------------------
  # * Access Method by Parameter Abbreviations
  #--------------------------------------------------------------------------
  def mhp;  param(0);   end          # MHP  Maximum Hit Points
  def mmp;  param(1);   end          # MMP  Maximum Magic Points
  def atk;  param(2);   end          # ATK  ATtacK power
  def def;  param(3);   end          # DEF  DEFense power
  def mat;  param(4);   end          # MAT  Magic ATtack power
  def mdf;  param(5);   end          # MDF  Magic DeFense power
  def agi;  param(6);   end          # AGI  AGIlity
  def luk;  param(7);   end          # LUK  LUcK
  #--------------------------------------------------------------------------
  # * Get Parameter
  #--------------------------------------------------------------------------
  def param(param_id)
    params[param_id]
  end
  
end # class RPG::EquipItem