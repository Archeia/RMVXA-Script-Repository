=begin
Region Map Loader
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Allows you to load parts of another map by using regions and switches
----------------------
Instructions
----------------------
See blog post for instructions.
----------------------
Known bugs
----------------------
None
=end
class Game_Map
  #--------------------------------------------------------------------------
  # * Aliases Setup
  #--------------------------------------------------------------------------
  alias regionmapsetup setup
  def setup(map_id)
    regionmapsetup(map_id)
    @regionmapdata = nil
  end
  #--------------------------------------------------------------------------
  # * Aliases Refresh
  #--------------------------------------------------------------------------
  alias regionmaprefresh refresh
  def refresh
    regionmaprefresh
    @regionmapdata = nil
  end
  #--------------------------------------------------------------------------
  # * Rewrites tile_id
  #--------------------------------------------------------------------------
  def tile_id(x, y, z)
    self.data[x, y, z] || 0
  end
  #--------------------------------------------------------------------------
  # * Rewrites data
  #--------------------------------------------------------------------------
  def data
    return @regionmapdata if @regionmapdata
    data = @map.data.clone
    if @map.note =~ /<regionmap (.*)>/i
      regions = $1.split(";")
      for region in regions
        regiondata = region.split(",")
        if $game_switches[regiondata[2].to_i]
          tmpdata = load_data(sprintf("Data/Map%03d.rvdata2", regiondata[1].to_i)).data
          for x in 0..@map.width
            for y in 0..@map.height
              if region_id(x,y) == regiondata[0].to_i
                data[x,y,0] = tmpdata[x,y,0]
                data[x,y,1] = tmpdata[x,y,1]
                data[x,y,2] = tmpdata[x,y,2]
                # Shadows and regions are stored in the same variable
                # If you can't bring yourself to copy regions then add 
                # % 256 to the end of the next line
                data[x,y,3] = tmpdata[x,y,3]
              end
            end
          end
        end
      end
    end
    @regionmapdata = data
    return @regionmapdata
  end
end