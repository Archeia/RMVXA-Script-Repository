#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                            *Threat System*
#│                              Version: 1.4
#│                            Author: Euphoria
#│                            Date: 8/15/2014
#│                        Euphoria337.wordpress.com
#│                        
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: This script overwrites the methods: 
#│                           random_target  in  Game_Unit
#│                           draw_gauge_area_without_tp  in  Window_BattleStatus
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: 1.1) Yanfly Battle Engine compatibility       
#│           1.2) RANDOM_CHNC and RANDOM_NUMB options added to allow some 
#│                  random targeting if chosen.
#│           1.3) ICON_VIEW added, if true, the threat gauge is replaced by
#│                  chosen icons depending on threat level.
#│           1.4) States can now give/take threat, DEFAULT_STT is the amount
#│                  used by states that are untagged. Skills/attacks with no 
#│                  damage now add to threat IF they have valid effects (add
#│                  a state or buff/remove a state or buff, etc). Buffs and
#│                  debuffs can also give/take threat now through the variables
#│                  DEFAULT_BF and DEFAULT_DB, or individually through the buff
#│                  and debuff settings if IND_BF_RATE and IND_DB_RATE are set
#│                  to true. RANDOM_CHNC has been changed to allow three 
#│                  different styles of battle. All threat values can be
#│                  be negative! (added HIDE_GAUGE option).
#├──────────────────────────────────────────────────────────────────────────────
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For Commercial use contact 
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                          
#│■ Instructions: Edit the configurable settings below:
#│
#│                RANDOM_CHNC if true will allow enemies to still attack 
#│                  randomly at times. They will mainly target the highest 
#│                  threat still, but occassional attacks will be random. If
#│                  false, enemies will ALWAYS attack the highest threat.
#│
#│                RANDOM_NUM is a number that helps determine if an enemy
#│                  attack will be based on the highest threat level or if it 
#│                  will be random. The higher this number is, the lower the 
#│                  chance for random attacks to occur. Play with it a bit until
#│                  you find the right balance for you!
#│
#│                THREAT_LOSS will be subtracted from the threat gauge at the 
#│                  end of each turn.
#│
#│                DEFAULT is the amount of threat that will be added to the 
#│                  gauge by items/skills that do not have another value set to
#│                  them.
#│
#│                DEFAULT_STT is the amount of threat that will be added to a
#│                  battler upon being inflicted with a state that does not have
#│                  a note tag specifying a different amount of threat to be
#│                  added/subtracted.
#│
#│                DEFAULT_BF is the amount of threat that will be added to a
#│                  battler when a buff is applied to that battler. SET TO ZERO 
#│                  IF IND_BF_RATE IS TRUE!
#│
#│                IND_BF_RATE when set to true allows you to use the buff
#│                  settings (below the icon settings) to change the amount of 
#│                  threat add/subtracted upon applying a buff based on the type
#│                  of buff! IF THIS IS TRUE, SET DEFAULT_BF TO 0!
#│
#│                DEFAULT_DB is the amount of threat that will be added or
#│                  removed from a battler when a debuff is applied to that
#│                  battler. SET TO ZERO IF IND_DB_RATE IS TRUE!
#│
#│                IND_DB_RATE when set to true allows you to use the debuff
#│                  settings (below the buff settings) to change the amount of
#│                  threat added/subtracted upon applying a debuff base on the
#│                  type of debuff! IF THIS IS TRUE, SET DEFAULT_DB TO 0!
#│
#│                ICON_VIEW if true, will remove the threat gauge from battle 
#│                  and instead, show an icon (set in the icon settings) for
#│                  separate levels of threat, when using YEA - Battle Engine
#│                  this icon will appear in the upper left corner of each 
#│                  character's face, taking the place of the YEA - B.E.'s 
#│                  "action icons". If HIDE_GAUGE is false, this MUST be false,
#│                  or neither will appear.
#│
#│                HIDE_GAUGE if true, will remove the threat gauge from battle 
#│                  and allows for an icon(set in the icon settings) to be
#│                  shown(if ICON_VIEW is true), or just leave ICON_VIEW false
#│                  and have threat run behind-the-scenes! If ICON_VIEW is true
#│                  this must be true, or nothing will appear.
#│
#│                Using a note tag you can have skills/items add different 
#│                amounts of threat than the default! The note tag should look
#│                like this:
#│
#│                <threat: x>         replace x with the amount of threat to add
#│
#│                STATES can now contain the <threat: x> note tag as well! When
#│                a state is applied to a battler THAT battler will gain x 
#│                amount of threat. The one casting the state will ONLY recieve
#│                the minimum skill threat, unless the skill with the state
#│                is also tagged, <threat: x> 
#│
#│                NOTE: THREAT CAN BE NEGATIVE! So poisoning a player could TAKE
#│                away threat from them if the poison state note tag has a 
#│                negative x value (or if DEFAULT_STT is negative)!
#│
#│                NOTE2: THREAT WILL ONLY BE ADDED FOR ATTACKS/SKILLS/ITEMS WITH
#│                  VALID EFFECTS. This means that if your attack/skill/item has
#│                  no damage, it must have an effect for threat to be added. 
#│                  Examples of effects are: buffs/debuffs being added/removed 
#│                  or states being added/removed. If you try to add a 
#│                  state/buff/debuff to a battler already inflicted with the 
#│                  same state/buff/debuff and nothing happens it WILL NOT count
#│                  as a valid effect.
#│
#│                GOOD IDEAS LIST:
#│                  -Set the guard state's note tag to <threat: 0> unless you 
#│                   actually want guarding to add threat. Maybe even make it
#│                   negative?
#│                  -Make detrimental states lower threat by tagging them with
#│                   a negative number, like so: <threat: -5>
#│                  -Any good ideas? Suggest them on my website or in the post
#│                   where this script can be downloaded, and I will most likely
#│                   add your idea here, if it's good...
#└──────────────────────────────────────────────────────────────────────────────
$imported ||= {}
$imported["EuphoriaThreatSystem"] = true
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Editable Region
#└──────────────────────────────────────────────────────────────────────────────
module Euphoria
  module Threat

#========================General Settings=======================================

    RANDOM_CHNC = 0 #Select the style of random chances, when 2, there is true
                    #random selection AT TIMES. When 1, there is SLIGHT random
                    #selection still based on threat. When 0, there is NO 
                    #random selection AT ALL.
    
    RANDOM_NUM  = 5 #The higher this number is, the lower the chance of a 
                    #random attack is. The chance is calculate like this for
                    #RANDOM_CHNC style 2:
                    #  if (random number: 0-RANDOM_NUM) == 0 then attack 
                    #    COMPLETELY RANDOMLY.
                    #The chance is calculated like this for RANDOM_CHNC style 1:
                    #  if (random number: 0-RANDOM_NUM) == 0 then attack MOSTLY
                    #    based on threat, but with SOME randomness.
                         
    THREAT_LOSS = 5 #Amount for threat level to decrease at the end of each turn
    
    DEFAULT     = 5 #Value used for items/skills/attacks with no threat tag
    
    DEFAULT_STT = 0 #Value used by states that do not have a threat tag
    
    DEFAULT_BF  = 0 #Value added/taken from threat when a buff is applied. Set
                    #to 0 if you wish to use the buff settings below to apply
                    #threat based on the buff type.
                    
    IND_BF_RATE = true  #Set to true if you wish to use the buff settings below
                        #to apply threat based on the buff type
    
    DEFAULT_DB  = 0  #Value added/taken from threat when a debuff is applied.
                     #set to 0 if you wish to use the debuff settings below to
                     #apply threat based on the debuff type.
                     
    IND_DB_RATE = true  #Set to true if you wish to use the debuff settings 
                        #below to apply threat based on the debuff type
    
    ICON_VIEW   = false #Set to true to display an icon instead of a gauge, the
                        #icon will change with the value of threat to whatever
                        #icons you set below in the icon settings. Set this to
                        #false if HIDE_GAUGE is set to false!
                            
    HIDE_GAUGE = false #Hide threat gauge from battle? true or false if using
                       #ICON_VIEW, set HIDE_GAUGE to true!
                      
#========================End General Settings===================================                      
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
#===========================Icon Settings=======================================

    ICON100    = 25 #Icon Index For Icon Displayed At Threat Level 100
    
    ICON80TO99 = 26 #Icon Index For Icon Displayed At Threat Level 80 To 99
    
    ICON60TO79 = 27 #Icon Index For Icon Displayed At Threat Level 60 To 79
    
    ICON40TO59 = 28 #Icon Index For Icon Displayed At Threat Level 40 To 59
    
    ICON20TO39 = 29 #Icon Index For Icon Displayed At Threat Level 20 To 39
    
    ICON1TO19  = 30 #Icon Index For Icon Displayed At Threat Level 1 To 19
    
    ICON0      = 31 #Icon Index For Icon Displayed At Threat Level 0
      
#==========================End Icon Settings====================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#=============================Buff Settings=====================================

    #These settings ONLY WORK if you have IND_BF_RATE set to true

    MHP_BUFF = 5  #Threat gain/loss on MHP buff
    
    MMP_BUFF = 5  #Threat gain/loss on MMP buff
    
    ATK_BUFF = 10 #Threat gain/loss on ATK buff
    
    DEF_BUFF = 5  #Threat gain/loss on DEF buff
    
    MAG_BUFF = 10 #Threat gain/loss on MAG buff
    
    MDF_BUFF = 5  #Threat gain/loss on MDF buff

    AGI_BUFF = 5  #Threat gain/loss on AGI buff
    
    LUK_BUFF = 0  #Threat gain/loss on LUK buff
    
#==========================End Buff Settings====================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#=============================Debuff Settings===================================    

    #These settings ONLY WORK if you have IND_DB_RATE set to true

    MHP_DEBUFF = -5  #Threat gain/loss on MHP debuff
    
    MMP_DEBUFF = -5  #Threat gain/loss on MMP debuff
    
    ATK_DEBUFF = -10 #Threat gain/loss on ATK debuff
    
    DEF_DEBUFF = -5  #Threat gain/loss on DEF debuff
    
    MAG_DEBUFF = -10 #Threat gain/loss on MAG debuff
    
    MDF_DEBUFF = -5  #Threat gain/loss on MDF debuff
    
    AGI_DEBUFF = -5  #Threat gain/loss on AGI debuff
    
    LUK_DEBUFF = 0   #Threat gain/loss on LUK debuff

#==========================End Debuff Settings==================================

  end
  module Regex
    
    THREAT_GEN    = /<Threat:[-_ ]?(\d+)>/i
    
  end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW HERE
#└──────────────────────────────────────────────────────────────────────────────


#┌──────────────────────────────────────────────────────────────────────────────
#│■ DataManager
#└──────────────────────────────────────────────────────────────────────────────
module DataManager
  class << self; alias euphoria_threat_datamanager_loaddatabase_15 load_database; end

  #ALIAS - LOAD_DATABASE
  def self.load_database
    euphoria_threat_datamanager_loaddatabase_15
    load_threat_notetags
  end
 
  #NEW - LOAD_THREAT_NOTETAGS
  def self.load_threat_notetags
    groups = [$data_skills, $data_states]
    for group in groups
      for obj in group
        next if obj.nil?
      obj.load_threat_notetags
      end
    end
  end
 
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ RPG::Skill
#└──────────────────────────────────────────────────────────────────────────────
class RPG::UsableItem < RPG::BaseItem
  attr_accessor :threat_plus
 
  #NEW - LOAD_THREAT_NOTETAGS
  def load_threat_notetags
    @threat_plus = nil
    self.note.scan(Euphoria::Regex::THREAT_GEN)
    @threat_plus = $1.to_i
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ RPG::State
#└──────────────────────────────────────────────────────────────────────────────
class RPG::State < RPG::BaseItem
  attr_accessor :state_threat

  #NEW - LOAD_THREAT_NOTETAGS
  def load_threat_notetags
    @state_threat = nil
    self.note.scan(Euphoria::Regex::THREAT_GEN)
    @state_threat = $1.to_i
  end

end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Game_BattlerBase
#└──────────────────────────────────────────────────────────────────────────────
class Game_BattlerBase
  attr_accessor :threat
  
  #NEW - THREAT_ICONS
  def threat_icons
    case @threat
    when 100
      icons = Euphoria::Threat::ICON100
    when 80...99
      icons = Euphoria::Threat::ICON80TO99
    when 60...79
      icons = Euphoria::Threat::ICON60TO79
    when 40...59
      icons = Euphoria::Threat::ICON40TO59
    when 20...39
      icons = Euphoria::Threat::ICON20TO39
    when 1...19
      icons = Euphoria::Threat::ICON1TO19
    when 0
      icons = Euphoria::Threat::ICON0
    end
  end

end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Game_Battler
#└──────────────────────────────────────────────────────────────────────────────
class Game_Battler < Game_BattlerBase
  attr_accessor :threat
  
  #ALIAS - INITIALIZE
  alias euphoria_threat_gamebattler_initialize_15 initialize
  def initialize
    @threat = 0
    euphoria_threat_gamebattler_initialize_15
  end
  
  #ALIAS - DIE
  alias euphoria_threat_gamebattler_die_15 die
  def die
    @threat = 0
    euphoria_threat_gamebattler_die_15
  end
  
  #ALIAS - ITEM_APPLY
  alias euphoria_threat_gamebattler_itemapply_15 item_apply
  def item_apply(user, item)
    if item_has_any_valid_effects?(user, item)
      if item.threat_plus == nil
        user.threat += Euphoria::Threat::DEFAULT
        user.threat = 100 if user.threat > 100
        user.threat = 0 if user.threat < 0
      else
        user.threat += item.threat_plus
        user.threat = 100 if user.threat > 100
        user.threat = 0 if user.threat < 0
      end
    end
    euphoria_threat_gamebattler_itemapply_15(user, item)
  end
  
  #ALIAS - ADD_NEW_STATE
  alias euphoria_threat_gamebattler_addnewstate_15 add_new_state
  def add_new_state(state_id)
    if $data_states[state_id].state_threat == nil
      @threat += Euphoria::Threat::DEFAULT_STT
      @threat = 100 if @threat > 100
      @threat = 0 if @threat < 0
    else
      @threat += $data_states[state_id].state_threat
      @threat = 100 if @threat > 100
      @threat = 0 if @threat < 0
    end
    euphoria_threat_gamebattler_addnewstate_15(state_id)
  end
  
  #NEW - RETURN_STATE
  def return_state_threat(state_id)
    states.find {|state|
      if state.id == state_id
        return state.state_threat
      end
    }
  end
  
  #ALIAS - ADD_BUFF
  alias euphoria_threat_gamebattler_addbuff_15 add_buff
  def add_buff(param_id, turns)
    euphoria_threat_gamebattler_addbuff_15(param_id, turns)
    if Euphoria::Threat::IND_BF_RATE == true
      case param_id
      when 0
        @threat += Euphoria::Threat::MHP_BUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 1
        @threat += Euphoria::Threat::MMP_BUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 2
        @threat += Euphoria::Threat::ATK_BUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 3
        @threat += Euphoria::Threat::DEF_BUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 4
        @threat += Euphoria::Threat::MAG_BUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 5
        @threat += Euphoria::Threat::MDF_BUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 6
        @threat += Euphoria::Threat::AGI_BUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 7
        @threat += Euphoria::Threat::LUK_BUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      end
    elsif Euphoria::Threat::IND_BF_RATE == false
      @threat += Euphoria::Threat::DEFAULT_BF
      @threat = 100 if @threat > 100
      @threat = 0 if @threat < 0
    end
  end
  
  #ALIAS - ADD_DEBUFF
  alias euphoria_threat_gamebattler_adddebuff_15 add_debuff
  def add_debuff(param_id, turns)
    euphoria_threat_gamebattler_adddebuff_15(param_id, turns)
    if Euphoria::Threat::IND_BF_RATE == true
      case param_id
      when 0
        @threat += Euphoria::Threat::MHP_DEBUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 1
        @threat += Euphoria::Threat::MMP_DEBUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 2
        @threat += Euphoria::Threat::ATK_DEBUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 3
        @threat += Euphoria::Threat::DEF_DEBUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 4
        @threat += Euphoria::Threat::MAG_DEBUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 5
        @threat += Euphoria::Threat::MDF_DEBUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 6
        @threat += Euphoria::Threat::AGI_DEBUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      when 7
        @threat += Euphoria::Threat::LUK_DEBUFF
        @threat = 100 if @threat > 100
        @threat = 0 if @threat < 0
      end
    elsif Euphoria::Threat::IND_DB_RATE == false
      @threat += Euphoria::Threat::DEFAULT_DB
      @threat = 100 if @threat > 100
      @threat = 0 if @threat < 0
    end
  end
  
  #NEW - THREAT
  def threat
    threat = @threat
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Game_Unit
#└──────────────────────────────────────────────────────────────────────────────
class Game_Unit
  
  #ALIAS - INITIALIZE
  alias euphoria_threat_gameunit_initialize_15 initialize
  def initialize
    @threat_array = []
    euphoria_threat_gameunit_initialize_15
  end
  
  #ALIAS - ON_BATTLE_START
  alias euphoria_threat_gameunit_onbattlestart_15 on_battle_start
  def on_battle_start
    members.each {|member| member.threat = 0 }
    euphoria_threat_gameunit_onbattlestart_15
  end
  
  #NEW - THREAT
  def threat
    alive_members.inject(0){|sum,member| sum += member.threat }
  end
  
  #NEW - THREAT_ARRAY
  def threat_array
    @threat_array
  end
  
  #OVERWRITE - RANDOM_TARGET
  def random_target
    if Euphoria::Threat::RANDOM_CHNC == 2
      alive_members.each {|member|
        number = member.threat
        @threat_array.push(number)
      }
      if @threat_array.uniq.size == 1
        tgr_rand = rand * tgr_sum
        alive_members.each do |member|
          tgr_rand -= member.tgr
          return member if tgr_rand < 0
        end
      else
        case rand(Euphoria::Threat::RANDOM_NUM)
        when 1...(Euphoria::Threat::RANDOM_NUM - 1)
          alive_members.max_by {|member|
            member.threat
          }
        when 0
          tgr_rand = rand * tgr_sum
          alive_members.each do |member|
            tgr_rand -= member.tgr
            return member if tgr_rand < 0
          end
        end
      end
    elsif Euphoria::Threat::RANDOM_CHNC == 1
      alive_members.each {|member|
        number = member.threat
        @threat_array.push(number)
      }
      if @threat_array.uniq.size == 1
        tgr_rand = rand * tgr_sum
        alive_members.each do |member|
          tgr_rand -= member.tgr
          return member if tgr_rand < 0
        end
      else
        case rand(Euphoria::Threat::RANDOM_NUM)
        when 1...(Euphoria::Threat::RANDOM_NUM - 1)
          alive_members.max_by {|member|
            member.threat
          }
        when 0
          threat_rand = rand * threat
          alive_members.each do |member|
            threat_rand -= member.threat
            return member if threat_rand < 0
          end
        end
      end
    elsif Euphoria::Threat::RANDOM_CHNC != 1 || Euphoria::Threat::RANDOM_CHNC != 2
      alive_members.each {|member|
        number = member.threat
        @threat_array.push(number)
      }
      if @threat_array.uniq.size == 1
        tgr_rand = rand * tgr_sum
        alive_members.each do |member|
          tgr_rand -= member.tgr
          return member if tgr_rand < 0
        end
      else
        alive_members.max_by {|member|
          member.threat
        }
      end
    end
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_Base
#└──────────────────────────────────────────────────────────────────────────────
class Window_Base < Window
  
  #NEW - DRAW_ACTOR_THREAT
  def draw_actor_threat(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.threat / 100.0, text_color(10), text_color(18))
    change_color(system_color)
    draw_text(x, y, 45, line_height, "Threat")
    change_color(text_color(18))
    draw_text(x + width - 42, y, 42, line_height, actor.threat.to_i, 2)
  end
  
  #NEW - DRAW_THREAT_ICONS
  def draw_threat_icons(actor, x, y, width = 96)
    icons = actor.threat_icons
    draw_icon(icons, x + 24, y)
  end
  
  #NEW - DRAW_ERROR_TEXT
  def draw_error_text(actor, x, y, width = 96, height = line_height, text = "Error")
    draw_text(x, y, width, height, text)
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_BattleStatus
#└──────────────────────────────────────────────────────────────────────────────
class Window_BattleStatus < Window_Selectable
  attr_reader :threat

  #OVERWRITE - DRAW_GAUGE_AREA_WITHOUT_TP
  def draw_gauge_area_without_tp(rect, actor)
    if Euphoria::Threat::ICON_VIEW == true && Euphoria::Threat::HIDE_GAUGE == true
      draw_actor_hp(actor, rect.x + 0, rect.y, 72)
      draw_actor_mp(actor, rect.x + 82,  rect.y, 64)
      draw_threat_icons(actor, rect.x + 156, rect.y, width = 24)
    elsif Euphoria::Threat::HIDE_GAUGE == true && Euphoria::Threat::ICON_VIEW == false
      draw_actor_hp(actor, rect.x + 0, rect.y, 136)
      draw_actor_mp(actor, rect.x + 144,  rect.y, 76)
    elsif Euphoria::Threat::HIDE_GAUGE == false && Euphoria::Threat::ICON_VIEW == true
      draw_actor_hp(actor, rect.x + 0, rect.y, 72)
      draw_actor_mp(actor, rect.x + 82,  rect.y, 64)
      draw_error_text(actor, rect.x + 156, rect.y, 64)
    elsif Euphoria::Threat::HIDE_GAUGE == false && Euphoria::Threat::ICON_VIEW == false
      draw_actor_hp(actor, rect.x + 0, rect.y, 72)
      draw_actor_mp(actor, rect.x + 82,  rect.y, 64)
      draw_actor_threat(actor, rect.x + 156, rect.y, 64)
    end
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Scene_Battle
#└──────────────────────────────────────────────────────────────────────────────
class Scene_Battle < Scene_Base
  
  #ALIAS - TURN_END
  alias euphoria_threat_scenebattle_turnend_15 turn_end
  def turn_end
    $game_party.members.each {|mem|
      mem.threat -= Euphoria::Threat::THREAT_LOSS
      mem.threat = 0 if mem.threat < 0
    }
    $game_troop.members.each {|mem|
      mem.threat -= Euphoria::Threat::THREAT_LOSS
      mem.threat = 0 if mem.threat < 0
    }
    euphoria_threat_scenebattle_turnend_15
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_BattleStatus - YANFLY COMPATIBILITY
#└──────────────────────────────────────────────────────────────────────────────
if $imported["YEA-BattleEngine"] == true
class Window_BattleStatus < Window_Selectable
  attr_reader :threat

  #OVERWRITE - DRAW_ACTOR_THREAT
  def draw_actor_threat(actor, dx, dy, width = 124)
    draw_gauge(dx, dy, width, actor.threat / 100.0, text_color(10), text_color(18))
    change_color(system_color)
    cy = (Font.default_size - contents.font.size) / 2 + 1
    draw_text(dx+2, dy+cy, 45, line_height, "TH")
    change_color(text_color(18))
    draw_text(dx + width - 42, dy+cy, 42, line_height, actor.threat.to_i, 2)
  end
  
  #OVERWRITE - DRAW_ITEM
  def draw_item(index)
    return if index.nil?
    clear_item(index)
    actor = battle_members[index]
    rect = item_rect(index)
    return if actor.nil?
    draw_actor_face(actor, rect.x+2, rect.y+2, actor.alive?)
    draw_actor_name(actor, rect.x, rect.y, rect.width-8)
    draw_actor_icons(actor, rect.x, line_height*1, rect.width)
    gx = YEA::BATTLE::BATTLESTATUS_HPGAUGE_Y_PLUS
    contents.font.size = YEA::BATTLE::BATTLESTATUS_TEXT_FONT_SIZE
    draw_actor_hp(actor, rect.x+2, line_height*2+gx, rect.width-4)
    if Euphoria::Threat::ICON_VIEW == true
      if draw_tp?(actor) && draw_mp?(actor)
        dw = rect.width/2-2
        dw += 1 if $imported["YEA-CoreEngine"] && YEA::CORE::GAUGE_OUTLINE
        draw_actor_tp(actor, rect.x+2, line_height*3, dw)
        dw = rect.width - rect.width/2 - 2
        draw_actor_mp(actor, rect.x+rect.width/2, line_height*3, dw)
      elsif draw_tp?(actor) && !draw_mp?(actor)
        draw_actor_tp(actor, rect.x+2, line_height*3, rect.width-4)
      else
        dw = rect.width/2-2
        dw += 1 if $imported["YEA-CoreEngine"] && YEA::CORE::GAUGE_OUTLINE
        draw_threat_icons(actor, rect.x - 24, rect.y, 24)
        draw_actor_mp(actor, rect.x+2, line_height*3, dw) 
      end
    else
      if draw_tp?(actor) && draw_mp?(actor)
        dw = rect.width/2-2
        dw += 1 if $imported["YEA-CoreEngine"] && YEA::CORE::GAUGE_OUTLINE
        draw_actor_tp(actor, rect.x+2, line_height*3, dw)
        dw = rect.width - rect.width/2 - 2
        draw_actor_mp(actor, rect.x+rect.width/2, line_height*3, dw)
      elsif draw_tp?(actor) && !draw_mp?(actor)
        draw_actor_tp(actor, rect.x+2, line_height*3, rect.width-4)
      else
        dw = rect.width/2-2
        dw += 1 if $imported["YEA-CoreEngine"] && YEA::CORE::GAUGE_OUTLINE
        draw_actor_threat(actor, rect.x+rect.width/2, line_height*3, dw)
        draw_actor_mp(actor, rect.x+2, line_height*3, dw) 
      end
    end
  end
  
end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script
#└──────────────────────────────────────────────────────────────────────────────