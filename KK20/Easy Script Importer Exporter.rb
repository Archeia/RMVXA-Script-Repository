=begin
================================================================================
Easy Script Importer-Exporter                                       Version 4.0
by KK20                                                             Jul 18 2018
--------------------------------------------------------------------------------

[ Introduction ]++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Ever wanted to export your RPG Maker scripts to .rb files, make changes to
  them in another text editor, and then import them back into your project?
  Look no further, fellow scripters. ESIE is easy to use!
  
[ Instructions ]++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Place this script at the top of your script list to ensure it runs first.
  Make any changes to the configuration variables below if desired.
  Run your game and a message box will prompt success and close the game.
  
  If exporting, you can find the folder containing a bunch of .rb files in your
  project folder. A new file called "!script_order.csv" will tell this script
  in what order to import your script files back into RPG Maker. As such, you
  can create new .rb files and include its filename into "!script_order.csv"
  without ever having to open RPG Maker!
  
  If importing, please close your project (DO NOT SAVE IT) and re-open it.
  
  ** As of Version 4.0, subfolders are now possible!
  
  - Script names that start with the character defined in FOLDER_INDICATOR will 
    be subfolders within your exported scripts folder. 
  - You can specify the depth of subfolders by increasing the number 
    FOLDER_INDICATOR characters. 
  - Any scripts below the subfolder will be placed within it. 
  - A script name that only consists of FOLDER_INDICATOR characters indicates 
    "closing" that subfolder; scripts below will now be placed in the previous 
    (i.e. its parent's) subfolder.
  - You may reuse a folder name multiple times. You can have subfolders named 
    after script authors and keep their scripts grouped together without
    disrupting your script order (and potentially crashing your project).
  
  Here's an example assuming FOLDER_INDICATOR is set to '@' :
  
  Project Script List       Project Directory
  
                            Scripts_Export_Folder/
  EarlyScript               ├ EarlyScript.rb
  @Base Scripts             ├ Base Scripts/
  @@Game Classes            │ ├ Game Classes/
  Game_Temp                 │ │ ├ Game_Temp.rb
  Game_System               │ │ └ Game_System.rb
  @@Sprite Classes          │ └ Sprite Classes/
  Sprite_Character          │   └ Sprite_Character
  @Custom Scripts           ├ Custom Scripts/
  MyScript                  │ └ MyScript.rb
  @                         │
  Main                      └ Main.rb
  
[ Compatibility ]+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  This script already has methods to ensure it will run properly on any RPG
  Maker version. This script does not rely on nor makes changes to any existing
  scripts, so it is 100% compatible with anything.
  
[ Credits ]+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  KK20 - made this script
  GubiD - referenced his VXA Script Import/Export
  FiXato and HIRATA Yasuyuki - referenced VX/VXA Script Exporter
  ForeverZer0 - suggesting and using Win32API to read .ini file

================================================================================
=end

#******************************************************************************
# B E G I N   C O N F I G U R A T I O N
#******************************************************************************
#------------------------------------------------------------------------------
# Set the script's mode. Will export the scripts, import the scripts, or do
# absolutely nothing.
#       ACCEPTED VALUES:
#       0 = Disable (pretends like this script doesn't even exist)
#       1 = Export
#       2 = Import
#       3 = Playtest (import scripts from folder to playtest game; does not
#                     replace or create a 'Scripts.r_data' file)
#------------------------------------------------------------------------------
IMPORT_EXPORT_MODE = 1
#------------------------------------------------------------------------------
# Folder name where scripts are imported from and exported to
#------------------------------------------------------------------------------
FOLDER_NAME = "Scripts"
#------------------------------------------------------------------------------
# Character positioned at the start of a script name to indicate a subfolder.
# All scripts (or other subfolders) below it will be placed within this folder.
# This must only be a one character string.
#------------------------------------------------------------------------------
FOLDER_INDICATOR = '@'
#------------------------------------------------------------------------------
# This tag will be added to the end of a script name in the CSV file for any 
# scripts that do not have code in them. This tag will be removed when imported
# back into the project. Note that this does not apply to scripts with no name.
#------------------------------------------------------------------------------
BLANK_SCRIPT_TAG = '~blank'
#------------------------------------------------------------------------------
# When exporting, if the folder FOLDER_NAME already exists, it will create
# another folder of the same name along with an ID. This will make sure you do
# not overwrite the changes you made to your scripts accidentally. If false,
# it will erase all the files in the folder prior to exporting. 
# Useless for importing.
#------------------------------------------------------------------------------
MAKE_EXPORT_COPIES = true
#------------------------------------------------------------------------------
# Creates a duplicate of the Scripts.r_data file to ensure you don't break your
# project. The duplicate will be placed in the Data folder as "Copy - Scripts".
# Useless for exporting.
#------------------------------------------------------------------------------
CREATE_SCRIPTS_COPY = true
#------------------------------------------------------------------------------
# If true, converts any instances of tab characters (\t) into two spaces. This
# is extremely helpful if writing code from an external editor and moving it
# back into RPG Maker where tab characters are instantly treated as two spaces.
#------------------------------------------------------------------------------
TABS_TO_SPACES = true
#******************************************************************************
# E N D   C O N F I G U R A T I O N
#******************************************************************************
#------------------------------------------------------------------------------
if IMPORT_EXPORT_MODE != 0

  RGSS = (RUBY_VERSION == "1.9.2" ? 3 : defined?(Hangup) ? 1 : 2)
  
  if RGSS == 3
    def p(*args)
      msgbox_p *args
    end
  end
  
  # From GubiD's script
  # These characters cannot be used as folder/file names. Any of your script
  # names that use the characters on the left will be replaced with the right.
  INVALID_CHAR_REPLACE = {
    '\\'=> '&',
    '/' => '&',
    ':' => ';',
    '*' => '°',
    '?' => '!',
    '<' => '«',
    '>' => '»',
    '|' => '¦',
    '"' => '\''
  }
  
  unless FOLDER_INDICATOR.is_a?(String) && FOLDER_INDICATOR.size == 1
    raise "FOLDER_INDICATOR needs to be 1 character long!"
  end
  
  def mkdir_p(list)
    path = ''
    list.each do |dirname|
      Dir.mkdir(path + dirname) unless File.exists?(path + dirname)
      path += "#{dirname}/"
    end
  end
  
  def traceback_report
    backtrace = $!.backtrace.clone
    backtrace.each{ |bt|
      bt.sub!(/{(\d+)}/) {"[#{$1}]#{$RGSS_SCRIPTS[$1.to_i][1]}"}
    }
    return $!.message + "\n\n" + backtrace.join("\n")
  end
  
  def raise_traceback_error
    if $!.message.size >= 900
      File.open('traceback.log', 'w') { |f| f.write($!) }
      raise 'Traceback is too big. Output in traceback.log'
    else
      raise
    end
  end
#-[ B E G I N ]-----------------------------------------------------------------
  # Get project's script file
  ini = Win32API.new('kernel32', 'GetPrivateProfileString','PPPPLP', 'L')
  scripts_filename = "\0" * 256
  ini.call('Game', 'Scripts', '', scripts_filename, 256, '.\\Game.ini')
  scripts_filename.delete!("\0")
  
  counter = 0
  # Exporting?
  if IMPORT_EXPORT_MODE == 1
    folder_name = FOLDER_NAME
    if File.exists?(FOLDER_NAME)
      # Keep a history of exports? Or only one folder?
      if MAKE_EXPORT_COPIES
        i = 1
        i += 1 while File.exists?("#{FOLDER_NAME}_#{i}")
        Dir.mkdir("#{FOLDER_NAME}_#{i}")
        folder_name = "#{FOLDER_NAME}_#{i}"
      else
        Dir['Scripts/*'].each { |file| File.delete(file) }
      end
    else
      Dir.mkdir(FOLDER_NAME) unless File.exists?(FOLDER_NAME)
    end
    # Create script order list
    script_order = File.open("#{folder_name}/!script_order.csv", 'w')
    script_names = {}
    folder_tree = [folder_name]
    current_subfolder_level = 0
    # Load the raw script data
    scripts = load_data(scripts_filename)
    scripts.each_index do |index|
      # skip ESIE
      next if index == 0
      script = scripts[index]
      id, name, code = script
      next if id.nil?
      
      # if this is a subfolder script name
      subfolder_level, subfolder_name = name.scan(/^(#{FOLDER_INDICATOR}+)(.*)/).flatten
      if subfolder_level
        # Replace invalid filename characters with valid characters
        subfolder_level = subfolder_level.size
        subfolder_name.split('').map{ |chr| INVALID_CHAR_REPLACE[chr] || chr }.join
        
        case subfolder_level <=> current_subfolder_level
        when -1
          (current_subfolder_level - subfolder_level).times do |n|
            folder_tree.pop
            current_subfolder_level -= 1
          end
          if subfolder_name.empty?
            folder_tree.pop
            current_subfolder_level -= 1
          else
            folder_tree[-1] = subfolder_name
          end
          
        when 0
          if subfolder_name.empty?
            folder_tree.pop
            current_subfolder_level -= 1
          else
            folder_tree[-1] = subfolder_name
          end
          
        when 1
          if subfolder_level - current_subfolder_level != 1
            raise "Invalid sublevel for folder!\n" +
                  "Expected: #{FOLDER_INDICATOR * (current_subfolder_level + 1)}#{subfolder_name}\n" +
                  "Received: #{name}"
          end
          raise "Branching subfolder needs a name!" if subfolder_name.empty?
          folder_tree << subfolder_name
          current_subfolder_level += 1
        end
        mkdir_p(folder_tree)
        script_order.write("#{name}\n")
        # no need to continue further with this script, so go to next
        next
      end
      
      # Replace invalid filename characters with valid characters
      name = name.split('').map{ |chr| INVALID_CHAR_REPLACE[chr] || chr }.join
      # Convert script data to readable format
      code = Zlib::Inflate.inflate(code)
      code.gsub!(/\t/) {'  '} if TABS_TO_SPACES

      if code.empty?
        name += BLANK_SCRIPT_TAG unless name.empty?
        script_order.write("#{name}\n")
        next
      end

      name = 'no_script_name' if name.empty?
      if script_names.key?(name)
        script_names[name] += 1
        name = "#{name}~@#{script_names[name]}"
      else
        script_names[name] = 0
      end
      # Output script to file
      script_order.write("#{name}\n")
      dir_path = folder_tree.join('/')
      File.open("#{dir_path}/#{name}.rb", 'wb') { |f| f.write(code) }
      counter += 1
    end
    script_order.close
    p "#{counter} files successfully exported to folder '#{folder_name}'"
    exit
  end
  # If importing or play-testing
  if IMPORT_EXPORT_MODE >= 2
    folder_tree = [FOLDER_NAME]
    counter = 1
    # If strictly importing, we want to replace the data directly in the scripts
    # data file. Otherwise, just override the scripts global variable.
    if IMPORT_EXPORT_MODE == 2
      scripts_file = File.open(scripts_filename, 'rb')
      import_obj = Marshal.load(scripts_file)
    else
      import_obj = $RGSS_SCRIPTS
    end
    # If strictly importing, create a copy of the scripts file in case something
    # goes wrong with the import.
    if IMPORT_EXPORT_MODE == 2 && CREATE_SCRIPTS_COPY
      base_name = File.basename(scripts_filename)
      dir_name = File.dirname(scripts_filename)
      copy = File.open(dir_name + "/Copy - " + base_name, 'wb')
      Marshal.dump(import_obj, copy)
      copy.close
    end
    # Load each script file
    File.open("#{FOLDER_NAME}/!script_order.csv", 'r') do |list| 
      list = list.read.split("\n")
      list.each do |filename|
        code = ''
        script_name = filename.gsub(/(.*?)(?:~@\d+)?$/) {$1}
        # Is this a subfolder?
        level, subfolder = script_name.scan(/^(#{FOLDER_INDICATOR}+)(.*)/).flatten
        if level
          level = level.size
          case level <=> (folder_tree.size - 1)
          when -1
            (folder_tree.size - 1 - level).times { |n| folder_tree.pop }
            if subfolder.empty?
              folder_tree.pop
            else
              folder_tree[-1] = subfolder
            end
          when 0
            if subfolder.empty?
              folder_tree.pop
            else
              folder_tree[-1] = subfolder
            end
          when 1
            if level - (folder_tree.size - 1) != 1
              raise "Invalid sublevel for folder!\n" +
                    "Expected: #{FOLDER_INDICATOR * (folder_tree.size)}#{subfolder}\n" +
                    "Received: #{script_name}"
            end
            raise "Branching subfolder needs a name!" if subfolder.empty?
            folder_tree << subfolder
          end
          
        elsif script_name.empty? || script_name[/#{BLANK_SCRIPT_TAG}$/]
          script_name = script_name.chomp("#{BLANK_SCRIPT_TAG}")
          code = ''
        else # script file
          dir_path = folder_tree.join('/')
          code = File.open("#{dir_path}/#{filename}.rb", 'r') { |f| f.read }
          code.gsub!(/\t/) {'  '} if TABS_TO_SPACES
        end
        # If strictly importing, compress script. Otherwise, keep script in
        # readable format.
        if IMPORT_EXPORT_MODE == 2
          z = Zlib::Deflate.new(6)
          data = z.deflate(code, Zlib::FINISH)
        else
          data = code
        end
        # If strictly importing, replaces entries in the scripts file data with
        # the newly-compressed imported scripts. Otherwise, replace entries in
        # $RGSS_SCRIPTS with imported scripts.
        import_obj[counter] = [counter]
        import_obj[counter][1] = script_name
        import_obj[counter][IMPORT_EXPORT_MODE] = data
        counter += 1
      end
    end
    # Dump imported file data to a new Scripts file and close the program.
    if IMPORT_EXPORT_MODE == 2
      data = File.open(scripts_filename, 'wb')
      Marshal.dump(import_obj[0, counter], data)
      data.close
      p "#{counter-1} files successfully imported. Please close your RPG Maker " +
      "now without saving it. Re-open your project to find the scripts imported."
      exit
    else
      # Run the project from here, eval-ing everything
      ($RGSS_SCRIPTS.size - counter).times { |n| $RGSS_SCRIPTS.pop }
      $RGSS_SCRIPTS.each_with_index do |script, i|
        next if i == 0
        begin
          eval(script[3], nil, script[1])
        rescue ScriptError
          raise ScriptError.new($!.message)
        rescue
          $!.message.sub!($!.message, traceback_report)
          raise_traceback_error
        end
      end
      exit
    end
  end
#------------------------------------------------------------------------------
end # if IMPORT_EXPORT_MODE != 0
