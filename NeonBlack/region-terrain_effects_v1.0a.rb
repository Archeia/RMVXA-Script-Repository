##----------------------------------------------------------------------------##
## Terrain and Region Effects v1.0a
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.0a - 8.13.2013
##  Fixed an issue with screen position
## v1.0 - 8.7.2013
##  Finished main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["CP_TR_EFFECTS"] = 1.0                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script allows a character's step to cause a sound effect or play an
## effect.  These effects can be based on terrains or regions and are defined
## in the notes of tilesets in the database.  Both the player and events can
## cause these effects while followers and vehichles cannot.  All step sounds
## and effects are defined by the following tags.
##
##------
##    Tileset Tags:
## <terrain 1 se>  -or-  <region 1 se>
##  The first tag used when defining effects for a terrain or region.  ALL
##  lines that follow one of these will affect how that terrain or region
##  acts.
##
## Sound Name
##  After using a starting name, typing out anything in the line that is not
##  one of the tags below will cause the tag to be read as a sound effect
##  name.  You can have several sound effect names and one will be selected
##  at random when a sound is to be played.
##
## vol: 80  -or-  vol: 60-100
##  The volume of sound effects played when a step effect is activated.  A
##  set number may be used to have a set volume or a range may be used to
##  have a random volume within the range.
##
## pit: 90  -or-  pit: 80-120
##  The pitch of sound effects played when a step effect is activated.  This
##  works the same way as volume and may be variable.
##
## eff: Effect Name
##  Plays a visual effect from the "VisEffects" hash in the config section.
##
## </terrain se>  -or-  </region se>
##  Stops checking for tags for a specific region or terrain.  This allows
##  other tags to continue working below these tags without interfering.
##
##------
##    Event Tags:
## <allow step effects>
##  This tag can be placed in a comment on an event page to allow that page
##  of the event to activate stepping effects.  This will only affect the
##  page the event is currently on while the event is stepping.
##----------------------------------------------------------------------------##
                                                                              ##
module CPStepEffects  # Do not touch this line.                               ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Config:
## The config options are below.  You can set these depending on the flavour of
## your game.  Each option is explained in a bit more detail above it.
##
##------
# The following 6 values affect offset and lead of footstep visual effects.
# Each setting with "Offset" in it's name is how far from the base of the
# character it will appear depending on which foot is currently out in front.
# This first value alternates with each foot.  Each setting with "Lead" in it's
# name is how far in front of the event an effect appears.  This second value
# ignored by downward movement.

# These numbers affect the offsets of a visual effect when its footprint flag
# is enabled and the character is moving up/down.
HorzOffset = 4
VertLead = 4

# These numbers affect the offsets of a visual effect when its footprint flag
# is enabled and the character is moving left/right.
VertOffset = 5
HorzLead = 5

# These numbers affect the offsets of a visual effect when its footprint flag
# is enabled and the character is moving diagonally.
DiagHorz = 4
DiagVert = 4

# This is the angle of rotation to display when an effect is rotated and the
# character is moving diagonally.  This value is taken from an event's
# left/right rotation, so a value of 0 will ALWAYS be facing either left or
# right.
DiagDirAngles = 45

# A hash containing the names of all the visual effect files and their
# properties.  Visuals effects go in the "Graphics/System" folder.
#  Name      - The id name for the effect.  Used with the "eff: Name" tag.
#  FileName  - The file name for the effect's graphic.
#  cells     - The number of cells in the graphic left to right.
#  delay     - The number of frames to display a single cell.
#  footprint - Determines if the effect offsets based on which foot is out.
#  rotate    - Determines if the effect is rotated to match character direction.
#  NOTE: When both footprint and rotate are set to true, the effect will mirror
#        when the left foot activates the effect.

VisEffects ={
# "Name"   => ["FileName",  cells, delay, footprint, rotate],
  "Grass"  => ["LeafFall",  6,     4,     false,     false],
  "Splash" => ["Splash",    6,     4,     true,      false],
  "Snow"   => ["Footprint", 6,     12,    true,      true],

##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


}

end

class Game_Map
  attr_reader :stepping_effect
  
  ## Adds a hash containing the steps related to terrain and region.
  alias :cp_080113_setup :setup
  def setup(*args)
    cp_080113_setup(*args)
    make_terrain_step_sounds
  end
  
  alias :cp_080113_change_tileset :change_tileset
  def change_tileset(*args)
    cp_080113_change_tileset(*args)
    make_terrain_step_sounds
  end
  
  alias :cp_080113_update_events :update_events
  def update_events(*args)
    cp_080113_update_events(*args)
    @stepping_effect.each { |eff| eff.update }
    @stepping_effect.delete_if { |eff| eff.delete_me? }
  end
  
  ## Creates the hash by checking tags to REGEXP.
  def make_terrain_step_sounds
    @stepping_sounds = {}
    @stepping_effect = []
    @slse = nil
    tileset.note.split(/[\r\n]+/).each do |line| ## Begins, ends, or changes
      if line =~ /<(terrain|region) (\d+) se>/i  ## the terrain or region to
        if $1.to_s.downcase == "terrain"         ## check.
          @slse = $2.to_i
        else
          @slse = $2.to_s
        end
        @stepping_sounds[@slse] = [[], 80, 100, nil]
        next
      elsif line =~ /<\/(terrain|region) se>/i
        @slse = nil
        next
      elsif @slse.nil?
        next
      end
      case line
      when /(vol|pit): (\d+)-(\d+)/i
        n = 1 if $1.to_s.downcase == "vol"
        n = 2 if $1.to_s.downcase == "pit"
        @stepping_sounds[@slse][n] = [$2.to_i, $3.to_i]
      when /(vol|pit): (\d+)/i
        n = 1 if $1.to_s.downcase == "vol"
        n = 2 if $1.to_s.downcase == "pit"
        @stepping_sounds[@slse][n] = $2.to_i
      when /eff: (.+)/i
        @stepping_sounds[@slse][3] = $1.to_s
      else
        @stepping_sounds[@slse][0].push(line.to_s)
      end
    end
  end
  
  ## Plays a sound effect.  Auto checks random effect with array.
  def play_terrain_step_sound(terrain, region)
    tag = @stepping_sounds[terrain].nil? ? region.to_s : terrain.to_i
    return if @stepping_sounds[tag].nil? || @stepping_sounds[tag][0].empty?
    name = @stepping_sounds[tag][0].shuffle[0]
    vol = @stepping_sounds[tag][1]
    pit = @stepping_sounds[tag][2]
    if vol.is_a?(Array)
      vol = vol[0] + rand(vol[1] - vol[0] + 1)
    end
    if pit.is_a?(Array)
      pit = pit[0] + rand(pit[1] - pit[0] + 1)
    end
    RPG::SE.new(name, vol, pit).play
  end
  
  ## Adds a visual effect to the list.
  def play_terrain_step_effect(terrain, region, x, y, dir, offset)
    tag = @stepping_sounds[terrain].nil? ? region.to_s : terrain.to_i
    return if @stepping_sounds[tag].nil? || @stepping_sounds[tag][3].nil?
    name = @stepping_sounds[tag][3]
    return unless CPStepEffects::VisEffects.include?(name)
    @stepping_effect.push(Game_StepEffect.new(name, x, y, dir, offset))
  end
end

class Game_CharacterBase
  include CPStepEffects
  
  alias :cp_080113_update_anime_pattern :update_anime_pattern
  def update_anime_pattern(*args)
    cp_080113_update_anime_pattern(*args)
    do_step_effects_set if pattern_step_sets.include?(@pattern)
  end
  
  def allowable_effects?  ## Determine what does not activate effects.
    return false if self.is_a?(Game_Follower)
    return false if self.is_a?(Game_Vehicle)
    return false if self.is_a?(Game_Player) && @vehicle_type != :walk
    return false if self.is_a?(Game_Event) && !@step_event_cont
    return false if self.is_a?(Game_Event) && !near_the_screen?
    return true
  end
  
  def do_step_effects_set  ## Does sounds and/or visuals.
    return unless allowable_effects?
    do_step_sound_effects
    do_step_action_effects
  end
  
  def do_step_sound_effects
    $game_map.play_terrain_step_sound(screen_terrain, screen_region)
  end
  
  def do_step_action_effects
    xs, ys = step_effects_display_array
    $game_map.play_terrain_step_effect(screen_terrain, screen_region, xs, ys,
                                       facing_direction_sub, pos_step_offset)
  end
  
  ## Gets the region or terrain for the exact position on screen.
  def screen_terrain
    xs, ys = step_effects_display_array
    $game_map.terrain_tag(xs/32, ys/32)
  end
  
  def screen_region
    xs, ys = step_effects_display_array
    $game_map.region_id(xs/32, ys/32)
  end
  
  def step_effects_display_array
    [self.screen_x + $game_map.display_x * 32,
     self.screen_y + $game_map.display_y * 32 - 16]
  end
  
  ## Offsets the footsteps for visual effects and sends it to the effect.
  def pos_step_offset
    frontstep = @pattern == low_pattern_num
    case facing_direction_sub
    when 2
      frontstep ? [-HorzOffset, 0, false] : [HorzOffset, 0, true]
    when 8
      frontstep ? [HorzOffset, -VertLead, false] : [-HorzOffset, -VertLead, true]
    when 4
      frontstep ? [-HorzLead, -VertOffset, false] : [-HorzLead, 0, true]
    when 6
      frontstep ? [HorzLead, -VertOffset, true] : [HorzLead, 0, false]
    when 1
      frontstep ? [0, -DiagVert, true] : [-DiagHorz, 0, false]
    when 3
      frontstep ? [DiagHorz, 0, true] : [0, -DiagVert, false]
    when 7
      frontstep ? [-DiagHorz, -DiagVert, true] : [0, -DiagVert, false]
    when 9
      frontstep ? [0, -DiagVert, true] : [DiagHorz, -DiagVert, false]
    end
  end
  
  ## Other methods related to stepping.  Set for easy compatibility patching.
  def facing_direction_sub
    @direction
  end
  
  def pattern_step_sets
    [low_pattern_num, top_pattern_num]
  end
  
  def low_pattern_num
    0
  end
  
  def top_pattern_num
    @original_pattern * 2
  end
end

## Checks events to see if they can activate effects.
class Game_Event < Game_Character
  alias :cp_080313_setup_page_settings :setup_page_settings
  def setup_page_settings
    cp_080313_setup_page_settings
    get_step_effects_condition
  end
 
  def get_step_effects_condition
    @step_event_cont = false
    return if @list.nil? || @list.empty?
    @list.each do |line|
      next unless line.code == 108 || line.code == 408
      case line.parameters[0]
      when /<allow step effects>/i
        @step_event_cont = true
      end
    end
  end
end

## Displays and alters the visual effects on screen.
class Spriteset_Map
  alias :cp_080313_update_characters :update_characters
  def update_characters(*args)
    cp_080313_update_characters(*args)
    @step_effect_sprites = [] if @step_effect_sprites.nil?
    [@step_effect_sprites.size, $game_map.stepping_effect.size].max.times do |i|
      if $game_map.stepping_effect[i].nil?
        if @step_effect_sprites[i]
          @step_effect_sprites[i].dispose
          @step_effect_sprites.delete_at(i)
        end
        next
      elsif @step_effect_sprites[i].nil?
        sprite = Sprite.new(@viewport1)
        sprite.z = 25
        @step_effect_sprites[i] = sprite
      end
      sprite, effect = @step_effect_sprites[i], $game_map.stepping_effect[i]
      sprite.bitmap = Cache.system(effect.file)
      wd = sprite.bitmap.width / effect.frames
      sprite.src_rect.set(wd * effect.get_frame, 0, wd, sprite.bitmap.height)
      sprite.ox = sprite.width / 2
      sprite.oy = sprite.height / 2
      sprite.mirror = effect.flip?
      sprite.angle = effect.rotation
      sprite.x = effect.screen_x
      sprite.y = effect.screen_y
    end
  end
  
  alias :cp_080313_dispose_characters :dispose_characters
  def dispose_characters
    cp_080313_dispose_characters
    @step_effect_sprites.each { |eff| eff.dispose }
  end
end

## The effect class to store an effect's info.
class Game_StepEffect
  def initialize(name, x, y, dir, offset)
    @name, @x, @y, @dir = name, x, y, dir
    @array = CPStepEffects::VisEffects[name]
    @ticks = 0
    @flip = offset[2]
    if @array[3]
      @x += offset[0]
      @y += offset[1]
    end
  end
  
  def update
    @ticks += 1
  end
  
  def get_frame
    @ticks / delay
  end
  
  def delete_me?
    @ticks >= frames * delay 
  end
  
  def screen_x
    @x - $game_map.display_x * 32
  end
  
  def screen_y
    @y - $game_map.display_y * 32 + y_offset
  end
  
  def y_offset
    16
  end
  
  def frames
    @array[1]
  end
  
  def delay
    @array[2]
  end
  
  def file
    @array[0]
  end
  
  def direction
    case @dir
    when 2; return 180
    when 4; return 90
    when 6; return 270
    when 8; return 0
    when 1; return 90  + CPStepEffects::DiagDirAngles
    when 3; return 270 - CPStepEffects::DiagDirAngles
    when 7; return 90  - CPStepEffects::DiagDirAngles
    when 9; return 270 + CPStepEffects::DiagDirAngles
    else;   return 0
    end
  end
  
  def rotation
    @array[4] ? direction : 0
  end
  
  def flip?
    @array[3] && @array[4] && @flip
  end
end
 
 
##-----------------------------------------------------------------------------
## End of script.
##-----------------------------------------------------------------------------