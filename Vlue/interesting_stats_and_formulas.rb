#--# Stats and Formulas v 1.0
#
# You know what LUK does? Just affect the chance of a state being applied. I 
#  thought it changed Critical hit or something. I didn't like that, so here
#  this is, any easy way to change the formulas of many different parts of
#  battle, as well as giving stats something more to do.
#
# Usage: Plug and play, customize as needed.
#
#------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
#--Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

module STATS
  #SPEED FORMULA use subject for stats. I.E subject.agi for agility
  #ESCAPE FORMULA has no references to actors or enemies
  #All the other formulas use user and self. User is the one using the ability,
  #  while self is the one being hit. I.E. self.agi - user.agi
  
  #The speed formula determines turn order in battle
  #The higher the value, the sooner they act
  SPEED_FORMULA = "subject.agi + rand(5 + subject.agi / 4)"
  
  #State chance is the change in chance to apply a state
  #The final chance will be the item's chance * STATE_CHANCE
  STATE_CHANCE = "[1.0 + (user.luk - luk) * 0.001, 0.0].max"
  
  #The following formulas occur when a random number between 0.0 and 1.0
  #  is less than ***_FORMULA
  #The formula for being hit with an attack.
  HIT_FORMULA = "user.hit"
  #The formula for evading an attack
  EVA_FORMULA = "self.eva"
  #Same as above, except for magical attacks instead of physical.
  MEV_FORMULA = "self.mev"
  #The formula for the chance for an attack to be a critical hit
  CRI_FORMULA = "user.cri * (1 - self.cev)"
  #The formula for chance to counter attack
  CNT_FORMULA = "self.cnt"
  #The formula for chance to reflect magic
  MRF_FORMULA = "self.mrf"
  
  #Whichever group (enemies or allies) with the greater agility recieve
  # the following percentages for Preemptive and Surprise attacks
  PREEMPTIVE_CHANCE = 5
  SURPRISE_CHANCE = 3
  
  #The formula for initial chance to escape.
  ESCAPE_FORMULA = "1.5 - 1.0 * $game_troop.agi / $game_party.agi"
  
  #Here is where you can make stats add points to secondary stats.
  # Each point in a stat adds that many points to the secondary stat.
  # Values for hp and mp are whole numbers, while everything else is
  #  float values (i.e. :hit => 0.001 for 0.1% chance to hit per point)
  #Options are :hp,  :mp,  :hit, :eva, :cri, :cev, :mev, :mrf, :cnt
  #      :hrg, :mrg, :trg, :tgr, :grd, :rec, :pha, :mcr, :tcr, :pdr
  #      :mdr, :fdr, :exr
  ATK = {:cnt => 0.0005}
  DEF = {:hp => 5, :trg => 0.001}
  MAT = {:mp => 1, :mev => 0.0005}
  MDF = {:mrg => 0.0001, }
  AGI = {:eva => 0.0005, :hit => 0.0005}
  LUK = {:cri => 0.0005, :cev => 0.0005}
  
  def self.all_bonuses
    [ATK,DEF,MAT,MDF,AGI,LUK]
  end
end

class Game_Battler
  def param_bonus(param_id)
    return 0 if param_id > 1
    param_id == 0 ? sym = :hp : sym = :mp
    bonus = 0
    iter = 1
    STATS.all_bonuses.each do |hash|
      iter += 1
      next unless hash[sym]
      bonus += hash[sym] * param(iter)
    end
    bonus
  end
  def xparam_bonus(param_id)
    sym = [:hit,:eva,:cri,:cev,:mev,:mrf,:cnt,:hrg,:mrg,:trg][param_id]
    bonus = 0
    iter = 1
    STATS.all_bonuses.each do |hash|
      iter += 1
      next unless hash[sym]
      bonus += hash[sym] * param(iter)
    end
    bonus
  end
  def sparam_bonus(param_id)
    sym = [:tgr,:grd,:rec,:pha,:mcr,:tcr,:pdr,:mdr,:fdr,:exr][param_id]
    bonus = 0
    iter = 1
    STATS.all_bonuses.each do |hash|
      iter += 1
      next unless hash[sym]
      bonus += hash[sym] * param(iter)
    end
    bonus
  end
  def param(param_id)
    value = param_base(param_id) + param_plus(param_id) + param_bonus(param_id)
    value *= param_rate(param_id) * param_buff_rate(param_id)
    [[value, param_max(param_id)].min, param_min(param_id)].max.to_i
  end
  def xparam(xparam_id)
    features_sum(FEATURE_XPARAM, xparam_id) + xparam_bonus(xparam_id)
  end
  def sparam(sparam_id)
    features_pi(FEATURE_SPARAM, sparam_id) + sparam_bonus(sparam_id)
  end
  def luk_effect_rate(user)
    eval(STATS::STATE_CHANCE)
  end
  def item_hit(user, item)
    rate = item.success_rate * 0.01 
    rate *= eval(STATS::HIT_FORMULA) if item.physical?  
    return rate                        
  end
  def item_eva(user, item)
    return eval(STATS::EVA_FORMULA) if item.physical?
    return eval(STATS::MEV_FORMULA) if item.magical?
    return 0
  end
  def item_cri(user, item)
    return eval(STATS::CRI_FORMULA) if item.damage.critical
    return 0
  end
  def item_cnt(user, item)
    return 0 unless item.physical?          
    return 0 unless opposite?(user)         
    return eval(STATS::CNT_FORMULA)                             
  end
  def item_mrf(user, item)
    return eval(STATS::MRF_FORMULA) if item.magical?     
    return 0
  end
  def rate_preemptive(troop_agi)
    high = STATS::PREEMPTIVE_CHANCE;low = STATS::SURPRISE_CHANCE
    (agi >= troop_agi ? high*0.01 : low*0.01) * (raise_preemptive? ? 4 : 1)
  end
  def rate_surprise(troop_agi)
    high = STATS::PREEMPTIVE_CHANCE;low = STATS::SURPRISE_CHANCE
    cancel_surprise? ? 0 : (agi >= troop_agi ? low*0.01 : high*0.01)
  end
end

class Game_Action
  def speed
    speed = eval(STATS::SPEED_FORMULA)
    speed += item.speed if item
    speed += subject.atk_speed if attack?
    speed
  end
end

module BattleManager
  def self.make_escape_ratio
    @escape_ratio = eval(STATS::ESCAPE_FORMULA)
  end
end