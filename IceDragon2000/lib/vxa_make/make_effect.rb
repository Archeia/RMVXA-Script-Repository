module MakeEffect
  include Enums::EffectConstants

  def effect(code, data_id, value1, value2)
    RPG::UsableItem::Effect.new(code, data_id, value1.to_f, value2.to_f)
  end

  def recover_hp(rate, set)
    effect(EFFECT_RECOVER_HP, 0, rate, set)
  end

  def recover_mp(rate, set)
    effect(EFFECT_RECOVER_MP, 0, rate, set)
  end

  def gain_tp(n)
    effect(EFFECT_GAIN_TP, 0, n, 0.0)
  end

  def add_state(id, rate)
    effect(EFFECT_ADD_STATE, id, rate, 0.0)
  end

  def rem_state(id, rate)
    effect(EFFECT_REMOVE_STATE, id, rate, 0.0)
  end

  def add_buff(param_id, turns)
    effect(EFFECT_ADD_BUFF, param_id, turns, 0.0)
  end

  def add_debuff(param_id, turns)
    effect(EFFECT_ADD_DEBUFF, param_id, turns, 0.0)
  end

  def rem_buff(param_id)
    effect(EFFECT_REMOVE_BUFF, param_id, 0.0, 0.0)
  end

  def rem_debuff(param_id)
    effect(EFFECT_REMOVE_DEBUFF, param_id, 0.0, 0.0)
  end

  def special(id, v1=0.0, v2=0.0)
    effect(EFFECT_SPECIAL, id, v1, v2)
  end

  def escape
    special(SPECIAL_EFFECT_ESCAPE)
  end

  def grow(param_id,n)
    effect(EFFECT_GROW, param_id, n, 0.0)
  end

  def learn_skill(skill_id)
    effect(EFFECT_LEARN_SKILL, skill_id, 0.0, 0.0)
  end

  def common_event(cid)
    effect(EFFECT_COMMON_EVENT, cid, 0.0, 0.0)
  end

  extend self
end
