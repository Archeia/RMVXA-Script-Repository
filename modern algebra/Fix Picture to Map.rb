#==============================================================================
#    Fix Picture to Map 
#    Version: 1.0.2a [VXA]
#    Author: modern algebra (rmrk.net)
#    Addition: Archeia and Kread-Ex
#    Date: 8 September, 2012
#    Updated: June 1, 2013
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This allows you to set the position of a picture by the X and Y position
#   of the map, rather than the screen, so that the picture won't move with you
#   when the screen scrolls. Additionally, the script lets you set the Z value 
#   to show below characters, or even below the tiles or below the parallax.
#
#    This script has no effect in battle and pictures there behave normally.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor, above Main but 
#   below Materials.
#
#    To specify that a picture should be fixed to a map and not follow the
#   screen, all you need to do is turn an in-game switch on before showing the 
#   picture. To specify which switch, all you need to do is change the value of
#   SWITCH_ID at line 60. Alternatively, you can include the code [Fixed] 
#   somewhere in the name of the picture.
# 
#    For the fixed pictures, you also have the option of assigning it to grid
#   coordinates instead of pixel coordinates. This means that if you wanted it
#   to show up at (3, 5) in the map, you could set it to that directly instead
#   of (96, 160). You can turn on this feature using another switch, again one
#   which you choose by changing the value of COORDINATES_SWITCH_ID at line 63.
#
#    To specify the layer of the tilemap (what shows above it and what shows
#   below it), all you need to do is change the value of a variable. Which 
#   variable is also specifed by you by changing Z_VARIABLE_ID at line 69.
#   The value to which that in-game variable is set at the time a picture is
#   shown determines where the picture will show up. If the variable is set to
#   0 then it will be in its normal place; if set to -1, it will show below 
#   the tilemap but above the parallax; if set to -2, it will show below the 
#   parallax; if set to 1, it will show above all non-star tiles but star tiles
#   and characters with normal priority; if set to 2, it will show above 
#   characters with normal priority but below characters with "Above 
#   Characters" priority. If set to any other value, the z value of the picture 
#   will be set to that directly. 
#==============================================================================

$imported = {} unless $imported
$imported[:MA_FixPictureToMap] = true

#==============================================================================
# *** MA_FixPicture
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module holds some relevant configuration Data
#==============================================================================

module MA_FixPicture
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #  Editable Region
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  SWITCH_ID - set this to the ID of the in-game switch that you want to 
  # use to control whether pictures should be fixed. 
  SWITCH_ID = 2 
  #  COORDINATES_SWITCH_ID - Set this to the ID of the in-game switch that you 
  # want to use to control how coordinates are set. If this switch is ON, then
  # for fixed pictures, you can just use the grid x and y coordinates (ie: you
  # would set (1, 4) instead of (32, 128). If you always want this feature to 
  # be on when the FPM Switch is on, you can set it to have the same ID.
  COORDINATES_SWITCH_ID = 2
  #  Z_VARIABLE_ID - set this to the ID of the in-game variable that you 
  # want to use to control the z-value priority of the picture.
  Z_VARIABLE_ID = 3
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  End Editable Region
  #////////////////////////////////////////////////////////////////////////////
  class << self
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Public Instance Variables
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    attr_accessor :spriteset_vp1
    attr_accessor :spriteset_vp2 
  end
end
#==============================================================================
# ** Game Picture
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variables - mafpm_vp_id; mafpm_fixed; mafpm_z
#    aliased method - initialize; show; move
#==============================================================================

class Game_Picture
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :mafpm_vp_id
  attr_accessor :mafpm_fixed
  attr_accessor :mafpm_z
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mafpm_iniz_2fg6 initialize
  def initialize(*args, &block)
    @mafpm_fixed = false
    @mafpm_vp_id = 2
    mafpm_iniz_2fg6(*args, &block) # Call Original Method
    @mafpm_z = self.number
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Show Picture
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mafpm_showpic_3jb7 show
  def show(name, *args, &block)
    # Only fix pictures if in Scene_Map
    if SceneManager.scene_is?(Scene_Map)
      @mafpm_fixed = (MA_FixPicture::SWITCH_ID == true || 
        $game_switches[MA_FixPicture::SWITCH_ID] || !name[/\[FIXED\]/i].nil?)
      z_var = $game_variables[MA_FixPicture::Z_VARIABLE_ID]
      # If 0 or less than 300, then it should belong to the viewport1 
      @mafpm_vp_id = (z_var != 0 && z_var < 300) ? 1 : 2 
      # Set Z shortcuts
      @mafpm_z = case z_var
      when -1 then -50         # Below tilemap but above parallax
      when -2 then -150        # Below parallax
      when 0 then self.number  # Normal position
      when 1 then 50           # Above tilemap but below normal characters
      when 2 then 150          # Above normal characters but below Above Characters
      else
        @mafpm_z = z_var < 300 ? z_var : z_var - 300 # Directly set to value
      end
    end
    mafpm_showpic_3jb7(name, *args, &block) # Call Original Method
    if @mafpm_fixed && (MA_FixPicture::COORDINATES_SWITCH_ID == true || $game_switches[MA_FixPicture::COORDINATES_SWITCH_ID])
      @x *= 32
      @y *= 32
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Move Picture
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mafpm_movepctr_2js1 move
  def move(*args, &block)
    mafpm_movepctr_2js1(*args, &block)
    if @mafpm_fixed && (MA_FixPicture::COORDINATES_SWITCH_ID == true || $game_switches[MA_FixPicture::COORDINATES_SWITCH_ID])
      @target_x *= 32
      @target_y *= 32
    end
  end
end

#==============================================================================
# ** Sprite Picture
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - update
#==============================================================================

class Sprite_Picture
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Frame Update
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mafpm_updt_5fw1 update
  def update(*args, &block)
    mafpm_updt_5fw1(*args, &block) # Call original method
    # If picture is fixed to map
    if @picture.mafpm_fixed
      # Scroll the picture appropriately
      self.x = @picture.x - ($game_map.display_x * 32)
      self.y = @picture.y - ($game_map.display_y * 32)
    end
    self.z = @picture.mafpm_z # Update Z to the correct Z
    # If the viewport has changed
    if @mafpm_vp_id != @picture.mafpm_vp_id && MA_FixPicture.send(:"spriteset_vp#{@picture.mafpm_vp_id}")
      @mafpm_vp_id = @picture.mafpm_vp_id
      # Change viewport
      self.viewport = MA_FixPicture.send(:"spriteset_vp#{@mafpm_vp_id}")
    end
  end
end

#==============================================================================
# ** Spriteset Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - create_viewports; dispose_viewports
#==============================================================================

class Spriteset_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Viewports
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mafpm_creatviewpor_3dk8 create_viewports
  def create_viewports(*args, &block)
    mafpm_creatviewpor_3dk8(*args, &block) # Call original method
    # Set the viewports to be globally accessible
    MA_FixPicture.spriteset_vp1 = @viewport1
    MA_FixPicture.spriteset_vp2 = @viewport2
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Viewports
  # * Kread Update:
  # * Picture will also shake when the screen is shaking.
  # * It will also shake the timer and the weather
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  class Spriteset_Map
    alias_method(:krx_mashake_sp_uv, :update_viewports)
    def update_viewports
      krx_mashake_sp_uv
      @viewport2.ox = $game_map.screen.shake
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Dispose Viewports
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mafpm_disposevps_2nr5 dispose_viewports
  def dispose_viewports(*args, &block)
    # Nullify the variables in MA_FixPicture
    MA_FixPicture.spriteset_vp1 = nil
    MA_FixPicture.spriteset_vp2 = nil
    mafpm_disposevps_2nr5(*args, &block) # Call original method
  end
end