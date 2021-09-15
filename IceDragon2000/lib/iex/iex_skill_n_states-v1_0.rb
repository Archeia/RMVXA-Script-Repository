#==============================================================================#
# ** IEX(Icy Engine Xelion) - Skill 'n' State 
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Skills, States)
# ** Script Type   : Skill/State Effects
# ** Date Created  : 01/08/2011
# ** Date Modified : 01/08/2011
# ** Version       : 1.0
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This is a script merge with all my Skill / State scripts
#
# -Skill Effective By States
# This script adds a new feature to your skills which affects the effective-ness
# These skills rely on states. If the target doesn't have the required states
# It will fail.
#
# -State Effect Skills
# This script was originally the State Only Skills. 
# That script was used to limit skill useage based on states.
#
# I haven't changed the concept, but rather improved it.
#
# -State Change Skills
# This script was originally the Overlimit skills, which required a certain
# state in order for the skill to be changed.
# Anyway, it was a bit hard coded so I decided to break it a bit to allow
# multiple states instead.
#
# -Skill Condition States
# >.> Okay so this script adds a ... can't call it new...
# Anyway this adds a conditional states effect to skills and items.. 
# How this works is, if the target has certain state or states, you can remove
# those to put a different set of states.
# 
# Deus Ex Procella:
# Enemy is frozen and player uses Fire. Instead of inflicting "Burn", 
#  it thaws the enemy and inflicts "Soaked".
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
# 1.0
#  Notetags! Can be placed in Skill noteboxes.
#==============================================================================#
# <effective_state: state_id, state_id, state_id> (or) <effs: state_id>
# If the target does not have all of the required states, the skill will fail.
#
# EG. <effs: 6>
# If the target is asleep the skill will be effective.
#
#==============================================================================#
# <skill_id sts: state_id, state_id, state_id>
# This will replace the current skill, with the one marked by skill_id if the 
# user has all the needed states
# 
# EG: 
# Skill
# 400 - Breath (Non Elemental)
# 401 - Freeze Breath (Ice)
#
# State
# 150 - Icecore (Attacks are all Ice Based)
#
# <401 sts: 150>
# If the user has state 150, they will use 'Freeze Breath' instead of 'Breath'
# <require_state: state_id, state_id, state_id>
# The skill cannot be used unless the user has all states marked by
# state_id.
#
# You can have as many as you like
# EG <require_state: 1>
# EG <require_state: 5, 6>
# EG <require_state: 4, 7, 8, 12, 19, 20, 25>
#
#==============================================================================#
#  <iex required state> or <iex required states> or
#  <iex required state: id, id, id> or <iex required states: id, id, id>
#  This will allow you to create a condition under which the state will work..
#  <iex required state> this is a non condition requirement.
#  Therefore the state effects will be applied regardless of the situtaion.
#  On the other hand <iex required state: id, id, id>
#  Will require the states marked by Id in order for the effects to be applied
#------------------------------------------------------------------------------#
# **Note this tag will be voided if the required state tag was not used.
#  iex add state: id, id, id or iex add states: id, id, id 
#  This will add the state(s) marked by id.
#------------------------------------------------------------------------------#
# **Note this tag will be voided if the required state tag was not used.
#  iex remove state: id, id, id or iex remove states: id, id, id
#  This will remove the state(s) marked by id.
#------------------------------------------------------------------------------#
#  </iex required state> or </iex required states>
#  This closes the required tags
#------------------------------------------------------------------------------#
#  Anyway in an item / skill notebox do something like this..
# **Note anything marked with ~ is compulsory
#
#  <iex required state> ~~
#   iex add state: 2
#   iex remove state: 1
#  </iex required state> ~~
#  
#  This effect would add state 2 (Poison) and Remove State 1 (Incapacitated)
#  Regardless.
#
#  <iex required state: 1> ~~
#   iex add state: 122
#   iex remove state: 1
#  </iex required state> ~~
# 
#  This effect would add state 122 (Zombied) and Remove State 1 (Incapacitated)
#  This requires state 1 (Incapacitated).
#
#==============================================================================#
# 2.0
#  Notetags! Can be placed in Skill and Equipment noteboxes
#------------------------------------------------------------------------------# 
# NOTES
# tt -
# user
# target
#------------------------------------------------------------------------------# 
# <tt stm state_id: +/-x>
# This is a set amount that will be added to the damage
#
# EG: <user stm 2: +200>
# If the user has state 2, 200 is added to the damage
#
# EG2: <target stm 2: -200>
# If the target has state 2, 200 is subtracted from the damage
#
#------------------------------------------------------------------------------# 
#
# <tt stm state_id: x%>
# This is a damage rate mod
# Values above 100 will increase the damage while below will, decrease it.
#
# EG: <user stm 2: 150%>
# If the user has state 2, the damage will change to 150% of it self.
#
# EG: <target stm 2: 80%>
# If the target has state 2, the damage will change to 80% of it self.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# BEM, DBS, Yggdrasil, Probably Takentai, not GTBS
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# Classes
#   RPG::BaseItem
#     new-method :iex_sns_cache
#     new-method :req_effect_states
#     new-method :req_state?
#     new-method :states_needed
#     new-method :state_dm_set
#     new-method :state_rate
#     new-method :sts_skill?
#     new-method :get_sts_skills
#     new-method :iex_required_states
#   RPG::Enemy
#     new-method :iex_sns_cache
#     new-method :state_dm_set
#     new-method :state_rate
#   Game_Battler
#     alias      :skill_effective?
#     alias      :apply_state_changes
#     alias      :skill_can_use?
#     alias      :make_obj_damage_value
#     alias      :make_attack_damage_value
#     new-method :sns_mult_change
#     new-method :get_sts_skill
#     new-method :iex_swap_states
#     new-method :iex_swap_states
#   Scene_Battle
#     alias      :execute_action_skill
#   Scene_Title
#     alias      :load_database
#     new-method :load_sns_database
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  01/08/2011 - V1.0  Merged, SEFFS, SES, STS, CS 
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#  
#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_Skill'n'States"] = true
#==============================================================================#
# ** IEX
#------------------------------------------------------------------------------#
#==============================================================================#
module IEX
  #==============================================================================
  # ** IMath
  #------------------------------------------------------------------------------
  #==============================================================================
  module IMath
    def self.cal_percent(perc, val)
      ans = val.to_i
      ans *= 100.0
      ans = ans * (perc.to_i / 100.0)
      ans /= 100.0
      return Integer(ans)
    end  
  end
  #==============================================================================
  # ** REGEXP::SkillNStates
  #------------------------------------------------------------------------------
  #==============================================================================
  module REGEXP
    module SKILLNSTATES
      # SEFFS
      EFFECTIVE_STATE = /<(?:EFFECTIVE_STATE|effective state|effs)s?:?[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      # SES
      REQ_STATE = /<(?:REQUIRE_STATE|require state)s?:?[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      DMG_ST_MULTI1 = /<(\w+)[ ]*STM[ ]*(\d+):?[ ]*([\+\-]?\d+)>/i
      DMG_ST_MULTI2 = /<(\w+)[ ]*STM[ ]*(\d+):?[ ]*(\d+)([%%])>/i
      # STS
      STA_SKILL = /<(\d+)[ ]*(?:REQ_STATE_SKILL|req state skill|STS):?[ ]*(\d+(?:\s*,\s*\d+)*)>/i           
      # Condition States
      ADD_STATES         = /(?:IEX_ADD_STATE|iex add state)s?:[ ]*(\d+(?:\s*,\s*\d+)*)/i
      REMOVE_STATES      = /(?:IEX_REMOVE_STATE|iex remove state)s?:[ ]*(\d+(?:\s*,\s*\d+)*)/i
      REQUIRED_STATES_ON = /<(?:IEX_REQUIRED_STATE|iex required state)s?(?::?:[ ]*(\d+(?:\s*,\s*\d+)*))*>/i
      REQUIRED_STATES_OFF= /<\/(?:IEX_REQUIRED_STATE|iex required state)s?>/i
    end  
  end
end

#==============================================================================#
# ** RPG::BaseItem
#------------------------------------------------------------------------------#
#==============================================================================#
class RPG::BaseItem
  
  def iex_sns_cache
    @iex_sns_cache_complete= false
    @sts_skill = false
    @sts_skills = {}
    @iex_effective_states  = []
    @state_skill           = false
    @states_needed         = []
    @sns_user_dm_set       = {}
    @sns_target_dm_set     = {}
    @sns_user_rate         = {}
    @sns_target_rate       = {}
    @iex_required_states   = {}
    @in_req_state          = false
    @key_a                 = []
    self.note.split(/[\r\n]+/).each { |line|
    case line
    # SEFFS
    when IEX::REGEXP::SKILLNSTATES::EFFECTIVE_STATE
      $1.scan(/\d+/).each { |sta_id|
      @iex_effective_states.push(sta_id.to_i) if sta_id.to_i > 0}
    # SES  
    when IEX::REGEXP::SKILLNSTATES::REQ_STATE
      @state_skill = true
      $1.scan(/\d+/).each { |num|
      @states_needed.push(num.to_i) if num.to_i > 0 }
    when IEX::REGEXP::SKILLNSTATES::DMG_ST_MULTI1
      sid = $2.to_i
      set = $3.to_i
      case $1.to_s.upcase
      when "USER"
        @sns_user_dm_set[sid]   = set
      when "TARGET"  
        @sns_target_dm_set[sid] = set
      end
    when IEX::REGEXP::SKILLNSTATES::DMG_ST_MULTI2
      sid = $2.to_i
      per = $3.to_i
      case $1.to_s.upcase
      when "USER"
        @sns_user_rate[sid]   = per
      when "TARGET"  
        @sns_target_rate[sid] = per
      end  
    # STS  
    when IEX::REGEXP::SKILLNSTATES::STA_SKILL
      ski_id = $1.to_i
      @sts_skill = true
      ski_sta = []
      $2.scan(/\d+/).each { |num| 
        ski_sta.push(num.to_i) if num.to_i > 0 }
      @sts_skills[ski_sta.clone] = ski_id  
    # Condition States
    when IEX::REGEXP::SKILLNSTATES::REQUIRED_STATES_ON
      @in_req_state = true
      @key_a = []
      if $1 != nil
        $1.scan(/\d+/).each { |sta_id|
          @key_a.push(sta_id.to_i) }
      end  
      @iex_required_states[@key_a.clone] = {:remove_states => [], :add_states => []}
    when IEX::REGEXP::SKILLNSTATES::REQUIRED_STATES_OFF
      @in_req_state = false
      @key_a = nil
    when IEX::REGEXP::SKILLNSTATES::ADD_STATES
      next unless @in_req_state
      $1.scan(/\d+/).each { |sta_id|
        @iex_required_states[@key_a][:add_states].push(sta_id.to_i) }
    when IEX::REGEXP::SKILLNSTATES::REMOVE_STATES
      next unless @in_req_state
      $1.scan(/\d+/).each { |sta_id|
        @iex_required_states[@key_a][:remove_states].push(sta_id.to_i) }
    end
    }
    @in_req_state = false
    @key_a = nil
    @iex_sns_cache_complete = true
  end
  
  # SEFFS
  def req_effect_states
    iex_sns_cache unless @iex_sns_cache_complete
    return @iex_effective_states
  end
  
  # SES
  def req_state?
    iex_sns_cache unless @iex_sns_cache_complete
    return @state_skill
  end
  
  def states_needed
    iex_sns_cache unless @iex_sns_cache_complete
    return @states_needed
  end
  
  def state_dm_set(type, state)
    iex_sns_cache unless @iex_sns_cache_complete
    return 1 if state == nil
    case type
    when 0      
      return @sns_user_dm_set[state.id] if @sns_user_dm_set.has_key?(state.id)
    when 1
      return @sns_target_dm_set[state.id] if @sns_target_dm_set.has_key?(state.id)
    end  
    return 1
  end
  
  def state_rate(type, state)
    iex_sns_cache unless @iex_sns_cache_complete 
    return 100 if state == nil
    case type
    when 0      
      return @sns_user_rate[state.id] if @sns_user_rate.has_key?(state.id)
    when 1
      return @sns_target_rate[state.id] if @sns_target_rate.has_key?(state.id)
    end  
    return 100 
  end
  
  # STS
  def sts_skill?
    iex_sns_cache unless @iex_sns_cache_complete 
    return @sts_skill 
  end
  
  def get_sts_skills
    iex_sns_cache unless @iex_sns_cache_complete 
    return @sts_skills
  end
  
  # Condition States
  def iex_required_states
    iex_sns_cache unless @iex_sns_cache_complete 
    return @iex_required_states
  end
  
end

#==============================================================================
# ** RPG::Enemy
#------------------------------------------------------------------------------
#==============================================================================
class RPG::Enemy
  
  def iex_sns_cache
    @iex_sns_cache_complete= false
    @sns_user_dm_set   = {}
    @sns_target_dm_set = {}
    @sns_user_rate         = {}
    @sns_target_rate       = {}
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEX::REGEXP::SKILLNSTATES::DMG_ST_MULTI1
      sid = $2.to_i
      set = $3.to_i
      case $1.to_s.upcase
      when "USER"
        @sns_user_dm_set[sid]   = set
      when "TARGET"  
        @sns_target_dm_set[sid] = set
      end
    when IEX::REGEXP::SKILLNSTATES::DMG_ST_MULTI2
      sid = $2.to_i
      per = $3.to_i
      case $1.to_s.upcase
      when "USER"
        @sns_user_rate[sid]   = per
      when "TARGET"  
        @sns_target_rate[sid] = per
      end  
    end
    }
    @iex_sns_cache_complete = true
  end
  
  def state_dm_set(type, state)
    iex_sns_cache unless @iex_sns_cache_complete 
    return 0 if state == nil
    case type
    when 0      
      return @sns_user_dm_set[state.id] if @sns_user_dm_set.has_key?(state.id)
    when 1
      return @sns_target_dm_set[state.id] if @sns_target_dm_set.has_key?(state.id)
    end  
    return 0
  end
  
  def state_rate(type, state)
    iex_sns_cache unless @iex_sns_cache_complete 
    return 100 if state == nil
    case type
    when 0      
      return @sns_user_rate[state.id] if @sns_user_rate.has_key?(state.id)
    when 1
      return @sns_target_rate[state.id] if @sns_target_rate.has_key?(state.id)
    end  
    return 100 
  end
  
end

#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#==============================================================================
class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------#
  # * alias load_database
  #--------------------------------------------------------------------------#
  alias iex_sns_load_database load_database unless $@
  def load_database
    iex_sns_load_database
    load_sns_database
  end
  
  #--------------------------------------------------------------------------#
  # * load_sns_database
  #--------------------------------------------------------------------------#
  # This loads all the sns caches so it doesn't have to during runtime
  #--------------------------------------------------------------------------#
  def load_sns_database
    for st in ($data_skills + $data_weapons + $data_armors + $data_items + $data_enemies) 
      next if st == nil
      st.iex_sns_cache
    end
  end
  
end
#==============================================================================#
# ** Game_Battler
#------------------------------------------------------------------------------#
#==============================================================================#
class Game_Battler
  
  #--------------------------------------------------------------------------
  # * Determine if a Skill can be Applied
  #     user  : Skill user
  #     skill : Skill
  #--------------------------------------------------------------------------
  alias iex_sns_skill_effective? skill_effective? unless $@
  def skill_effective?(user, skill)
    for sta in skill.req_effect_states
      next if sta == nil
      return false unless @states.include?(sta.to_i)
    end  
    iex_sns_skill_effective?(user, skill)
  end
  
  # Condition States
  #--------------------------------------------------------------------------
  # * Apply State Changes
  #     obj : Skill, item, or attacker
  #--------------------------------------------------------------------------
  alias iex_condition_states_apply_state_changes apply_state_changes unless $@
  def apply_state_changes(obj)
    iex_condition_states_apply_state_changes(obj)
    if obj.kind_of?(RPG::BaseItem)
      iex_swap_states(obj)
    end  
  end
  
  # SES    
  #--------------------------------------------------------------------------
  # * Determine Usable Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  alias iex_sns_skill_can_use? skill_can_use? unless $@
  def skill_can_use?(skill)
    if skill != nil
      if skill.req_state?
        for sta_id in skill.states_needed
          return false unless @states.include?(sta_id)
        end
      end
    end  
    iex_sns_skill_can_use?(skill)
  end 
    
  alias iex_sns_make_obj_damage_value make_obj_damage_value unless $@
  def make_obj_damage_value(user, obj)
    iex_sns_make_obj_damage_value(user, obj)
    dama = 0
    dama = @hp_damage if @hp_damage > 0
    dama = @mp_damage if @mp_damage > 0
    for st in states
      dama = sns_mult_change(1, obj, dama, st)
    end
    for st2 in user.states
      dama = sns_mult_change(0, obj, dama, st2)
    end
    @hp_damage = Integer(dama) if @hp_damage > 0
    @mp_damage = Integer(dama) if @mp_damage > 0
  end
  
  alias iex_sns_make_attack_damage_value make_attack_damage_value unless $@
  def make_attack_damage_value(attacker)
    iex_sns_make_attack_damage_value(attacker)
    dama = 0
    dama = @hp_damage if @hp_damage > 0
    dama = @mp_damage if @mp_damage > 0
    if attacker.actor?
      for eq in attacker.equips
        next if eq == nil
        for st in states
          dama = sns_mult_change(1, eq, dama, st)
        end
        for st2 in attacker.states
          dama = sns_mult_change(0, eq, dama, st2)
        end 
      end 
    else
      for st in states
        dama = sns_mult_change(1, attacker.enemy, dama, st)
      end
      for st2 in attacker.states
        dama = sns_mult_change(0, attacker.enemy, dama, st2)
      end 
    end  
    @hp_damage = Integer(dama) if @hp_damage > 0
    @mp_damage = Integer(dama) if @mp_damage > 0
  end
  
  # SES
  def sns_mult_change(type, obj, dam, state)
    dam = dam.to_i
    return Integer(dam) if obj == nil
    dam *= 100.0
    dam += obj.state_dm_set(type, state).to_i
    dam = IEX::IMath.cal_percent(obj.state_rate(type, state), dam)
    dam /= 100.0
    return Integer(dam)
  end
  
  # STS
  def get_sts_skill(skil)
    return skil unless skil.is_a?(RPG::Skill)
    ret_skill = skil
    if skil.sts_skill?
      ski_cons = skil.get_sts_skills
      for sta_set in ski_cons.keys
        next if sta_set == nil
        valid = false
        sta_set.each { |sta_id|
          valid = false
          break unless @states.include?(sta_id) 
          valid = true }
        if valid 
          ret_skill = $data_skills[ski_cons[sta_set]]
          break
        end  
      end  
    else
      ret_skill = skil
    end 
    return ret_skill
  end
  
  # Condition States
  def iex_swap_states(obj)
    reque = obj.iex_required_states
    for req_sta in reque.keys
      req_ret = false
      for sta_id in req_sta
        next if sta_id == nil
        unless @states.include?(sta_id)
          req_ret = true 
          break
        end
      end  
      return if req_ret
      rem_sta = reque[req_sta][:remove_states]
      add_sta = reque[req_sta][:add_states]
      for rem_sta_id in rem_sta
        next if rem_sta_id == nil
        remove_state(rem_sta_id)
        @removed_states.delete(rem_sta_id)
      end  
      for add_sta_id in add_sta
        next if add_sta_id == nil
        add_state(add_sta_id)
      end
    end
  end
  
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Skill
  #--------------------------------------------------------------------------
  alias iex_overlimit_scb_execute_action_skill execute_action_skill unless $@
  def execute_action_skill(*args)
    ol_skill = @active_battler.action.skill
    swa_skill = @active_battler.get_sts_skill(ol_skill)
    @active_battler.action.skill_id = swa_skill.id
    iex_overlimit_scb_execute_action_skill(*args)
  end
  
end