=begin
Unique Classes Script
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Useless by itself.
This script allows for scripters to develop more individual
characters or classes with less concern for
----------------------
Instructions
----------------------
Edit the case like this:
when class_id # Class Name
  @data[actor_id] ||= Game_ClassName.new(actor_id)

Follow the instructions in any Unique Class you add
----------------------
Known Bugs
----------------------
None
=end
class Game_Actors
  #--------------------------------------------------------------------------
  # ● Rewrites []
  #--------------------------------------------------------------------------
  def [](actor_id)
    return nil unless $data_actors[actor_id]
    case $data_actors[actor_id].class_id
    # All edits should take place in this case
    when 1 # Weapon Master
      @data[actor_id] ||= Game_WeaponMaster.new(actor_id)
    when 2, 3 # Blue Mage
      @data[actor_id] ||= Game_BlueMage.new(actor_id)
    when 4 # Skill Master
      @data[actor_id] ||= Game_SkillMaster.new(actor_id)
    else
      @data[actor_id] ||= Game_Actor.new(actor_id)
    end
  end
end