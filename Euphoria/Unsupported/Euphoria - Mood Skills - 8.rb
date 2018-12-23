#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                             *Mood Skills*
#│                              Version: 1.2
#│                            Author: Euphoria
#│                            Date: 4/30/2014
#│                        Euphoria337.wordpress.com
#│
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: None
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: 1.2) 1-25 and 75-99 Skills Added
#│           1.1) Code Shortened.
#├──────────────────────────────────────────────────────────────────────────────                      
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For Commercial use contact 
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                           
#│■ Instructions: Simply make skills for mood 100, mood 0, mood 75-99, and mood
#│                1-25 in the database and then set the numbers to the skills id 
#│                numbers in the area below. You must have the Mood Gauge script 
#│                for this to work!
#└──────────────────────────────────────────────────────────────────────────────
if $imported["EuphoriaMoodGauge"] != true
msgbox_p("Euporia - Mood Gauge REQUIRED")
exit
else
$imported ||= {}
$imported["EuphoriaMoodSkills"] = true
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Editable Region
#└──────────────────────────────────────────────────────────────────────────────
module Euphoria
  module Mood_Skills
    
    MOOD_100_SKILL = 82   #Skill Number To Learn When Mood Is At 100
    
    MOOD_75_SKILL  = 83   #Skill Number To Learn When Mood Is Between 75 and 99
    
    MOOD_25_SKILL  = 84   #Skill Number To Learn When Mood Is Between 1 and 25
    
    MOOD_0_SKILL   = 81   #Skill Number To Learn When Mood Is At 0

  end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW HERE
#└──────────────────────────────────────────────────────────────────────────────


#┌──────────────────────────────────────────────────────────────────────────────
#│■ Add/Remove Skills
#└──────────────────────────────────────────────────────────────────────────────
class Game_Actor < Game_Battler
  attr_reader :mood
  
  alias euphoria_moodskills_gameactor_initialize_8 initialize
  def initialize(actor_id)
    euphoria_moodskills_gameactor_initialize_8(actor_id)
    @mood = 50
  end
  
  alias euphoria_moodskills_gameactor_refresh_8 refresh
  def refresh
    euphoria_moodskills_gameactor_refresh_8
    mood_skill_change_100
    mood_skill_change_75
    mood_skill_change_25
    mood_skill_change_0
  end
  
  def mood_skill_change_100
      if @mood == 100
      learn_skill(Euphoria::Mood_Skills::MOOD_100_SKILL)
      elsif @mood < 100
      forget_skill(Euphoria::Mood_Skills::MOOD_100_SKILL)
      end
  end
  
  def mood_skill_change_75
      if @mood >= 75 && @mood < 100
      learn_skill(Euphoria::Mood_Skills::MOOD_75_SKILL)
      elsif @mood == 100 || @mood < 75
      forget_skill(Euphoria::Mood_Skills::MOOD_75_SKILL)
      end
  end
  
  def mood_skill_change_25
      if @mood <= 25 && @mood > 0
      learn_skill(Euphoria::Mood_Skills::MOOD_25_SKILL)
      elsif @mood == 0 || @mood > 25
      forget_skill(Euphoria::Mood_Skills::MOOD_25_SKILL)
      end
  end
  
  def mood_skill_change_0
      if @mood == 0
      learn_skill(Euphoria::Mood_Skills::MOOD_0_SKILL)
      elsif @mood > 0
      forget_skill(Euphoria::Mood_Skills::MOOD_0_SKILL)
      end
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script
#└──────────────────────────────────────────────────────────────────────────────