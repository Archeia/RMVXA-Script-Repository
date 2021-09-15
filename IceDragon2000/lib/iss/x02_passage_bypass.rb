#encoding:UTF-8
# ISSX02 - Passage Bypass
#==============================================================================#
# ** ISSX::PassageBypass
#==============================================================================#
module ISSX
  module PassageBypass

    RULES = {
    # // ID => Replacement
      0 => 0x00, # // Passable
      1 => 0x01, # // Impassable
      2 => 0x10, # // Upper Passable
      3 => 0x10, # // Swap to Upper Passable
      4 => -1  , # // Resets TilePassage
    }

    ID_CORRECTION = {
    # // Tiled ID => Bypass Passage ID
      1025 => 0,
      1026 => 1,
      1027 => 2,
      1028 => 3,
      1029 => 4,
    }

    TILE_ID_READ_OFFSET = -1
  end
end

#==============================================================================#
# ** ISSX::PassageBypass
#==============================================================================#
module ISSX
  module PassageBypass

    EXTDATA_FOLDER = 'Data/ExtData'
    BYPASS_FOLDER  = File.join(EXTDATA_FOLDER, 'Bypass_Passages')
    FileUtils.mkdir_p(EXTDATA_FOLDER)
    FileUtils.mkdir_p(BYPASS_FOLDER)

    BYPASSES = {}
    BYPASS_MAPS = {}
    TILEID_FIX = Array.new( 1024, 0 )
    for i in 0...TILEID_FIX.size
      TILEID_FIX[i] = i # // Need to fix this
    end

    File.open(EXTDATA_FOLDER+"/BypassSettings.xml", "r") do |f|
      ISSX::BXMLR.get_element_contents( "bypass_passages", f ).each do |s|
        case s
        when /<bypass name="(.*)" filename="(.*)"\/>/i
          BYPASSES[$1] = $2
        end
      end
    end
    File.open(EXTDATA_FOLDER+"/BypassSettings.xml", "r") do |f|
      reading_maps = []
      ISSX::BXMLR.get_element_contents( "bypass_maps", f ).each do |s|
        case s
        when /<\/map>/i
          reading_maps = []
        when /<map id="(\d+)">/i
          reading_maps = [$1.to_i]
        when /<map range="(\d+) to (\d+)">/i
          reading_maps = (($1.to_i)..($2.to_i)).to_a
        when /<bypass_passage="(.*)"\/>/i
          pname = $1 ; reading_maps.each { |i| (BYPASS_MAPS[i] ||= []) << pname }
        end
      end
    end

    PASSTABLE_DATA = {}

    BYPASSES.each_pair do |key, value|
      PASSTABLE_DATA[key] ||= []
      File.open(BYPASS_FOLDER+"/"+value) do |f|
        layer_type = -1
        read_props = false
        read_data  = false
        tileids = []
        count = 0
        f.each_line do |l|
          case l
          when /<layer name="(.*)"/i
            count = 0
            layer_type = 0
          when /<\/layer>/i
            count = 0
            layer_type = -1
          when /<properties>/i
            read_props = layer_type > -1 ? true : false
          when /<\/properties>/i
            read_props = false
          when /<property name="(.*)" value="(.*)"\/>/i
            next unless read_props
            case $1.upcase
            when "TILES"
              layer_type = 1
            when "PASSAGES"
              layer_type = 2
            end
          when /<data>/i
            read_data = layer_type > -1 ? true : false
            count = 0
          when /<\/data>/i
            read_data = false
            count = 0
          when /<tile gid="(\d+)"\/>/i
            gid = $1.to_i
            next unless read_data
            if layer_type == 1
              tileids[count] ||= [TILEID_FIX[gid+TILE_ID_READ_OFFSET], -1]
            end
            if layer_type == 2
              tileids[count][1] = RULES[ID_CORRECTION[gid]]
            end
            count += 1
          end
        end # // Each Line
        PASSTABLE_DATA[key] += tileids
      end # // File
    end # // BYPASSES

    @@bypass_cache = {}

  end
end

$bypass_cache = {}

#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iss_passby_gmp_setup :setup unless $@
  def setup( map_id )
    @bypassages ||= Table.new( 10000 )
    iss_passby_gmp_setup( map_id )
    setup_bypass_passages( map_id )
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_bypass_passages
  #--------------------------------------------------------------------------#
  def setup_bypass_passages( map_id )
    if $bypass_cache[map_id].nil?()
      passtable = @passages.clone()
      byp = ISSX::PassageBypass::BYPASS_MAPS[map_id]
      pd  = ISSX::PassageBypass::PASSTABLE_DATA
      byp.each { |pp| pd[pp].each { |a| passtable[a[0]] = a[1] unless a[1] == -1 } } unless byp.nil?()
      $bypass_cache[map_id] = passtable
    end
    @bypassages = $bypass_cache[map_id]
  end

  #--------------------------------------------------------------------------#
  # * new-method :back_passable?
  #--------------------------------------------------------------------------#
  def back_passable?( x, y ) ; return false ; end unless method_defined? :back_passable?

  #--------------------------------------------------------------------------#
  # * overwrite-method :passable?
  #--------------------------------------------------------------------------#
  def passable?( x, y, flag = 0x01 )
    return true if back_passable?( x, y )   # // Compatability with Backpass
    for event in events_xy( x, y )          # events with matching coordinates
      next if event.tile_id == 0            # graphics are not tiled
      next if event.priority_type > 0       # not [Below characters]
      next if event.through                 # pass-through state
      pass = @bypassages[event.tile_id]     # get passable attribute
      next if pass & 0x10 == 0x10           # *: Does not affect passage
      return true if pass & flag == 0x00    # o: Passable
      return false if pass & flag == flag   # x: Impassable
    end
    for i in [2, 1, 0]                      # in order from on top of layer
      tile_id = @map.data[x, y, i]          # get tile ID
      return false if tile_id == nil        # failed to get tile: Impassable
      pass = @bypassages[tile_id]           # get passable attribute
      next if pass & 0x10 == 0x10           # *: Does not affect passage
      return true if pass & flag == 0x00    # o: Passable
      return false if pass & flag == flag   # x: Impassable
    end
    return false                            # Impassable
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :bush?
  #--------------------------------------------------------------------------#
  def bush?( x, y )
    return false unless valid?( x, y )
    return @bypassages[@map.data[x, y, 1]] & 0x40 == 0x40
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :counter?
  #--------------------------------------------------------------------------#
  def counter?( x, y )
    return false unless valid?( x, y )
    return @bypassages[@map.data[x, y, 0]] & 0x80 == 0x80
  end


end
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
