##----------------------------------------------------------------------------##
## Picture Variables v2.0
## Created by Neon Black at request of Celianna
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v2.0 - 8.14.2013
##  Complete overhaul of how pictures are displayed
##  Numerous bugfixes
## v1.0 - 12.24.2012
##  Finished main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["CP_PIC_VARS"] = 2.0                                                ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script allows you to set pictures from the "Graphics/Pictures" folder
## to show up when a switch is turned on and a variable is set to a certain
## value.  This pictures can appear on any of the map's viewports and at any Z
## position.  This allows the script to be useful for parallax mapping as well
## as any form of HUD.
##----------------------------------------------------------------------------##
                                                                              ##
module CPVPics  # Do not touch this line.                                     ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Config:
## The following is a hash containing the images assigned to a variable.  Each
## variable has several options that apply to all image in it as follows.
##
## :comment
##   A comment used to help identify the use of the variable.  Not read by the
##   script for anything.
## :files
##   A hash of image names for certain variable settings.  Each contains a
##   value on the left and a file name on the right.
## :z
##   The z position of the image.  Higher Z values appear above lower values.
## :sw
##   The switch that must be turned on for the picture to appear.  If the
##   switch is turned off the picture will dissappear.
## :map_mode
##   Determines how the picture will follow the map.
##   0 - The picture will snap it's top left corner to the top left position
##       of the screen and stay there.
##   1 - The picture will snap it's top left corner to the top left position
##       of the screen, but will scroll as the map scrolls.
##   2 - The picture will snap it's top left corner to the top left position
##       of the MAP and will scroll with the map.  Most useful for parallax
##       mapping.
## :viewport
##   The Spriteset_Map viewport for the picture to appear in.
##   1 - Used by all map objects/tilesets/events.  Any picture in this
##       viewport will tint with the screen.  As a general rule of thumb for
##       z values in this viewport, 0 = below events, 100 = same as events,
##       200 = over events.
##   2 - Viewport used by the default game pictures.
##   3 - Viewport used by weather.
##   Any other value assigned to this will cause the picture to not use a
##   viewport.
## :loop
##   Another feature useful for parallax mapping.  If this value is set to
##   true the picture will tile across the screen.  If it is set to false only
##   a single picture will be displayed based on the other parameters.  Set
##   this value to true when using a picture for a parallax map and having a
##   map that loops.
##------
#

Pictures ={

1 =>{ ## <- This number is the variable the picture is assigned to.
  :comment => "This is the background for a parallax map",
  :files =>{
    1 => "Map_1",
    2 => "Map_2",
    }, #end of files
  :z  => -50,
  :sw => 21,
  :map_mode => 2,
  :viewport => 1,
  :loop => true,
  },

2 =>{
  :comment => "The upper part of each map.  Holds stuff over the player.",
  :files =>{
    1 => "Map_1_Up",
    2 => "Map_2_Up",
  }, #end of files
  :z  => 199,
  :sw => 21,
  :map_mode => 2,
  :viewport => 0,
  :loop => true,
  },

} #Pictures


##------------------------------------------------------------------------------
## End of configuration settings.
##------------------------------------------------------------------------------

end

## Sets up variables for the system.  This allows them to be saved when the game
## is saved.
class Game_System
  attr_accessor :vpics
end

## New class that holds the variable style picture.  This stores and allows
## access to some additional information.
class Game_VariablePic < Game_Picture
  attr_accessor :num
  attr_reader :xo
  attr_reader :yo
  
  def initialize(num)
    super(-1)  ## Changes the default blend type, sets the ID, sets the map set.
    @blend_type = 0
    @num = num
    @xo = $game_map.display_x * 32
    @yo = $game_map.display_y * 32
  end
  
  def name
    return "" unless @num
    return info[:files][$game_variables[@num]] || ""
  end
  
  def info
    CPVPics::Pictures[@num]
  end
end

## New class that is used to actually display the picture.  Changes a bit
## about how pictures work.
class Sprite_VariablePic < Sprite_Picture
  def initialize(num, viewport, picture)
    @num = num  ## Stores the picture's number.
    super(viewport, picture)
  end
  
  ## Changes how the picture is updated to allow map scrolling.
  def update_position
    case @picture.info[:map_mode]
    when 1
      self.x = -$game_map.display_x * 32 + @picture.xo
      self.y = -$game_map.display_y * 32 + @picture.yo
    when 2
      self.x = -$game_map.display_x * 32
      self.y = -$game_map.display_y * 32
    else
      self.x = self.y = 0
    end
    self.z = @picture.info[:z] ? @picture.info[:z] : 100
  end
end

## Replicates the Sprite_Picture class as a plane.
class Sprite_VariablePln < Plane
  def initialize(num, viewport, picture)
    @num = num
    @picture = picture
    super(viewport)
    update
  end
  
  def dispose
    bitmap.dispose if bitmap
    super
  end
  
  def update
    update_bitmap
    update_position
    update_zoom
    update_other
  end
  
  def update_bitmap
    if @picture.name.empty?
      self.bitmap = nil
    else
      self.bitmap = Cache.picture(@picture.name)
    end
  end
  
  def update_position
    case @picture.info[:map_mode]
    when 1
      self.ox = $game_map.display_x * 32 + @picture.xo
      self.oy = $game_map.display_y * 32 + @picture.yo
    when 2
      self.ox = $game_map.display_x * 32
      self.oy = $game_map.display_y * 32
    else
      self.ox = self.oy = 0
    end
    self.z = @picture.info[:z] ? @picture.info[:z] : 100
  end
  
  def update_zoom
    self.zoom_x = @picture.zoom_x / 100.0
    self.zoom_y = @picture.zoom_y / 100.0
  end
  
  def update_other
    self.opacity = @picture.opacity
    self.blend_type = @picture.blend_type
    self.tone.set(@picture.tone)
  end
end

## Modifies some methods on the map just for funnies.
class Spriteset_Map
  alias :cp_vpic_create_pictures :create_pictures
  def create_pictures
    cp_vpic_create_pictures
    create_vpics
  end
  
  def create_vpics
    $game_system.vpics = []
    @var_pictures = []
  end
  
  alias :cp_vpic_update :update
  def update
    cp_vpic_update
    update_vpic
  end
  
  ## This sucker hangs on to pictures.
  def update_vpic
    CPVPics::Pictures.each do |var, info|
      if $game_switches[info[:sw]]
        bitmap = info[:files][$game_variables[var]]
        next unless bitmap
        unless $game_system.vpics[var]
          $game_system.vpics[var] = Game_VariablePic.new(var)
          case info[:viewport]
          when 1; vp = @viewport1
          when 2; vp = @viewport2
          when 3; vp = @viewport3
          else; vp = nil
          end
          values = [var, vp, $game_system.vpics[var]]
          if info[:loop]
            @var_pictures[var] = Sprite_VariablePln.new(*values)
          else
            @var_pictures[var] = Sprite_VariablePic.new(*values)
          end
        end
      else
        if $game_system.vpics[var]
          @var_pictures[var].dispose
          @var_pictures.delete_at(var)
          $game_system.vpics.delete_at(var)
        end
      end
    end
    @var_pictures.each do |pic|
      next unless pic
      pic.update
    end
  end
  
  ## Disposes the pictures.
  alias :cp_vpic_dispose :dispose
  def dispose
    cp_vpic_dispose
    dispose_vpic
  end
  
  ## Does what I said up there.
  def dispose_vpic
    return unless @var_pictures
    @var_pictures.each do |pic|
      next if pic.nil?
      pic.dispose
    end
  end
end

 
##-----------------------------------------------------------------------------
## End of script.
##-----------------------------------------------------------------------------