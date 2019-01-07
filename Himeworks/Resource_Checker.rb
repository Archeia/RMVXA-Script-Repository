=begin
#==============================================================================
 ** Resource Checker
 Author: Hime
 Date: May 5, 2013
------------------------------------------------------------------------------
 ** Change log
 Feb 11, 2015
   - added support for listing unused resources
 May 5, 2013
   - added move routes
 Aug 2, 2012
   - added support for VX
 Jul 27, 2012
   - initial release
------------------------------------------------------------------------------   
 ** Description
 
 This script goes through all of the data files in the data folder and
 displays a list of graphics and audio used.
 
 It performs a very simple resource check and copy: if it's defined in your
 database or in any event, it is assumed you are using it.
 
 Additionally, it also prints out a list of files that exist in your project
 resource folders, but are not being used in the game
 
 This script also does not support custom scripts that reference RTP
 resources; if you have custom scripts and you know they use RTP materials,
 you should consider copying everything related to that script over manually.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Press F5 to run the resource checker. You can change this key in the 
 configuration section.
 
 After the resource checker finishes, a file called "used_resources.txt" will be
 created in your project folder.
 
 It will also create a file called "unused_resources.txt" which lists
 all of the files that aren't in use currently
 
 You can also choose to copy files over from the RTP folder directly.
 In the configuration section, type in the absolute path to the RTP, and
 enable file copying.

#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Tsuki_Resource_Checker"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module Tsuki
  module Resource_Checker
    
    # Copy your RTP path here.
    # Don't forget the trailing slash (I don't check it)
    RTP_Directory = "F:/Program Files/RPG Runtime/RPGVXAce/"
    
    # Set it to false if you only want a list of resources you use
    Copy_Files_Over = true
    
    # change this if you need to
    Check_Key = Input::F5
#==============================================================================
# ** Rest of the script
#============================================================================== 
    Graphics_Dirs = [:Animations, :Battlebacks1, :Battlebacks2, :Battlers,
                     :Characters, :Faces, :Parallaxes, :Pictures, :System,
                     :Tilesets, :Titles1, :Titles2]
    Audio_Dirs = [:BGM, :BGS, :ME, :SE]
    Font_Dirs = [:Fonts]
    
    # this is supposed to add some path checking...
    def self.rtp_directory
      RTP_Directory
    end
  
    def self.rpgvxace?
      defined? BasicObject
    end
    
    def self.rpgvx?
      defined? Graphics.resize_screen
    end
    
    def self.show_message(message)
      if rpgvxace?
        $game_message.add(message)
      elsif rpgvx?
        $game_message.texts.push(message)
      end
    end
    
    def self.init_resource_finder
      return Resource_Finder_Ace.new if rpgvxace?
      return Resource_Finder_VX.new if rpgvx?
    end
  end
end

# just add it somewhere

class Game_Player
  
  alias tsuki_Resource_Checker_update update
  def update
    tsuki_Resource_Checker_update
    if Input.trigger?(Tsuki::Resource_Checker::Check_Key)
      r = Tsuki::Resource_Checker.init_resource_finder
      r.run
    end
  end
end
#~  
# generic parser class. Subclasses should implement the methods if needed
class Data_Parser
  
  def initialize
    @data_animations = load_data_file("Animations")
  end
  
  def make_data_path(filename)
  end
  
  def load_data_file(filename)
    path = make_data_path(filename)
    return load_data(path)
  end
  
  def parse_actors
  end
  
  def parse_classes
  end
  
  def parse_skills
  end
  
  def parse_items
  end
  
  def parse_weapons
  end
  
  def parse_armors
  end
  
  def parse_states
  end
  
  def parse_enemies
  end
  
  def parse_troops
  end
  
  def parse_animations
  end
  
  def parse_tilesets
  end
  
  def parse_system
  end
  
  def parse_fonts
  end
  
  # takes a vehicle object stored in System.rvdata2
  def parse_vehicle(vehicle)
  end
  
  def parse_terms
  end
  
  # map parsing
  
  def parse_datamaps
  end
  
  # pass in a map ID
  def parse_map(map_id)
  end
  
  # takes an RPG::Map::Encounter object
  def parse_encounters(encounters)
  end
  
  # event parsers
  
  def parse_event_commands(list)
  end
  
  def parse_event_page(page)
  end
  
  def parse_event(event)
  end
  
  def parse_map_events(events)
  end
  
  def parse_common_events
  end
  
  def parse_data_files
    parse_actors
    parse_classes
    parse_skills
    parse_items
    parse_weapons
    parse_armors
    parse_enemies
    parse_troops
    parse_states
    parse_animations
    parse_tilesets
    parse_common_events
    parse_system
    parse_terms
    parse_datamaps
    parse_fonts
  end
end

class Resource_Finder_Ace < Data_Parser
  
  attr_reader :resources

  def initialize
    super
    @resources = {}
  end
  
  def make_data_path(filename)
    "Data/#{filename}.rvdata2"
  end
  
  def init_category(category)
    @resources[category] = []
  end
  
  def add_resource(category, name)
    init_category(category) if @resources[category].nil?
    return unless name && !name.empty?
    @resources[category] |= [name]
  end
  
  def parse_actors
    actors = load_data_file("Actors")
    actors.each {|actor|
      next unless actor
      add_resource(:Characters, actor.character_name)
      add_resource(:Faces, actor.face_name)
    }
  end   
  
  def parse_enemies
    enemies = load_data_file("Enemies")
    enemies.each {|enemy|
      next unless enemy
      add_resource(:Battlers, enemy.battler_name)
    }
  end
  
  def parse_troops
    troops = load_data_file("Troops")
  end
  
  def parse_animations
    anims = load_data_file("Animations")
    anims.each {|anim|
      next unless anim
      add_resource(:Animations, anim.animation1_name)
      add_resource(:Animations, anim.animation2_name)
    }
  end
  
  def parse_tilesets
    tilesets = load_data_file("Tilesets")
    tilesets.each {|tileset|
      next unless tileset
      tileset.tileset_names.each {|name|
        add_resource(:Tilesets, name)
      }
    }
  end
  
  def parse_common_events
    events = load_data_file("CommonEvents")
    events.each {|evt|
      next unless evt
      parse_command_list(evt.list)
    }
  end
  
  def parse_system
    system = load_data_file("System")
    add_resource(:BGM, system.title_bgm.name)
    add_resource(:BGM, system.battle_bgm.name)
    add_resource(:ME, system.battle_end_me.name)
    add_resource(:ME, system.gameover_me.name)
    
    # add system sounds
    system.sounds.each {|sound|
      add_resource(:SE, sound.name)
    }
    
    # test battle and editor related
    add_resource(:Battlebacks1, system.battleback1_name)
    add_resource(:Battlebacks2, system.battleback2_name)
    add_resource(:Battlers, system.battler_name)    
    
    # vehicles
    parse_vehicle(system.boat)
    parse_vehicle(system.ship)
    parse_vehicle(system.airship)
    
    # titles
    add_resource(:Titles1, system.title1_name)
    add_resource(:Titles2, system.title2_name)
    
    # some default stuff
    add_resource(:System, "BattleStart")
    add_resource(:System, "GameOver")
    add_resource(:System, "IconSet")
    add_resource(:System, "Shadow")
    add_resource(:System, "Window")
  end
  
  def parse_vehicle(vehicle)
    add_resource(:Characters, vehicle.character_name)
    add_resource(:BGM, vehicle.bgm.name)
  end
  
  # just hardcoded...
  def parse_fonts
    add_resource(:Fonts, "VL-Gothic-Regular")
    add_resource(:Fonts, "VL-PGothic-Regular")
  end
  
  # map parser
  
  def parse_datamaps
    
    infos = load_data_file("MapInfos")
    infos.each {|id, map|
      next unless map
      parse_map(id)
    }
  end
  
  def parse_map(map_id)
    map = load_data_file(sprintf("Map%03d", map_id))
    add_resource(:Parallaxes, map.parallax_name)
    add_resource(:BGM, map.bgm.name)
    add_resource(:BGS, map.bgs.name)
    parse_map_events(map.events)
  end
  
  # event parsing
  
  def check_event_resources(cmd)
    code, params = cmd.code, cmd.parameters
    case code
    when 101 # show text
      add_resource(:Faces, params[0]) # face name
    when 205 # move route
      check_move_route(params[1])
    when 212 # show animation
    when 213 # show balloon
      add_resource(:System, "Balloon")
    when 231 # show picture
      add_resource(:Pictures, params[1])
    when 241 # play BGM
      add_resource(:BGM, params[0].name)
    when 245 # play BGS
      add_resource(:BGS, params[0].name)
    when 249 # play ME
      add_resource(:ME, params[0].name)
    when 250 # play SE
      add_resource(:SE, params[0].name)
    when 261 # play movie
    when 282 # change tileset
      tset_id = params[0]
    when 283 # change battleback
      add_resource(:Battlebacks1, params[0])
      add_resource(:Battlebacks2, params[1])
    when 284 # change parallax
      add_resource(:Parallaxes, params[0])
    when 322 # Change Actor Graphic
      add_resource(:Characters, params[1])
      add_resource(:Faces, params[3])
    when 323 # Change Vehicle Graphic
      add_resource(:Characters, params[1])
    when 335 # Enemy appear
    when 336 # Enemy transform
    when 337 # Show battle animation
      add_resource(:Animations, @data_animations[params[1]].name)
    end
  end
  
  def check_move_route(route)
    route.list.each do |cmd|
      case cmd.code
      when 41 # change character graphic
        add_resource(:Characters, cmd.parameters[0])
      when 44 # play SE
        add_resource(:SE, cmd.parameters[0].name)
      end
    end
  end
  
  def parse_command_list(list)
    list.each {|cmd|
      check_event_resources(cmd)
    }
  end
  
  def parse_event_page(page)
    
    add_resource(:Characters, page.graphic.character_name)
    parse_command_list(page.list)
  end
  
  def parse_event(event)
    event.pages.each {|page|
      parse_event_page(page)
    }
  end
  
  def parse_map_events(events)
    events.each {|id, evt|
      parse_event(evt)
    }
  end
  
  def run
    parse_data_files
    export
  end
  
  def export
    r = Resource_Exporter.new(@resources)
    r.run
  end
end

# basically the same thing, except no tilesets and different system
class Resource_Finder_VX < Resource_Finder_Ace
  
  def make_data_path(filename)
    "Data/#{filename}.rvdata"
  end
  
  def parse_tilesets
    system = load_data_file("System")
    add_resource(:System, "TileA1")
    add_resource(:System, "TileA2")
    add_resource(:System, "TileA3")
    add_resource(:System, "TileA4")
    add_resource(:System, "TileA5")
    add_resource(:System, "TileB")
    add_resource(:System, "TileC")
    add_resource(:System, "TileD")
    add_resource(:System, "TileE")
  end
  
  def parse_system
    system = load_data_file("System")
    add_resource(:BGM, system.title_bgm.name)
    add_resource(:BGM, system.battle_bgm.name)
    add_resource(:ME, system.battle_end_me.name)
    add_resource(:ME, system.gameover_me.name)
    
    # add system sounds
    system.sounds.each {|sound|
      add_resource(:SE, sound.name)
    }
    
    # test battle and editor related
    add_resource(:Battlers, system.battler_name)    
    
    # vehicles
    parse_vehicle(system.boat)
    parse_vehicle(system.ship)
    parse_vehicle(system.airship)
    
    # titles
    add_resource(:System, "Title")
    
    # some default stuff
    add_resource(:System, "BattleStart")
    add_resource(:System, "BattleFloor")
    add_resource(:System, "MessageBack")
    add_resource(:System, "GameOver")
    add_resource(:System, "IconSet")
    add_resource(:System, "Shadow")
    add_resource(:System, "Window")
  end
  
  def parse_fonts
    add_resource(:Fonts, "umeplus-gothic")
  end
end

class Resource_Exporter
  
  def initialize(data)
    @data = data
    @outfile = nil
  end
  
  def rtp_directory
    Tsuki::Resource_Checker.rtp_directory
  end
  
  def rtp_directory_valid?
    return false unless File.directory?(rtp_directory)
    return false unless File.directory?(rtp_directory + "Graphics")
    return false unless File.directory?(rtp_directory + "Audio")
    return false unless File.directory?(rtp_directory + "Fonts")
    return true
  end
  
  def create_outfile(name)
    File.open(name, "w")
  end
  
  def make_category_folder(category)
    if Tsuki::Resource_Checker::Graphics_Dirs.include?(category)
      name = "Graphics%s%s" %[File::Separator, category]
    elsif Tsuki::Resource_Checker::Audio_Dirs.include?(category)
      name = "Audio%s%s" %[File::Separator, category]
    elsif Tsuki::Resource_Checker::Font_Dirs.include?(category)
      return
    end
    Dir.mkdir(name) unless File.directory?(name)
    return name
  end
  
  def make_out_name(folder, category, name)
    matches = Dir::glob("#{rtp_directory}#{folder}/#{category}/#{name}.*")
    unless matches.empty?
      ext = matches[0].split("/")[-1].split(".")[-1]
    else
      #Tsuki::Resource_Checker.show_message("%s was not found" %name)
    end
    return name #+ ".#{ext}"
  end
  
  def make_path(category, name)    
    outName = ""
    if Tsuki::Resource_Checker::Graphics_Dirs.include?(category)
      name = make_out_name("Graphics", category, name)
      outName << sprintf("Graphics%s%s%s", File::Separator, category, File::Separator)
    elsif Tsuki::Resource_Checker::Audio_Dirs.include?(category)
      name = make_out_name("Audio", category, name)
      outName << sprintf("Audio%s%s%s", File::Separator, category, File::Separator)
    elsif Tsuki::Resource_Checker::Font_Dirs.include?(category)
      name = make_out_name("", category, name)
      outName << sprintf("Fonts%s", File::Separator)
    end
    return outName << name
  end
  
  # just read/write
  def copy_file(srcPath, destPath)
    File.open(srcPath, 'rb') {|src_file|
      File.open(destPath, 'wb') {|dest_file|
        dest_file.write(src_file.read)
      }
    }
  end
  
  def make_file(path)
    begin
      if FileTest.exist?(path)
        # nothing. Don't clutter the console
      elsif !FileTest.exist?(rtp_directory + path)
        p "%s isn't an RTP file" %path
      else
        copy_file(rtp_directory + path, path)
        p "%s - copied successfully" %path
      end
    rescue
      Tsuki::Resource_Checker.show_message("Something went wrong! Just be careful")
    end
  end
  
  def write_heading(name)
    @outfile.puts("== %s == " %name)
  end
  
  def write_data(category, list)
    list.sort.each {|name| 
      path = make_path(category, name)
      @outfile.puts(sprintf("%s", path))
    }
    @outfile.puts("\n")
  end
  
  # write the log out
  def export_log
    Tsuki::Resource_Checker.show_message("Scanning for resources")    
    @outfile = create_outfile("used_resources.txt")
    
    @outfile.puts("The follow resources are used in the game:\n")
    @data.each {|category, list|
      write_heading(category)
      write_data(category, list)
    }
    @outfile.close
    
    @outfile = create_outfile("unused_resources.txt")
    write_unused_resources
    @outfile.close
    
    Tsuki::Resource_Checker.show_message("Finished scanning resources")
  end
  
  def write_unused_resources
    @outfile.puts("=========================================\n")
    @outfile.puts("The follow resources are unused\n")
    @outfile.puts("=========================================\n")
    @data.each do |category, list|
      dirName = make_category_folder(category)
      next unless dirName
      
      # Grab all of the files in the folder, without extensions
      filenames = Dir.glob(dirName << "/*").collect {|path| File.basename(path, ".*") }
      
      # Remove the ones that we found in the game
      filenames -= list
      
      # These are all unused      
      write_heading(category)
      write_data(category, filenames)
    end
  end
  
  # lol inefficient but I like it separated
  def copy_files
    Tsuki::Resource_Checker.show_message("Begin file copying")
    t1 = Time.now
    # check RTP folder exists
    unless rtp_directory_valid? 
      Tsuki::Resource_Checker.show_message("Your RTP directory is invalid or inaccessible")
      return
    end
    # basic folders
    Dir.mkdir("Graphics") unless File.directory?("Graphics")
    Dir.mkdir("Audio") unless File.directory?("Audio")
    Dir.mkdir("Fonts") unless File.directory?("Fonts")
    Dir.mkdir("Movies") unless File.directory?("Movies")
    Dir.mkdir("System") unless File.directory?("System")
    
    @data.each {|category, list|
      make_category_folder(category)
      list.each { |name|
        path = make_path(category, name)
        make_file(path)
      }
    }
    t2 = Time.now
    Tsuki::Resource_Checker.show_message("File copy complete in %f seconds." %(t2 - t1))
  end
  
  def run
    export_log
    copy_files if Tsuki::Resource_Checker::Copy_Files_Over
  end
end

class Game_Interpreter
  
  def build_resource_list
    r = Tsuki::Resource_Checker.init_resource_finder
    r.run
  end
end