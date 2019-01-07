=begin
EST - Clone Actor v1.1

version history
v1.0 - 2012-12-10 - finished the script
v1.1 - 2013-01-03 - fixed some bugs

add new actor based on existing one.
could be used for pokemon games.
ex: create actor 5 as pikachu.
then use
$game_party.add_custom_actor(5,30,"Pikachu A")

then you will get new actor
who is like actor 5 (pikachu)
will enter party at lv 30
then named "Pikachu A"

all the feature of the base actor will be gained
even the initial equipment will be the same
=end
$imported = {} if $imported.nil?
$imported["EST - CLONE ACTOR"] = true

class Game_Actors
  def set(actor_id, actor)
  @data[actor_id] = actor
  end  
end



class Game_Party < Game_Unit

  def add_custom_actor(actor_id,level=nil,name=nil)
  clone_data = $data_actors[actor_id].clone
  clone_data.base_actor = actor_id
  clone_data.custom_actor = true
  new_actor_id = $data_actors.size 
  $data_actors.push(clone_data)  

  actor = Game_Actor.new(new_actor_id)
  actor.level = level if level
  actor.init_exp if level
  actor.init_skills if level
  actor.clear_param_plus if level
  actor.recover_all if level
  actor.name = name if name
  
  $game_actors.set(new_actor_id, actor)
  
  @actors.push(actor.id)
  $game_player.refresh
  $game_map.need_refresh = true
  end
    
  def members_by_base_actor(actor_id)
    all_members.select {|actor| actor.base_actor_id == actor_id}
  end
  
end

class RPG::Actor < RPG::BaseItem
  attr_accessor :base_actor
  attr_accessor :custom_actor
  def base_actor
    return @base_actor if @base_actor
    return @id
  end
  def custom_actor?
    return @custom_actor if @custom_actor
    return false
  end
end # RPG::Actor


class Game_Actor < Game_Battler
  attr_accessor :level
  attr_accessor :base_actor_id
    
  alias set_base_actor_init initialize
  def initialize(actor_id)
    set_base_actor_init(actor_id)
    @base_actor_id = $data_actors[actor_id].base_actor
  end
    
end