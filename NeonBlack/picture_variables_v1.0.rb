##------
# Picture Variables v1.0
# Created by Neon Black at request of Celianna
# Started 12.23.2012 - Completed 12.24.2012
# For non-commercial use; commercial use at request only
##------
module CP
module VPICS

## Links variables to switches.  If the switch is turned off, the picture 
## vanishes and will reset once turned back on.
## Uses syntax "variable ID => switch ID,".
VARIABLE_SWITCHES ={
1 => 1,
2 => 1,
3 => 1,
}

## Viewport used by the pictures.  Viewport 0 will display under all map data.
## Viewport 1 is the viewport used by map data, events, characters, etc.
## Viewport 2 is used by weather and flashes and displays above the map.
## Viewport 3 is above all other viewports.  If no viewport is defined, 3 is
## used instead.  Uses syntax "variable ID => viewport ID,".
PICTURE_VIEWPORT ={
1 => 1,
2 => 2,
3 => 2,
}

## Adjusts the Z position of pictures in similar viewports.  Higher numbers will
## display above lower numbers in the same viewport.  If no number is defined,
## a value of 100 is used.  Uses syntax "variable ID => Z position,".
PICTURE_Z ={
1 => 1,
2 => 101,
3 => 100,
}

## Do not touch these lines.--
Pictures ={} ##---------------
##----------------------------

## The following lines link pictures to variables.  To use, first add a line
## "Pictures[ID] ={" without quotes where "ID" is the variable ID.  Afterwards
## add the names of pictures to use when the variable is set to a particular
## amount.  Uses syntax "number => 'picture name',".  Finally, enclose the
## entire structure with a right bracket symbol '}'.

Pictures[1] ={
0 => nil,
1 => "test1",
2 => "test2",
}

Pictures[2] ={
0 => nil,
1 => "test1",
2 => "test2",
}

Pictures[3] ={
0 => nil,
1 => "test1",
2 => "test2",
}

## This section sets whether pictures are fixed to the map or fixed to the
## screen.  A value of "true" fixes the picture to the map, while "false"
## will fix it to the screen.  Uses syntax "variable ID => true/false,".
FIX_MAP ={
1 => true,
2 => false,
3 => false,
}

## Determines if the picture tints with the "Tint Screen" event command.  Note
## that pictures set to viewport 1 will ALWAYS tint to the screen no matter
## what this value is set to, and pictures in viewport 2 are affected by
## such things as weather than "Flash Screen" commands.
## Uses syntax "variable ID => true/false,".
TINT_MAP ={
1 => true,
2 => false,
3 => false,
}

##------------------------------------------------------------------------------
## End of configuration settings.
##------------------------------------------------------------------------------

end
end

## Sets up variables for the system.  This allows them to be saved when the game
## is saved.
class Game_System
  attr_accessor :vpics
  attr_accessor :gpics
  attr_accessor :picvar
end

## New class that holds the variable style picture.  This stores and allows
## access to some additional information.
class Game_VariablePic < Game_Picture
  attr_accessor :num
  attr_accessor :name
  attr_reader :xo
  attr_reader :yo
  
  def initialize(num)
    super(-1)  ## Changes the default blend type, sets the ID, sets the map set.
    @blend_type = 0
    @num = num
    @xo = $game_map.display_x * 32
    @yo = $game_map.display_y * 32
  end
end

## New class that is used to actually display the picture.  Changes a bit
## about how pictures work.
class Sprite_VariablePic < Sprite_Picture
  def initialize(num, viewport, picture)
    @num = num  ## Stores the picture's number.
    super(viewport, picture)
  end
  
  ## Allows the picture to be easily changed.
  def change_value(id)
    return self.dispose if id.nil?
    name = CP::VPICS::Pictures[@num][id]
    return self.dispose if name.nil?
    @picture.name = name
    update
  end
  
  ## Changes how the picture is updated to allow map scrolling.
  def update_position
    self.x = CP::VPICS::FIX_MAP[@num] ? -$game_map.display_x * 32 + @picture.xo : 0
    self.y = CP::VPICS::FIX_MAP[@num] ? -$game_map.display_y * 32 + @picture.yo : 0
    self.z = CP::VPICS::PICTURE_Z[@num] ? CP::VPICS::PICTURE_Z[@num] : 100
  end
  
  ## Allows the screen tone to update properly.
  def update_other
    self.opacity = @picture.opacity
    self.blend_type = @picture.blend_type
    self.angle = @picture.angle
    self.tone.set(CP::VPICS::TINT_MAP[@num] ? $game_map.screen.tone : Tone.new) 
  end
end

## Modifies some methods on the map just for funnies.
class Spriteset_Map
  alias cp_vpic_update update
  def update
    cp_vpic_update
    update_vpic
  end
  
  ## Holy sh-...  This sucker hangs on to picture and 
  def update_vpic
    $game_system.vpics = {} if $game_system.vpics.nil?
    $game_system.gpics = {} if $game_system.gpics.nil?
    $game_system.picvar = {} if $game_system.picvar.nil?
    CP::VPICS::Pictures.each do |id, pics|
      next if id.nil?
      if $game_switches[id]
        next if $game_system.picvar[id] == $game_variables[id]
        if $game_system.gpics[id].nil?
          $game_system.gpics[id] = Game_VariablePic.new(id)
        end
        if $game_system.vpics[id].nil?
          vp = CP::VPICS::PICTURE_VIEWPORT[id]
          if vp < 1
            port = nil
          elsif vp == 1
            port = @viewport1
          elsif vp == 2
            port = @viewport2
          elsif vp >= 3
            port = @viewport3
          else
            port = @viewport3
          end
          $game_system.vpics[id] = Sprite_VariablePic.new(id, port,
                                                         $game_system.gpics[id])
        end
        $game_system.vpics[id].change_value($game_variables[id])
      else
        next unless $game_system.vpics[id]
        $game_system.vpics[id].dispose
        $game_system.vpics[id] = nil
        $game_system.picvar[id] = nil
        $game_system.gpics[id] = nil
      end
    end
  end
  
  ## Disposes the pictures.
  alias cp_vpic_dispose dispose
  def dispose
    cp_vpic_dispose
    dispose_vpic
  end
  
  ## Does what I said up there.
  def dispose_vpic
    return unless @vpics
    @vpics.values do |array|
      next if array.nil?
      next if array[0].nil?
      array[0].dispose
    end
  end
end