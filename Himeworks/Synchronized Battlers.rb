=begin
#===============================================================================
 Title: Synchronized Battlers
 Author: Hime
 Date: Nov 13, 2013
 URL: http://himeworks.com/2013/11/10/synchronized-battlers/
--------------------------------------------------------------------------------
 ** Change log
 Nov 13, 2013
  - implemented actor sync and link
 Nov 12, 2013
  - introduced sync link object
  - added "sync_death" flag if enemy dies from sync death effect
 Nov 10, 2013
  - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to "link" battlers together. Linked battlers can share
 some special properties that regular battlers do not have.
 
 Links follow a parent-child relationship. When the parent dies, the
 child also dies. But if the child dies, nothing happens to the parent.
 You can set up a two-way link between a parent and a child such that when
 the child dies, so does the parent.
 
 Suppose you have a hydra that consists of three heads and a body.
 When you kill a head, the rest of the heads and the body is unaffected,
 but when you kill the body, the heads will also die. The hydra's body is the
 parent, and each head is a child.

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 -- Linking Enemies --
 
 To link two enemies together, make the script call
 
   link_enemy(child_index, parent_index)
   link_enemy(child_index, parent_index, two_way)
   
 Where the index is based on the order that the enemy was inserted into the
 troop. You can look up the index by selecting one of the "enemy battle" event
 commands such as "Change Enemy HP", showing the dropdown list, and looking at
 the index before the enemy name.
 
 `two_way` is either true or false, and is used to establish a two-way link
 between child-parent and parent-child.
 
 -- Unlinking enemies --
 
 To unlink two enemies, make the script call
 
   unlink_enemy(child_index, parent_index)
   
 This will break any links between two enemies. If the link was established
 as a two-way link, then the two-way link will be broken as well.
 
 -- Linking actors --
 
 To link two actors, make the script call
 
   link_actor(child_index, parent_index)
   link_actor(child_index, parent_index, two_way)
   
 Where the index is a number that can represent two things: if the index is
 positive, then it is the actor ID. If the index is negative, then it is
 the party index. For example, an index of 3 would mean "actor 3", but an index
 of -3 would mean "the actor in the 3rd party position"
 
 -- Unlinking actors --
 
 To unlink two actors, make the script call
 
   unlink_actor(child_index, parent_index)
   
    
 -- Linking battlers --
 
 You can link actors to enemies, or enemies to actors as well.
 Unlike the previous linking methods where you pass in indices, this time you
 need to pass in battler objects.
 
 There are two methods available to make this easy for you:
 
   get_actor(index) - returns an actor for the given index
   get_enemy(index) - returns an enemy for the given index
   
 The indexing rules are the same as before. When you have your actor and enemy,
 you can now link them together like this
 
   actor = get_actor(-2)
   enemy = get_enemy(3)
   link_battler(actor, enemy)
   
 This will link the actor to tne enemy, where the actor is the child and
 the enemy is the parent.
 
--------------------------------------------------------------------------------
 ** Example
 
 To set up the hydra example, you would create a troop consisting of a hydra
 body and three hydra heads. Assume the body is index 1, and the heads
 are indices 2, 3, 4.
 
 Then you would make the following script calls to run at the beginning of the
 battle
 
   link_enemy(2, 1)  # link first head to body
   link_enemy(3, 1)  # link second head to body
   link_enemy(4, 1)  # link third head to body
   
 Now, when the body is killed, all three heads will die as well.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_SynchronizedBattlers"] = true
#===============================================================================
# ** Rest of script
#===============================================================================
class Data_SyncLink
  
  attr_reader :parent
  attr_reader :child
  
  def initialize(parent, child, two_way=false)
    @parent = parent
    @child = child
    @two_way = two_way
  end
  
  #-----------------------------------------------------------------------------
  # Returns true if it's a two-way link.
  #-----------------------------------------------------------------------------
  def two_way?
    @two_way
  end
end

class Game_BattlerBase
  attr_reader :sync_check
  attr_accessor :sync_death
  attr_reader :sync_links
  
  alias :th_synchronized_battlers_initialize :initialize
  def initialize
    th_synchronized_battlers_initialize
    @sync_parent = nil
    clear_sync_links
    clear_sync_check
  end
  
  #-----------------------------------------------------------------------------
  # Hack workaround.
  #-----------------------------------------------------------------------------
  alias :th_sync_effects_refresh :refresh
  def refresh
    th_sync_effects_refresh
    perform_collapse_effect if dead?
  end
  
  def clear_sync_links
    @sync_links = []
  end
  
  def clear_sync_check
    @sync_check = false
  end
  
  def sync_battler?
    !@sync_links.empty?
  end
  
  def sync_death?
    @sync_death
  end
  
  def link_battler(battler, two_way)
    @sync_check = true
    syncLink = Data_SyncLink.new(self, battler, two_way)
    @sync_links.push(syncLink)
    battler.link_battler(self, two_way) if two_way && !battler.sync_check
    @sync_check = false
  end
  
  def unlink_battler(battler)
    @sync_check = true
    syncLink = @sync_links.find {|link| link.child == battler }
    if syncLink
      @sync_links.delete(syncLink)
      battler.unlink_battler(self) if syncLink.two_way? && !battler.sync_check
    end
    @sync_check = false  
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def perform_sync_collapse(battler)
    battler.sync_death = true
    battler.hp = 0
    battler.perform_collapse_effect
  end
end

class Game_Enemy < Game_Battler
  
  alias :th_synchronized_battlers_perform_collapse_effect :perform_collapse_effect
  def perform_collapse_effect
    @sync_check = true
    th_synchronized_battlers_perform_collapse_effect
    @sync_links.each do |syncLink|
      battler = syncLink.child
      perform_sync_collapse(battler) unless battler.sync_check || battler.dead?
    end
    @sync_check = false
  end
end

class Game_Actor < Game_Battler
  
  alias :th_synchronized_battlers_perform_collapse_effect :perform_collapse_effect
  def perform_collapse_effect
    @sync_check = true
    th_synchronized_battlers_perform_collapse_effect
    @sync_links.each do |syncLink|
      battler = syncLink.child
      perform_sync_collapse(battler) unless battler.sync_check || battler.dead?
    end
    @sync_check = false
  end
end

class Game_Interpreter
  
  def get_enemy(index)
    return $game_troop.members[index-1]
  end
  
  def get_actor(index)
    if index < 0
      return $game_party.members[index * -1]
    else
      return $game_actors[index]
    end
  end
  
  #-----------------------------------------------------------------------------
  # Links a child enemy to another enemy
  #-----------------------------------------------------------------------------
  def link_enemy(child_index, parent_index, two_way=false)
    parent = get_enemy(parent_index)
    child = get_enemy(child_index)
    parent.link_battler(child, two_way)
  end
  
  def unlink_enemy(child_index, parent_index, two_way=false)
    parent = get_enemy(parent_index)
    child = get_enemy(child_index)
    parent.unlink_battler(child, two_way)
  end
  
  def link_actor(child_index, parent_index, two_way=false)
    parent = get_actor(parent_index)
    child = get_actor(child_index)
    parent.link_battler(child, two_way)
  end
  
  def unlink_actor(child_index, parent_index)
    parent = get_actor(parent_index)
    child = get_actor(child_index)
    parent.unlink_battler(child)
  end
  
  def link_battler(child, parent, two_way=false)
    parent.link_battler(child, two_way)
  end
  
  def unlink_battler(child, parent)
    parent.unlink_battler(child)
  end
end