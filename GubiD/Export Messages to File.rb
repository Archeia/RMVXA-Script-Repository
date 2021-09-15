#-------------------------------------------------------------------------------
# Extract Messages to File by GubiD
#-------------------------------------------------------------------------------
# Modified by Archeia/Trihan to fix issues where events and map names containing illegal
# characters will stop the extraction process.

#------------------------------------------------------------------
# Object
#------------------------------------------------------------------
class Object
    def string?
      return false
    end
  end
  #-----------------------------------------------------------------
  # String
  #------------------------------------------------------------------
  class String
    def string?
      true
    end
  end
  #------------------------------------------------------------------
  module Export_Messages
    #------------------------------------------------------------------
    # Enabled - When true, data will export.  Otherwise no.
    #------------------------------------------------------------------
    ENABLED = true
    
    #------------------------------------------------------------------
    # Maps File - File in which contains the map information
    #------------------------------------------------------------------
    MapsFile = "./Data/MapInfos.rvdata2"
    
    #------------------------------------------------------------------
    # Event Messages Folder
    #------------------------------------------------------------------
    EVENT_MESSAGES_FOLDER = "./Messages/"
    
    #------------------------------------------------------------------
    # Make Folder Name (from map ID and MAP)
    #------------------------------------------------------------------
    def self.make_folder_name(id, map)
      return sprintf("%03d_%s", id, map.name.gsub!(/[^0-9A-Za-z]/, ''));
    end
    #------------------------------------------------------------------
    # Export Messages
    #------------------------------------------------------------------
    # This exports all the events messaging in the game on every map
    #------------------------------------------------------------------
    def self.export_messages
      maps = load_data(MapsFile)
      if !Dir.exist?(EVENT_MESSAGES_FOLDER)
        Dir.mkdir(EVENT_MESSAGES_FOLDER)
      end
      for id in 1...maps.size+1
        mapFile = sprintf("Data/Map%03d.rvdata2", id)
        mapInfo = maps[id]
        map = load_data(mapFile) rescue next
        foldername = EVENT_MESSAGES_FOLDER + make_folder_name(id, mapInfo)
        if !Dir.exist?(foldername)
          Dir.mkdir(foldername)
        end
        for event_id in map.events.keys
          event = map.events[event_id]
          for i in 0...event.pages.size
            filename = sprintf("%s/%03d_%s_%02d.txt", foldername, event_id, event.name.gsub!(/[^0-9A-Za-z]/, ''), i+1)
            if File.exist?(filename)
              File.delete(filename)
            end
            file = File.new(filename, 'a') #open file in append mode
            file.write(sprintf("%03d %s Page_%02d", event_id, event.name.gsub!(/[^0-9A-Za-z]/, ''), i+1))
            write_linebreak(file)
            
            page = event.pages[i]
            
            event_string_data = build_event_string_data(page)
            
            file.write(event_string_data)
            file.close
            
            if event_string_data == ""
              File.delete(filename)
            end
          end
          
        end
      end
      print "Finished Exporting messages to file\n"
    end
    #------------------------------------------------------------------
    # Construct message string data
    #------------------------------------------------------------------
    def self.build_event_string_data(page)
      save_string = []
      @index = 0
      #------------------------------------------------------------------
      # Walk list and check each item.  
      # Since choices already sort items for us, no additional sort is needed. 
      #------------------------------------------------------------------
      while page.list[@index] != nil
        event_data = page.list[@index]
        indent = "\t " * event_data.indent
        if ([101, 401].include?(event_data.code))
          s = event_data.parameters[0]
          save_string << indent + "[MESSAGE]" + s unless s == ""
        elsif [402].include?(event_data.code)
          for s in event_data.parameters
            save_string << indent + "[CHOICE]" + s if s.string?
          end
        elsif [404].include?(event_data.code)
          save_string << indent + "[END_CHOICE]"
        end
        @index += 1
      end
      return save_string.join("\n")
    end
    #------------------------------------------------------------------
    # Write Linebreak
    #------------------------------------------------------------------
    def self.write_linebreak(file)
      file.write("\r\n")
    end
    if ENABLED
      export_messages
    end
  end