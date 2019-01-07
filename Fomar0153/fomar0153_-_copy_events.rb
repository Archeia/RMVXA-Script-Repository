=begin
Copy Event Script
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Allows you to copy events.
----------------------
Instructions
----------------------
In a script command use:
$game_map.add_event(mapid, eventid, x, y) 
to add a new event.
mapid and eventid refer to map and event you're copying
x and y refer to the location you wish to copy it to
----------------------
Known bugs
----------------------
None
=end
class Game_Map
  #--------------------------------------------------------------------------
  # ● Adds an event from another map to the current map
  #--------------------------------------------------------------------------
  def add_event(mapid, eventid, x, y)
        map = load_data(sprintf("Data/Map%03d.rvdata2", mapid))
        map.events.each do |i, event|
          if event.id == eventid
                e = Game_Event.new(@map_id, event)
                e.moveto(x,y)
                @events[@events.length + 1] = e
          end
        end
        SceneManager.scene.get_spriteset.refresh_characters
  end
end

class Scene_Map < Scene_Base
  def get_spriteset
        return @spriteset
  end
end