#-------------------------------------------------------------------------------
# Script Import/Export to File by GubiD
#-------------------------------------------------------------------------------
module Script_ImportExport
  
  #--------------------------------------------------------------------
  # * USAGE * 
  #--------------------------------------------------------------------
  # Place this script in your project in the last available slot in Script Editor
  # prior to Main.  
  # To export your script files ensure EXPORT is true and IMPORT is false
  # To import your script files ensure IMPORT is true
  #--------------------------------------------------------------------
  # Read header for each of the below options for description of its usage
  #--------------------------------------------------------------------
  
  #--------------------------------------------------------------------
  # Import/Export Scripts from Scripts Folder?
  #--------------------------------------------------------------------
  # Note:
  #   When IMPORT is true, export is automatically disabled.  
  #--------------------------------------------------------------------
  IMPORT = false
  EXPORT = false
  DELETE_ON_IMPORT = false
  SHOW_CONSOLE = false
  
  #--------------------------------------------------------------------
  #So this script doesn't export/import it self into the script file, put the
  # name you assign to this script in the "THIS SCRIPT" variable below
  #--------------------------------------------------------------------
  THIS_SCRIPT = "Export&Import Scripts"
  
  #--------------------------------------------------------------------
  # When this file is present then the scripts have been imported already
  # This file will then be deleted and the game will load normally.
  #--------------------------------------------------------------------
  # WARNING: Ensure this is not an empty string!
  #--------------------------------------------------------------------
  IMPORT_TEMP_FILE = "ImportingScripts.tmp"
  
  #--------------------------------------------------------------------
  # Holding Folder
  #--------------------------------------------------------------------
  # This is the folder in which your script files will be stored
  #--------------------------------------------------------------------
  Holding_Folder = "Scripts"
  
  #--------------------------------------------------------------------
  # Script File
  #--------------------------------------------------------------------
  # Path to Project Scripts file - "./" is current directory
  #--------------------------------------------------------------------
  ScriptFile = "./Data/Scripts.rvdata2"
  
  #--------------------------------------------------------------------
  Export_Core_Scripts = false
  Overwrite_Core_Scripts = false
  
  #--------------------------------------------------------------------
  INVALID_CHAR_REPLACE = {
    "\\"=> "&",
    "/" => "&",
    ":" => "_",
    "*" => "_",
    "?" => "_",
    "<" => "_",
    ">" => "_",
    "|" => "Â¦"
  }
  
  CORE_SCRIPTS = ["Vocab", "Sound", "Cache", "DataManager", "SceneManager", 
  "BattleManager", "Game_Temp", "Game_System", "Game_Timer", "Game_Message", 
  "Game_Switches", "Game_Variables", "Game_SelfSwitches", "Game_Screen", 
  "Game_Picture", "Game_Pictures", "Game_BaseItem", "Game_Action", 
  "Game_ActionResult", "Game_BattlerBase", "Game_Battler", "Game_Actor", 
  "Game_Enemy", "Game_Actors", "Game_Unit", "Game_Party", "Game_Troop", 
  "Game_Map", "Game_CommonEvent", "Game_CharacterBase", "Game_Character", 
  "Game_Player", "Game_Follower", "Game_Followers", "Game_Vehicle", "Game_Event", 
  "Game_Interpreter", "Sprite_Base", "Sprite_Character", "Sprite_Battler", 
  "Sprite_Picture", "Sprite_Timer", "Spriteset_Weather", "Spriteset_Map", 
  "Spriteset_Battle", "Window_Base","Window_Selectable", "Window_Command", 
  "Window_HorzCommand", "Window_Help", "Window_Gold","Window_MenuCommand", 
  "Window_MenuStatus", "Window_MenuActor", "Window_ItemCategory", 
  "Window_ItemList", "Window_SkillCommand", "Window_SkillStatus", 
  "Window_SkillList", "Window_EquipStatus", "Window_EquipCommand", 
  "Window_EquipSlot", "Window_EquipItem", "Window_Status", "Window_SaveFile", 
  "Window_ShopCommand", "Window_ShopBuy", "Window_ShopSell", "Window_ShopNumber", 
  "Window_ShopStatus", "Window_NameEdit", "Window_NameInput", "Window_ChoiceList", 
  "Window_NumberInput", "Window_KeyItem", "Window_Message", "Window_ScrollText", 
  "Window_MapName","Window_BattleLog", "Window_PartyCommand", 
  "Window_ActorCommand", "Window_BattleStatus", "Window_BattleActor", 
  "Window_BattleEnemy", "Window_BattleSkill", "Window_BattleItem", 
  "Window_TitleCommand", "Window_GameEnd", "Window_DebugLeft", 
  "Window_DebugRight", "Scene_Base", "Scene_Title", "Scene_Map", "Scene_MenuBase", 
  "Scene_Menu", "Scene_ItemBase", "Scene_Item", "Scene_Skill", "Scene_Equip", 
  "Scene_Status", "Scene_File", "Scene_Save", "Scene_Load", "Scene_End", 
  "Scene_Shop", "Scene_Name", "Scene_Debug", "Scene_Battle", "Scene_Gameover",
  "Main", "( Insert here )"]
  
  #------------------------------------------------------------------
  # Load Data from file
  #------------------------------------------------------------------
  def self.load_file(file)
    File.open(file, "rb") { |f| 
      return ( Marshal.load(f))
    }
  end
  def save_data(data,file)
    File.open(file, "wb") { |f|
      Marshal.dump(data, f)
    }
  end
  #------------------------------------------------------------------
  # Inflate - Method to unzip code data
  #------------------------------------------------------------------
  def self.inflate(string)
    zstream = Zlib::Inflate.new()
    text = zstream.inflate(string)
    zstream.finish
    zstream.close
    return text
  end
  #------------------------------------------------------------------
  # Deflate - Method to zip code data
  #------------------------------------------------------------------
  def self.deflate(string, level = Zlib::BEST_COMPRESSION)
    z = Zlib::Deflate.new(level)
    data = z.deflate(string, Zlib::FINISH)
    z.close
    return data
  end
  #------------------------------------------------------------------
  # Ensure Holding Directory Exist
  #------------------------------------------------------------------
  def self.ensure_holding
    if Dir[Holding_Folder] != [Holding_Folder]
      Dir.mkdir(Holding_Folder)
    end
  end
  #------------------------------------------------------------------
  # Replace Invalid Characters - Used during export to ensure valid
  # filenames are generated. 
  #------------------------------------------------------------------
  def self.replace_invalid_char(ltr)
    if INVALID_CHAR_REPLACE[ltr] != nil
      ltr = INVALID_CHAR_REPLACE[ltr]
    end
    return ltr
  end
  #------------------------------------------------------------------
  # Restart Game - Issues the game to restart
  #------------------------------------------------------------------
  def self.restart_game
    print "Import Completed.  Press ENTER to exit game.\n"
    
    if File.exists?(IMPORT_TEMP_FILE)
      loop do
        Input.update
        if Input.trigger?(Input::C) or !SHOW_CONSOLE
          exit(01)
        end
      end
    end
  end
  #------------------------------------------------------------------
  # Show Console
  #------------------------------------------------------------------
  def self.show_console
    if !SHOW_CONSOLE
      return
    end
    # Get game window text
    console_w = Win32API.new('user32','GetForegroundWindow', 'V', 'L').call
    buf_len = Win32API.new('user32','GetWindowTextLength', 'L', 'I').call(console_w)
    str = ' ' * (buf_len + 1)
    Win32API.new('user32', 'GetWindowText', 'LPI', 'I').call(console_w , str, str.length)
 
    # Initiate console
    Win32API.new('kernel32.dll', 'AllocConsole', '', '').call
    Win32API.new('kernel32.dll', 'SetConsoleTitle', 'P', '').call('RGSS3 Console')
    $stdout.reopen('CONOUT$')
 
    # Sometimes pressing F12 will put the editor in focus first,
    # so we have to remove the program's name
    game_title = str.strip
    game_title.sub! ' - RPG Maker VX Ace', ''
 
    # Set game window to be foreground
    hwnd = Win32API.new('user32.dll', 'FindWindow', 'PP','N').call(0, game_title)
    Win32API.new('user32.dll', 'SetForegroundWindow', 'P', '').call(hwnd)
  end
  #------------------------------------------------------------------
  # Export - method for exporting scripts
  #------------------------------------------------------------------
  def self.export
    ensure_holding
    
    scripts = load_file(ScriptFile)
    num_exported = 0
 
    for script in scripts
      pre_name = script[1]
      name = ""
      pre_name.each_char {|ltr|
        ltr = replace_invalid_char(ltr)
        name << ltr
      }
      next if name == ""
      if Export_Core_Scripts == false && CORE_SCRIPTS.include?(name)
        next
      end
      
      code = inflate(script[2])
      if code.size > 10
        num_exported += 1
        filename = name + ".rb"
        print "Exporting Script : #{filename}\n"
        file = File.new("./" + Holding_Folder + "/" +  filename, "wb")
        file.write(code)
        file.close
      end
    end
    p "Scripts Exported: #{num_exported}"
  end
  #------------------------------------------------------------------
  # Import - Method for importing scripts
  #------------------------------------------------------------------
  def self.import
    ensure_holding
    scripts = load_file(ScriptFile)
    imported = []
    main_index = -1
    for i in 0...scripts.size
      script = scripts
      pre_name = script[1]
      name = ""
      pre_name.each_char {|ltr|
        ltr = replace_invalid_char(ltr)
        name << ltr
      }
      if !Overwrite_Core_Scripts && CORE_SCRIPTS.include?(name)
        next
      end
      filename = Holding_Folder + "/" + name + ".rb"
      if FileTest.exists?(filename)
        p "Importing Script : #{name}"
        file = File.new(filename, "rb")
        code = file.read
        file.close
        script[2] = deflate(code)
        imported << name
      end
      if ["Main", "MAIN", "main"].include?(pre_name)
        main_index = i
      end
      scripts = script
    end
    dir = "./" + Holding_Folder + "/"
    #dir = Dir.glob("./" + Holding_Folder + "/*.rb")
    for file in Dir.glob("./" + Holding_Folder + "/*.rb")#Dir.entries(dir)
      #next if !FileTest.file?(dir + file)
      name = File.basename(file, ".rb")
      if imported.include?(name) or (!Overwrite_Core_Scripts && CORE_SCRIPTS.include?(name))
        File.delete(file) if DELETE_ON_IMPORT
        next
      end
      print ("The following file \"#{file}\" was not imported because you do not have a" +
      " script section header for it.  Would you like to import it anyway?\n" + 
      "YES : ENTER\n"+
      "NO  : ESCAPE\n")
      loop do
        Input.update
        if Input.trigger?(Input::C)
          _file = File.new(file, "rb")
          code = _file.read
          _file.close
          script = Array.new
          script[0] = 11111111
          script[1] = name
          script[2] = deflate(code)
          scripts.insert(main_index, script)
          imported << name
          main_index += 1
          break;
        elsif Input.trigger?(Input:: B)
          break;
        end
      end
      File.delete(file) if DELETE_ON_IMPORT
    end
    if imported.size > 0
      print "Updating #{ScriptFile}"
      save_data(scripts, ScriptFile)
      print ". . . Done\n"
      File.open(IMPORT_TEMP_FILE, 'w+') {|f| f.write("Restarting project\n") }
    end
    return  imported.size
  end
  #------------------------------------------------------------------
  # Actual execute logic - Do not touch!
  #------------------------------------------------------------------
  if IMPORT
    if File.exists?(IMPORT_TEMP_FILE)
      print "Deleting Last Import Script Temp..."
      File.delete(IMPORT_TEMP_FILE)
      print "Done\nResuming Game\n"
    else
      show_console
      count = import
      restart_game if count > 0
    end    
  end
  if EXPORT && !IMPORT
    show_console
    export
  end
end
 