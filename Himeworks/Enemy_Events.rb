=begin
#===============================================================================
 Title: Enemy Events
 Author: Hime
 Date: Feb 13, 2014
 URL: http://himeworks.com/2014/01/12/enemy-events/
--------------------------------------------------------------------------------
 ** Change log
 Feb 13, 2014
   - fixed bug where multiple pages referenced the same page object
   - enemy events stored in a hash to easily reference an enemy's added pages
 Jan 12, 2014
   - initial release
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
 
 This script allows you to create "enemy events". Whenever an enemy
 appears in battle, the enemy's event pages are added to the current troop's
 event pages.
 
 The purpose of this script is to allow you to create an enemy's events once
 and then re-use it in multiple troops without having to duplicate event pages
 yourself.
 
 Furthermore, not only can you re-use your event pages, but the pages are only
 added to the current battle if the enemy actually "appears". This means that
 if the enemy was initially hidden (through appear halfway), the pages are
 not added until the enemy appears.
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 -- Creating Enemy Events --
 
 Enemy events are just regular troop events, except they will be added to the
 current battle if the enemy is present.
 
 All of the event commands can be used as usual.
 
 -- Assigning Enemy Events --
 
 To indicate which troop should be assigned as an enemy's event, note-tag an
 enemy with
 
   <enemy event: ID>
   
 Where ID is the ID of the troop whose event pages will be assigned to the
 enemy.
 
 -- Referencing Enemies --
 
 A special feature to this script is that you can actually reference the enemy
 in your enemy events. Simply add the enemy to the troop, and then create your
 event commands. When an enemy appears in battle, the indexes of all of its
 event pages commands will be updated to point to the enemy's current index.
 
 For example, suppose you want to "change enemy state" for a slime at the
 beginning of the battle. In your enemy event, you would add your slime to the
 screen, and then create your command and point to the slime.
 
 When you start a battle where the slime appears, the change state command will
 correctly update itself to point to the slime.
 
 Note that you can only reference the enemy that the pages are being assigned
 to, so even if you add two slimes to the screen, that would not change how
 the script behaves.
 
 -- Merging Enemy Events --
 
 When a battle begins, all enemy event pages will be added to the current
 battle. For example, if your slime has two event pages, then those two event
 pages will be added to the current troop. If the battle has two slimes, then
 each slime will contribute its own event pages to the battle, resulting in 
 four additional pages.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_EnemyEvents] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Enemy_Events
    Regex = /<enemy[-_ ]event:\s*(\d+)\s*>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class Enemy
    def event_pages
      load_notetag_enemy_events unless @enemy_event_pages
      return @enemy_event_pages
    end
    
    def load_notetag_enemy_events
      @enemy_event_pages = []
      results = self.note.scan(TH::Enemy_Events::Regex)
      results.each do |res|
        troop_id = res[0].to_i
        troop = $data_troops[troop_id]
        troop.pages.each do |page|
          process_enemy_event_page(page)
        end
      end
    end
    
    def process_enemy_event_page(page)
      @enemy_event_pages << page
    end
  end
  
  class Troop
    #---------------------------------------------------------------------------
    # Enemy event pages allow you to specify indices to refer to the enemy
    # itself. Therefore, all commands that involve indexes will need to be
    # updated to the enemy's current index in the troop.
    #---------------------------------------------------------------------------
    def add_enemy_event_page(index, page)
      page.list.each do |cmd|
        params = cmd.parameters
        case cmd.code
        when 111 # conditional branch has enemy indexing
          params[1] = index if params[0] == 5
        when 331 # change enemy HP
          params[0] = index unless params[0] < 0
        when 332 # change enemy MP
          params[0] = index unless params[0] < 0
        when 333 # change enemy state
          params[0] = index unless params[0] < 0
        when 334 # enemy recover all
          params[0] = index unless params[0] < 0
        when 335 # enemy appear
          params[0] = index unless params[0] < 0
        when 336 # enemy transform
          params[0] = index unless params[0] < 0
        when 337 # show battle animation
          params[0] = index unless params[0] < 0
        when 339 # force action
          params[1] = index if params[0] == 0
        end
      end
      @pages << page
    end
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Enemy < Game_Battler
  
  def event_pages
    enemy.event_pages
  end
  
  def can_add_event_pages?
    !hidden?
  end
  
  alias :th_enemy_events_appear :appear
  def appear
    th_enemy_events_appear
    $game_troop.add_enemy_event_pages(self)
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Troop < Game_Unit
  
  alias :th_enemy_events_setup :setup
  def setup(*args)
    th_enemy_events_setup(*args)
    @enemy_event_pages = {}
    members.each do |enemy|
      @enemy_event_pages[enemy] ||= []
      add_enemy_event_pages(enemy)
    end
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def add_enemy_event_pages(enemy)
    return unless enemy.can_add_event_pages?
    index = enemy.index
    enemy.event_pages.each do |page|
      new_page = Marshal.load(Marshal.dump(page))
      troop.add_enemy_event_page(index, new_page)
      @enemy_event_pages[enemy].push(new_page)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Removes all enemy event pages for the given enemy
  #-----------------------------------------------------------------------------
  def remove_enemy_event_pages(enemy)
    pages = @enemy_event_pages[enemy]
    return unless pages
    pages.each do |page|
      troop.pages.delete(page)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Removes all custom enemy event pages (that are not part of the troop)
  #-----------------------------------------------------------------------------
  def remove_all_enemy_event_pages
    @enemy_event_pages.each do |enemy, pages|
      remove_enemy_event_pages(enemy)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Delete any of those custom pages that we've added from the database. This is
  # so future use of the troop won't be affected
  #-----------------------------------------------------------------------------
  alias :th_enemy_events_on_battle_end :on_battle_end
  def on_battle_end
    th_enemy_events_on_battle_end
    remove_all_enemy_event_pages
  end
end