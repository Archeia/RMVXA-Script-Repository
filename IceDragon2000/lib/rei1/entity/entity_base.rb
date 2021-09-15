module REI
  class EntityBase
    include ::Enums::FeatureConstants

    #--------------------------------------------------------------------------
    # * Constants (Starting Number of Buff/Debuff Icons)
    #--------------------------------------------------------------------------
    ICON_BUFF_START       = 64              # buff (16 icons)
    ICON_DEBUFF_START     = 80              # debuff (16 icons)
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_reader   :hp                       # HP
    attr_reader   :mp                       # MP
    attr_reader   :tp                       # TP
    attr_reader   :id
    attr_accessor :name
    attr_accessor :title
    attr_accessor :unit
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
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize
      @hp = @mp = @tp = 0
      @hidden = false
      @id     = nil
      @name   = ''
      @title  = ''
      @unit   = nil
      clear_param_plus
      clear_states
      clear_buffs
    end

    def character
      unit.character
    end

    def clear_param_plus
      @param_plus = Array.new(8, 0)
    end

    def clear_states
      @states = []
      @state_turns = {}
      @state_steps = {}
    end

    def erase_state(state_id)
      @states.delete(state_id)
      @state_turns.delete(state_id)
      @state_steps.delete(state_id)
    end

    def clear_buffs
      @buffs = Array.new(8, 0)
      @buff_turns = {}
    end

    def state?(state_id)
      @states.include?(state_id)
    end

    def death_state?
      state?(death_state_id)
    end

    def death_state_id
      1
    end

    def states
      @states.map {|id| $data_states[id] }
    end

    def state_icons
      icons = states.map {|state| state.icon_index }
      icons.delete(0)
      icons
    end

    def buff_icons
      icons = []
      @buffs.each_with_index {|lv, i| icons.push(buff_icon_index(lv, i)) }
      icons.delete(0)
      icons
    end

    def buff_icon_index(buff_level, param_id)
      if buff_level > 0
        return ICON_BUFF_START + (buff_level - 1) * 8 + param_id
      elsif buff_level < 0
        return ICON_DEBUFF_START + (-buff_level - 1) * 8 + param_id
      else
        return 0
      end
    end

    def feature_objects
      states
    end

    def all_features
      feature_objects.inject([]) {|r, obj| r + obj.features }
    end

    def features(code)
      all_features.select {|ft| ft.code == code }
    end

    def features_with_id(code, id)
      all_features.select {|ft| ft.code == code && ft.data_id == id }
    end

    def features_pi(code, id)
      features_with_id(code, id).inject(1.0) {|r, ft| r *= ft.value }
    end

    def features_sum(code, id)
      features_with_id(code, id).inject(0.0) {|r, ft| r += ft.value }
    end

    def features_sum_all(code)
      features(code).inject(0.0) {|r, ft| r += ft.value }
    end

    def features_set(code)
      features(code).inject([]) {|r, ft| r |= [ft.data_id] }
    end

    def param_base(param_id)
      return 0
    end

    def param_plus(param_id)
      @param_plus[param_id]
    end

    def param_min(param_id)
      return 0 if param_id == 1  # MMP
      return 1
    end

    def param_max(param_id)
      return 999999 if param_id == 0  # MHP
      return 9999   if param_id == 1  # MMP
      return 999
    end

    def param_rate(param_id)
      features_pi(FEATURE_PARAM, param_id)
    end

    def param_buff_rate(param_id)
      @buffs[param_id] * 0.25 + 1.0
    end

    def param(param_id)
      value = param_base(param_id) + param_plus(param_id)
      value *= param_rate(param_id) * param_buff_rate(param_id)
      [[value, param_max(param_id)].min, param_min(param_id)].max.to_i
    end

    def xparam(xparam_id)
      features_sum(FEATURE_XPARAM, xparam_id)
    end

    def sparam(sparam_id)
      features_pi(FEATURE_SPARAM, sparam_id)
    end

    def element_rate(element_id)
      features_pi(FEATURE_ELEMENT_RATE, element_id)
    end

    def debuff_rate(param_id)
      features_pi(FEATURE_DEBUFF_RATE, param_id)
    end

    def state_rate(state_id)
      features_pi(FEATURE_STATE_RATE, state_id)
    end

    def state_resist_set
      features_set(FEATURE_STATE_RESIST)
    end

    def state_resist?(state_id)
      state_resist_set.include?(state_id)
    end

    def atk_elements
      features_set(FEATURE_ATK_ELEMENT)
    end

    def atk_states
      features_set(FEATURE_ATK_STATE)
    end

    def atk_states_rate(state_id)
      features_sum(FEATURE_ATK_STATE, state_id)
    end

    def atk_speed
      features_sum_all(FEATURE_ATK_SPEED)
    end

    def atk_times_add
      [features_sum_all(FEATURE_ATK_TIMES), 0].max
    end

    def added_skill_types
      features_set(FEATURE_STYPE_ADD)
    end

    def skill_type_sealed?(stype_id)
      features_set(FEATURE_STYPE_SEAL).include?(stype_id)
    end

    def added_skills
      features_set(FEATURE_SKILL_ADD)
    end

    def skill_sealed?(skill_id)
      features_set(FEATURE_SKILL_SEAL).include?(skill_id)
    end

    def equip_wtype_ok?(wtype_id)
      features_set(FEATURE_EQUIP_WTYPE).include?(wtype_id)
    end

    def equip_atype_ok?(atype_id)
      features_set(FEATURE_EQUIP_ATYPE).include?(atype_id)
    end

    def equip_type_fixed?(etype_id)
      features_set(FEATURE_EQUIP_FIX).include?(etype_id)
    end

    def equip_type_sealed?(etype_id)
      features_set(FEATURE_EQUIP_SEAL).include?(etype_id)
    end

    def slot_type
      features_set(FEATURE_SLOT_TYPE).max || 0
    end

    def dual_wield?
      slot_type == 1
    end

    def action_plus_set
      features(FEATURE_ACTION_PLUS).map {|ft| ft.value }
    end

    def special_flag(flag_id)
      features(FEATURE_SPECIAL_FLAG).any? {|ft| ft.data_id == flag_id }
    end

    def collapse_type
      features_set(FEATURE_COLLAPSE_TYPE).max || 0
    end

    def party_ability(ability_id)
      features(FEATURE_PARTY_ABILITY).any? {|ft| ft.data_id == ability_id }
    end

    def auto_battle?
      special_flag(FLAG_ID_AUTO_BATTLE)
    end

    def guard?
      special_flag(FLAG_ID_GUARD) && movable?
    end

    def substitute?
      special_flag(FLAG_ID_SUBSTITUTE) && movable?
    end

    def preserve_tp?
      special_flag(FLAG_ID_PRESERVE_TP)
    end

    def add_param(param_id, value)
      @param_plus[param_id] += value
      refresh
    end

    def hp=(hp)
      @hp = hp
      refresh
    end

    def mp=(mp)
      @mp = mp
      refresh
    end

    def change_hp(value, enable_death)
      if !enable_death && @hp + value <= 0
        self.hp = 1
      else
        self.hp += value
      end
    end

    def tp=(tp)
      @tp = [[tp, max_tp].min, 0].max
    end

    def max_tp
      return 100
    end

    def refresh
      state_resist_set.each {|state_id| erase_state(state_id) }
      @hp = [[@hp, mhp].min, 0].max
      @mp = [[@mp, mmp].min, 0].max
      @hp == 0 ? add_state(death_state_id) : remove_state(death_state_id)
    end

    def recover_all
      clear_states
      @hp = mhp
      @mp = mmp
    end

    def hp_rate
      @hp.to_f / mhp
    end

    def mp_rate
      mmp > 0 ? @mp.to_f / mmp : 0
    end

    def tp_rate
      @tp.to_f / 100
    end

    def hide
      @hidden = true
    end

    def appear
      @hidden = false
    end

    def hidden?
      @hidden
    end

    def exist?
      !hidden?
    end

    def dead?
      exist? && death_state?
    end

    def alive?
      exist? && !death_state?
    end

    def normal?
      exist? && restriction == 0
    end

    def inputable?
      normal? && !auto_battle?
    end

    def movable?
      exist? && restriction < 4
    end

    def confusion?
      exist? && restriction >= 1 && restriction <= 3
    end

    def confusion_level
      confusion? ? restriction : 0
    end

    def actor?
      return false
    end

    def enemy?
      return false
    end

    def sort_states
      @states = @states.sort_by {|id| [-$data_states[id].priority, id] }
    end

    def restriction
      states.map {|state| state.restriction }.push(0).max
    end

    def most_important_state_text
      states.each {|state| return state.message3 unless state.message3.empty? }
      return ""
    end

    def skill_wtype_ok?(skill)
      return true
    end

    def skill_mp_cost(skill)
      (skill.mp_cost * mcr).to_i
    end

    def skill_tp_cost(skill)
      skill.tp_cost
    end

    def skill_cost_payable?(skill)
      tp >= skill_tp_cost(skill) && mp >= skill_mp_cost(skill)
    end

    def pay_skill_cost(skill)
      self.mp -= skill_mp_cost(skill)
      self.tp -= skill_tp_cost(skill)
    end

    def occasion_ok?(item)
      $game.party.in_battle ? item.battle_ok? : item.menu_ok?
    end

    def usable_item_conditions_met?(item)
      movable? && occasion_ok?(item)
    end

    def skill_conditions_met?(skill)
      usable_item_conditions_met?(skill) &&
      skill_wtype_ok?(skill) && skill_cost_payable?(skill) &&
      !skill_sealed?(skill.id) && !skill_type_sealed?(skill.stype_id)
    end

    def item_conditions_met?(item)
      usable_item_conditions_met?(item) && $game.party.has_item?(item)
    end

    def usable?(item)
      return skill_conditions_met?(item) if item.is_a?(RPG::Skill)
      return item_conditions_met?(item)  if item.is_a?(RPG::Item)
      return false
    end

    def equippable?(item)
      return false unless item.is_a?(RPG::EquipItem)
      return false if equip_type_sealed?(item.etype_id)
      return equip_wtype_ok?(item.wtype_id) if item.is_a?(RPG::Weapon)
      return equip_atype_ok?(item.atype_id) if item.is_a?(RPG::Armor)
      return false
    end

    def attack_skill_id
      return 1
    end

    def guard_skill_id
      return 2
    end

    def attack_usable?
      usable?($data_skills[attack_skill_id])
    end

    def guard_usable?
      usable?($data_skills[guard_skill_id])
    end

  end
end
