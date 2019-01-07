=begin
#===============================================================================
 Title: Encounter Alert
 Author: Hime
 Date: Mar 3, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 3
   - added max encounter points formula
   - added encounter level and encounter points
 Nar 2
   - added "disable movement" option
 Mar 1, 2013
   - added skip condition
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
 
 This script displays an encounter balloon over your player character on the
 map whenever you are about to encounter a random battle monster. 
 
 When this balloon is displayed, the player can choose to skip the random
 encounter by pressing a specific button.
 
 This only applies to random encounters.
 
--------------------------------------------------------------------------------
 ** Usage
 
 Download the encounter_balloons spritesheet and place it in your 
 Graphics/System folder.
 
 There are several configuration options.
 
 -- Skip Condition --
 
 Each troop comes with a "skip condition", which is a special condition
 associated with the troop that determines whether your party can skip
 the battle or not.
 
 To set up a skip condition:
 
 1. create an event page for the troop
 2. the first command must be a comment, with the line "<encounter skip>"
 3. the second command is a conditional branch, which you will use to specify
    the skip condition
    
 Whenever a random encounter appears, the colour of the balloon determines
 whether you can skip the battle or not: if it is red, then you can't skip.
 If it is blue, then you can skip. The skip condition must be met in order
 for the balloon to be blue. If no skip condition is specified, then it is
 assumed to be not skippable.
 
 -- Encounter Points --
 
 In order to skip battles, you must have enough "encounter points".
 Each troop may require a certain amount of encounter points in order to skip.
 If you choose to skip the battle, then your encounter points will decrease
 by that amount.
 
 The encounter points are stored with the game party, and tied to
 a variable of your choice.
 
 To specify the amount of encounter points is required to skip a battle:
 
 1. In the same troop page that you used for the skip condition
 2. Create a comment "<encounter points>"
 3. Create a "control variable" command, and use the script box to set the
    amount of encounter points required. This is a formula.
    
 The max amount of points you have can be set in the configuration.
 You will use a formula.
 
 -- Encounter Level --
 
 In addition to encounter points, a party also has an encounter level.
 This can be used in the encounter points formula.
 
 You can change the encounter level using script calls
 
   encounter_level_up(x)
   encounter_level_down(x)
   
 For some integer `x`
 
 -- System options --
 
 You can disable the encounter balloon option by making a script call
  
    disable_encounter_balloon
    enable_encounter_balloon
    
 If disabled, random encounters will be processed as usual.
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_EncounterAlert"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Encounter_Alert
    
    # Button to press to avoid random encounter
    Skip_Key = :C
    
    # Disable menu access when the encounter balloon appears
    Disable_Menu = true
    
    # Disable player movement when encounter balloon appears
    Disable_Movement = true
    
    # Sound effect to play when you encounter a random battle
    Play_SE = true          # you can disable it
    Encounter_SE = "Flash2" # the SE filename
    
    # Variable to store "encounter points" and "encounter level"
    Points_Var = 5
    Level_Var = 6
    
    # How many encounter points or level you initially begin with
    Initial_Points = 10
    Initial_Level = 1
    
    # A formula that determines your max points. You can use the "enc_level"
    # to base the maximum on your encounter level
    Points_Max_Formula = "enc_level * 10"
    
    # Max encounter level
    Level_Max = 30
    
    #---------------------------------------------------------------------------
    # The following options are related to the encounter balloon sprite
    # and animation
    #---------------------------------------------------------------------------
    
    # name of encounter balloon sprite-sheet
    Spritesheet_Name = "Encounter_Balloons"
    
    # ID's of the balloons to display depending on whether you can skip the
    # random encounter or not
    No_Skip_ID = 1
    Can_Skip_ID = 2
    
    # Some balloon animation settings
    Balloon_Speed  = 8    # how fast it animates
    Balloon_Wait   = 12   # how long it will appear
    Balloon_Frames = 7    # number of frames in your sequence, minus 1
    Balloon_Width  = 32   # width of balloon frame
    Balloon_Height = 32   # height of balloon frame
    
    # Comment to use in the troop event page for specifying skip condition
    Skip_Regex = /<encounter skip>/i
    Points_Regex = /<encounter points>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class Troop
    
    #---------------------------------------------------------------------------
    # 
    #---------------------------------------------------------------------------
    def skip_condition
      return @skip_condition unless @skip_condition.nil?
      parse_encounter_skip
      return @skip_condition
    end
    
    def encounter_points
      return @encounter_points unless @encounter_points.nil?
      parse_encounter_skip
      return @encounter_points
    end
    
    #---------------------------------------------------------------------------
    # Look for a page where the first command is a comment matches the
    # encounter skip regex. The next command is assumed to be a conditional
    # branch that represents the skip condition
    #---------------------------------------------------------------------------
    def parse_encounter_skip
      @skip_condition = false
      @encounter_points = false
      page = self.pages.detect {|page| page.list[0].code == 108 && page.list[0].parameters[0] =~ TH::Encounter_Alert::Skip_Regex}
      return unless page
      index = -1
      page.list.each {|cmd|
        index += 1
        if cmd.indent > 0
          next          
        elsif cmd.code == 108 && cmd.parameters[0] =~ TH::Encounter_Alert::Skip_Regex
          index += 1
          @skip_condition = page.list[index]
        elsif cmd.code == 108 && cmd.parameters[0] =~ TH::Encounter_Alert::Points_Regex
          @encounter_points = page.list[index]
        end
      }
      self.pages.delete(page)
    end
  end
end

#-------------------------------------------------------------------------------
# Store some system settings that can be toggled in-game
#-------------------------------------------------------------------------------
class Game_System
  attr_accessor :disable_encounter_balloon
  
  alias :th_encounter_alert_init :initialize
  def initialize
    th_encounter_alert_init
    @disable_encounter_balloon = false
  end
end

class Game_Variables
  
  alias :th_encounter_alert_on_change :on_change
  def on_change
    $game_party.set_encounter_points(@data[TH::Encounter_Alert::Points_Var])
    $game_party.set_encounter_level(@data[TH::Encounter_Alert::Level_Var])
    th_encounter_alert_on_change
  end
  
  def set_encounter_level(n)
    @data[TH::Encounter_Alert::Level_Var] = n
  end
  
  def set_encounter_points(n)
    @data[TH::Encounter_Alert::Points_Var] = n
  end
end

#-------------------------------------------------------------------------------
# Store the encounter balloon ID
#-------------------------------------------------------------------------------
class Game_CharacterBase
  attr_accessor :encounter_balloon_id
  
  alias :th_encounter_alert_init_public :init_public_members
  def init_public_members
    th_encounter_alert_init_public
    @encounter_balloon_id = 0
  end
end

#-------------------------------------------------------------------------------
# Manage party encounter level
#-------------------------------------------------------------------------------
class Game_Party < Game_Unit
  attr_accessor :encounter_level
  attr_accessor :encounter_points
  
  alias :th_encounter_alert_init :initialize
  def initialize
    th_encounter_alert_init
    @encounter_level = TH::Encounter_Alert::Initial_Level
    @encounter_points = TH::Encounter_Alert::Initial_Points
    update_encounter_level_variable
    update_encounter_points_variable
  end
  
  def encounter_level_up(amount)
    @encounter_level = [@encounter_level + amount, encounter_level_max].min
    update_encounter_level_variable
  end
  
  def encounter_level_down(amount)
    @encounter_level = [@encounter_level - amount, 1].max
    update_encounter_level_variable
  end
  
  def gain_encounter_points(amount)
    @encounter_points = [@encounter_points + amount, encounter_points_max].min
    update_encounter_points_variable
  end
  
  def lose_encounter_points(amount)
    @encounter_points = [@encounter_points - amount, 0].max
    update_encounter_points_variable
  end
  
  def encounter_level_max
    TH::Encounter_Alert::Level_Max
  end
  
  def encounter_points_max
    eval_encounter_points_max(@encounter_level)
  end
  
  def eval_encounter_points_max(enc_level)
    eval(TH::Encounter_Alert::Points_Max_Formula)
  end
  
  def set_encounter_points(n)
    @encounter_points = [n, encounter_points_max].min
    update_encounter_points_variable
  end
  
  def set_encounter_level(n)
    @encounter_level = [n, encounter_level_max].min
    update_encounter_level_variable
  end
  
  def update_encounter_level_variable
    $game_variables.set_encounter_level(@encounter_level)
  end
  
  def update_encounter_points_variable
    $game_variables.set_encounter_points(@encounter_points)
  end
end

#-------------------------------------------------------------------------------
# Optionally disable movement when encounter balloon appears
#-------------------------------------------------------------------------------
class Game_Player < Game_Character
  
  alias :th_encounter_alert_movable? :movable?
  def movable?
    return false if @encounter_balloon_id > 0 && TH::Encounter_Alert::Disable_Movement
    th_encounter_alert_movable?
  end
end

#-------------------------------------------------------------------------------
# Convenience methods for events
#-------------------------------------------------------------------------------
class Game_Interpreter
  
  def disable_encounter_balloon
    $game_system.disable_encounter_balloon = true
  end
  
  def enable_encounter_balloon
    $game_system.disable_encounter_balloon = false
  end
  
  def encounter_level_up(amount)
    $game_party.encounter_level_up(amount)
  end
  
  def encounter_level_down(amount)
    $game_party.encounter_level_down(amount)
  end
end

#-------------------------------------------------------------------------------
# Store information about battle skipping, such as the skip condition and
# number of encounter points required to skip
#-------------------------------------------------------------------------------
class Game_Troop < Game_Unit
  
  def encounter_points_needed
    cmd = troop.encounter_points
    return 0 unless cmd
    return eval(cmd.parameters[4])
  end
  
  #-----------------------------------------------------------------------------
  # New. Copied over from the interpreter. Basically the same logic, except
  # certain cases are not available...
  #-----------------------------------------------------------------------------
  def skip_condition_met?
    points = encounter_points_needed
    return false if $game_party.encounter_points < points
    condition = troop.skip_condition
    return false unless condition
    params = condition.parameters
    result = false
    case params[0]
    when 0  # Switch
      result = ($game_switches[params[1]] == (params[2] == 0))
    when 1  # Variable
      value1 = $game_variables[params[1]]
      if params[2] == 0
        value2 = params[3]
      else
        value2 = $game_variables[params[3]]
      end
      case params[4]
      when 0  # value1 is equal to value2
        result = (value1 == value2)
      when 1  # value1 is greater than or equal to value2
        result = (value1 >= value2)
      when 2  # value1 is less than or equal to value2
        result = (value1 <= value2)
      when 3  # value1 is greater than value2
        result = (value1 > value2)
      when 4  # value1 is less than value2
        result = (value1 < value2)
      when 5  # value1 is not equal to value2
        result = (value1 != value2)
      end
    #when 2  # Self switch
      #if @event_id > 0
        #key = [$game_map.map_id, @event_id, params[1]]
        #result = ($game_self_switches[key] == (params[2] == 0))
      #end
    when 3  # Timer
      if $game_timer.working?
        if params[2] == 0
          result = ($game_timer.sec >= params[1])
        else
          result = ($game_timer.sec <= params[1])
        end
      end
    when 4  # Actor
      actor = $game_actors[params[1]]
      if actor
        case params[2]
        when 0  # in party
          result = ($game_party.members.include?(actor))
        when 1  # name
          result = (actor.name == params[3])
        when 2  # Class
          result = (actor.class_id == params[3])
        when 3  # Skills
          result = (actor.skill_learn?($data_skills[params[3]]))
        when 4  # Weapons
          result = (actor.weapons.include?($data_weapons[params[3]]))
        when 5  # Armors
          result = (actor.armors.include?($data_armors[params[3]]))
        when 6  # States
          result = (actor.state?(params[3]))
        end
      end
    when 5  # Enemy
      enemy = $game_troop.members[params[1]]
      if enemy
        case params[2]
        when 0  # appear
          result = (enemy.alive?)
        when 1  # state
          result = (enemy.state?(params[3]))
        end
      end
    #when 6  # Character
      #character = get_character(params[1])
      #if character
        #result = (character.direction == params[2])
      #end
    when 7  # Gold
      case params[2]
      when 0  # Greater than or equal to
        result = ($game_party.gold >= params[1])
      when 1  # Less than or equal to
        result = ($game_party.gold <= params[1])
      when 2  # Less than
        result = ($game_party.gold < params[1])
      end
    when 8  # Item
      result = $game_party.has_item?($data_items[params[1]])
    when 9  # Weapon
      result = $game_party.has_item?($data_weapons[params[1]], params[2])
    when 10  # Armor
      result = $game_party.has_item?($data_armors[params[1]], params[2])
    when 11  # Button
      result = Input.press?(params[1])
    when 12  # Script
      result = eval(params[1])
    when 13  # Vehicle
      result = ($game_player.vehicle == $game_map.vehicles[params[1]])
    end
    return result
  end
end

#-------------------------------------------------------------------------------
# Useful to retrieve the player's sprite
#-------------------------------------------------------------------------------
class Spriteset_Map
  
  attr_reader :player_sprite
  
  alias :th_encounter_alert_create_characters :create_characters
  def create_characters
    th_encounter_alert_create_characters
    @player_sprite = @character_sprites.detect {|spr| spr.character == $game_player}
  end
end

#-------------------------------------------------------------------------------
# Manage the encounter balloon
#-------------------------------------------------------------------------------
class Sprite_Character < Sprite_Base
  
  alias :th_encounter_alert_initialize :initialize
  def initialize(viewport, character = nil)
    @encounter_balloon_duration = 0
    th_encounter_alert_initialize(viewport, character)
  end
  
  alias :th_encounter_alert_update :update
  def update
    th_encounter_alert_update
    update_encounter_balloon
  end
  
  def dispose_encounter_balloon
    if @encounter_balloon_sprite
      @encounter_balloon_sprite.dispose
      @encounter_balloon_sprite = nil
    end
  end
  
  alias :th_encounter_alert_setup_new_effect :setup_new_effect
  def setup_new_effect
    th_encounter_alert_setup_new_effect
    if !@encounter_balloon_sprite && @character.encounter_balloon_id > 0
      @encounter_balloon_id = @character.encounter_balloon_id
      start_encounter_balloon
    end
  end
  
  def start_encounter_balloon
    dispose_encounter_balloon
    @encounter_balloon_duration = 8 * balloon_speed + balloon_wait
    @encounter_balloon_sprite = ::Sprite.new(viewport)
    @encounter_balloon_sprite.bitmap = Cache.system(TH::Encounter_Alert::Spritesheet_Name)
    @encounter_balloon_sprite.ox = 16
    @encounter_balloon_sprite.oy = 32
    update_encounter_balloon
  end
  
  #-----------------------------------------------------------------------------
  # New. Dispose of the encounter balloon immediately
  #-----------------------------------------------------------------------------
  def end_encounter_balloon
    @encounter_balloon_duration = 0
    dispose_encounter_balloon
    @character.encounter_balloon_id = 0
  end
  
  def update_encounter_balloon
    if @encounter_balloon_duration > 0
      @encounter_balloon_duration -= 1
      if @encounter_balloon_duration > 0
        w = TH::Encounter_Alert::Balloon_Width
        h = TH::Encounter_Alert::Balloon_Height
        @encounter_balloon_sprite.x = x
        @encounter_balloon_sprite.y = y - height
        @encounter_balloon_sprite.z = z + 200
        sx = encounter_balloon_frame_index * w
        sy = (@encounter_balloon_id - 1) * h
        @encounter_balloon_sprite.src_rect.set(sx, sy, w, h)
      else
        end_encounter_balloon
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # How fast it goes through each frame
  #-----------------------------------------------------------------------------
  def encounter_balloon_speed
    TH::Encounter_Alert::Balloon_Speed
  end
  
  #-----------------------------------------------------------------------------
  # How long the balloon will be shown
  #-----------------------------------------------------------------------------
  def encounter_balloon_wait
    TH::Encounter_Alert::Balloon_Wait
  end
  
  #-----------------------------------------------------------------------------
  # Number of frames in the sequence - 1
  #-----------------------------------------------------------------------------
  def encounter_balloon_frame_count
    TH::Encounter_Alert::Balloon_Frames
  end
  
  #-----------------------------------------------------------------------------
  # Current frame index
  #-----------------------------------------------------------------------------
  def encounter_balloon_frame_index
    return encounter_balloon_frame_count - [(@encounter_balloon_duration - encounter_balloon_wait) / encounter_balloon_speed, 0].max
  end
end
  
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Scene_Map < Scene_Base
  
  alias :th_encounter_alert_update_scene :update_scene
  def update_scene
    th_encounter_alert_update_scene
    update_encounter_skip
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :th_encounter_alert_update_encounter :update_encounter
  def update_encounter
    if $game_system.disable_encounter_balloon
      th_encounter_alert_update_encounter
    else
      if $game_player.encounter && $game_player.encounter_balloon_id == 0
        Audio.se_play("Audio/SE/#{TH::Encounter_Alert::Encounter_SE}") if TH::Encounter_Alert::Play_SE
        @prepare_encounter = true
        start_encounter_balloon
        $game_system.menu_disabled = true if TH::Encounter_Alert::Disable_Menu
      elsif @prepare_encounter && $game_player.encounter_balloon_id == 0
        SceneManager.call(Scene_Battle)
        @prepare_encounter = false
        $game_system.menu_disabled = false
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # New. Press specific keys at right time to avoid battle
  #-----------------------------------------------------------------------------
  def update_encounter_skip
    if @prepare_encounter && $game_player.encounter_balloon_id == TH::Encounter_Alert::Can_Skip_ID
      if Input.press?(TH::Encounter_Alert::Skip_Key)
        @prepare_encounter = false
        @spriteset.player_sprite.end_encounter_balloon
        
        # deduct encounter points
        $game_party.lose_encounter_points($game_troop.encounter_points_needed)
        $game_system.menu_disabled = false
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # New. Determine which balloon to draw, depending on whether the player
  # can avoid the battle or not. Currently can avoid all
  #-----------------------------------------------------------------------------
  def start_encounter_balloon
    if $game_troop.skip_condition_met?
      $game_player.encounter_balloon_id = TH::Encounter_Alert::Can_Skip_ID
    else
      $game_player.encounter_balloon_id = TH::Encounter_Alert::No_Skip_ID
    end
  end
end