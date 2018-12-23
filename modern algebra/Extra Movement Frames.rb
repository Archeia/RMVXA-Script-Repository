#==============================================================================
#    Extra Movement Frames
#    Version: 1.0.1
#    Author: modern algebra (rmrk.net)
#    Date: 26 September 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script allows you to import character sprites with more than 3 frames 
#  for movement animation. In other words, it allows you to animate sprites a 
#  little more smoothly. One use for it is it allows RMXP format characters to 
#  be imported directly into a VXA game without editing (although you will need 
#  to rename the file).
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials. If you are using my Composite Graphics script, then this
#   script must be placed in a slot below Composite Graphics.
#
#    To create a sprite with extra movement frames, all you need to do is 
#   rename the character graphic to something of the form:
#
#      Regular_Name%(x)
#        where:
#          x is the number of frames in each character sprite
#  
#  EXAMPLES:
#
#    $001-Fighter01%(4)
#      This graphic is a single character with four frames of animation. [XP]
#    022-Actors12%(6)
#      This graphic would be interpreted as a character sheet of 8 characters,
#      each having six frames of animation.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    Additionally, this script also allows you to specify the "idle" frame (the
#   frame where the sprite is not moving), and also the pattern if wish to so
#   specify. In essence, all you need to do is add those integers after the
#   number of frames:
#
#      Regular_Name%(x y1 y2 y3 ... yx)
#        where:
#          x is the number of frames in each character sprite
#          y1 is the idle frame (the frame shown when sprite is not moving)
#          y2 ... yx are the pattern.
#
#   Keep in mind that the first frame in a sprite is index 0, the second frame
#   is index 1, etc.
#
#    Where y1 is excluded, it is assumed to be 0. Where y2 ... yx are excluded,
#   the pattern is assumed to simply cycle through the frames one by one until
#   it repeats.
#
#  EXAMPLES:
#
#    $003-Fighter03%(4 2)
#      This graphic is a single character with four frames of animation. The 
#      idle frame is 2 (the third one over). The pattern when moving would be
#      2 3 0 1, 2 3 0 1, etc.
#    032-People05%(4 0 1 0 3 2 1)
#      This graphic would be interpreted as a character sheet of 8 characters,
#      each having four frames of animation. The idle frame is 0 (the first
#      in the sheet), and the pattern is 0 1 0 3 2 1, 0 1 0 3 2 1, etc.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_ExtraMovementFrames] = true

#==============================================================================
# *** MA_ExtraMovementFrames
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module holds a method for calculating width and height of an emf
# character frame
#==============================================================================

module MA_ExtraMovementFrames
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Check if Character has extra movement frames
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_char_is_emf_sprite?(character_name)
    character_name && !character_name[/\%[\(\[].+?[\)\]]/].nil?
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Derive Frames Array
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maemf_get_frames(character_name)
    character_name = "" unless character_name
    frames = !character_name[/\%[\(\[](.+?)[\)\]]/] ? [] : 
      $1.scan(/\d+/).collect { |s| s.to_i }
    frames[0] = 3 unless frames[0] # If empty, then set to default 3
    frames.push(1, 2, 1, 0) if frames[0] == 3 && frames.size < 2
    frames[1] = 0 unless frames[1] # Set idle frame
    if frames.size < 3
      # Create pattern 
      (frames[0] - 1).times {|i| frames.push((frames[1] + i + 1) % frames[0]) } 
    end
    return frames
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Calculate Frame Size
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maemf_calc_frame_size(character_name, bitmap, frames = [])
    character_name = "" unless character_name
    frames = maemf_get_frames(character_name) if frames.empty?
    cw = bitmap.width / (frames[0] ? frames[0] : 3)
    ch = bitmap.height / 4
    sign = character_name[/^[\!\$]./]
    if !sign || !sign.include?('$')
      cw /= 4
      ch /= 2
    end
    return cw, ch
  end
end

# Compatibility with Composite Graphics
if $imported[:MA_CompositeGraphics]
  #============================================================================
  # *** Cache
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    aliased method - macgve_make_unique_name
  #============================================================================
  class << Cache
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Make Unique Name
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias macgemf_uniqname_3tc8 macgve_make_unique_name
    def macgve_make_unique_name(cg_array = [], *args)
      result = macgemf_uniqname_3tc8(cg_array, *args) # Call Original Method
      # Add %(x) code to name if the first graphic in the array contains it.
      result += $1 if cg_array[0] && cg_array[0].filename[/(\%[\(\[].+?[\)\]])/]
      result
    end
  end
end

#==============================================================================
# ** Game_CharacterBase
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - straighten; update_anime_pattern; initialize;
#      set_graphic; character_name=
#    new methods - maemf_init_char_frames
#==============================================================================

class Game_CharacterBase
  include MA_ExtraMovementFrames
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Straighten
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maemf_straghtn_5sb3 straighten
  def straighten(*args, &block)
    maemf_straghtn_5sb3(*args, &block) # Run original method
    @pattern = @original_pattern if @walk_anime || @step_anime
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Anime Pattern
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maemf_updanim_ptrn_2yv5 update_anime_pattern
  def update_anime_pattern(*args)
    if @ma_char_is_emf_sprite # If an emf sprite
      if !@step_anime && @stop_count > 0 # Reset to stationary
        @maemf_frame_index = 0
        @pattern = @original_pattern
      else
        # Next Pattern
        @maemf_frame_index = (@maemf_frame_index + 1) % @maemf_character_pattern.size
        @pattern = @maemf_character_pattern[@maemf_frame_index]
      end
    else
      maemf_updanim_ptrn_2yv5(*args) # Call original method
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize Character Frames
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maemf_init_char_frames
    @maemf_frame_index = 0 # Initialize Index
    # Save this value for faster reference
    @ma_char_is_emf_sprite = ma_char_is_emf_sprite?(character_name)
    if @ma_char_is_emf_sprite
      # Get pattern
      @maemf_character_pattern = maemf_get_frames(character_name)
      @maemf_character_pattern.shift # Remove frame number
      @original_pattern = @maemf_character_pattern[0]
    else
      @maemf_character_pattern = []
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize Character Frames Proc
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.maemf_init_char_frames_proc
    Proc.new { |method_name|
      alias_method(:"maemf_#{method_name}_2ev9", method_name) # Alias
      define_method(method_name) do |*args| # Define method
        send(:"maemf_#{method_name}_2ev9", *args) # Call original method
        maemf_init_char_frames
      end
    }
  end
  proc = maemf_init_char_frames_proc
  [:initialize, :set_graphic].each { |name| proc.call(name) }
end

#==============================================================================
# ** Game_Player/Follower/Vehicle/Event
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This aliases methods in these classes that change @character_name in order
# to call maemf_init_char_frames
#==============================================================================

class Game_Player
  # Refresh
  maemf_init_char_frames_proc.call(:refresh)
end

class Game_Follower
  # Refresh
  maemf_init_char_frames_proc.call(:refresh)
end

class Game_Vehicle
  # Load System Settings
  maemf_init_char_frames_proc.call(:load_system_settings)
end

class Game_Event  
  proc = maemf_init_char_frames_proc
  # Clear Page Settings & Setup Page Settings
  [:clear_page_settings, :setup_page_settings].each { |name| proc.call(name) }
end

#==============================================================================
# ** Sprite_Character
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - set_character_bitmap; update_src_rect
#    new methods - ma_set_emf_character_bitmap; ma_update_emf_src_rect
#==============================================================================

class Sprite_Character
  include MA_ExtraMovementFrames
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Character Bitmap
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maemf_setcharbmp_4rm6 set_character_bitmap
  def set_character_bitmap(*args)
    @emf_char = ma_char_is_emf_sprite?(@character_name)
    @emf_char ? ma_set_emf_character_bitmap : maemf_setcharbmp_4rm6(*args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Transfer Origin Rectangle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maemf_updtsrcrect_2kq5 update_src_rect
  def update_src_rect(*args)
    @emf_char ? ma_update_emf_src_rect : maemf_updtsrcrect_2kq5(*args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Character Bitmap
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_set_emf_character_bitmap
    self.bitmap = Cache.character(@character_name)
    @emf_char_frames = maemf_get_frames(@character_name)
    @cw, @ch = maemf_calc_frame_size(@character_name, bitmap, @emf_char_frames)
    self.ox = @cw / 2
    self.oy = @ch
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Transfer Origin Rectangle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_update_emf_src_rect
    if @tile_id == 0
      index = @character.character_index
      pattern = @character.pattern < @emf_char_frames[0] ? @character.pattern : @emf_char_frames[1]
      sx = (index % 4 * @emf_char_frames[0] + pattern) * @cw
      sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end
end

#==============================================================================
# ** Window_Base
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes: 
#    aliased method - draw_character
#    new method - ma_draw_emf_character
#==============================================================================

class Window_Base
  include MA_ExtraMovementFrames
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Character Graphic
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maemf_drawcharct_3kq6 draw_character
  def draw_character(character_name, *args)
    character_name[/\%[\(\[].+?[\)\]]/] ? ma_draw_emf_character(character_name, *args) :
      maemf_drawcharct_3kq6(character_name, *args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Extra Movement Frames Character Graphic
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_draw_emf_character(character_name, character_index, x, y)
    return unless character_name
    if !ma_char_is_emf_sprite?(character_name)
      # Draw regular if there is no frame specification in the name
      maemf_drawcharct_3kq6(character_name, *args)
    else
      bitmap = Cache.character(character_name)
      frames = maemf_get_frames(character_name)
      cw, ch = maemf_calc_frame_size(character_name, bitmap, frames)
      n = character_index
      src_rect = Rect.new((n%4*frames[0]+frames[1])*cw, (n/4*4)*ch, cw, ch)
      contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
    end
  end
end