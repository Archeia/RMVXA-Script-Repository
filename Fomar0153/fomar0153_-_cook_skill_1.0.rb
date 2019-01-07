=begin
Cook Skill
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Allows you to cook enemies and cause them to drop a set item.
----------------------
Instructions
----------------------
By default an enemy is only eatable if you set them to have
a cooked drop item. To set it notetag the enemy:
<cook_itemid x>
where x is the id of the item.

By default an enemy has to be under 20% health in order for the 
cook skill to work. You can edit this by notetagging the enemy:
<cook_chance x>
where x is the chance e.g. 20 -> 20%

To set up the skill in the custom damage formula box enter:
b.cook
----------------------
Known bugs
----------------------
None
=end
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias cook_initialize initialize
  def initialize(index, enemy_id)
    cook_initialize(index, enemy_id)
    @cooked = false
  end
  #--------------------------------------------------------------------------
  # * Can you smell what Thalzon is cooking?
  #--------------------------------------------------------------------------
  def cook
    return if enemy.cook_chance == 0 or enemy.cook_itemid == 0
    if @hp < (enemy.cook_chance * mhp)/100
      @cooked = true
      damage = @hp
      add_state(1)
      damage
    else
      0
    end
  end
  #--------------------------------------------------------------------------
  # * Create Array of Dropped Items
  #--------------------------------------------------------------------------
  alias cook_make_drop_items make_drop_items
  def make_drop_items
    if @cooked
      cook_make_drop_items + [$data_items[enemy.cook_itemid]]
    else
      cook_make_drop_items
    end
  end
end

class RPG::Enemy
  
  def cook_chance
    if @cook_chance.nil?
      if @note =~ /<cook_chance (.*)>/i
        @cook_chance = $1.to_i
      else
        @cook_chance = 20
      end
    end
    @cook_chance
  end
  
  def cook_itemid
    if @cook_itemid.nil?
      if @note =~ /<cook_itemid (.*)>/i
        @cook_itemid = $1.to_i
      else
        @cook_itemid = 0
      end
    end
    @cook_itemid
  end
  
end