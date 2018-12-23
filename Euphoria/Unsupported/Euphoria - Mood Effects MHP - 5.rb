#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                           *Mood Effects MHP*
#│                              Version: 1.0
#│                            Author: Euphoria
#│                            Date: 4/29/2014
#│                        Euphoria337.wordpress.com
#│
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: None
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: None
#├──────────────────────────────────────────────────────────────────────────────
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For commercial use contact 
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                          
#│■ Instructions: Plug 'N Play, as long as you have the Mood Gauge script! This
#│                script will add or subtract from your MHP based on your
#│                character's mood.
#└──────────────────────────────────────────────────────────────────────────────


#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW HERE
#└──────────────────────────────────────────────────────────────────────────────
if $imported["EuphoriaMoodGauge"] != true
msgbox_p("Euporia - Mood Gauge REQUIRED")
exit
else
$imported ||= {}
$imported["EuphoriaMoodEffectsHP"] = true
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Apply MHP Change
#└──────────────────────────────────────────────────────────────────────────────
class Game_Actor < Game_Battler
  attr_accessor :mood
  
  alias euphoria_moodeffects_gameactor_initialize_5  initialize
  def initialize(actor_id)
    @mood = 50
    euphoria_moodeffects_gameactor_initialize_5(actor_id)
  end
  
  alias euphoria_moodeffects_gameactor_mhp_5 mhp
  def mhp
    max_hp = euphoria_moodeffects_gameactor_mhp_5
    case @mood
    when 100 then
      (max_hp * 1.25).to_i
    when 75..99 then
      (max_hp * 1.10).to_i
    when 51..75 then
      (max_hp * 1.05).to_i
    when 50 then
      (max_hp * 1.00).to_i
    when 26..49 then
      (max_hp * 0.95).to_i
    when 1..25 then
      (max_hp * 0.90).to_i
    when 0 then
      (max_hp * 0.75).to_i
    else
      max_hp
    end
  end

  alias euphoria_moodeffects_gameactor_hprate_5 hp_rate
  def hp_rate
    refresh 
    euphoria_moodeffects_gameactor_hprate_5 
  end

  def hp
    refresh
    return @hp
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script
#└──────────────────────────────────────────────────────────────────────────────