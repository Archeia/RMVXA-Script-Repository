=begin
#==============================================================================
 ** Map Creator
 Author: Hime
 Date: Jan 31, 2013
------------------------------------------------------------------------------
 ** Change log
 Jan 31
   - combining maps now copied events over. Event commands are not updated
 Jan 8, 2013
   - fixed bugs in logic preventing maps from being created
 Oct 23
   - added support for combining maps. Does not copy events
 Oct 20
   - added check to make sure new map size does not exceed 250000 tiles
 Aug 24, 2012
   - added support for resizing existing maps
   - added map info verification to remove invalid entries
   - added automatic back-up functionality for map-related files
   - initial release
   
------------------------------------------------------------------------------   
 Create new maps in your project with no dimension limits.
 
 Just run the script and if successful you should get a message that it was
 successful.
 
 To create new maps, add some entries to the New_Map array. These will
 be created as new maps with no tile info.
 
 To resize existing maps, add some entries to Resize_Maps.
 Each key should refer to a valid map ID.
  
 To combine maps, add some entries to the Combine_Maps hash.
 Each key is the desired map name, and each value is a 2D matrix corresponding
 to the i'th and j'th map.
 
 For example, if you have 4 maps A1 A2 A3 A4 and you want to combine them
 into one big rectangular shape like
 
   A1 A2
   A3 A4
   
 You would write [ [A1, A2], [A3, A4] ] as the matrix. The tileset that 
 is assigned to the new map will be the tileset of the first map.
 
 All events in the maps are copied over, but any event commands that rely on
 event ID's are currently not updated automatically.
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Tsuki_MapCreator"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module Tsuki
  module MapExtend
    
    # run this script?
    Run_Script = false
    
    # back up MapInfo.rvdata2 and maps.
    Backup_Info = true
    Backup_Maps = true
    
    # table of new map info. Format for each entry
    #   [name, display_name, width, height]
    Create_Maps = [
        #["Long3", "", 250, 1000],
    ]
    
    # a hash of maps that you want to resize. Format
    #    map_ID => [width, height]
    Resize_Maps = {
      #5 => [500, 5000]
    }
    
    # How much padding to place between maps
    Padding = 0
    
    # Combines maps into one large map
    Combine_Maps = {
      "tester" => [[1,1],[1,1]]
    }
#==============================================================================
# ** Rest of script
#==============================================================================

    def self.make_backup_folder
      Dir.mkdir("Data/Backup") unless Dir.exist?("Data/Backup")
    end 
    
    def self.warn_map_size(name)
      msgbox("Map `%s` is too large. Max tiles is 250000. Skipping" %name)
    end
    
    def self.load_map(map_id)
      return load_data(sprintf("Data/Map%03d.rvdata2", map_id))
    end
    
    # back up the mapinfos files
    def self.backup_info
      make_backup_folder
      save_data(@data_mapinfos, "Data/Backup/MapInfos.rvdata2")
    end
    
    # back up all maps
    def self.backup_maps
      make_backup_folder
      @data_mapinfos.each {|map_id, data|
        
        name = sprintf("Data/Map%03d.rvdata2", map_id)
        outName = sprintf("Data/Backup/Map%03d.rvdata2", map_id)
        begin
          save_data(load_data(name), outName)
        rescue
        end
      }
    end
    
    # verify that the mapinfos file up to date
    def self.verify_mapinfo
      
      @data_mapinfos.each {|map_id, data|
        name = sprintf("Data/Map%03d.rvdata2", map_id)
        if FileTest.exist?(name)
          
        else
          @data_mapinfos.delete(map_id)
        end
      }
    end
    
    def self.backup_files
      backup_info if Backup_Info
      backup_maps if Backup_Maps      
    end

    def self.create_maps
      @data_mapinfos = load_data("Data/MapInfos.rvdata2")
      backup_files
      verify_mapinfo
      make_new_maps if Create_Maps
      resize_maps if Resize_Maps
      combine_maps unless Combine_Maps.empty?
    end
    
    def self.make_new_maps
      Create_Maps.each {|info|      
        make_map(*info)
      }
    end
    
    def self.resize_maps
      Resize_Maps.each {|id, dims|
        resize_map(id, *dims)
      }
    end
    
    def self.combine_maps
      Combine_Maps.each {|name, entry|
        combine_map(name, entry)
      }
    end

    def self.make_map(name, display_name, width, height)
      if width * height > 250000
        warn_map_size(name)
        return
      end
      map_id = @data_mapinfos.keys.max + 1
      @map = RPG::Map.new(width, height)
      @map.display_name = display_name
      create_map_entry(map_id, name)
      
      save_data(@map, sprintf("Data/Map%03d.rvdata2", map_id))
      save_data(@data_mapinfos, "Data/MapInfos.rvdata2")
    end

    def self.create_map_entry(map_id, name)
      entry = RPG::MapInfo.new
      entry.name = name
      entry.order = map_id
      @data_mapinfos[map_id] = entry
    end
    
    def self.resize_map(map_id, width, height)
      if width * height > 250000
        warn_map_size(map_id)
        return
      end
      name = sprintf("Data/Map%03d.rvdata2", map_id)
      begin
        @map = load_data(name)
        @map.width = width
        @map.height = height
        @map.data.resize(width, height)
        save_data(@map, sprintf("Data/Map%03d.rvdata2", map_id))
      rescue
        msgbox("map ID %d doesn't exist" %map_id)
      end
    end
    
    # Combine all the maps together
    def self.combine_map(name, entry)
      map_id = @data_mapinfos.keys.max + 1
      new_map = RPG::Map.new(0, 0)
      new_map.display_name = name
      new_map.tileset_id = load_map(entry[0][0]).tileset_id
      
      new_data = new_map.data
      x_ofs = 0
      y_ofs = 0
      event_ofs = 0
      max_height = 0
      for i in 0...entry.size
        for j in 0...entry[i].size
          id = entry[i][j]
          map = load_map(id)
          
          temp_x = x_ofs + map.width
          temp_y = y_ofs + map.height
          new_x = temp_x > new_data.xsize ? temp_x : new_data.xsize
          new_y = temp_y > new_data.ysize ? temp_y : new_data.ysize
          new_data.resize(new_x, new_y, 4)
          
          copy_map(new_map, map, x_ofs, y_ofs) 
          copy_events(new_map, map, x_ofs, y_ofs, event_ofs)
          
          # increment width offset
          x_ofs += map.width + Padding
          event_ofs += map.events.size
        end
        
        # next row of maps, reset x offset to 0, and increase y offset
        # by the height of the tallet map from the previous row
        x_ofs = 0
        y_ofs = new_data.ysize + Padding
      end
      
      # update map attributes
      new_map.width = new_data.xsize
      new_map.height = new_data.ysize
      
      # create map
      create_map_entry(map_id, name)
      save_data(new_map, sprintf("Data/Map%03d.rvdata2", map_id))
      save_data(@data_mapinfos, "Data/MapInfos.rvdata2")
    end
    
    def self.copy_map(new_map, map, width_ofs, height_ofs)
      # copy tiles
      new_data = new_map.data
      data = map.data
      for x in 0...data.xsize
        for y in 0...data.ysize
          for z in 0...4
            new_data[x+width_ofs, y+height_ofs, z] = data[x, y, z]
          end
        end
      end
    end
    
    # copy events to new map, offsetting all event ID's as required
    def self.copy_events(new_map, map, width_ofs, height_ofs, event_ofs)
      map.events.each {|event_id, event|
        event_id += event_ofs
        new_event = event.clone
        new_event.x += width_ofs
        new_event.y += height_ofs
        new_map.events[event_id] = new_event
      }
    end
  end
end

# just run this
if Tsuki::MapExtend::Run_Script
  Tsuki::MapExtend.create_maps
  msgbox("Done")
  exit
end