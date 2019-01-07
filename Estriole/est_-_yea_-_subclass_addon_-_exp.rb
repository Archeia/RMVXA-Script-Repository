=begin
#==============================================================================
 ** EST - YEA - SUBCLASS ADD ON : GAIN EXP , LEARN SKILL, WORKING TRAIT, ETC
 REWRITTEN !!!
 v 3.07
#------------------------------------------------------------------------------
 Author : ESTRIOLE
 also credits: Disturbed Inside for class level bugfix which i modified more

 Version History:
  v 1.00 - 2012.06.21 > First relase
  v 2.00 - final - 2012.06.25 > updated skill and trait from subclass works
  v 3.00 - 2013.03.24 > - rewritten the script. to make it lots more 
                        compatible with another script.
                        - add ability to set class max level by notetags:
                        <class_max_lv: 20> 
                        to set the class max lv to 20.
                        - add ability to set subclass exp rate for each class.
                        so when that class is equipped as subclass. how many
                        percent exp it will gained.
                        <sub_exp_rate: 50>
                        to set the class sub exp rate to 50 percent
  v 3.01 - 2013.03.29 > - add configuration to set when exp divided by sub exp
                        rate below 1. it could set exp gain to 1 instead of 0.
                        example1: slimex2 give 8 exp * subrate 10% = 0,8 -> 1 exp
                        example2: slimex2 give 0 exp * subrate 10% = 0 -> 0 exp.
  v 3.02 - 2013.05.26 > - add support for float percentage sub exp rate. ex:
                        <sub_exp_rate: 1.5> means 1.5% rate.
                        even i doubt people will use it... but the function is available in case
                        someone crazy enough to use it :D.
                        - add ability to boost/reduce sub exp rate
                        give notetags to actor/class/weapon/armor/state
                        <sub_exp_mod: 30> means +30%
                        it's direct addition to current rate so if the rate 50% it will become 80%
                        <sub_exp_mod: -30> means -30%
                        it's direct substraction to current rate so if the rate 50% it will become 20%
                        all actor/class/subclass/weapon/armor/state mod stacks
                        usefull to make accessory that make your subclass gain (+30% battle exp)
                        - add ability to grant multiplier to sub_exp_rate. ex:
                        <sub_exp_mult: 150> will multiply current rate to 150%
                        multiplier STACKS
  v 3.03 - 2013.05.28 > - add MAIN EXP RATE function. this function is SEPARATE
                        with SUB EXP RATE. means increasing MAIN EXP RATE didn't
                        raise sub exp gained. ONLY raised exp gained by main class.
                        notetags the class with:
                        <main_exp_rate: 75> -> to set main class exp rate to 75 percent
                        - add ability to boost/reduce main exp rate
                        give notetags to actor/class/weapon/armor/state
                        <main_exp_mod: 30> means +30%
                        it's direct addition to current rate so if the rate 50% it will become 80%
                        <main_exp_mod: -30> means -30%
                        it's direct substraction to current rate so if the rate 50% it will become 20%
                        all actor/class/subclass/weapon/armor/state mod stacks
                        usefull to make accessory that make your mainclass gain (+30% battle exp)
                        - add ability to grant multiplier to main_exp_rate. ex:
                        <main_exp_mult: 150> will multiply current rate to 150%
                        multiplier STACKS
  v 3.04 - 2013.10.22 > - add compatibility patch to yanfly adjust limit script                        
  v 3.05 - 2014.01.09 > - stop exp gain when max level reached. (both subclass and main class works now) 
                        in case the exp gained will make the actor exceed max level... it will add to maximum exp 
                        you can get to reach next level and ignore the rest.  
  v 3.06 - 2014.01.16 > - compatibility patch with yanfly victory aftermath. to recognize exp rate.
  v 3.07 - 2014.07.16 > - fix the script. IF maintain level set to true. stop the sub exp gain.
                        since the level should be the same with main class.
                        
#------------------------------------------------------------------------------
  This script is addon to YEA class system. Subclass equipped will gain
  full or some exp. gain skill as the subclass level up. actor will have
  all the subclass trait. also if using Tsukihime Effect Manager. subclass
  can be given 'effect' too like normal class.
#------------------------------------------------------------------------------
 Compatibility
   1) REQUIRES the script YEA - Class System. put this script below yanfly class script

   -> built in compatibility with Tsukihime Effect Manager script
   -> built in compatibility with Formar extra trait lv up script
   -> built in compatibility with yanfly adjust limit

   2) put this script BELOW yanfly victory aftermath
   
 HOW TO USE:
 1) by plugging this script automatically...
    - subclass gain exp (default sub_exp_rate is using what you defined in config)
    - subclass's skill and trait gained by actor
    - subclass's effect is executed (if using tsukihime effect manager)
    
 2) you can set a class max level by notetagging the class with:

    <class_max_lv: 20> 
    to set the class max lv to 20. change the number as you want.

 3) to customize each class to have different sub exp rate. give the class

    <sub_exp_rate: 50>
    to set the class sub exp rate to 50%.  change the number as you want.
    
    support float percentage. ex:
    
    <sub_exp_rate: 2.5>
    to set the class sub exp rate to 2.5%    
 
 4) you can give sub_exp_rate modifier by notetagging:
    actor / class / subclass / weapon / armor / state
    
    <sub_exp_mod: 30> means +30% increase to sub exp rate

    it's direct addition so if current sub_exp_rate is 50% it will become 80%
    support negative value too
    
    <sub_exp_mod: -30> means -30% decrease to sub exp rate
    
    it's direct substraction so if current sub_exp_rate is 50% it will become 20%
    ALL sub exp rate modifier STACKS
    so example current sub exp rate 50%
    actor +10%, class -5%, subclass -5%, weapon +100%, armor1 -10%, armor2 -5%, state1 10%, state2 - 10%
    final rate = (50%) +10% -5% -5% +100% -10% -5% +10% + 10%
    count it yourself :D.
 
 5) you can give sub_exp_rate multiplier by notetagging:
    actor / class / subclass / weapon / armor / state
    
    <sub_exp_mult: 150> means sub exp rate multiplied by 150%

    it's multiplication so if current sub_exp_rate is 50% it will become 75%
    current sub_exp rate is sub exp rate after adding sub_exp_mod
    ALL sub exp rate multiplier STACKS
    so example current sub exp rate 50% (after adding exp_mod)
    actor *150%, class *50%, subclass *500%, weapon *125%, armor1 *250%, armor2 *105%, state1 *410%, state2 *310%
    final rate = (50%) * 150% * 500% * 125% * 250% * 105% * 410% * 310%
    count it yourself :D.

 6) to customize each class to have different main exp rate. give the class

    <main_exp_rate: 50>
    to set the class main exp rate to 50%.  change the number as you want.
    
    support float percentage. ex:
    
    <main_exp_rate: 2.5>
    to set the class main exp rate to 2.5%    
 
 7) you can give main_exp_rate modifier by notetagging:
    actor / class / subclass / weapon / armor / state
    
    <main_exp_mod: 30> means +30% increase to main exp rate

    it's direct addition so if current main_exp_rate is 50% it will become 80%
    support negative value too
    
    <main_exp_mod: -30> means -30% decrease to main exp rate
    
    it's direct substraction so if current main_exp_rate is 50% it will become 20%
    ALL main exp rate modifier STACKS
    so example current main exp rate 50%
    actor +10%, class -5%, subclass -5%, weapon +100%, armor1 -10%, armor2 -5%, state1 10%, state2 - 10%
    final rate = (50%) +10% -5% -5% +100% -10% -5% +10% + 10%
    count it yourself :D.
 
 8) you can give main_exp_rate multiplier by notetagging:
    actor / class / subclass / weapon / armor / state
    
    <main_exp_mult: 150> means main exp rate multiplied by 150%

    it's multiplication so if current main_exp_rate is 50% it will become 75%
    current main_exp rate is main exp rate after adding main_exp_mod
    ALL main exp rate multiplier STACKS
    so example current main exp rate 50% (after adding exp_mod)
    actor *150%, class *50%, subclass *500%, weapon *125%, armor1 *250%, armor2 *105%, state1 *410%, state2 *310%
    final rate = (50%) * 150% * 500% * 125% * 250% * 105% * 410% * 310%
    count it yourself :D.
    
interesting play with subexpmod and subexpmult...
create a subclass only which have no growth in subclass. but after equipping
some accessory that increase subexpmod. it will have some growth and raised lv.
could create a weapon/armor which is strong but subexpmult = 0%. so no growth.    

#------------------------------------------------------------------------------
=end

module ESTRIOLE
  SUB_EXP_RATE = 50   #default sub exp rate (in percentage so 50 means 50% exp,
                      #200 means 200% exp. etc). when no notetags set for that class
  MAIN_EXP_RATE = 100 #default MAIN exp rate (in percentage so 50 means 50% exp,
                      #200 means 200% exp. etc). when no notetags set for that class
                      #better to leave it at 100%
  SUBCLASS_VOCAB = "Subclass"
  SUBCLASS_MIN_1_EXP = true #if true minimum 1 exp gained when the result exp x sub exp rate is between 0 - 1
  
  module VICTORY_AFTERMATH
  VICTORY_SUB_EXP  = "+%sSUBEXP"      # Text used to display SUB EXP. IF USING YANFLY VICTORY AFTERMATH SCRIPT
  end

end

class RPG::BaseItem
  def sub_exp_mod
    return nil if !@note[/<sub_exp_mod:(.*)>/i]
    a = @note[/<sub_exp_mod:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0].to_f
  end    
  def sub_exp_mult
    return nil if !@note[/<sub_exp_mult:(.*)>/i]
    a = @note[/<sub_exp_mult:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0].to_f
  end    
  def main_exp_mod
    return nil if !@note[/<main_exp_mod:(.*)>/i]
    a = @note[/<main_exp_mod:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0].to_f
  end    
  def main_exp_mult
    return nil if !@note[/<main_exp_mult:(.*)>/i]
    a = @note[/<main_exp_mult:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0].to_f
  end    
end
#Notetags ability to set max level for each class instead of using actor max_lv
class RPG::Class < RPG::BaseItem
  def max_level
    return nil if !@note[/<class_max_lv:(.*)>/i]
    a = @note[/<class_max_lv:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0].to_i
  end
  def sub_exp_rate
    return nil if !@note[/<sub_exp_rate:(.*)>/i]
    a = @note[/<sub_exp_rate:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0].to_f
  end  
  def main_exp_rate
    return nil if !@note[/<main_exp_rate:(.*)>/i]
    a = @note[/<main_exp_rate:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0].to_f
  end  
end

class Game_Actor < Game_Battler
  def main_exp_rate(class_id)
    exprate = $data_classes[class_id].main_exp_rate ? $data_classes[class_id].main_exp_rate * 0.01 : ESTRIOLE::MAIN_EXP_RATE  * 0.01
    exprate = (exprate + main_exp_mod) * main_exp_mult
    exprate = [exprate,0].max #disallow negative exp rate
  end
  def main_exp_mod
    actormod = (self.actor.main_exp_mod ? self.actor.main_exp_mod : 0) rescue 0
    classmod = (self.class.main_exp_mod ? self.class.main_exp_mod : 0) rescue 0
    subclassmod = (self.subclass.main_exp_mod ? self.subclass.main_exp_mod : 0) rescue 0
    equipsmod = 0
    equips.each do |equip|
      next if !equip
      equipsmod += equip.main_exp_mod if equip.main_exp_mod
    end    
    statesmod = 0
    states.each do |state|
      statesmod += state.main_exp_mod if state.main_exp_mod
    end
    return main_exp_mod = (actormod + classmod + subclassmod + equipsmod + statesmod) * 0.01
  end
  def main_exp_mult
    actor_mult = (self.actor.main_exp_mult ? self.main_exp_mult * 0.01 : 1) rescue 1
    class_mult = (self.class.main_exp_mult ? self.class.main_exp_mult * 0.01 : 1) rescue 1
    subclass_mult = (self.subclass.main_exp_mult ? self.subclass.main_exp_mult * 0.01 : 1) rescue 1
    equips_mult = 1
    equips.each do |equip|
      next if !equip
      equips_mult = equips_mult * equip.main_exp_mult * 0.01 if equip.main_exp_mult
    end    
    states_mult = 1
    states.each do |state|
      states_mult = states_mult * state.main_exp_mult * 0.01 if state.main_exp_mult
    end
    return main_exp_mult = actor_mult * class_mult * subclass_mult * equips_mult * states_mult
  end
  
  def sub_exp_rate(class_id)
    exprate = $data_classes[class_id].sub_exp_rate ? $data_classes[class_id].sub_exp_rate * 0.01 : ESTRIOLE::SUB_EXP_RATE  * 0.01
    exprate = (exprate + sub_exp_mod) * sub_exp_mult
    exprate = [exprate,0].max #disallow negative exp rate
  end
  def sub_exp_mod
    actormod = (self.actor.sub_exp_mod ? self.actor.sub_exp_mod : 0) rescue 0
    classmod = (self.class.sub_exp_mod ? self.class.sub_exp_mod : 0) rescue 0
    subclassmod = (self.subclass.sub_exp_mod ? self.subclass.sub_exp_mod : 0) rescue 0
    equipsmod = 0
    equips.each do |equip|
      next if !equip
      equipsmod += equip.sub_exp_mod if equip.sub_exp_mod
    end    
    statesmod = 0
    states.each do |state|
      statesmod += state.sub_exp_mod if state.sub_exp_mod
    end
    return sub_exp_mod = (actormod + classmod + subclassmod + equipsmod + statesmod) * 0.01
  end
  def sub_exp_mult
    actor_mult = (self.actor.sub_exp_mult ? self.sub_exp_mult * 0.01 : 1) rescue 1
    class_mult = (self.class.sub_exp_mult ? self.class.sub_exp_mult * 0.01 : 1) rescue 1
    subclass_mult = (self.subclass.sub_exp_mult ? self.subclass.sub_exp_mult * 0.01 : 1) rescue 1
    equips_mult = 1
    equips.each do |equip|
      next if !equip
      equips_mult = equips_mult * equip.sub_exp_mult * 0.01 if equip.sub_exp_mult
    end    
    states_mult = 1
    states.each do |state|
      states_mult = states_mult * state.sub_exp_mult * 0.01 if state.sub_exp_mult
    end
    return sub_exp_mult = actor_mult * class_mult * subclass_mult * equips_mult * states_mult
  end
  
# buxfix for yanfly class level method. i make it read the 'max level' from database
  def class_level(class_id)
  return @level if YEA::CLASS_SYSTEM::MAINTAIN_LEVELS
  temp_class = $data_classes[class_id]
  @exp[class_id] = 0 if @exp[class_id].nil?
  max_lv = temp_class.max_level == nil ? actor.max_level : temp_class.max_level 
  maxlv_exp = temp_class.exp_for_level(max_lv)
  #below part is taken from bugfix by disturbed inside
    n = 1
    loop do
    break if temp_class.exp_for_level(n+1) > @exp[class_id]
    n += 1
    #add a restriction to “kick out” of loop if exp exceeds max level exp
    break if temp_class.exp_for_level(n+1) > maxlv_exp
    end
  return n
  #end bugfix by disturbed inside here
  end  
  
# patch for max level using class max level instead of using actor (if notetags exist)
  alias est_yan_game_actor_max_level max_level
  def max_level
    return $data_classes[@class_id].max_level if $data_classes[@class_id].max_level != nil 
    return est_yan_game_actor_max_level
  end
  def subclass_max_level
    return 0 if @subclass_id == 0
    return $data_classes[@subclass_id].max_level if $data_classes[@subclass_id].max_level != nil 
    return actor.max_level
  end
  
# to prevent initial level more than initial class max level
  alias est_yan_game_actor_setup setup
  def setup(actor_id)
    est_yan_game_actor_setup(actor_id)
    if $data_classes[@class_id].max_level
    @level = [actor.initial_level,$data_classes[@class_id].max_level].min
    init_exp
    init_skills
    clear_param_plus
    recover_all
    end
  end
  
# new method to add exp to subclass  
  def subclass_add_exp(class_id,value)
    return if !@subclass_id
    return if @subclass_id == 0
    return if YEA::CLASS_SYSTEM::MAINTAIN_LEVELS
    last_level = class_level(class_id).to_i
    last_skills = skills
    exprate = sub_exp_rate(class_id)
    expvalue = (value * exprate).to_i
    expvalue = [expvalue,1].max if ESTRIOLE::SUBCLASS_MIN_1_EXP && value != 0
    @exp[class_id] = @exp[class_id] + expvalue
    @exp[class_id] = [@exp[class_id],subclass.exp_for_level(subclass_max_level)].min
      #learn skill if sub level can learn it
      self.subclass.learnings.each do |learning|
        learn_skill(learning.skill_id) if learning.level <= class_level(class_id).to_i
           # formar extra traits lv up patch
           if @extra_features && class_level(class_id).to_i > last_level && learning.note =~ /<extratrait (.*)>/i
            @extra_features.features += $data_weapons[$1.to_i].features if EXTRA_FEATURES_SOURCE == 0
            @extra_features.features += $data_armors[$1.to_i].features if EXTRA_FEATURES_SOURCE == 1
            @extra_features.features += $data_states[$1.to_i].features if EXTRA_FEATURES_SOURCE == 2
           end 
           #end formar extra traits lv up patch
        end
    # display subclass level up msg
    display_level_up_sub(skills - last_skills) if class_level(class_id).to_i > last_level
  end
  
# new method subclass -> to get data classes of subclass  
  def subclass
    @subclass_id = 0 if @subclass_id.nil?
    $data_classes[@subclass_id]
  end

# to make subclass traits works...
  alias est_yan_subclass_feature_objects feature_objects
  def feature_objects
    return est_yan_subclass_feature_objects + [self.subclass] if @subclass_id && @subclass_id != 0
    return est_yan_subclass_feature_objects
  end

# compatibility patch with tsukihime effect manager. so you can have subclass
# that can give you 'effects'
  if $imported["Effect_Manager"]
    alias est_yan_hime_effect_objects effect_objects
    def effect_objects
      return est_yan_hime_effect_objects + [self.subclass] if @subclass_id && @subclass_id != 0
      return est_yan_hime_effect_objects
    end
  end
  
# new method to display level up when subclass level  
  def display_level_up_sub(new_skills)
    return if !@subclass_id || @subclass_id == 0
    level_sub = class_level(@subclass_id).to_i
    $game_message.new_page
    temp = ESTRIOLE::SUBCLASS_VOCAB
    text = "%s's %s now reached %s %s!"
    text = "%s's %s now reached\n%s %s!" if SceneManager.scene_is?(Scene_Battle)
    $game_message.add(sprintf(text, @name, temp ,Vocab::level ,level_sub))
    new_skills.each do |skill|
      $game_message.add(sprintf(Vocab::ObtainSkill, skill.name))
    end
  end

  #patch compatibility to yanfly adjust limit
  if $imported["YEA-AdjustLimits"] == true
  def param_base(param_id)
    result = game_actor_param_base_cs(param_id)
    unless subclass.nil?
      subclass_rate = YEA::CLASS_SYSTEM::SUBCLASS_STAT_RATE
      slevel = subclass_level
      result += subclass.params[param_id, slevel] * subclass_rate if slevel <= 99
      result += subclass.above_lv99_params(param_id, slevel) * subclass_rate if slevel > 99
    end
    return result.to_i
  end
  end
    
# alias method gain exp to also gain subclass exp. 
# before i use change_exp. but then i realize it will break when using change_level method
# so i use gain_exp method instead. but... gain_exp only occur when you get exp
# from enemy/battle. and not working for event command that grant exp. so i also
# alias command_315 to handle that. 
# so basically battle use gain_exp method, event use command_315 method.
  alias est_yan_gain_exp gain_exp
  def gain_exp(exp,enabled = false)
    new_exp = (exp * main_exp_rate(@class_id) * final_exp_rate).to_i
    new_exp = [new_exp,1].max if ESTRIOLE::SUBCLASS_MIN_1_EXP && exp != 0
    max_exp = self.class.exp_for_level(max_level) - self.exp
    new_exp = [new_exp,max_exp].min
    est_yan_gain_exp(new_exp)
    subclass_add_exp(@subclass_id,exp) if @subclass_id
  end

end

class Game_Interpreter
  #Overwrite command_315 to make it also gain subclass exp. read gain_exp comment.:D
  #have to overwrite to implement main exp rate which SEPARATED with sub exp rate
  #so increasing main sub exp rate didn't raise sub exp gained.
  def command_315
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      new_value = (value * actor.main_exp_rate(actor.class.id) * actor.final_exp_rate).to_i
      new_value = [new_value,1].max if ESTRIOLE::SUBCLASS_MIN_1_EXP && value != 0
      new_value = actor.exp + new_value
      max_exp =  actor.class.exp_for_level(actor.max_level)
      new_value = [new_value,max_exp].min
      actor.change_exp(new_value, @params[5])
    end
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.subclass_add_exp(actor.subclass.id, value * actor.final_exp_rate) if actor.subclass
    end
  end
end


#yanfly aftermath exp rate patch
class Window_VictoryEXP_Back < Window_Selectable
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, fitting_height(1), Graphics.width, window_height)
    self.z = 200
    self.openness = 0
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    return Graphics.height - fitting_height(4) - fitting_height(1)
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max; return item_max; end
  
  #--------------------------------------------------------------------------
  # spacing
  #--------------------------------------------------------------------------
  def spacing; return 8; end
  
  #--------------------------------------------------------------------------
  # item_max
  #--------------------------------------------------------------------------
  def item_max; return $game_party.battle_members.size; end
  
  #--------------------------------------------------------------------------
  # open
  #--------------------------------------------------------------------------
  def open
    @exp_total = $game_troop.exp_total
    super
  end
  
  #--------------------------------------------------------------------------
  # item_rect
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = contents.height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = index / col_max * item_height
    return rect
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.battle_members[index]
    return if actor.nil?
    rect = item_rect(index)
    reset_font_settings
    draw_actor_name(actor, rect)
    draw_exp_gain(actor, rect)
    draw_sub_exp_gain(actor, rect)
    draw_jp_gain(actor, rect)
    draw_actor_face(actor, rect)
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_name
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, rect)
    name = actor.name
    draw_text(rect.x, rect.y+line_height, rect.width, line_height, name, 1)
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_face
  #--------------------------------------------------------------------------
  def draw_actor_face(actor, rect)
    face_name = actor.face_name
    face_index = actor.face_index
    bitmap = Cache.face(face_name)
    rw = [rect.width, 96].min
    face_rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, rw, 96)
    rx = (rect.width - rw) / 2 + rect.x
    contents.blt(rx, rect.y + line_height * 2, bitmap, face_rect, 255)
  end
  
  #--------------------------------------------------------------------------
  # draw_exp_gain
  #--------------------------------------------------------------------------
  def draw_exp_gain(actor, rect)
    dw = rect.width - (rect.width - [rect.width, 96].min) / 2
    dy = rect.y + line_height * 2 + 96
    fmt = YEA::VICTORY_AFTERMATH::VICTORY_EXP
    text = sprintf(fmt, actor_exp_gain(actor).group)
    contents.font.size = YEA::VICTORY_AFTERMATH::FONTSIZE_EXP
    change_color(power_up_color)
    draw_text(rect.x, dy, dw, line_height, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # actor_exp_gain
  #--------------------------------------------------------------------------
  def actor_exp_gain(actor)
    n = @exp_total * actor.main_exp_rate(actor.class.id) * actor.final_exp_rate
    return n.to_i
  end
  
  def actor_sub_exp_gain(actor)
    return nil if !actor.subclass
    n = @exp_total * actor.sub_exp_rate(actor.subclass.id) * actor.final_exp_rate
    return n.to_i
  end

  def draw_sub_exp_gain(actor, rect)
    return if !actor_sub_exp_gain(actor)
    return if YEA::CLASS_SYSTEM::MAINTAIN_LEVELS
    dw = rect.width - (rect.width - [rect.width, 96].min) / 2
    dy = rect.y + line_height * 4 + 96
    fmt = ESTRIOLE::VICTORY_AFTERMATH::VICTORY_SUB_EXP
    text = sprintf(fmt, actor_sub_exp_gain(actor).group)
    contents.font.size = YEA::VICTORY_AFTERMATH::FONTSIZE_EXP
    change_color(power_up_color)
    draw_text(rect.x, dy, dw, line_height, text, 2)
  end
  
  
  #--------------------------------------------------------------------------
  # draw_jp_gain
  #--------------------------------------------------------------------------
  def draw_jp_gain(actor, rect)
    return unless $imported["YEA-JPManager"]
    dw = rect.width - (rect.width - [rect.width, 96].min) / 2
    dy = rect.y + line_height * 0
    fmt = YEA::JP::VICTORY_AFTERMATH
    text = sprintf(fmt, actor_jp_gain(actor).group, Vocab::jp)
    contents.font.size = YEA::VICTORY_AFTERMATH::FONTSIZE_EXP
    change_color(power_up_color)
    draw_text(rect.x, dy, dw, line_height, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # actor_jp_gain
  #--------------------------------------------------------------------------
  def actor_jp_gain(actor)
    n = actor.battle_jp_earned
    if actor.exp + actor_exp_gain(actor) > actor.exp_for_level(actor.level + 1)
      n += YEA::JP::LEVEL_UP unless actor.max_level?
    end
    return n
  end
  
end # Window_VictoryEXP_Back

class Window_VictoryEXP_Front < Window_VictoryEXP_Back  
  def draw_item(index)
    actor = $game_party.battle_members[index]
    return if actor.nil?
    rect = item_rect(index)
    draw_actor_exp(actor, rect)
    draw_actor_sub_exp(actor, rect)
  end
  def draw_actor_exp(actor, rect)
    if actor.max_level?
      draw_exp_gauge(actor, rect, 1.0)
      return
    end
    total_ticks = YEA::VICTORY_AFTERMATH::EXP_TICKS
    bonus_exp = actor_exp_gain(actor) * @ticks / total_ticks
    now_exp = actor.exp - actor.current_level_exp + bonus_exp
    next_exp = actor.next_level_exp - actor.current_level_exp
    rate = now_exp * 1.0 / next_exp
    draw_exp_gauge(actor, rect, rate)
  end
  
  def draw_actor_sub_exp(actor, rect)
    return if !actor.subclass
    return if YEA::CLASS_SYSTEM::MAINTAIN_LEVELS
    rect.y += line_height * 2
    if actor.subclass_level == actor.subclass_max_level
      draw_sub_exp_gauge(actor, rect, 1.0)
      return
    end
    total_ticks = YEA::VICTORY_AFTERMATH::EXP_TICKS
    bonus_exp = actor_sub_exp_gain(actor) * @ticks / total_ticks
    now_exp = actor.exp[actor.subclass.id] - actor.subclass.exp_for_level(actor.subclass_level) + bonus_exp
    next_exp = actor.subclass.exp_for_level(actor.subclass_level+1) - actor.subclass.exp_for_level(actor.subclass_level)
    rate = now_exp * 1.0 / next_exp
    draw_sub_exp_gauge(actor, rect, rate)
  end
  def draw_exp_gauge(actor, rect, rate)
    rate = [[rate, 1.0].min, 0.0].max
    dx = (rect.width - [rect.width, 96].min) / 2 + rect.x
    dy = rect.y + line_height * 1 + 96
    dw = [rect.width, 96].min
    colour1 = rate >= 1.0 ? lvl_gauge1 : exp_gauge1
    colour2 = rate >= 1.0 ? lvl_gauge2 : exp_gauge2
    draw_gauge(dx, dy, dw, rate, colour1, colour2)
    fmt = YEA::VICTORY_AFTERMATH::EXP_PERCENT
    text = sprintf(fmt, [rate * 100, 100.00].min)
    if [rate * 100, 100.00].min == 100.00
      text = YEA::VICTORY_AFTERMATH::LEVELUP_TEXT
      text = YEA::VICTORY_AFTERMATH::MAX_LVL_TEXT if actor.max_level?
    end
    draw_text(dx, dy, dw, line_height, text, 1)
  end
  def draw_sub_exp_gauge(actor, rect, rate)
    rate = [[rate, 1.0].min, 0.0].max
    dx = (rect.width - [rect.width, 96].min) / 2 + rect.x
    dy = rect.y + line_height * 1 + 96
    dw = [rect.width, 96].min
    colour1 = rate >= 1.0 ? lvl_gauge1 : exp_gauge1
    colour2 = rate >= 1.0 ? lvl_gauge2 : exp_gauge2
    draw_gauge(dx, dy, dw, rate, colour1, colour2)
    fmt = YEA::VICTORY_AFTERMATH::EXP_PERCENT
    text = sprintf(fmt, [rate * 100, 100.00].min)
    if [rate * 100, 100.00].min == 100.00
      text = YEA::VICTORY_AFTERMATH::LEVELUP_TEXT
      text = YEA::VICTORY_AFTERMATH::MAX_LVL_TEXT if actor.subclass_level == actor.subclass_max_level
    end
    draw_text(dx, dy, dw, line_height, text, 1)
  end
end # Window_VictoryEXP_Front