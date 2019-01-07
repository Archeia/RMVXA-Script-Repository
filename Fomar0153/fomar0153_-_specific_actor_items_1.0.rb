=begin
Specific Actor Items
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Let's restore a lost feature. This script allows you to make some
items only affect certain characters. My use for this was skill tomes.
----------------------
Instructions
----------------------
Notetag the actor specific items e.g.
<actoritem 1>
just for Eric
<actoritem 1,2>
for Eric and Natalie
etc
Please be aware that the items can be used on the wrong actors but they
will have no affect.
----------------------
Known bugs
----------------------
None
=end
class RPG::Item < RPG::UsableItem
  
  def for_specific_actors?
    if @note =~ /<actoritem (.*)>/i
      return true
    else
      return false
    end
  end
  
  def for_actor(id)
    if @note =~ /<actoritem (.*)>/i
      actor_ids = $1.split(",")
      return actor_ids.include?(id.to_s)
    end
    return 0
  end
  
end

class Game_Battler < Game_BattlerBase
  
  alias aoi_item_test item_test
  def item_test(user, item)
    if item.is_a?(RPG::Item) && item.for_specific_actors?
      return false unless item.for_actor(self.id)
    end
    return aoi_item_test(user, item)
  end
  
end