require 'vxa_make/enums'

module MakeFeature
  include Enums::FeatureConstants
  include Enums::ParamConstants
  include Enums::XParamConstants
  include Enums::SParamConstants
  include Enums::AbilityConstants

  def feature(feature_id, data_id, value = 0)
    RPG::BaseItem::Feature.new(feature_id, data_id, value.to_f)
  end

  def null
    feature(0, 0, 0.0)
  end

  # // And More @_@ - 02/24/2012
  def element_r(id, n)
    feature(FEATURE_ELEMENT_RATE, id, n)
  end

  # // 02/29/2012
  def debuff_r(id, n)
    feature(FEATURE_DEBUFF_RATE, id, n)
  end

  def state_r(id, n)
    feature(FEATURE_STATE_RATE, id, n)
  end

  def state_resist(id)
    feature(FEATURE_STATE_RESIST, id)
  end

  # // 02/23/2012
  def param_r(i, n)
    feature(FEATURE_PARAM, i, n)
  end

  def mhp_r(n)
    param_r(PARAM_MHP, n)
  end

  def mmp_r(n)
    param_r(PARAM_MMP, n)
  end

  def atk_r(n)
    param_r(PARAM_ATK, n)
  end

  def def_r(n)
    param_r(PARAM_DEF, n)
  end

  def mat_r(n)
    param_r(PARAM_MAT, n)
  end

  def mdf_r(n)
    param_r(PARAM_MDF, n)
  end

  def agi_r(n)
    param_r(PARAM_AGI, n)
  end

  def luk_r(n)
    param_r(PARAM_LUK, n)
  end

  # // XPARAM
  def xparam_r(i,n)
    feature(FEATURE_XPARAM, i, n)
  end

  def hit_r(n)
    xparam_r(XPARAM_HIT_RATE, n)
  end

  def eva_r(n)
    xparam_r(XPARAM_EVA_RATE, n)
  end

  def evasion_r(*args, &block)
    eva_r(*args, &block)
  end

  def critical_r(n)
    xparam_r(XPARAM_CRI_RATE, n)
  end

  def cri_r(*args, &block)
    critical_r(*args, &block)
  end

  def cri_eva_r(n)
    xparam_r(XPARAM_CRI_EVA_RATE, n)
  end

  def mag_eva_r(n)
    xparam_r(XPARAM_MAG_EVA_RATE, n)
  end

  def mag_reflect_r(n)
    xparam_r(XPARAM_MAG_REF_RATE, n)
  end

  def counter_attack_r(n)
    xparam_r(XPARAM_CAT_RATE, n)
  end

  def cat_r(*args, &block)
    counter_attack_r(*args, &block)
  end

  def hp_regen_r(n)
    xparam_r(XPARAM_HP_REGEN_RATE, n)
  end

  def mp_regen_r(n)
    xparam_r(XPARAM_MP_REGEN_RATE, n)
  end

  def tp_regen_r(n)
    xparam_r(XPARAM_TP_REGEN_RATE, n)
  end

  # // Special Abilities
  def sparam_r(i,n)
    feature(FEATURE_SPARAM, i, n)
  end

  def target_r(n)
    sparam_r(SPARAM_TARGET_RATE, n)
  end

  def tgr(n)
    target_r(n)
  end

  def guard_r(n)
    sparam_r(SPARAM_GUARD_RATE, n)
  end

  def grd_r(n)
    guard_r(n)
  end

  def recovery_r(n)
    sparam_r(SPARAM_RECOVERY_RATE, n)
  end

  def rec_r(n)
    recovery_r(n)
  end

  def pharmacology_r(n)
    sparam_r(SPARAM_PHARMACOLOGY_RATE, n)
  end

  def pha_r(n)
    pharmacology_r(n)
  end

  def mp_cost_r(n)
    sparam_r(SPARAM_MP_COST_RATE, n)
  end

  def mcr(n)
    mp_cost_r(n)
  end

  def tp_charge_r(n)
    sparam_r(SPARAM_TP_CHARGE_RATE, n)
  end

  def tcr(n)
    tp_charge_r(n)
  end

  def phy_dam_r(n)
    sparam_r(SPARAM_PHYSICAL_DAM_RATE, n)
  end

  def pdr(n)
    phy_dam_r(n)
  end

  def mat_dam_r(n)
    sparam_r(SPARAM_MAGICAL_DAM_RATE, n)
  end

  def mdr(n)
    mat_dam_r(n)
  end

  def floor_dam_r(n)
    sparam_r(SPARAM_FLOOR_DAM_RATE, n)
  end

  def fdr(n)
    floor_dam_r(n)
  end

  def exp_gain_r(n)
    sparam_r(SPARAM_EXP_GAIN_RATE, n)
  end

  def exr(n)
    exp_gain_r(n)
  end

  # // 02/29/2012
  def atk_element(n)
    feature(FEATURE_ATK_ELEMENT, n)
  end

  def atk_state(id, n)
    feature(FEATURE_ATK_STATE, id, n)
  end

  def atk_speed(n)
    feature(FEATURE_ATK_SPEED, 0, n)
  end

  def atk_times(n)
    feature(FEATURE_ATK_TIMES, 0, n)
  end

  # // Some More -3- - 02/25/2012
  def stype_add(n)
    feature(FEATURE_STYPE_ADD, n)
  end

  def skill_type_add(*args, &block)
    stype_add(*args, &block)
  end

  def stype_seal(n)
    feature(FEATURE_STYPE_SEAL, n)
  end

  def skill_type_seal(*args, &block)
    stype_seal(*args, &block)
  end

  def skill_add(n)
    feature(FEATURE_SKILL_ADD, n)
  end

  def skill_seal(n)
    feature(FEATURE_SKILL_SEAL, n)
  end

  # // More x.x
  def equip_wtype(n)
    feature(FEATURE_EQUIP_WTYPE, n)
  end

  def weapon_type(n)
    equip_wtype(n)
  end

  def equip_atype(n)
    feature(FEATURE_EQUIP_ATYPE, n)
  end

  def armor_type(n)
    equip_atype(n)
  end

  # // EVEN MOAR 030 - 02/29/2012
  def equip_fix(n)
    feature(FEATURE_EQUIP_FIX, n)
  end

  def equip_seal(n)
    feature(FEATURE_EQUIP_SEAL, n)
  end

  def slot_type(n = 0)
    feature(FEATURE_SLOT_TYPE, n, 0)
  end

  def action_plus(rate, n)
    feature(FEATURE_ACTION_PLUS, rate, n)
  end

  # // Special
  def special(id, n = 0)
    feature(FEATURE_SPECIAL_FLAG, id, n)
  end

  def auto_battle
    special(FLAG_ID_AUTO_BATTLE, 0)
  end

  def guard
    special(FLAG_ID_GUARD, 0)
  end

  def substitute
    special(FLAG_ID_SUBSTITUTE, 0)
  end

  def preserve_tp
    special(FLAG_ID_PRESERVE_TP, 0)
  end

  # // Collapse
  def collapse_type(n)
    feature(FEATURE_COLLAPSE_TYPE, n)
  end

  # // Party
  def party_ability(n)
    feature(FEATURE_PARTY_ABILITY, n)
  end

  def encounter_halve
    party_ability(ABILITY_ENCOUNTER_HALF)
  end

  def encounter_none
    party_ability(ABILITY_ENCOUNTER_NONE)
  end

  def cancelsurprise
    party_ability(ABILITY_CANCEL_SURPRISE)
  end

  def raise_preemitive
    party_ability(ABILITY_RAISE_PREEMPTIVE)
  end

  def gold_double
    party_ability(ABILITY_GOLD_DOUBLE)
  end

  def drop_item_double
    party_ability(ABILITY_DROP_ITEM_DOUBLE)
  end

  extend self
end
