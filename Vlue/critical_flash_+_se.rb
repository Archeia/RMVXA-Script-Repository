#Critical Flash + Sound Effect v1.3
#----------#
#Features: Provides the ability to have the screen flash and a se to play
#          upon any critical strike
#
#Usage:    None! Plug and play.
#
#Customization follows in the script, can edit filename, volume and pitch of se
#   and color and duration of flash
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
 
#class Scene_Battle < Scene_Base
class Game_Battler < Game_BattlerBase
  #---------#
  #PLAYSE to true to play SE. Filename (in quotes), Volume (0-100), Pitch, (0-150)
  #---------#
  PLAYSE       = true
  CSE_FILENAME = "Skill3"
  CSE_VOLUME   = 100
  CSE_PITCH    = 100
 
  #Here we go if you wish to have a random assortment of Se's play:
  USE_RANDOM   = false
  #Array format: [ [ "filename" , volume , pitch ] , ]
  RANDOM_SE    = [["Skill1",100,100],["Skill2",100,100],["Skill3",100,100]]
  #---------#
  #FLASH to true to execute flash
  #Color in (Red,Green,Blue,Alpha) format (0-255), Duration in frames
  #---------#
  FLASH        = true
  FLASHCOLOR   = Color.new(255,255,255,255)
  FLASHDURAT   = 30
  
  #Want to set it up so you have to time a button press to land a critical?
  #Well some people do, and for you people, there's this:
  #Total time is time to press button and min <> max is window to press it right
  PRESS_FOR_CRITICAL = false
  TOTAL_TIME_TO_PRESS = 30
  MIN_TIME_FOR_CRIT = 10
  MAX_TIME_FOR_CRIT = 20
  CRIT_INPUT_TRIGGER = :C
  #---------#END
  alias crit_item_apply item_apply
  def item_apply(user, item)
    if self.is_a?(Game_Actor)
      crit_item_apply(user,item)
    else
      @result.clear
      if PRESS_FOR_CRITICAL
        TOTAL_TIME_TO_PRESS.times do |i|
          Input.update
          Graphics.update
          if(Input.trigger?(CRIT_INPUT_TRIGGER))
            if i > MIN_TIME_FOR_CRIT && i < MAX_TIME_FOR_CRIT
              @result.critical = true
            end
            break
          end
        end
      end
      @result.used = item_test(user, item)
      @result.missed = (@result.used && rand >= item_hit(user, item))
      @result.evaded = (!@result.missed && rand < item_eva(user, item))
      if @result.hit?
        unless item.damage.none?
          @result.critical = (rand < item_cri(user, item)) unless PRESS_FOR_CRITICAL
          make_damage_value(user, item)
          execute_damage(user)
        end
        item.effects.each {|effect| item_effect_apply(user, item, effect) }
        item_user_effect(user, item)
      end
    end
    play_critical_flash if @result.critical
  end
  def play_critical_flash
    $game_troop.screen.start_flash(FLASHCOLOR, FLASHDURAT) if FLASH
    play_critical_se if PLAYSE
  end
  def play_critical_se
    if !USE_RANDOM
      Audio.se_play('Audio/SE/' + CSE_FILENAME,CSE_VOLUME,CSE_PITCH)
    else
      id = rand(RANDOM_SE.size)
      Audio.se_play("Audio/SE/" + RANDOM_SE[id][0],RANDOM_SE[id][1],RANDOM_SE[id][2])
    end
  end
end