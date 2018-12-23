#==============================================================================
# ** TDS Sprite Reflection
#    Ver: 1.3
#------------------------------------------------------------------------------
#  * Description:
#  This script creates the effect of reflection on certain map tiles.
#------------------------------------------------------------------------------
#  * Features: 
#  Set reflection tiles based on terrain.
#  Set Y offset of reflection based on terrain tag on the tile notes.
#  Set individual Y offset for character or events.
#------------------------------------------------------------------------------
#  * Instructions:
#  For events to have a reflection their name must include this, "[Reflect]".
#  (It's not case sensitive.)
#
#  To turn on/off the reflection on an event or player use this on a script
#  call:
#
#  turn_on_reflection(id)
#  turn_off_reflection(id)
#  
#  id = ID of Event to turn effect ON/OFF. For the player use 0 and for the
#       followers use negative ID's (-1, -2, -3)
#
#  Example:
#
#  turn_off_reflection(0)
#
#  That would make the players reflection invisible.
#
#  turn_off_reflection(-1)
#
#  That would turn off the first followers reflection.
#
#  To set the terrain ID's that are reflective find this constant
#  "REFLECTION_TERRAIN_TAGS" below the Setting Constants and set the ID's
#
#  Example:
#  
#  REFLECTION_TERRAIN_TAGS = [terrain_id, terrain_id, ...]
#  REFLECTION_TERRAIN_TAGS = [1, 2]
#
#  To enable or disable the water wave effect of reflections find this constant
#  "REFLECTION_WAVE_EFFECT" and set the value to true or false.
#
#  To set the individual offset based on terrain tag, go to the tileset editor
#  and add this on it's notes.
#
#  S_REFLECT_OFFSET:
#  terrain_tag: y_offset
#  terrain_tag: y_offset
#  terrain_tag: y_offset
#  E_REFLECT_OFFSET:
#
#  terrain_tag: = Terrain Tag (1, 2, 3, 4, 5, 6, 7)
#  y_offset: Y value offset of the reflection while on this terrain tag.
#
#  Example:
#
#  S_REFLECT_OFFSET:
#  1: 9
#  2: 14
#  E_REFLECT_OFFSET:
#------------------------------------------------------------------------------
#  * Notes:
#  This script is meant to be used mostly with the default sprites and square 
#  water tiles. If people need more complex clipping and X offset I will add
#  them in a later version.
#------------------------------------------------------------------------------
#  * Special Thanks:
#  Many thanks to Cozziekuns for his help witht the clipping method.
#------------------------------------------------------------------------------
# WARNING:
#
# Do not release, distribute or change my work without my expressed written 
# consent, doing so violates the terms of use of this work.
#
# If you really want to share my work please just post a link to the original
# site.
#
# * Not Knowing English or understanding these terms will not excuse you in any
#   way from the consequenses.
#==============================================================================
# * Import to Global Hash *
#==============================================================================
($imported ||= {})[:TDS_Sprite_Reflection] = true

#------------------------------------------------------------------------------
# * Settings Constants
#------------------------------------------------------------------------------
# Reflection Terrain Tag ID's
REFLECTION_TERRAIN_TAGS = [1, 2]
# Reflection Water Wave Effect
REFLECTION_WAVE_EFFECT = true


#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader :reflect_terrain_offsets         # Map Reflection Y Offset Hash
  #--------------------------------------------------------------------------
  # * Alias Listings
  #--------------------------------------------------------------------------  
  alias tds_sprite_reflection_game_map_setup                   setup
  alias tds_sprite_reflection_game_map_change_tileset          change_tileset 
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(*args)
    # Run Original Method
    tds_sprite_reflection_game_map_setup(*args)
    # Setup Terrain Reflect Offset Values
    setup_terrain_reflect_offset
  end
  #--------------------------------------------------------------------------
  # * Setup Reflect Terrain Offset Values
  #--------------------------------------------------------------------------
  def setup_terrain_reflect_offset    
    # Make Reflect Terrain Offsets Hash
    @reflect_terrain_offsets = {}
    # Set Default Terrain Offset Value
    @reflect_terrain_offsets.default = 0    
    # Get Tileset Terrain Offset Text
    tileset.note[/S_REFLECT_OFFSET:(.*)E_REFLECT_OFFSET:/m] ; offsets = $1
    # Return if offsets list text is nil
    return if offsets.nil?
    # Scan Battleback Text for region names information
    offsets.scan(/(?'terrain_tag'[0-9]+): (?'offset'[0-9]+)/) {|t|
      # Get Match Information
      m = Regexp.last_match
      # Set Region Name
      @reflect_terrain_offsets[m[:terrain_tag].to_i] = m[:offset].to_i
    } 
  end
  #--------------------------------------------------------------------------
  # * Change Tileset
  #--------------------------------------------------------------------------
  def change_tileset(*args)  
    # Run Original Method
    tds_sprite_reflection_game_map_change_tileset(*args)
    # Setup Terrain Reflect Offset
    setup_terrain_reflect_offset    
  end
  #--------------------------------------------------------------------------
  # * Get Terrain Reflection Offset Value
  #--------------------------------------------------------------------------
  def terrain_reflection_offset(terrain_tag) ; @reflect_terrain_offsets[terrain_tag] end
  #--------------------------------------------------------------------------
  # * Determine if Reflection happens at position
  #--------------------------------------------------------------------------
  def reflection_at?(x, y) ; REFLECTION_TERRAIN_TAGS.include?(terrain_tag(x, y)) end
end


#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
#  Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Turn On/Off Character Reflection
  #   id : event id (0 and negative for player and followers)
  #--------------------------------------------------------------------------
  def turn_on_reflection(id) ; change_reflection_state(id, true) end  
  def turn_off_reflection(id) ; change_reflection_state(id, false) end
  #--------------------------------------------------------------------------
  # * Change Reflection State
  #   id    : event id (0 and negative for player and followers)
  #   state : True/False
  #--------------------------------------------------------------------------
  def change_reflection_state(id, state)
    # If ID is less than 1
    if id < 1
      if id == 0
        # Set Reflection State for Player
        $game_player.reflection_active = state 
      else
        # Set Reflection State for Followers
        $game_player.followers[id.abs].reflection_active = state        
      end
    else
      # Set Event Reflection State
      $game_map.events[id].reflection_active = state
    end
  end
end


#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc. It's used
# within the Scene_Map class.
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Alias Listings
  #--------------------------------------------------------------------------  
  alias tds_sprite_reflection_spriteset_map_initialize          initialize
  alias tds_sprite_reflection_spriteset_map_dispose             dispose
  alias tds_sprite_reflection_spriteset_map_update              update
  alias tds_sprite_reflection_spriteset_map_refresh_characters  refresh_characters
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    # Create Character Reflection Sprites
    create_character_reflections    
    # Run Original Method
    tds_sprite_reflection_spriteset_map_initialize    
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    # Run Original Method
    tds_sprite_reflection_spriteset_map_dispose
    # Dispose of Reflection Sprites
    dispose_reflection_sprites  
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose_reflection_sprites  
    # Dispose of Reflection Sprites
    @reflection_sprites.each {|s| s.dispose}
    # Clear Reflection Sprites Array
    @reflection_sprites.clear
  end
  #--------------------------------------------------------------------------
  # * Refresh Characters
  #--------------------------------------------------------------------------
  def refresh_characters
    # Run Original Method
    tds_sprite_reflection_spriteset_map_refresh_characters
    # Dispose of Reflection Sprites
    dispose_reflection_sprites  
    # Create Character Reflection Sprites
    create_character_reflections
  end  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Run Original Method
    tds_sprite_reflection_spriteset_map_update
    # Update Character Reflections
    update_character_reflections
  end
  #--------------------------------------------------------------------------
  # * Create Character Reflection Sprites
  #--------------------------------------------------------------------------
  def create_character_reflections
    # Make Reflection Sprites Array
    @reflection_sprites = []
    # Go Through Game Map Events
    $game_map.events.values.each do |event|
      # If Event has Reflection
      if event.has_reflection?
        # Add Reflection Sprite to Array
        @reflection_sprites << Sprite_Character_Reflection.new(@viewport1, event)
      end
    end
    # Go Through Follower Sprites
    $game_player.followers.reverse_each do |follower|
      # Add Reflection Sprite to Array      
      @reflection_sprites << Sprite_Character_Reflection.new(@viewport1, follower)
    end
    # Add Player Reflection Sprite to Array      
    @reflection_sprites << Sprite_Character_Reflection.new(@viewport1, $game_player)
  end
  #--------------------------------------------------------------------------
  # * Update Character Reflection Sprites
  #--------------------------------------------------------------------------
  def update_character_reflections
    # Update Reflection Sprites
    @reflection_sprites.each {|s| s.update}
  end
end


#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  A character class with mainly movement route and other such processing added.
#  It is used as a super class of Game_Player, Game_Follower, GameVehicle,
#  and Game_Event.
#==============================================================================

class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :reflection_active               # Reflection Active Flag
  attr_accessor :reflection_y_offset             # Reflection Y Offset value
  #--------------------------------------------------------------------------
  # * Alias Listings
  #--------------------------------------------------------------------------  
  alias tds_sprite_reflection_game_character_init_public_members init_public_members    
  #--------------------------------------------------------------------------
  # * Initialize Public Member Variables
  #--------------------------------------------------------------------------
  def init_public_members
    # Set Reflection Active Flag
    @reflection_active = true
    # Set Reflection Y Offset Value
    @reflection_y_offset = 0
    # Run Original Method
    tds_sprite_reflection_game_character_init_public_members
  end
  #--------------------------------------------------------------------------
  # * Determine if Character has a reflection
  #--------------------------------------------------------------------------
  def has_reflection?
    # If Self is an Game_Event Character
    if self.is_a?(Game_Event)
      # Return true if Event Name Includes the Reflect Flag
      return true if /\[REFLECT\]/i =~ @event.name
    end
    # Return false by default
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Reflection Offset Value
  #--------------------------------------------------------------------------
  def reflection_offset(x = @x, y = @y + 1)
    # Return Character Reflection Offset with Character Offset    
    $game_map.terrain_reflection_offset($game_map.terrain_tag(x, y)) + @reflection_y_offset
  end
  #--------------------------------------------------------------------------
  # * Determine if Character reflection is visible
  #--------------------------------------------------------------------------
  def reflection_visible?(x = @x, y = @y + 1)
    return false if !@reflection_active
    return false if @transparent
    return false if !$game_map.reflection_at?(x, y)
    return true
  end
end


#==============================================================================
# ** Sprite_Character_Reflection
#------------------------------------------------------------------------------
#  This sprite is used to display character reflection. It observes an instance
#  of the Game_Character class and automatically changes sprite state.
#==============================================================================

class Sprite_Character_Reflection < Sprite_Character
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport  : Viewport
  #     character : Game_Character
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    super(viewport, character)
    # Character Ojbect
    @character = character
    # Reflection Sprite Settings
    self.mirror = true ; self.angle = 180 ; self.opacity = 160    
    # Set Self Wave Amp if Reflection Wave Effect is true
    self.wave_amp = 1 if REFLECTION_WAVE_EFFECT
    # Set Reflection Visibility Flag
    @visible = @character.reflection_visible?
    @clipping = false
    # Update
    update
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose ; super end ; def update_balloon ; end ; def setup_new_effect ; end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
  end
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Rectangle
  #--------------------------------------------------------------------------
  def update_src_rect
    # If Enter Clipping should be applied
    if enter_clipping?
      if @tile_id == 0
        # Character Index
        index = @character.character_index
        # Character Pattern
        pattern = @character.pattern < 3 ? @character.pattern : 1
        sx = (index % 4 * 3 + pattern) * @cw
        sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch        
        # X Coordinate Distance
        x_dist = (@character.x - @character.real_x).abs
        # Y Coordinate Distance
        y_dist = (@character.y - @character.real_y).abs        
        
        # If Character Y Position is more than Real Y (Entering Down)
        if @character.y > @character.real_y
          # Set Source Rect
          self.src_rect.set(sx, sy, @cw, @ch - (y_dist * @ch))          
          # Set OX Value
          self.oy = (y_dist * @ch)
        end
        
        # If Character X Position is less than Real X (Entering to LEFT)
        if @character.x < @character.real_x          
          self.src_rect.set(sx, sy, @cw - (@cw * x_dist), @ch)
          # Set OX Value
          self.ox = (@cw - (x_dist * @cw)) / 2
        end
        # If Character X Position is more than Real X (Entering to RIGHT)
        if @character.x > @character.real_x
          self.src_rect.set(sx + (x_dist * @cw), sy, @cw - (x_dist * @cw), @ch)
          # Set OX Value
          self.ox = (x_dist * @cw) / 2                  
        end        
      end
      # Set Visibility to true
      self.visible = true            
      # Set Reflection X Coordinate Position
      self.x = @character.screen_x + (@cw / 2 - self.ox) * (@character.real_x < @character.x ? 1 : -1)      
      # Set Reflection Y Coordinate Position
      self.y = @character.screen_y + @character.reflection_offset  + (@ch - self.oy) * (@character.real_y < @character.y ? 1 : -1)
      # Set Clipping Flag to true
      @clipping = true      
      return
    end
    
    # If Exit Clipping should be applied
    if exit_clipping?      
      if @tile_id == 0
        index = @character.character_index
        pattern = @character.pattern < 3 ? @character.pattern : 1
        sx = (index % 4 * 3 + pattern) * @cw
        sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch        
        # X Coordinate Distance
        x_dist = (@character.x - @character.real_x).abs
        # Y Coordinate Distance
        y_dist = (@character.y - @character.real_y).abs
                
        # If Character Y Position is less than Real Y (Exiting UP)
        if @character.y < @character.real_y
          # Set Source Rect
          self.src_rect.set(sx, sy, @cw, y_dist * @ch)          
          # Set OX Value
          self.oy = (y_dist * @ch)
          # Get Y offset for terrain
          y_offset = @character.reflection_offset(@character.x, @character.y + 2)
          # Set Reflection X Coordinate Position
          self.y = @character.screen_y + y_offset + (@ch - self.oy) * (@character.real_y < @character.y ? -1 : 1)
        end        
        
        # If Character X Position is less than Real X (Exiting LEFT)
        if @character.x < @character.real_x
          self.src_rect.set(sx + @cw - x_dist * @cw, sy, x_dist * @cw, @ch)
        end
        # If Character X Position is more than Real X (Exiting RIGHT)
        self.src_rect.set(sx, sy, x_dist * @cw, @ch) if @character.x > @character.real_x
        # Set OX Value
        self.ox = (x_dist * @cw) / 2        
        # Set Reflection X Coordinate Position
        self.x = @character.screen_x + (@cw / 2 - self.ox) * (@character.real_x < @character.x ? -1 : 1)        
        # Set Clipping Flag to true
        @clipping = true        
      end
      return
    end    

    # If Clipping
    if @clipping
      # Set Visibility
      self.visible = @visible = true if !@character.moving? and @character.reflection_visible?
      self.visible = @visible = false if !@character.moving? and !@character.reflection_visible?
      # Set Clipping flag to false
      @clipping = false
      # Reset OX and OY Values
      self.ox = @cw / 2 ; self.oy = @ch      
    end    
    super
  end
  #--------------------------------------------------------------------------
  # * Determine if enter clipping should be applied
  #--------------------------------------------------------------------------
  def enter_clipping?
    return false if !@character.moving?
    return false if @visible    
    # Vertical Clipping (Up/Down)
    if @character.y != @character.real_y
      return false if !@character.reflection_visible?(@character.y + (@character.y > @character.real_y ? -1 : 1))
    end
    # Horizontal Clipping (Left/Right)
    if @character.x != @character.real_x
      return false if @character.reflection_visible?(@character.x + (@character.x > @character.real_x ? -1 : 1))      
    end
    return false if !@character.reflection_visible?
    return true
  end
  #--------------------------------------------------------------------------
  # * Determine if exit clipping should be applied
  #--------------------------------------------------------------------------
  def exit_clipping?
    return false if !@character.moving?
    return false if !@visible
    # Vertical Clipping (Up/Down)
    if @character.y != @character.real_y      
      return false if @character.reflection_visible?(@character.y + (@character.y > @character.real_y ? -1 : 1))
    end
    # Horizontal Clipping (Left/Right)
    if @character.x != @character.real_x
      return false if !@character.reflection_visible?(@character.x + (@character.x > @character.real_x ? -1 : 1))      
    end    
    return false if @character.reflection_visible?
    return true
  end  
  #--------------------------------------------------------------------------
  # * Update Position
  #--------------------------------------------------------------------------
  def update_position    
    # Return if Clipping Sprite
    return if @clipping
    self.x = @character.screen_x
    self.y = @character.screen_y + @character.reflection_offset
    self.z = @character.screen_z
  end
  #--------------------------------------------------------------------------
  # * Update Other
  #--------------------------------------------------------------------------
  def update_other    
    self.blend_type = @character.blend_type
    self.visible = @character.reflection_visible? if !@clipping    
    return
  end
end