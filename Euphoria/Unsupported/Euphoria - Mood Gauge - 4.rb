#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                              *Mood Gauge*
#│                              Version: 1.2
#│                            Author: Euphoria
#│                             Date: 5/1/2014
#│                        Euphoria337.wordpress.com
#│
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: This script overwrites the methods: draw_actor_simple_status
#│                                                 draw_guage_area_without_tp
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: 1.2) Ability To Add Mood Gauge To Battle.
#│           1.1) Fixed Mood To Stay Between 0 And 100.
#├──────────────────────────────────────────────────────────────────────────────                     
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For Commercial use contact 
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                          
#│■ Instructions: The mood meter should start at neutral for all characters (50),
#│                to increase an actors mood use the script call: 
#│
#│                $game_actors[x].mood_plus         x = actor ID
#│
#│                to decrease an actors mood use the script call:
#│
#│                $game_actors[x].mood_minus        x = actor ID
#│
#│                For use in conditional branches the script calls are:
#│                  
#│                $game_actors[x].mood == y         x = actor ID, y = mood value
#│
#│                $game_actors[x].mood <= y         x = actor ID, y = mood value
#│
#│                $game_actors[x].mood >= y         x = actor ID, y = mood value
#│
#│                To use the mood gauge in battle you MUST disable TP in the 
#│                database, if you do not wish to use mood in battle set the 
#│                option to false below.
#└──────────────────────────────────────────────────────────────────────────────
$imported ||= {}
$imported["EuphoriaMoodGauge"] = true
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Editable Region Below
#└──────────────────────────────────────────────────────────────────────────────
module Euphoria
  module Gauge
    
    BATTLE_MOOD_GAUGE = true     #True if you want to show mood in battle
    
  end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW HERE
#└──────────────────────────────────────────────────────────────────────────────


#┌──────────────────────────────────────────────────────────────────────────────
#│■ Add Mood To Menu
#└──────────────────────────────────────────────────────────────────────────────
class Window_Base < Window

  alias euphoria_moodmeter_windowbase_initialize_4 initialize
  def initialize(x, y, width, height)
    euphoria_moodmeter_windowbase_initialize_4(x, y, width, height)
  end
  
  alias euphoria_moodmeter_windowbase_update_4 update
  def update
   euphoria_moodmeter_windowbase_update_4
  end
  
  def draw_actor_simple_status(actor, x, y)
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_class(actor, x, y + line_height * 2)
    draw_actor_hp(actor, x + 120, y)
    draw_actor_mp(actor, x + 120, y + line_height * 1)
    draw_actor_mood(actor, x + 120, y + line_height * 2)
  end

  def draw_actor_mood(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.mood / 100.0, text_color(22), text_color(29))
    change_color(system_color)
    draw_text(x, y, 30, line_height, "Mood")
    draw_current_and_max_values(x, y, width, actor.mood, 100, text_color(0), text_color(0))
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Set Mood Operations
#└──────────────────────────────────────────────────────────────────────────────
class Game_Actor < Game_Battler
  attr_accessor :mood
  
  alias euphoria_moodmeter_gameactor_setup_4 setup
  def setup(actor_id)
    euphoria_moodmeter_gameactor_setup_4(actor_id)
    @mood = 50
  end
  
  def mood
    mood = @mood
  end
  
  def mood_plus
    @mood += 5 unless @mood == 100
  end
  
  def mood_minus
    @mood -= 5 unless @mood == 0
  end

end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Show Mood In Battle
#└──────────────────────────────────────────────────────────────────────────────
class Window_BattleStatus < Window_Selectable

  def draw_gauge_area_without_tp(rect, actor)
     if Euphoria::Gauge::BATTLE_MOOD_GAUGE == true
     draw_actor_hp(actor, rect.x + 0, rect.y, 72)
     draw_actor_mp(actor, rect.x + 82, rect.y, 64)
     draw_actor_mood(actor, rect.x + 156, rect.y, 64)
     else
     draw_actor_hp(actor, rect.x + 0, rect.y, 134)
     draw_actor_mp(actor, rect.x + 144,  rect.y, 76)
     end
  end

end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script
#└──────────────────────────────────────────────────────────────────────────────