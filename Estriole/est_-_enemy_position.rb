$imported = {} if $imported.nil?
$imported["EST - ENEMY POSITION"] = true
=begin
==============================================================================
 ** EST - ENEMY POSITION v3.4   

 (front row, back row, underground, underwater, flying, custom scope)
------------------------------------------------------------------------------
 Author             : ESTRIOLE
 Usage Level        : Easy
 Modification level : Easy
 
 licences:
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE).
 
 also credits to TSUKIHIME since i use his target scope script as my target
 scope base (in early version) and some helping from him/her to adjust it to my need. 
 and his/her advice after v 1.4 finish which made me rewrite the whole script.
 
 another credits to DoubleX for his patch to auto battle actor.
 
 modification for your own usage is permitted just don't claim this is yours
 just add below the author: Modded by : ....
 
 Version History:
  v 3.4 - 2015.08.25 > -  another bug on custom_smooth_target (again... c'mon >.<)
                          if having skill that target one ally which using 
                          scope_condition... it will messed the index
  v 3.3 - 2015.02.10 > -  compatibility patch to Euphoria threat system 1.4 script
  v 3.2 - 2014.08.08 > -  fix another bug with custom_smooth_target
                       -  add compatibility with EST - BRIBE AND BATTLE ROYALE SCRIPT
  v 3.1 - 2014.02.12 > -  added patch by DoubleX for auto battle actor.
  v 3.0 - 2013.05.28 > -  version increased by a lot because this is quite major update
                       -  fix bug with custom_smooth_target.
                       -  compatibility with moghunter battle cursor
                       -  added scope_condition feature. this script can work with 
                          custom scope condition. 
                          you could notetags:
                          <scope_cond>
                          b.name[/slime/i] 
                          </scope_cond>
                          to make skill that only target enemy containing 'slime' in
                          the name. need to be careful since notetags box is small.
                          using this new feature make we easily create 'new' scope.
                          search
                          "NEW FEATURE FROM v.3.0"
                          for detail
                       -  added scope description text when using yanfly ace battle engine
                          you can set the chosen item/skill to shown custom text rather than 
                          using "All Foes". give notetags to the skill/item:
                          <scope_desc>
                          All Enemy You Hate 
                          </scope_desc>
                          it will shown "All Enemy You Hate" if the skill/item scope is for_all?
                          this used as combo with scope condition
                          
  v 2.3 - 2013.03.29 > -  patch for enemy will pick skill that have valid target
                          if they have it instead picking skill that don't have target.
  v 2.2 - 2013.03.15 > -  add ability to modify any ALL scope to become random with numbers of target
                          you specify. ex: you set the scope to ALL BACKROW ENEMIES
                          then you give notetags <random: 3>
                          it will become skill that attack 3 random backrow enemies
                          search
                          "NEW FEATURE FROM v.2.2"
                          for detail
                            
  v 2.1 - 2013.03.14 > -  add configuration to disable the skill/item and attack command
                          when NO VALID TARGET for that skill. i put the configuration in the top most of the module
  v 2.0 - 2013.01.23 > -  fix the M range. it's been long time i play that and forgot how it work.
  v 1.9 - 2013.01.16 > -  fix bug if subclass is nil
  v 1.8 - 2013.01.11 > -  add compatibility patch for yanfly weapon attack replace
                     >    with yanfly class system to able use sublass attack skill
  v 1.7 - 2012.10.01 > -  add more scopes like suikoden series (including gun)
                     > -  bugfix to yea attack replace patch that ignore the
                     >    notetags at actors
  v 1.6 - 2012.09.20 > -  fix bug with dead friend issues
  v 1.5 - 2012.09.09 > -  Completely rewrite the whole script from the window,
                     >    scopes, compatibility patch. but i guess now it really
                     >    compatible with other scripts. and it become so easy to
                     >    add more scope (ex: hit front and underwater?)
                     > -  Added item support for scopes. now you can tag item
                     >    to have the same scope with skills. means... net item
                     >    available now.
                     > -  Added item / skill for friend support. you can now use
                     >    skill that hit your front row only or back row only
                     > -  Added more scope (friend related)
                     > -  Several bugfix again since i rewritten this scipt
                     > -  Removed the switch requirement
                     > -  Since rewrite. script become only exact 1000 lines
                     >    (ok i cheated a little at bottom). but have more function. this
                     >    shows how modular/abstract thing is better than hardcode
                     >    (quoting Tsukihime)
  v 1.4 - 2012.09.08 > -  removed the necessary to put the the skill id to array
                     > now only need to put scope tag instead
                     > -  script level downgraded to easy now
                     > -  add scopes to hit front row and back row (either row)
                     > -  some logical bugfix for underground smooth target
                     > -  add some bugfix when no yanfly script presents. when
                     > using skills without selection. even though no valid enemy
                     > exist. actor skill can select the skills and waste his 
                     > precious turn hitting nothing.
                     > -  some minor bugfix with either attack[all] can still selected
                     > after using all skill that have valid target.
                     > -  add patch for yanfly attack replace script with bugfix
                     > to make the script work correctly (original has bugs
                     > when equiping weapon without notetags your attack skill
                     > is default regardless your class/actor attack skill
                     > -  change the arrangement of yanfly attack replace priority 
                     > from : weapon > actor > class to weapon > class > actor
                     > since it's more make sense. warrior hit using short range
                     > archer long range, etc.
  v 1.3 - 2012.09.07 > -  Add three more position : flying, underwater, underground
                     > -  several scope targeting bugfix
                     > -  some switch bugfix
                     > -  make the all front row skill to be able to target back row when
                     > no more front row enemy
                     > -  make the same with all back row skill and make suikoden style permanent
                     > -  hopefully remove all bugs
  v 1.2 - 2012.09.06 > -  Fixed bug that make editor single enemy scope to only
                     > show front row only target
                     > -  Added Yanfly Battle Engine v1.22 patch
                     > -  Added Yanfly Enemy HP Bars v1.10 patch
                     > -  Fixed some visual bugs
  v 1.1 - 2012.09.05 > -  Manage to fix the scope
  v 1.0 - 2012.09.04 > -  First release
  
------------------------------------------------------------------------------
  This script is to make certain enemies (using state) cannot be selected as 
  target by normal attack / skill. only certain skill can (and if you use yanfly
  attack replace script. certain actor can select it too with normal attack.
  in this version there's also flying, underwater, underground state + suikoden
  series attack range.
------------------------------------------------------------------------------
 Feature
 - FROM 3.0 above. CAN SET CUSTOM SCOPE CONDITION
 - can set enemy front row / back row using states
 - can set enemy flying, underwater, underground using states
 - can make suikoden attack range *new in 1.7
 - can make skill to attack only front row[single]
 - can make skill to attack only front row[all]
 - can make skill to attack only back row[single]
 - can make skill to attack only back row[all]
 - can make skill to attack only flying[single]
 - can make skill to attack only flying[all]
 - can make skill to attack only underwater[single]
 - can make skill to attack only underwater[all]
 - can make skill to attack only underground[single]
 - can make skill to attack only underground[all]
 - can make skill to attack both row[single]
 - can make skill to attack both row[all] (all skills see advanced instructions)
 - NOW CAN make RANDOM Skill
 - have good algorithm for the scopes so when enemy dead before you hit it will 
   search only next valid target.
 - prevent player to select non valid targets
 - prevent player to waste his action (except if the dead enemy before strike
   situation)
 - you add it yourself... don't know what to add again :D.

 Compatibility
 - almost all script (i use yanfly, victor, moghunter, etc total about 120++ scripts) 
 - and i especially tailor this to compatible with yanfly battle system since majority
   use that scripts.
 - also made compatibility to yanfly enemy hp bar
 
 Instructions:
  To instal the script, open you script editor and paste this script on
  a new section on bellow the Materials section. This script best put below
  other script(especially battle script)
  
 Advanced Instructions:
 1) to make the enemy have position
  set the module estriole for configuration for the states.
  then in database editor troops tab. set to add the state at beginning of battle. 
  YES set them for every troop you have.
  back row - just add back row state
  flying - just add flying state
  underwater - just add underwater state
  underground - just add underground state
  the enemy could also use skills that add those state. and after use the state
  the position will treated like the state(immediately). just make sure they don't add two state
  such as back row + flying, flying + underwater, flying + underground. maybe i will
  make add on later so the states are unique.
  
  and once again YES... it's manual. except you want to make your own script to flag the
  enemy back row / flying and add the state at battle start. or use other scripter script
  i think i have seen victor script something like that (state-auto-apply). but
  i have no idea about the compatibility since i don't use the script (not compatible
  with my battlesystem script)
 
 2) since this is state related you can custom the state example underwater state
    weak to electric attack, etc.
    if you want to make dig, float, dive state (after 3 turn disappear). just add
    those state in coresponding state array ex : dig in underground array
    then add the automatic timed released to remove after 3 turn and after battle
  
 3) finally the most important parts
    this is the step to set the skills that you want.
    all this is using default scope setting without modifying the configuration
    if you modify it you have to take the risk yourself. since i set
    the scope high number i guess it won't have incompatibility with tsukihime
    target-scope script and no need to change. now let's get to the point...
    
    first note: only front row and back row have swap ability. other state is not.

    a) skill that can hit front row only [single] (ex-sword normal attack)
       - add this notetags to the skill : <scope: 82>
       note:       
       edit : after adding flying, underwater, underground state i guess i will make
       the suikoden style permanent. meaning if no front row you can hit back row
       
       and if you want your normal attack cannot attack other position just set
       your normal attack to this.
        
    b) skill that can hit back row only [single] (ex skill that only attack back rows)
       - add this notetags to the skill : <scope: 81>
       note:
       edit : now also with suikoden style support. when no back row can hit
       front row
       
    c) skill that can hit front row only[all] (ex: one of suikoden rune skill that hit all front)
       - add this notetags to the skill : <scope: 84>
       note :
       hit all front rows. when no front row enemy it will hit back row
    d) skill that can hit back_row_only[all] (ex: suikoden rune skill that hit all back)   
      - add this notetags to the skill : <scope: 83>
      note : hit all back rows. when no back row enemy it will hit front row.
    e) skill that can attack flying_only[single] (ex:net skill to bring down the enemy)
      - <scope: 85>
    f) skill that can attack flying_only[all] (ex:turbulance that hit the flyings)
      - <scope: 86>
    g) skill that can attack underwater_only[single] (ex:fishing rod skill to pull the enemy to surface)
      - <scope: 87>
    h) skill that can attack underwater_only[all] (ex:Electric attack that shock all swimmers)
      - <scope: 88>
    i) skill that can attack underground_only[single] (ex:have no idea for this)
      - <scope: 89>
    j) skill that can attack underground_only[all] (ex:you fog the hole with poison so all underground poisoned)
      - <scope: 90>      
    k) skill that can attack front_row and back row[single] (ex:spear medium range weapon)
      - <scope: 91>      
    l) skill that can attack front_row and back row[all] (ex:earthquake that hit ground members)
      - <scope: 92>            
    k) skill that can hit all target [single] (ex: magic attack)  
       - basicly you just create regular skill that target single enemy.
    l) skill that can hit all front row and back row [all] (ex: magic area skill)
      - basicly you just create regular skill that target all enemies.
    m) for the new scope just basicly add the scope to the skill like above example  

  4) you can also use the back row or other state on your actor. the rule is the same
    just give the enemy appropriate skill setting in no3. but it's better not set it
    permanent.
 
 scope note :
 for easier access i provide the notetags for the skill to use(if you not change 
 the config of course). just add them in your skill notetags
 <scope: 81> -> one back enemy
 <scope: 82> -> one front enemy
 <scope: 83> -> all back enemy
 <scope: 84> -> all front enemy
 <scope: 85> -> one flying enemy
 <scope: 86> -> all flying enemy
 <scope: 87> -> one underwater enemy
 <scope: 88> -> all underwater enemy
 <scope: 89> -> one underground enemy
 <scope: 90> -> all underground enemy
 <scope: 91> -> one either row enemy
 <scope: 92> -> all either row enemy
 <scope: 93> -> one back ally
 <scope: 94> -> one front ally
 <scope: 95> -> all back ally
 <scope: 96> -> all front ally
 <scope: 97> -> one enemy - short range weapon suikoden style 
 <scope: 98> -> one enemy - mid range weapon suikoden style
 <scope: 99> -> one enemy - long range weapon suikoden style + hit flying (gun)
 <scope: 100> -> all enemy - short range weapon suikoden style
 <scope: 101> -> all enemy - mid range weapon suikoden style
 <scope: 102> -> all enemy - long range weapon suikoden style + hit flying (gun)
 
 new scope series: suikoden style
 short -> if actor at front row hit front row. if at back row hit nothing
 mid -> if actor at front row hit front row. if at back row hit front row
 long -> hit either row + flying (gun)
 
 what the difference front row and short range?
 front row will hit front row enemy anytime (best used as skill)
 short range will hit front row enemy only when actor not at back row 
 (best used as weapon attack skill)
 
 if you want skill that hit all just use the editor instead.
 notes: since now easy to add scopes. request is welcome. just post in the forum
 what the scope you want. ex: the one i currently have in plan = gun_attack
 can hit front row, back row, flying.
   
 NEW FEATURE FROM v.2.2
 you could make skill/item that attack X random POS Enemy.
 X -> number of target    POS -> backrow / frontrow / flying / etc
 how to do that?
 1) first make that skill to attack ALL X Position. Example attack ALL FLYING ENEMY
 use notetags: <scope: 86>
 2) give notetags to make it random plus how many random target it will attack.
 example you want it to attack 3 random flying enemy
 use notetags: <random: 3>
 then in the skill will contain notetags:
 <scope: 86>
 <random: 3>
 it will make the skill attack 3 random flying enemies.
 I also make compatibility patch for yanfly ace battle engine to show
 X Random POS Enemies in the help text.
 
 also note this use default random targeting. so if you set it to 4 random enemies
 while your damage is one hit kill. you might hit less than 4 enemies.
 because the targetting work like this
 hit 1: enemy A
 hit 2: enemy B
 hit 3: enemy A
 hit 4: enemy A
 but enemy A dies in first hit. so you'll only score 2 hit.
 if anyone write more good random target script. i could write compatibility patch
 for using that.
 
 NEW FEATURE FROM v.3.0
 -  added scope_condition feature. this script can work with  custom scope condition. 
  give the skill/item notetags:
  <scope_cond>
  your condition here
  </scope_cond>
  I also assign some variable to shorten the writing:
  a -> user
  b -> target
  o -> user opponent
  f -> user friend
  s -> switch
  v -> variable

  |> WARNING PREMADE SCOPE HAS HIGHER PRIORITY THAN SCOPE CONDITION. so if you want
  to use scope condition. don't use <scope: x> feature.
  
  |> you could change the area of effect to switch target from friend or foe...
  |> you could change the area of effect to switch target from single or all...

  it's better to put
    b.alive? &&
  as the first line condition if your skill target alive target only..... 
  since if not it will also able to target dead member as well.
  why i'm not adding it automatically. since there's possibility that we want
  to target dead target (revive it perhaps). also mix of dead and alive target.
  (ex: miracle skill that heal all living and revived dead to full hp)

  example condition usage:
  <scope_cond>
  b.id == 2 &&
  b.id == 1
  </scope_cond>
  means that item/skill will only target OBJ that
  the first and second id in database...
  if area of effect single enemy -> target one enemy that match the condition
  if area of effect all enemy -> target all enemy that match the condition
  if area of effect single ally -> target one ally that match the condition
  if area of effect single ally -> target all allies that match the condition
  also if you realize i create .id method for game_enemy. so it won't crash
  if the skill used by enemy too.

  some interesting idea: hate slayer. slay the target that the [actor/enemy] hate  
  i use case syntax in this condition
  <scope_cond>
  !b.state?(1) &&
  case a.id
  when 1; b.name[/slime/i]
  when 2; b.name[/mimic/i]
  when 3; b.name[/rate/i]
  else; b.name[/hornet/i]
  end
  </scope_cond> 
  means: first the target must NOT dead(alive)
  then [actor/enemy] 1 will able to target [actor/enemy] contain 'slimes' in the name
  then [actor/enemy] 2 will able to target [actor/enemy] contain 'mimic' in the name
  then [actor/enemy] 3 will able to target [actor/enemy] contain 'rate' in the name
  then other [actor/enemy] will able to target [actor/enemy] contain 'hornet' in the name
  
  if you want real complex filter. then you can create method in game_battler.
  you can pass the a, b, o, f, s, v in the method (if neccessary).

 Known Bugs:
  TELL ME if there's a bug and i'll try to fix it.
 Future plan:
 tell me
 
 SCRIPTER LOG 
 decide to delete the scripter log. since made real major changes in this script
#------------------------------------------------------------------------------
=end
module ESTRIOLE
################################################################################
#  - CONFIGURATION PART
################################################################################
  #DISABLE SKILL IF NO VALID TARGET MODE
  DISABLE_SKILL_IF_NO_VALID_TARGET = true

  #if above set to true. the skill will be disabled when no valid target. 
  #if false. the skill not disabled but will show no valid target warning (old mode)

  #WARNING ALL STATE ARRAY MUST NOT HAVE DUPLICATES IN OTHER ARRAY
  BACK_ROW_STATE               = [49,50]  #state id that flag the enemy back_row  
  FLYING_STATE                 = [51,52]  
  UNDERWATER_STATE             = [53,54]    
  UNDERGROUND_STATE            = [55,56]
  ALLMOD_STATE = BACK_ROW_STATE+FLYING_STATE+UNDERWATER_STATE+UNDERGROUND_STATE  
  TEXT_NO_VALID_TARGET = "No Valid Target"   #text to show if no valid target                                     
  #CREDIT TSUKIHIME FOR THIS TARGET SCOPE - IT'S BASED ON HIS/HER SCRIPTS.
  #SCOPE_RELATED CONFIG BETTER IF UNTOUCHED. TOUCH IT AT YOUR OWN RISK
  ONE_BACK_ENEMY        = 81
  ONE_FRONT_ENEMY       = 82
  ALL_BACK_ENEMY        = 83
  ALL_FRONT_ENEMY       = 84
  ONE_FLYING_ENEMY      = 85
  ALL_FLYING_ENEMY      = 86
  ONE_UNDERWATER_ENEMY  = 87
  ALL_UNDERWATER_ENEMY  = 88
  ONE_UNDERGROUND_ENEMY = 89
  ALL_UNDERGROUND_ENEMY = 90
  ONE_EITHER_ROW_ENEMY  = 91
  ALL_EITHER_ROW_ENEMY  = 92
  #ally series
  ONE_BACK_ALLY         = 93
  ONE_FRONT_ALLY        = 94
  ALL_BACK_ALLY         = 95
  ALL_FRONT_ALLY        = 96
  #suikoden series
  ONE_SHORT_WEAPON          = 97
  ONE_MID_WEAPON            = 98
  ONE_LONG_WEAPON           = 99
  ALL_SHORT_WEAPON          = 100
  ALL_MID_WEAPON            = 101
  ALL_LONG_WEAPON           = 102

####DO NOT EDIT BELOW THIS EXCEPT YOU KNOW WHAT YOU'RE DOING ####################
#PUT ALL CUSTOM SCOPES THAT TARGET ALL X ENEMY
  SCOPE_ENEMY_ALL_X_ARRAY = [ALL_FRONT_ENEMY, ALL_BACK_ENEMY,ALL_FLYING_ENEMY,
                              ALL_UNDERWATER_ENEMY,ALL_UNDERGROUND_ENEMY,
                              ALL_EITHER_ROW_ENEMY,ALL_SHORT_WEAPON,
                              ALL_MID_WEAPON,ALL_LONG_WEAPON]
                              
#PUT ALL CUSTOM SCOPES THAT TARGET SINGLE X ENEMY
  SCOPE_ENEMY_SINGLE_X_ARRAY = [ONE_FRONT_ENEMY, ONE_BACK_ENEMY, 
  ONE_FLYING_ENEMY, ONE_UNDERWATER_ENEMY, ONE_UNDERGROUND_ENEMY, 
  ONE_EITHER_ROW_ENEMY,ONE_SHORT_WEAPON,ONE_MID_WEAPON,ONE_LONG_WEAPON]
# NO NEED TO PUT IT HERE SINCE ALREADY USING ADDITION
  ALL_CUSTOM_ENEMY_SCOPE_ARRAY = SCOPE_ENEMY_SINGLE_X_ARRAY + SCOPE_ENEMY_ALL_X_ARRAY
#PUT ALL CUSTOM SCOPES THAT TARGET ALL X ALLY
  SCOPE_FRIEND_ALL_X_ARRAY = [ALL_BACK_ALLY,ALL_FRONT_ALLY]
#PUT ALL CUSTOM SCOPES THAT TARGET SINGLE X ALLY
  SCOPE_FRIEND_SINGLE_X_ARRAY = [ONE_BACK_ALLY,ONE_FRONT_ALLY]
# NO NEED TO PUT IT HERE SINCE ALREADY USING ADDITION
  ALL_CUSTOM_FRIEND_SCOPE_ARRAY = SCOPE_FRIEND_ALL_X_ARRAY + SCOPE_FRIEND_SINGLE_X_ARRAY
  
  Scope_Regex = /<scope:?\s*(\d+)\s*/i  
end

if $imported["YEA-BattleEngine"] == true
module YEA
  module BATTLE
    HELP_TEXT_ALL_FRONT_FOES       = "All Front Row Foes"
    HELP_TEXT_ALL_BACK_FOES        = "All Back Row Foes"
    HELP_TEXT_ALL_FLYING_FOES      = "All Flying Foes"
    HELP_TEXT_ALL_UNDERWATER_FOES  = "All Underwater Foes"
    HELP_TEXT_ALL_UNDERGROUND_FOES = "All Underground Foes"
    HELP_TEXT_ALL_EITHER_ROW_FOES  = "All Ground Foes"
    HELP_TEXT_ALL_BACK_ALLY        = "All Back Row Allies"
    HELP_TEXT_ALL_FRONT_ALLY       = "All Front Row Allies"
    HELP_TEXT_ALL_SHORT_WEAPON     = "All Front Row Foes"
    HELP_TEXT_ALL_MID_WEAPON       = "All Mid Range Weapon Target Foes"
    HELP_TEXT_ALL_LONG_WEAPON      = "All Ground and Flying Foes"
  end
end
end


################################################################################
# - END CONFIGURATION
################################################################################
#-------DO NOT EDIT PAST THIS LINE EXCEPT YOU KNOW WHAT YOU'RE DOING-----------#
class Game_Party < Game_Unit
  attr_accessor :suikoden_style
  alias game_party_initialize_estriole777 initialize
  def initialize
    game_party_initialize_estriole777
    @suikoden_style = true
  end
end

class Game_Temp
  attr_accessor :est_enemy
  attr_accessor :est_friend
  attr_accessor :est_skill
  attr_accessor :est_valid_target
  alias game_temp_initialize_estriole777 initialize
  def initialize
    game_temp_initialize_estriole777
  end
end

module RPG
  class UsableItem < BaseItem
      include ESTRIOLE          
      
      def scope_cond
      return nil if !note[/<scope_cond?>(?:[^<]|<[^\/])*<\/scope_cond?>/i]
      a = note[/<scope_cond?>(?:[^<]|<[^\/])*<\/scope_cond?>/i].scan(/(?:!<scope_cond?>|(.*)\r)/)
      a.delete_at(0)    
      return noteargs = a.join("\r\n")
      end
    
      alias est_for_opponent? for_opponent?
      def for_opponent?
      return true if ALL_CUSTOM_ENEMY_SCOPE_ARRAY.include?(@scope) #81
      est_for_opponent?
      end

      alias est_for_friend? for_friend?
      def for_friend?
      return true if ALL_CUSTOM_FRIEND_SCOPE_ARRAY.include?(@scope) #81
      est_for_friend?
      end

      alias est_for_all? for_all?
      def for_all?
      temp = SCOPE_ENEMY_ALL_X_ARRAY + SCOPE_FRIEND_ALL_X_ARRAY
      return true if temp.include?(@scope) #81
      est_for_all?
      end

      alias est_for_one? for_one?
      def for_one?
      temp = SCOPE_ENEMY_SINGLE_X_ARRAY + SCOPE_FRIEND_SINGLE_X_ARRAY
      return true if temp.include?(@scope) #81
      est_for_one?
      end
      
      def custom_random?
        return nil if !@note[/<random:(.*)>/i]
        a = @note[/<random:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| (\w+)|(\w+),|,(\w+))/).flatten.compact
        a.collect!{|x| x.to_i}
        return noteargs = a[0]
      end
      
      alias custom_random_number_of_targets number_of_targets
      def number_of_targets
        return custom_random? if custom_random?
        custom_random_number_of_targets
      end
      
      alias est_for_random? for_random?
      def for_random?
      return true if custom_random?
      est_for_random?
      end
      
      def for_one_back_ally?
      [ONE_BACK_ALLY].include?(@scope) #81
      end
      def for_one_front_ally?
      [ONE_FRONT_ALLY].include?(@scope) #81
      end
      def for_all_back_ally?
      [ALL_BACK_ALLY].include?(@scope) #81
      end
      def for_all_front_ally?
      [ALL_FRONT_ALLY].include?(@scope) #81
      end
    
      def for_one_back_enemy?
      [ONE_BACK_ENEMY].include?(@scope) #81
      end
      def for_one_front_enemy?
      [ONE_FRONT_ENEMY].include?(@scope) #82
      end
      def for_all_back_enemy?
      [ALL_BACK_ENEMY].include?(@scope) #83
      end
       def for_all_front_enemy?
      [ALL_FRONT_ENEMY].include?(@scope) #84
      end
      def for_one_flying_enemy?
      [ONE_FLYING_ENEMY].include?(@scope) #81
      end
      def for_all_flying_enemy?
      [ALL_FLYING_ENEMY].include?(@scope) #83
      end
      def for_one_underwater_enemy?
      [ONE_UNDERWATER_ENEMY].include?(@scope) #81
      end
      def for_all_underwater_enemy?
      [ALL_UNDERWATER_ENEMY].include?(@scope) #83
      end
      def for_one_underground_enemy?
      [ONE_UNDERGROUND_ENEMY].include?(@scope) #81
      end
      def for_all_underground_enemy?
      [ALL_UNDERGROUND_ENEMY].include?(@scope) #83
      end
      def for_one_either_row_enemy?
      [ONE_EITHER_ROW_ENEMY].include?(@scope) #83
      end
      def for_all_either_row_enemy?
      [ALL_EITHER_ROW_ENEMY].include?(@scope) #83
      end
      #suikoden range series
      def for_one_short_weapon_enemy?
      [ONE_SHORT_WEAPON].include?(@scope) #83
      end
      def for_one_mid_weapon_enemy?
      [ONE_MID_WEAPON].include?(@scope) #83
      end
      def for_one_long_weapon_enemy?
      [ONE_LONG_WEAPON].include?(@scope) #83
      end
      def for_all_short_weapon_enemy?
      [ALL_SHORT_WEAPON].include?(@scope) #83
      end
      def for_all_mid_weapon_enemy?
      [ALL_MID_WEAPON].include?(@scope) #83
      end
      def for_all_long_weapon_enemy?
      [ALL_LONG_WEAPON].include?(@scope) #83
      end
      
      alias :est_target_scope_selection? :need_selection?
      def need_selection?
       temp = SCOPE_ENEMY_SINGLE_X_ARRAY + SCOPE_FRIEND_SINGLE_X_ARRAY
       temp.include?(@scope) || est_target_scope_selection?
      end
     
      def back_row?(actor)
        for i in 0..ESTRIOLE::BACK_ROW_STATE.size
        return actor.state?(ESTRIOLE::BACK_ROW_STATE[i]) if actor.state?(ESTRIOLE::BACK_ROW_STATE[i])==true
        end
        return false
      end

      #patch for enemy choosing skill that have valid target if there's any.
      def enemy_any_valid_target(enemy)
        return true if !SceneManager.scene.is_a?(Scene_Battle)
        target = enemy.friends_unit 
        target = enemy.opponents_unit if for_opponent?
        val_target = valid_target(target,enemy)
        return true if val_target.size > 0
        return false
      end
      
      def any_valid_target?
        return true if !SceneManager.scene.is_a?(Scene_Battle)
        return false if !BattleManager.actor
        target = BattleManager.actor.friends_unit 
        target = BattleManager.actor.opponents_unit if for_opponent?
        val_target = valid_target(target,BattleManager.actor)
        return true if val_target.size > 0
        return false
      end
      
      def valid_target(target,user = nil)
      ##########################################################################
      #
      #   THIS PREBUILD SCOPE (not using custom scope condition)
      #   prebuild scope take priority above custom scope condition
      #  
      ###########################################################################  
      #ACTUALLY IT'S POSSIBLE TO MERGE THEM TOGETHER USING || BUT FOR THE SAKE
      #OF EASIER EDITING I PURPOSELY SPLIT IT TO OPPONENT AND ALLY PART
      ########OPPONENT PART ##############################################################################
      if for_one_back_enemy? || for_all_back_enemy?
        if $game_party.suikoden_style ==true
          if target.alive_back_row_members.size == 0
            return target.alive_front_row_members 
          else
            return target.alive_back_row_members 
          end
        else
        return target.alive_back_row_members 
        end  
      end
      if for_one_front_enemy? || for_all_front_enemy?
        if $game_party.suikoden_style ==true
          if target.alive_front_row_members.size == 0
            return target.alive_back_row_members 
          else
          return target.alive_front_row_members             
          end
        else
        return target.alive_front_row_members 
        end  
      end
      return target.alive_flying_members if for_one_flying_enemy? || for_all_flying_enemy?
      return target.alive_underwater_members if for_one_underwater_enemy? || for_all_underwater_enemy?
      return target.alive_underground_members if for_one_underground_enemy? ||for_all_underground_enemy?
      return target.alive_either_row_members if for_one_either_row_enemy? || for_all_either_row_enemy?
      ####### suikoden weapon ####################################################
      if for_one_short_weapon_enemy? || for_all_short_weapon_enemy?
        if back_row?(user)
        return []
        else
          if $game_party.suikoden_style ==true
            if target.alive_front_row_members.size == 0
              return target.alive_back_row_members 
            else
            return target.alive_front_row_members             
            end
          else
          return target.alive_front_row_members 
          end  
        end
      end
      if for_one_mid_weapon_enemy? || for_all_mid_weapon_enemy?
        if back_row?(user)
          if $game_party.suikoden_style ==true
            if target.alive_front_row_members.size == 0
              return target.alive_back_row_members 
            else
            return target.alive_front_row_members             
            end
          else
          return target.alive_front_row_members 
          end  
        else
          if $game_party.suikoden_style ==true
            if target.alive_front_row_members.size == 0
              return target.alive_back_row_members 
            else
            return target.alive_front_row_members             
            end
          else
          return target.alive_front_row_members 
          end  
        end
      end
      if for_one_long_weapon_enemy? || for_all_long_weapon_enemy?
        if back_row?(user)
          valid = target.alive_either_row_members + target.alive_flying_members
          return valid           
        else
          valid = target.alive_either_row_members + target.alive_flying_members
          return valid           
        end
      end
      
      #######ALLY PART#####################################################################################
      if for_one_back_ally? || for_all_back_ally?
        return target.alive_back_row_members 
      end  
      if for_one_front_ally? || for_all_front_ally?
        return target.alive_front_row_members 
      end
      #######DEFAULT CUSTOM SCOPES#############################
      all_custom = ALL_CUSTOM_ENEMY_SCOPE_ARRAY + ALL_CUSTOM_FRIEND_SCOPE_ARRAY
      if all_custom.include?(self.scope)
      return []
      end
      return target.dead_members if for_dead_friend?
      #######DEFAULT NO SCOPES#############################
      ##########################################################################
      #
      #   BELOW IS THE CODE WHICH RETURN SCOPE CONDITION TARGET
      #  
      ###########################################################################  
      a = user
      o = user.opponents_unit
      f = user.friends_unit
      v = $game_variables
      s = $game_switches
      cond = scope_cond ? scope_cond : "true"
      return target.alive_members if !scope_cond
      return target.members.select {|b|eval(cond)}
      end #end def valid target enemy

    #yea battle patch
    if $imported["YEA-BattleEngine"] == true
      #scope_description (shown in yanfly engine)
      def scope_desc
      return nil if !note[/<scope_desc?>(?:[^<]|<[^\/])*<\/scope_desc?>/i]
      a = note[/<scope_desc?>(?:[^<]|<[^\/])*<\/scope_desc?>/i].scan(/(?:!<scope_desc?>|(.*)\r)/)
      a.delete_at(0)    
      return noteargs = a.join("\r\n")        
      end
      
      def yea_special_text
      number = $game_temp.battle_aid.number_of_targets
      if for_random?
      help = "%d Random Foes" if for_all? && for_opponent?
      help = "%d Random Allies" if for_all? && for_friend?
      help = "%d Random Front Row Foes" if for_all_front_enemy?
      help = "%d Random Back Row Foes" if for_all_back_enemy?
      help = "%d Random Flying Foes" if for_all_flying_enemy?
      help = "%d Random Underwater Foes" if for_all_underwater_enemy?
      help = "%d Random Underground Foes" if for_all_underground_enemy?
      help = "%d Random Ground Foes" if for_all_either_row_enemy?
      help = "%d Random Front Row Foes" if for_all_short_weapon_enemy?
      help = "%d Random Mid Range Weapon Target Foes" if for_all_mid_weapon_enemy?
      help = "%d Random Ground and Flying Foes" if for_all_long_weapon_enemy?
      help = "%d Random Back Row Allies" if for_all_back_ally?
      help = "%d Random Front Row Allies" if for_all_front_ally?
      help = "%d Random Target" if !help
      text = sprintf(help, number)
      return text
      end  
      return YEA::BATTLE::HELP_TEXT_ALL_BACK_FOES if for_all_back_enemy?
      return YEA::BATTLE::HELP_TEXT_ALL_FRONT_FOES if for_all_front_enemy?
      return YEA::BATTLE::HELP_TEXT_ALL_FLYING_FOES if for_all_flying_enemy?
      return YEA::BATTLE::HELP_TEXT_ALL_UNDERWATER_FOES if for_all_underwater_enemy?
      return YEA::BATTLE::HELP_TEXT_ALL_UNDERGROUND_FOES if for_all_underground_enemy?
      return YEA::BATTLE::HELP_TEXT_ALL_EITHER_ROW_FOES if for_all_either_row_enemy?
      return YEA::BATTLE::HELP_TEXT_ALL_SHORT_WEAPON if for_all_short_weapon_enemy?
      return YEA::BATTLE::HELP_TEXT_ALL_MID_WEAPON if for_all_mid_weapon_enemy?
      return YEA::BATTLE::HELP_TEXT_ALL_LONG_WEAPON if for_all_long_weapon_enemy?
      return YEA::BATTLE::HELP_TEXT_ALL_BACK_ALLY if for_all_back_ally?
      return YEA::BATTLE::HELP_TEXT_ALL_FRONT_ALLY if for_all_front_ally?
      return nil
      end  
    end #end yea battle patch
          
      def est_ts_load_notetags
      matches = Scope_Regex.match(self.note)
      if matches
      @scope = matches[1].to_i
      end
    end
  end
end

module DataManager

  class << self
    alias est_target_skill_load_database load_database
    alias est_target_skill_init init
  end

  def self.init
    est_target_skill_init
    load_notetags_est_target_skill
  end

  def self.load_database
    est_target_skill_load_database
    if $BTEST
    load_notetags_est_target_skill
    end
  end
        
  def self.load_notetags_est_target_skill
    groups = [$data_skills, $data_items]
    for group in groups
    for obj in group
    next if obj.nil?
    obj.est_ts_load_notetags
    end
    end
  end
end

class Game_Action
  #overwrite targets for opponents to use valid target
  def targets_for_opponents
    enemy = item.valid_target(opponents_unit,@subject)
    if item.for_random?
      Array.new(item.number_of_targets) { opponents_unit.custom_random_target(enemy) }
    elsif item.for_one?
      num = 1 + (attack? ? subject.atk_times_add.to_i : 0)
      if @target_index < 0
        [opponents_unit.custom_random_target(enemy)] * num
      else
        [opponents_unit.custom_smooth_target(@target_index,enemy)] * num
      end
    else
      enemy
    end
  end
#  #overwrite targets for friends to use valid target
#  def targets_for_friends
#    friend = item.valid_target(friends_unit,@subject)
#    if item.for_user?
#      [@subject]
#    elsif item.for_dead_friend?
#      if item.for_one?
#        [friends_unit.smooth_dead_target(@target_index)]
#      else
#        friends_unit.dead_members
#      end
#    elsif item.for_friend?
#      if item.for_one?
#        [friends_unit.custom_smooth_target(@target_index,friend)]
#      else
#        friend
#      end
#    end
#  end  
#  method overwritten in patch below

end

class Window_SkillList < Window_Selectable
  alias disable_skill_if_no_valid_target? enable?
  def enable?(item)
    disable_skill_if_no_valid_target?(item) &&
    (!ESTRIOLE::DISABLE_SKILL_IF_NO_VALID_TARGET||item.any_valid_target?)
  end
end

class Window_ItemList < Window_Selectable
  alias disable_item_if_no_valid_target? enable?
  def enable?(item)
    disable_item_if_no_valid_target?(item) &&
    (!ESTRIOLE::DISABLE_SKILL_IF_NO_VALID_TARGET||item.any_valid_target?)
  end  
end

# first part below is class game unit and battler base
class Game_BattlerBase
  alias disable_attack_command_if_no_valid_target? attack_usable?
  def attack_usable?
    disable_attack_command_if_no_valid_target? && 
    (!ESTRIOLE::DISABLE_SKILL_IF_NO_VALID_TARGET||$data_skills[attack_skill_id].any_valid_target?)
  end
  
  def back_row_state?
    for i in 0..ESTRIOLE::BACK_ROW_STATE.size
    return state?(ESTRIOLE::BACK_ROW_STATE[i]) if state?(ESTRIOLE::BACK_ROW_STATE[i])==true
    end
    return false
  end
  def flying_state?
    for i in 0..ESTRIOLE::FLYING_STATE.size
    return state?(ESTRIOLE::FLYING_STATE[i]) if state?(ESTRIOLE::FLYING_STATE[i])==true
    end
    return false
  end
  def underwater_state?    
    for i in 0..ESTRIOLE::UNDERWATER_STATE.size
    return state?(ESTRIOLE::UNDERWATER_STATE[i]) if state?(ESTRIOLE::UNDERWATER_STATE[i])==true
    end
    return false
  end
  def underground_state?
    for i in 0..ESTRIOLE::UNDERGROUND_STATE.size
    return state?(ESTRIOLE::UNDERGROUND_STATE[i]) if state?(ESTRIOLE::UNDERGROUND_STATE[i])==true
    end
    return false
  end
  def front_row?
    exist? && !back_row_state? &&
     !flying_state? && !underwater_state? && !underground_state?
  end
  def back_row?
    exist? && back_row_state?
  end
  def flying?
    exist? && flying_state?
  end
  def underwater?
    exist? && underwater_state?
  end
  def underground?
    exist? && underground_state?
  end
  def either_row?
    exist? && !flying_state? && !underwater_state? && !underground_state?
  end
  
end

class Game_Unit
  def alive_front_row_members
    members.select {|member| member.alive? && member.front_row?}
  end
  def alive_back_row_members
    members.select {|member| member.alive? && member.back_row? }
  end
  def alive_flying_members
    members.select {|member| member.alive? && member.flying? }
  end
  def alive_underwater_members
    members.select {|member| member.alive? && member.underwater? }
  end
  def alive_underground_members
    members.select {|member| member.alive? && member.underground? }
  end
  def alive_either_row_members
    members.select {|member| member.alive? && member.either_row? }
  end  
  def custom_random_target(target)
    tgr_rand = rand * tgr_sum
    target.each do |member|
      tgr_rand -= member.tgr
      return member if tgr_rand < 0
    end
    target[0]
  end
  def custom_smooth_target(index,target,scope_cond = nil)
    member = members[index]
    member = target[index] if scope_cond
    (member && member.alive?) ? member : target.sample
  end
end

# below is the window select enemy modified to only able to select front only / back only / all
class Window_BattleEnemy < Window_Selectable
  def item_max
    return 1 if $game_temp.est_valid_target == nil
    return 1 if $game_temp.est_valid_target.size == 0
    return $game_temp.est_valid_target.size
  end

  def enemy  
    return $game_troop.alive_members[@index] if $game_temp.est_valid_target == nil
    return $game_troop.alive_members[@index] if $game_temp.est_valid_target.size == 0
    return $game_temp.est_valid_target[@index]
  end
  
  def name_est
    return nil if $game_temp.est_valid_target == nil
    return nil if $game_temp.est_valid_target.size == 0
    return $game_temp.est_valid_target
  end
  
  def draw_item(index)
    change_color(normal_color)
    enemy = name_est
    if enemy != nil
      name = enemy[index].name 
    else
    name = ESTRIOLE::TEXT_NO_VALID_TARGET
    end  
    draw_text(item_rect_for_text(index), name)
  end 
    
  alias process_ok_est process_ok
  def process_ok
    if $game_temp.est_valid_target.size == 0
      process_cancel
    else
    process_ok_est
    end
  end
  
  #yea battle patch
  if $imported["YEA-BattleEngine"] == true    
    def update
      super
      return unless active
        if $game_temp.est_valid_target.size == 0
        else
        enemy.sprite_effect_type = :whiten
        end
      return unless $game_temp.est_skill.for_all?
      for enemy in $game_temp.est_valid_target
        enemy.sprite_effect_type = :whiten
      end        
    end
    
    def update_cursor
      if $game_temp.est_skill == nil
      help = false
      else
      help = $game_temp.est_skill.for_all?
      end
      if help
      cursor_rect.set(0, 0, contents.width, contents.height)
      self.top_row = 0
      elsif @index < 0
      cursor_rect.empty
      else
      ensure_cursor_visible
      cursor_rect.set(item_rect(@index))
      end
    end #end update_cursor

  end #end yea battle patch
  
end #end window_battleenemy

#yea battle patch
if $imported["YEA-BattleEngine"] == true
class Window_BattleHelp < Window_Help
  def refresh_special_case(battler)
    if $game_temp.battle_aid.for_opponent?
      if $game_temp.battle_aid.for_all?
        text = $game_temp.battle_aid.yea_special_text 
        text = YEA::BATTLE::HELP_TEXT_ALL_FOES if text == nil
      else
        text = $game_temp.battle_aid.yea_special_text 
        case $game_temp.battle_aid.number_of_targets
        when 1
          text = YEA::BATTLE::HELP_TEXT_ONE_RANDOM_FOE if !text
        else
          number = $game_temp.battle_aid.number_of_targets
          text = sprintf(YEA::BATTLE::HELP_TEXT_MANY_RANDOM_FOE, number) if !text
        end      
      end
    else 
      if $game_temp.battle_aid.for_dead_friend?
        text = YEA::BATTLE::HELP_TEXT_ALL_DEAD_ALLIES
      else
        text = $game_temp.battle_aid.yea_special_text
        text = YEA::BATTLE::HELP_TEXT_ALL_ALLIES if text == nil
      end
    end
      if $game_temp.est_valid_target.size == 0
      text = ESTRIOLE::TEXT_NO_VALID_TARGET
      end
      text = $game_temp.battle_aid.scope_desc if $game_temp.battle_aid.scope_desc
      return if text == @text
      @text = text
      contents.clear
      reset_font_settings
      draw_text(0, 0, contents.width, line_height*2, @text, 1)
  end

  def update_battler_name
    return unless @actor_window.active || @enemy_window.active
    if @actor_window.active
      battler = $game_party.battle_members[@actor_window.index]
    elsif @enemy_window.active
      battler = @enemy_window.enemy
    end
    if special_display?
      refresh_special_case(battler)
    else
      if $game_temp.est_valid_target.size == 0
      refresh_special_case(battler)      
      else
      refresh_battler_name(battler) if battler_name(battler) != @text
      end
    end
  end
  
end#end class battle_help
end#end yea battle patch

#yea enemy hp patch
if $imported["YEA-EnemyHPBars"] == true
class Enemy_HP_Gauge_Viewport < Viewport
  def gauge_visible?
    update_original_hide
    return false if @original_hide
    return false if case_original_hide?
    return true if @visible_counter > 0
    return true if @gauge_width != @target_gauge_width
    if SceneManager.scene_is?(Scene_Battle)
      return false if SceneManager.scene.enemy_window.nil?
      unless @battler.dead?
        if SceneManager.scene.enemy_window.active
          if SceneManager.scene.enemy_window.enemy == @battler
          return false if !$game_temp.est_valid_target.include?(@battler)
          return true if $game_temp.est_valid_target.include?(@battler)
          end
          if SceneManager.scene.enemy_window.select_all?
          return false if !$game_temp.est_valid_target.include?(@battler)
          return true if $game_temp.est_valid_target.include?(@battler)
          end
          return true if highlight_aoe?
        end
      end
    end
    return false    
  end
end #end yea enemy hp gauge viewport
end #end yea enemy hp patch

class Scene_Battle < Scene_Base
  alias on_skill_ok_est on_skill_ok
  def on_skill_ok
    @skillchk = @skill_window.item
    cur_actor                   = BattleManager.actor
    cur_enemy                   = BattleManager.actor.opponents_unit
    cur_friend                  = BattleManager.actor.friends_unit
    $game_temp.est_skill        = @skillchk
    if @skillchk.for_opponent?
    $game_temp.est_valid_target  = $game_temp.est_skill.valid_target(cur_enemy, cur_actor)
    else
    $game_temp.est_valid_target  = $game_temp.est_skill.valid_target(cur_friend, cur_actor)
    end
    if !@skillchk.need_selection?
      #if yea battle engine not present
      if $imported["YEA-BattleEngine"] == true
      else
        if $game_temp.est_valid_target.size == 0
        on_skill_cancel
        @log_window.add_text(ESTRIOLE::TEXT_NO_VALID_TARGET)
        3.times do @log_window.wait end
        @log_window.back_one
        return
        end
      end#end yea battle engine not present    
    end
    on_skill_ok_est
  end
  
  alias on_item_ok_est on_item_ok
  def on_item_ok
    @itemchk = @item_window.item
    cur_actor                   = BattleManager.actor
    cur_enemy                   = BattleManager.actor.opponents_unit
    cur_friend                  = BattleManager.actor.friends_unit
    $game_temp.est_skill        = @itemchk
    if @itemchk.for_opponent?
    $game_temp.est_valid_target  = $game_temp.est_skill.valid_target(cur_enemy, cur_actor)
    else
    $game_temp.est_valid_target  = $game_temp.est_skill.valid_target(cur_friend, cur_actor)
    end
    if !@itemchk.need_selection?
      #if yea battle engine not present
      if $imported["YEA-BattleEngine"] == true
      else
        if $game_temp.est_valid_target.size == 0
        on_item_cancel
        @log_window.add_text(ESTRIOLE::TEXT_NO_VALID_TARGET)
        3.times do @log_window.wait end
        @log_window.back_one
        return
        end
      end#end yea battle engine not present    
    end
    on_item_ok_est    
  end
  
  alias command_attack_est command_attack
  def command_attack
    @attack = $data_skills[BattleManager.actor.attack_skill_id]
    cur_actor                   = BattleManager.actor
    cur_enemy                   = BattleManager.actor.opponents_unit
    cur_friend                  = BattleManager.actor.friends_unit
    $game_temp.est_skill        = @attack
    if @attack.for_opponent?
    $game_temp.est_valid_target  = $game_temp.est_skill.valid_target(cur_enemy, cur_actor)
    else
    $game_temp.est_valid_target  = $game_temp.est_skill.valid_target(cur_friend, cur_actor)
    end
    if !@attack.need_selection?
      #if yea battle engine not present
      if $imported["YEA-BattleEngine"] == true
      else
        if $game_temp.est_valid_target.size == 0
        on_skill_cancel
        @log_window.add_text(ESTRIOLE::TEXT_NO_VALID_TARGET)
        3.times do @log_window.wait end
        @log_window.back_one
        return
        end
      end#end yea battle engine not present    
    end
    command_attack_est
  end    
  
  alias select_enemy_selection_est select_enemy_selection
  def select_enemy_selection
    select_enemy_selection_est
  end
end

class Window_BattleActor < Window_BattleStatus
  def item_max
    return $game_party.battle_members.size if $game_temp.est_valid_target == nil
    return 1 if $game_temp.est_valid_target.size == 0
    return $game_temp.est_valid_target.size
    #$game_party.battle_members.size
  end

  if $imported["YEA-BattleEngine"] == true
  #--------------------------------------------------------------------------
  # overwrite method: draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    return if index.nil?
    clear_item(index)
    actor = battle_members[index]
      if $game_temp.est_valid_target != nil
        if $game_temp.est_valid_target.size == 0
          name = ""
          rect = item_rect(index)
          draw_text(rect.x, rect.y, rect.width, line_height, name)
          return
        end
      actor = $game_temp.est_valid_target[index]        
      end
    rect = item_rect(index)
    return if actor.nil?
    draw_actor_face(actor, rect.x+2, rect.y+2, actor.alive?)
    draw_actor_name(actor, rect.x, rect.y, rect.width-8)
    draw_actor_action(actor, rect.x, rect.y)
    draw_actor_icons(actor, rect.x, line_height*1, rect.width)
    gx = YEA::BATTLE::BATTLESTATUS_HPGAUGE_Y_PLUS
    contents.font.size = YEA::BATTLE::BATTLESTATUS_TEXT_FONT_SIZE
    draw_actor_hp(actor, rect.x+2, line_height*2+gx, rect.width-4)
    if draw_tp?(actor) && draw_mp?(actor)
      dw = rect.width/2-2
      dw += 1 if $imported["YEA-CoreEngine"] && YEA::CORE::GAUGE_OUTLINE
      draw_actor_tp(actor, rect.x+2, line_height*3, dw)
      dw = rect.width - rect.width/2 - 2
      draw_actor_mp(actor, rect.x+rect.width/2, line_height*3, dw)
    elsif draw_tp?(actor) && !draw_mp?(actor)
      draw_actor_tp(actor, rect.x+2, line_height*3, rect.width-4)
    else
      draw_actor_mp(actor, rect.x+2, line_height*3, rect.width-4)
    end
  end
  
  else #else yea battle engine
    
  def draw_item(index)
    actor = $game_party.battle_members[index]
      if $game_temp.est_valid_target != nil
        if $game_temp.est_valid_target.size == 0
          name = ESTRIOLE::TEXT_NO_VALID_TARGET
          draw_text(item_rect_for_text(index), name)
          return
        end
      actor = $game_temp.est_valid_target[index]        
      end
    draw_basic_area(basic_area_rect(index), actor)
    draw_gauge_area(gauge_area_rect(index), actor)
  end
  def name_est
    return nil if $game_temp.est_valid_target == nil
    return nil if $game_temp.est_valid_target.size == 0
    return $game_temp.est_valid_target
  end

  end #end yea battle not present

  def process_ok
    if $game_temp.est_valid_target.size == 0
      process_cancel
    else
      Sound.play_ok
      Input.update
      deactivate
      call_ok_handler
    end
  end  
end

#patch for enemy choosing skill that have valid target if there's any.
#and patch for grabbing enemy id
class Game_Enemy < Game_Battler
  alias est_pos_action_valid? action_valid?
  def action_valid?(action)
   est_pos_action_valid?(action) && $data_skills[action.skill_id].enemy_any_valid_target(self)
  end
  def id
    @enemy_id
  end
end

#MOG battle cursor patch. now only able to hover valid target
module Battle_Cursor_index
  def set_cursor_position_enemy
  return if !self.active
   $game_temp.battle_cursor[0] = $game_temp.est_valid_target[self.index].screen_x + CURSOR_POSITION[0] rescue nil
   $game_temp.battle_cursor[1] = $game_temp.est_valid_target[self.index].screen_y + CURSOR_POSITION[1] rescue nil
   $game_temp.battle_cursor[3] = $game_temp.est_valid_target[self.index].name rescue nil
   $game_temp.battle_cursor = [0,0,false,0] if $game_temp.battle_cursor[0] == nil
  end
  def set_cursor_position_actor
   return if !self.active
   $game_temp.battle_cursor[0] = $game_temp.est_valid_target[self.index].screen_x + CURSOR_POSITION[0] rescue nil
   $game_temp.battle_cursor[1] = $game_temp.est_valid_target[self.index].screen_y + CURSOR_POSITION[1] rescue nil
   $game_temp.battle_cursor[3] = $game_temp.est_valid_target[self.index].name rescue nil
   $game_temp.battle_cursor = [0,0,false,0] if $game_temp.battle_cursor[0] == nil
  end  
end

#yea attack replace patch and bugfix when equiping weapon without tags it will
#make default attack even actor / class have tags. also rearrange the priority
#to weapon, class, actor. so class could override the actor attack skill.
#because it's more make sense. you change the class of an actor.
if $imported["YEA-WeaponAttackReplace"] == true
  
class Game_Actor < Game_Battler
  def weapon_attack_skill_id
    for weapon in weapons
      next if weapon.nil?
      return weapon.attack_skill if weapon.attack_skill != YEA::WEAPON_ATTACK_REPLACE::DEFAULT_ATTACK_SKILL_ID
    end
    return self.class.attack_skill if !self.class.attack_skill.nil? &&
                                  self.class.attack_skill != YEA::WEAPON_ATTACK_REPLACE::DEFAULT_ATTACK_SKILL_ID
    if $imported["YEA-ClassSystem"] == true
    return self.subclass.attack_skill if self.subclass &&!self.subclass.attack_skill.nil? &&
                                  self.subclass.attack_skill != YEA::WEAPON_ATTACK_REPLACE::DEFAULT_ATTACK_SKILL_ID
    end                          
    return self.actor.attack_skill if !self.actor.attack_skill.nil? &&
                                  self.actor.attack_skill != YEA::WEAPON_ATTACK_REPLACE::DEFAULT_ATTACK_SKILL_ID
    return YEA::WEAPON_ATTACK_REPLACE::DEFAULT_ATTACK_SKILL_ID                              
  end  
end # Game_Actor

end #end yea attack replace patch


#patch from DoubleX for auto battle actor
class Game_BattlerBase
  alias est_pos_usable? usable?
  def usable?(item)
    est_pos_usable?(item) && ((item.for_dead_friend? || item.for_friend?) && 
    item.valid_target(self.friends_unit, self).size > 0 || item.for_opponent? && 
    item.valid_target(self.opponents_unit, self).size > 0 || !item.for_dead_friend? && 
    !item.for_friend? && !item.for_opponent?)
  end
end

# patch for targeting friends... compatibility for battle royale script
# so bribed enemy can heal actor...
# based on victor basic module... default scripts is faulty by default... omg.
class Game_Action
  #overwrite targets for friends to use valid target
  def targets_for_friends
    friend = item.valid_target(friends_unit,@subject)
    if item.for_user?
      [@subject]
    elsif item.for_dead_friend?
      if item.for_one?
        [friends_unit.smooth_dead_target(@target_index)]
      else
        friends_unit.dead_members
      end
    elsif item.for_friend?
      if item.for_one?
        if @target_index < 0
        [friends_unit.custom_random_target(friend)]
        else
        [friends_unit.custom_smooth_target(@target_index,friend, item.scope_cond)]
        end
      else
        friend
      end
    end
  end  
end

if $imported["EuphoriaThreatSystem"] == true
class Game_Unit
  alias est_euphoria_custom_random_target custom_random_target  
  def custom_random_target(target)
      case Euphoria::Threat::RANDOM_CHNC
      when 1
        threat_rand = rand * tgr_sum
        target.each do |member|
          threat_rand -= member.threat
          return member if threat_rand < 0
        end
      when 2
        chance = rand(Euphoria::Threat::RANDOM_NUM)
        return est_euphoria_custom_random_target(target) if chance == 0        
      end #end case
      target.sort! {|a,b| b.threat - a.threat}
      return target[0]
  end#end custom random member  
end#end game unit
end#end if imported threat system