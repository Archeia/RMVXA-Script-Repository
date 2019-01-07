$imported = {} if $imported.nil?
$imported["EST - NOTEBOOK SYSTEM"] = true

#===============================================================================
# [VXACE] Notebook System
#-------------------------------------------------------------------------------
# EST - Notebook System
# Version: 2.6
# Released on: 26/07/2012
# Author : Estriole (yin_estriole@yahoo.com)
#
# Licenses :
# Free to use in all project (except one containing pornography)
# as long as i credited (ESTRIOLE)
#
# also credits : 
# Woratana for Adv text Reader VX version
# Jet for Notebooks Menu VX version
# Pacman for converting Jet Notebooks menu to ACE
#===============================================================================
=begin
################################################################################
# Version History:
#  v 1.00 - 2012.07.22 > First relase
#  v 1.01 - 2012.07.23 > replace the old decorate text with escape code usage   
#  v 1.02 - 2012.07.26 > make switch togle between old decorate text and new
#                        escape code version
#  v 2.0  - 2013.01.06 > combine the script with notebooks menu. then improve it.
#                        can be used separately or with notebooks menu. 
#                        also change the script name to reflect the changes...
#  v 2.1  - 2013.01.10 > make it compatible with custom resolution.
#  v 2.2  - 2013.01.13 > make notebook not exiting if no entry                      
#  v 2.3  - 2013.07.02 > fix some typo and private method. also compatibility with 
#                        yami - pop message script. put this script below it
#  v 2.4  - 2013.07.31 > compatibility with victor sfont script.
#                        but since the sfont make the font wider. you need to 
#                        break some lines in your existing txt files. just experiment
#                        until you got the result you wanted.
#                      > add feature to set font size. (both manual and config)
#                        so we can show MORE text in a line...
#                        WARNING: if using victor SFONT this feature DISABLED.
#                      > Add FAQ section in this script header to clear things
#                      > Decide to DISABLE the AUTO LINE BREAK feature since many
#                        people complain about cutted text below. now you must edit
#                        your text files manually if your text exceed window width
#                      > by disabling the auto line break. it's compatible with
#                        custom resolution... so MORE text again in a line !!!
#                      > Accidentally manage to find way to combine old mode feature.
#                        now you could use [b] to bold, [i] to italic, [cen] to center text
#                        while STILL using escape code. so old mode is not needed anymore
#  v 2.5  - 2013.08.04 > when returning from text_reader it will pick the last chosen entry
#                      > Add category feature. search NEW FEATURE FROM v2.5
#                      > Add sorting feature. search NEW FEATURE FROM v2.5 
#                      > Add Common Event Launch feature. search NEW FEATURE FROM v2.5
#                        if you manage to do something great using this feature
#                        share with me in the topic page please :D.
#  v 2.6  - 2014.08.16 > added compatibility patch to Galv Menu Themes Engine
#                                            
###############################################################################

--- FAQ (FREQUENTLY ASKED QUESTION ----

Q: the notebook file settings in configuration have no effect
A: make sure the filename without .txt in it. and make sure it's CASE SENSITIVE
   means same upper case and lower case as the txt filename.

Q: my text go to new line and break my formatting
A: edit your txt files so it won't exceed the window width. from v2.4. i disabled
   the autoline break. so this case won't happen anymore. edit your txt files
   so it won't exceed the window width...   

Q: i set the font size to 10. but it have no effect
A: if you use victor sfont script. the font size feature is DISABLED.

Q: i got bad size error warning
A: it because you set the font_size to really low value. make sure it 10 or above 

BELOW FAQ ANSWER MAINLY = DOWNLOAD THE LATEST VERSION :D.   
Q: my text got cutted at the bottom
A: it happen because of you have line that exceed window width and autoadd new line
   you can break that line so it fit the window width. from v2.4. i disabled
   the autoline break. so this case won't happen anymore. edit your txt files.
   so it won't exceed the window width   
   
Q: my text go to new line and got cutted at the bottom. the formatting already
   look fine as is. i'm to lazy to restructure my text and i just want the bottom 
   not cutted.
A: add extra enter in the text files bottom. (press enter several times. then save)
   it will then show the missing part. add as much as you need until it show all text.
   from v2.4. i disabled the autoline break. so this case won't happen anymore. 
   edit your txt files so it won't exceed the window width...
   
Q: This script sucks because i have to do lots of things MANUALLY
   want to use escape code + align the text to center? add space
   line too long and exceed the window width? add line break and restructure it.
A: you still need to do some work... not all thing can be handled using script.
   BUT FROM v 2.4 you can use [cen] to align text to middle. 
   basically combine of old mode and new mode...
   hope you're satisfy now lazy people LOL. just kidding.

================================================================================
                          NEW FEATURE FROM v2.5
--------------------------------------------------------------------------------
CATEGORY FUNCTIOM
--------------------------------------------------------------------------------
> set category to each txt files
  search FILE_READER_SETTING
  and read the documentation above it.
  
  if not set in FILE_READER_SETTING. the txt files will use category from:
  DEFAULT_TXT_CATEGORY
  
> setting starting unlocked category
  search START_CATEGORY in module ESTRIOLE and fill the starting category the
  notebook can access.

> adding category in game
To add new category to the journal, use this in an event "Script..." command
add_category("cat_name")
"catname" is a string where will be used as category

> to sort category you can sort $game_system.notebook_categories
using script call:
$game_system.notebook_categories.sort!
will sort the category alphabetically A-Z
$game_system.notebook_categories.sort!{|x,y| y <=> x}
will sort the category alphabetically Z-A

i didn't add ability to freely sort categories like entries yet. since i don't think 
that necessary. unless you have LOOOTS of category. which i think rarely happen.
and even with lots of category. A-Z and Z-A sort might already enough.

to remove categories from the journal script call
rem_category("cat_name")

--------------------------------------------------------------------------------
SORTING FUNCTIOM
--------------------------------------------------------------------------------
> press shift in entries list. and you can sort the entries by the rules set in module ESTRIOLE
  i include 6 rules:
  1) Alphabetical: A-Z
  2) Alphabetical: Z-A
  3) Priority High
  4) Priority Low
  5) First Received
  6) Last Received

> priority sort requires developer to fill FILE_READER_SETTING to set the priority each files.
  search FILE_READER_SETTING
  and read the documentation above it.
  if not set in FILE_READER_SETTING. the txt files will use priority from:
  DEFAULT_PRIORITY
  
> you can custom the sorting rule if you understand ruby.
  search SORTING_RULE

--------------------------------------------------------------------------------
COMMON EVENT LAUNCH FUNCTIOM
--------------------------------------------------------------------------------
this feature have two type
1) LAUNCH AT the text reader scene (before viewing the text)
REQUIRES TSUKIHIME SCENE INTERPRETER SCRIPT
so we can launch common event directly in the scene.

this feature is handy if we want to make some little conversation
before reading the text. (might require conditional branch to make
it one time conversation)
example: opening a letter.
actor a said. hey it's a letter from your lover
actor b said. get lost.
sorta like that. :D.

COMMON EVENT command some works some don't (since it's not at scene_map). 
in demo i show that show text, show choice, play SE works
while show picture not working. (it works but shown on map instead on that scene)
you can try it yourself what works what not. Don't be too lazy ok! :D.

to set it search FILE_READER_SETTING
and add
common_event: youridhere,
in the hash (see the example)

2) LAUNCH AFTER the text reader scene (after viewing the text)
this not require any script since it works using default RM reserve common event method.

this feature is handy if we want something happen AFTER we read the entry.
just use your imagination. it could be cursed book. or something like that.
or some conversation after reading it (might require conditional branch to make
it one time conversation)

since it working in Scene_Map. most command will works.
so if you're a genius eventer... i cannot imagine what you can make using this feature.
(share with me okay :D)

to set it search FILE_READER_SETTING
and add
common_event_after: youridhere,
in the hash (see the example)

the difference with the first function is it have _after.

--------------------------------------------------------------------------------
Major Changes from version 2.0
================================================================================
- now have notebook function like Jet Notebook menu for vx.
- config to auto adding to yanfly menu system :D
- can add record and remove record to journal at will
- can choose which file to view
- can differ each file how it shown in adv text reader using configuration
- add new call method for adv text reader instead of long scenemanagerplus 
thing :D (i'm ashamed but that method actually because of my noobiness as 
scripter at that time :D. i don't know about scenemanager.scene.prepare thing :D)

i STILL keep the original call so in case you already set your project that way...
you're still okay. (although i wanted to delete the 'shame' but i need to think
the need of many T.T). 

now original call also can use .txt or not in the filename
(worked really hard to fix shame of the past :D)

--------------------------------------------------------------------------------
now we can use script call for adv text reader like this:
--------------------------------------------------------------------------------
SceneManager.call(Text_Reader) #required
SceneManager.scene.set_file("Credits") #required
SceneManager.scene.set_face(1)
SceneManager.scene.set_type("text_title")
SceneManager.scene.set_text_title("This is combat tutorial")
SceneManager.scene.set_font_size(30)
SceneManager.scene.set_old_mode

from set face to set old mode is optional.
set_face is for setting face to shown. add the actor id you want the face to show
set_type is for setting the adv reader custom type. either "simple_status" or "text_title"
set_text_title is for setting text title if you use "text_title" mode
set_font_size is to set the font of the window content.
set_old_mode is for setting the adv reader to use old mode once only.

================================================================================
                          NEW NOTEBOOK function
--------------------------------------------------------------------------------
To add new entries to the journal, use this in an event "Script..." command
add_entry("filename")
"filename" should be the name of a .txt file in the text folder, excluding
the .txt. So say i have a file called Test.txt: add_entry("Test")
Even if you use the .rvdata file, the filenames stay the same so make sure
you remember your filenames.

i also modify it to add check if that file exist or not either in folder
or if use .rvdata file in the file array.

to remove entries from the journal script call
rem_entry("filename")

--------------------------------------------------------------------------------
You can call the journal scene with this code in an event "Script..." command:

goto_notebook

The journal scene will be inaccessable unless the player has at least 1 entry
(edit: from v.2.2 now can open without entry)
--------------------------------------------------------------------------------

you can add setting to modify the text reader. see the configuration
search "NOTEBOOK FILE SETTING"


===============================================================================

Old Script call still works. below is the list of it
==================================
+[Features in Version 1.2]+

** Start Read Text File by call script:
SceneManager.callplus(Text_Reader,"filename with file type")

* For example, you want to read file "test.txt", call script:
SceneManager.callplus(Text_Reader,"test.txt")

* ability to use almost all msg system escape codes
such as \c[4], \n[3]. default or custom message system 
(known so far yanfly, victor, modern algebra ats)

* Advanced syntax to call is like this
SceneManager.callplus(Text_Reader,filename,[actorid],[type],[infocontent])

[actorid] & [type] & [infocontent] is optional
[infocontent] will print inside info window when some type chosen max [41char].

list of [type]: (what the content of info window)
"default"       - just draw face window (if no actorid) without info window then draw text reader window
"simple_status" - info window containing simple actor status
"text_title"    - info window containing titles for the text centered and yellow color
still building more [type]

example of some variation to call advanced syntax:
SceneManager.callplus(Text_Reader,"test.txt",11,"simple_status")
means it will draw actor 11 face and actor 11 simple status then below
is test.txt content.

or

SceneManager.callplus(Text_Reader,"test.txt",nil,"text_title","Stupid Tutorial")
which translate to : only info window containing text "Stupid Tutorial" with larger
font and yellow color centered (vertical and horizontal). and below it is the 
test.txt content. (no actor face window because you put nil)

or
SceneManager.callplus(Text_Reader,"test.txt",12)
translate to : test.txt content with actor face window (small square at top left
of the test.txt (means it will block any text that below it. but its not a problem
if you center the text (manualy or using decorate text if you didn't need icons, color, etc)

** Custom Folder for Text File
You can change Text File's folder at line:
TEXT_FOLDER = "folder you want"

"" << for no folder, text file should be in your game's folder.
"Files/" << for folder "Your Game Folder > Files"
"Data/Files/" << for folder "Your Game Folder > Data > Files"

==================================
decorate text feature below can be used by editing :

TR_old_mode_switch = 0
change to switch you want.
if the switch turn on you can use decorate text feature below but lost ability
to use all the escape code (such as \c[5] \n[3] etc)

so basicly you can switch between using decorate text and using escape codes.
   
+[Decorate Text]+ [if you still want to use this feature instead nice icon and pics]
You can decorate your text by following features:

[b] << Bold Text
[/b] << Not Bold Text

[i] << Italic Text
[/i] << Not Italic Text

[s] << Text with Shadow
[/s] << Text without Shadow

[cen] << Show Text in Center
[left] << Show Text in Left side
[right] << Show Text in Right side

* Note: Don't put features that have opposite effects in same line...
For example, [b] that make text bold, and [/b] that make text not bold

* Note2: The decoration effect will be use in the next lines,
Until you use opposite effect features... For example,

[b]text1
text2
[/b]text3

text1 and text2 will be bold text, and text3 will be thin text.

==================================
+[Configuration]+

OPEN_SPEED = Speed when Reader Window is Opening/Closing
SCROLL_SPEED = Speed when player Scroll Reader Window up/down

TEXT_FOLDER = Folder for Text Files
e.g. "Data/Texts/" for Folder "Your Project Folder > Data > Texts"

================================================================================
compatibility list
================================================================================
message system
- yanfly ace msg system
- victor msg system
- modern algebra ats msg system
and i'm using loooottss of script and no conflict but i won't list them there
because it's not necessary (the one who can conflict only the one who alter
window_base or scene_base heavily like overwriting the method without mercy lol)

================================================================================
=end
# editable region
module ESTRIOLE
   TR_old_mode_switch = 31 # switch if on use old decorate text mode change to 0
                          # you dont want to use the decorate text mode at all
   DISABLE_SFONT_SWITCH = 32 # if using victor sfont script and you want to disable
                             # it. turn on this switch...   
   
   TEXT_FOLDER = "Notebook/" # Folder for Text Files -> this means at your project folder/text
   OPEN_SPEED = 30 # Open/Close Speed of Reader Window (Higher = Faster)
   SCROLL_SPEED = 30 # Scroll Up/Down Speed
      
  # Would you like to convert all .txt files in the "Notebook" folder to a
  # .rvdata data file which can be encrpyted with the game, and used with
  # the USE_RVDATA_FILE option?
  DO_CONVERSION_TO_RVDATA = false

  # Would you like to use the Notebook.rvdata file generated with the
  # DO_CONVERSION_TO_RVDATA instead of the .txt files in the "Notebook" folder?
  USE_RVDATA_FILE = false

  # What is the notebook called?
  NOTEBOOK_NAME = "Notebook"
  
  ADV_READER_USE_YANFLY_MENU = true
  ADV_READER_PUT_BELOW = :status #this must be valid symbol in yanfly menu

=begin  
  NOTEBOOK FILE SETTING
  this setting for if you want to customize for each file how it 
  will shown in text reader. AUTOMATICALLY when choosing it in notebook menu
  
  make sure you don't forget the , (coma) for every setting.
  and to be sure just copy from "entry 1" to "end entry 1" so you don't break the
  hash format...
  format is like this
  
   "Filename" => {
                   type: x,
                   face_id: y,
                   text_title: z,
                   old_mode: v,
                   desc: w,
                   font_size: n,
                   priority: m,
                   category: a,
                 },
  ----------------------------------------------------------------------------
  "Filename" => string. the filename without .txt extension. CASE SENSITIVE.
                means upper case and lower case must match the filename
   x => string. this is the type of the text reader. available type:
                 "Default" => default mode
                 "Simple_status" => will add status for the actor if face_id exist
                 "Text_Title" => will add text title. usefull for tutorial type
   
   y => int. id of the actor you want it face to shown. usefull if you want it like
             this information is told by that actor/about that actor (like suikoden investigation file)
   z => string. if use text title type. it will use this as title
   v => true/false. true will use old mode for one time. false didn't use it at all.
   w => string. what you want to shown as text description in notebook menu
   n => integer. font size the window reader content will use. minimum 10.
   n => integer. priority of the files. means that files more important the higher the value
   a => array. categories this txt files belong to
=end

  FILE_READER_SETTING = {#do not touch
  #entry 1 ##############################
  "Credits" => {
                type: "TEXT_TITLE",
                face_id: 10,
                text_title: "THANK YOU ALL FOR YOUR WORKS",
                desc: "text_title, face=10, font = 10\nfont feature disabled if sfont installed",
                font_size: 10,
                category: ["All","System"],
               },
  #end entry 1 ##########################
  #entry 2 ##############################
  "English" => {
                type: "SIMPLE_STATUS",
                face_id: 1,
                old_mode: true,
                category: ["All","System"],
                priority: 20,
                desc: "test one time only jibber jabber conversation\nsee common event 3 for more info",
                common_event: 3,
               },               
  #end entry 2 ##########################  
  #entry 3 ##############################
  "FontSizeTest" => {
                type: "TEXT_TITLE",
                face_id: 1,
                text_title: "THANK YOU ALL FOR YOUR WORKS",
                desc: "font = 40, face = 1, text_title",
                font_size: 40,
                category: ["All","Testing"],
               },
  #end entry 3 ##########################  
  #entry 4 ##############################
  "Note from Elsie" => {
                type: "TEXT_TITLE",
                face_id: 1,
                text_title: "THANK YOU ALL FOR YOUR WORKS",
                desc: "A letter from beloved Elsie\nFrom London",
                category: ["Letter"],
                priority: 100,
               },
  #end entry 4 ##########################  
  #entry 5 ##############################
  "Common Event Test" => {
                type: "SIMPLE_STATUS",
                face_id: 1,
                category: ["All","System"],
                priority: 20,
                desc: "will execute Common Event 4 at text reader\nwill execute Common Event 5 after closing",
                common_event: 4,
                common_event_after: 5,
               },               
  #end entry 5 ##########################  
  }#do not touch
   
  DEFAULT_NOTEBOOK_FILE_DESC = "No information about this specific #{NOTEBOOK_NAME}'s entry"
  NOTEBOOK_NO_ENTRY_DESC = "No entries"  
  
## CATEGORY CUSTOMIZATION #####
  #category which contain every text - must not empty
  ALL_TXT_CATEGORY = ["All"]

  #the game will start with these category unlocked already. if you want to unlock
  #you can use the script call method if you don't want any category to unlocked
  #just change it to []
  START_CATEGORY = [ALL_TXT_CATEGORY[0],"Letter"]
  # CHANGE ABOVE TO = [] if you don't want any category
  
  #help text that will be shown when hovering at category
  CATEGORY_HELP_TEXT = {
  "All" => "All Notebook Entries",
  "Letter" => "Letter written by someone",
  "System" => "System related notebook entry",
  "Testing" => "for debug and testing purpose entry",
  }# do not remove this line
  
  #if didn't set the help text above. use this instead.
  CATEGORY_DEFAULT_HELP_TEXT = "No information about this specific category"
  
  #if not set in file_reader_setting. text will belong to these categories
  DEFAULT_TXT_CATEGORY = [ALL_TXT_CATEGORY[0],"Letter"]
  
## SORTING CUSTOMIZATION ##### 
  #if not set in file_reader_setting. then it will use this default priority
  DEFAULT_PRIORITY = 1


=begin
  IF YOU WANT CUSTOM SORTING RULE...
  Enter your sorting rule in hash below
  REQUIRE RUBY KNOWLEDGE !!! it's better not mess with it if you don't know ruby
  and just use what i already made
  
  "SORT TYPE" => {"RUBY COMMAND IN STRING"},
  
  RUBY COMMAND IN STRING explanation
  entries is an array that you sort so you can do:
  "entries.sort!{|x,y| y <=> x}"
  and it will sort descending (Z-A)
  
=end
  SORTING_RULE = {
  "Alphabet: A-Z" => "entries.sort!",
  "Alphabet: Z-A" => "entries.sort!{|x,y| y <=> x}",
  "Priority High" =>"entries.sort!{|x,y| ESTRIOLE.get_priority(x) <=> ESTRIOLE.get_priority(y)}",
  "Priority Low" => "entries.sort!{|x,y| ESTRIOLE.get_priority(y) <=> ESTRIOLE.get_priority(x)}",
  "First Received" => "",  #no sorting
  "Last Received" => "entries.reverse!", #reverse order
  }#DO NOT TOUCH THIS LINE
  
  def self.get_priority(string)
    priority = DEFAULT_PRIORITY
    setting = FILE_READER_SETTING[string] rescue nil
    priority = setting[:priority] if setting && setting[:priority] rescue DEFAULT_PRIORITY
    return priority
  end
  
###### YANFLY MENU PATCH #######################################################

#do not touch below this... unless you know what you're doing
  ADV_TEXT_TYPE = ["DEFAULT","SIMPLE_STATUS","TEXT_TITLE"] 

# SIMPLY ADD :notebook to the COMMANDS in yanfly configuration
  #below in setting for yanfly menu.
  NOTEBOOK_CUSTOM_COMMAND = {
    :notebook => [  "#{NOTEBOOK_NAME}", 0, 0, :command_to_notebook],
  } # <- Do not delete.
  
  YEA::MENU::CUSTOM_COMMANDS.merge!(NOTEBOOK_CUSTOM_COMMAND) if $imported["YEA-AceMenuEngine"] == true   

end
 
#=========================================================================== 
# do not edit below this line except you know what you're doing
#===========================================================================

module SceneManager
  def self.callplus(scene_class,filename,actor = nil,type="DEFAULT",infocontent="")
    @stack.push(@scene)
    @scene = scene_class.new(filename,actor,type,infocontent)
  end  
end

if ESTRIOLE::ADV_READER_USE_YANFLY_MENU && $imported["YEA-AceMenuEngine"] == true
# AUTO INSERTING NOTE BELOW CERTAIN SYMBOL
index, target = nil
for i in 0..YEA::MENU::COMMANDS.size-1
 index = i if YEA::MENU::COMMANDS[i] == ESTRIOLE::ADV_READER_PUT_BELOW
end
target = index - YEA::MENU::COMMANDS.size if index !=nil
YEA::MENU::COMMANDS.insert(target,:notebook) if target!=nil
YEA::MENU::COMMANDS.insert(-1,:notebook)if target==nil
# END AUTO INSERTING
end

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # compatibility method : command_tocrafting
  #--------------------------------------------------------------------------
  def command_to_notebook
    SceneManager.call(Scene_Notebook)
  end
end # class Scene_Menu

class Text_Reader < Scene_MenuBase  
  OPEN_SPEED = ESTRIOLE::OPEN_SPEED 
  SCROLL_SPEED = ESTRIOLE::SCROLL_SPEED
  TEXT_FOLDER = ESTRIOLE::TEXT_FOLDER  
  def initialize(file_name = "",actor = nil,type="DEFAULT",infocontent="",mode = 0)
    #compatibility with old script call
    name = file_name.partition(".")
    @filename = name[0]
    @infocontent = infocontent
    @actorx = actor.nil?? nil : $game_actors[actor]
    @mode = mode
    @type = type
    create_interpreter if $imported["TH_SceneInterpreter"]
  end
  
  #configuration
  def set_file(file_name)
  @filename = file_name
  end
  def set_face(id=nil)
  @actorx = id.nil?? nil : $game_actors[id]
  end
  def set_type(type="DEFAULT")
  return if type.nil?
  @type = type.upcase if ESTRIOLE::ADV_TEXT_TYPE.include?(type.upcase)
  end
  def set_text_title(text="")
  return if text.nil?
  @infocontent = text
  end
  def set_old_mode
  $game_switches[ESTRIOLE::TR_old_mode_switch] = true
  @old_mode_one_time_only = true
  end
  def set_font_size(size)
  @font_size = size
  end
  def set_common_event(id)
  @common_event_id = id
  end
  def set_common_event_after(id)
  @common_event_after_id = id
  puts @common_event_after_id
  end
  def start
    super
    create_reader_windows
    return if !$imported["TH_SceneInterpreter"]
    @interpreter.setup($data_common_events[@common_event_id].list) if @common_event_id
  end
  
  def create_reader_windows
    if ESTRIOLE::USE_RVDATA_FILE
      file = load_data("Data/Notebook.rvdata2")[@filename + ".txt"]
    else
      file = File.open(TEXT_FOLDER + @filename + ".txt")
    end
    @text = []
    file.each_line do |line|
      @text.push line.sub(/\n/) {}
    end
    if @mode == 1
      @text[0] = @text[0].sub(/^./m) {}
    end
        
    @window = Window_Reader.new(@text,@actorx,@type,@font_size)
    @window.visible = true
    
    if @actorx == nil
      
    else
    @actor_face_window = Window_Top_Reader_Face.new(@actorx)
    end
  
    case @type.upcase
    when "DEFAULT"
    else;
      @info_window = Window_Top_Reader_Info.new(@actorx,@type,@infocontent)
    end
  end
  
  def restart
    @window.dispose if @window
    @actor_face_window.dispose if @actor_face_window
    @info_window.dispose if @info_window
    @window = nil if @window
    @actor_face_window = nil if @actor_face_window
    @info_window = nil if @info_window
    create_reader_windows
  end
      
  def update
    super
    @window.update
    process_exit if Input.trigger?(:B) or Input.trigger?(:C)
    process_down if Input.repeat?(:DOWN)
    process_up if Input.repeat?(:UP)
  end
  
  def process_exit
      return if $imported["TH_SceneInterpreter"] == true && @interpreter.running?      
      puts @common_event_after
      Sound.play_cancel
      #SceneManager.call(Scene_Map)
      $game_switches[ESTRIOLE::TR_old_mode_switch] = false if @old_mode_one_time_only
      return reserve_common_event(@common_event_after_id) if @common_event_after_id
      SceneManager.return
  end
  
  def reserve_common_event(id)
      $game_temp.reserve_common_event(id)
      $game_temp.notebook_entries_chosen = nil
      $game_temp.notebook_categories_chosen = nil    
      SceneManager.goto(Scene_Map)
  end

  def process_down
      return if $imported["TH_SceneInterpreter"] == true && @interpreter.running?      
      Sound.play_cursor if (@window.oy + 272) < @window.contents.height
      @window.oy += SCROLL_SPEED if (@window.oy + 272) < @window.contents.height
  end
  
  def process_up
      return if $imported["TH_SceneInterpreter"] == true && @interpreter.running?      
      Sound.play_cursor if (@window.oy + 272) < @window.contents.height
      @window.oy -= SCROLL_SPEED if @window.oy > 0
  end  
  
  def scene_changing?
    SceneManager.scene != self
  end
end

class Window_Top_Reader_Face < Window_Base
  def initialize(actor)
    super(0,0,116,116)
    draw_actor_face(actor,0,0,true)
  end
end

class Window_Top_Reader_Info < Window_Base
  def initialize(actor,type,infocontent)
    if actor == nil
    super(0,0,Graphics.width,116)
    @infowidth = Graphics.width
    else
    super(116,0,Graphics.width-116,116)
    @infowidth = Graphics.width - 116
    end
    case type.upcase
    when "SIMPLE_STATUS"
      draw_actor_simple_status(actor, 10, 10) if actor != nil
    when "TEXT_TITLE" 
      make_font_bigger
      make_font_bigger if actor == nil
      change_color(text_color(6))
      draw_text(0, 28, @infowidth - 40, 40, infocontent, 1) if actor == nil
      draw_text(0, 32, @infowidth - 40, 32, infocontent, 1) if actor != nil
      reset_font_settings
    else;
    end
  end
end

class Window_Reader < Window_Base
  #include ATS_Formatting_WindowMessage
  attr_accessor :firstline, :nowline
  
  def initialize(text,actorx,type,size)
    if actorx == nil
      case type.upcase
        when "DEFAULT"
          super(0,0,Graphics.width,Graphics.height)
        else;
          super(0,116,Graphics.width,Graphics.height - 116)
      end
    else
      case type.upcase
        when "DEFAULT"
          super(0,0,Graphics.width,Graphics.height)
        else;
          super(0,116,Graphics.width,Graphics.height - 116)    
      end
    end

    @font_size = size
    @firstline = @nowline = 0
    @text = text
    @align = 0
    @line_index = 0
    draw_text_reader
  end
  
  
  def update
    if self.openness < 255
      self.openness += Text_Reader::OPEN_SPEED
    end
  end
  
  def draw_text_reader
    self.contents = Bitmap.new(width - 32, @text.size * (@font_size) + 32) if (@font_size && !($imported[:ve_sfonts] && Victor_Engine::VE_ALL_SFONT))
    self.contents = Bitmap.new(width - 32, @text.size * 24 + 32) if !(@font_size && !($imported[:ve_sfonts] && Victor_Engine::VE_ALL_SFONT))
    self.contents.font.size = @font_size if @font_size && !($imported[:ve_sfonts] && Victor_Engine::VE_ALL_SFONT)
    a = contents.sfont = $sfont[0] if Victor_Engine::VE_ALL_SFONT rescue nil
    @line_index = 0
    for i in 0..@text.size
      if @text[i] == nil
      else
        text = decorate_text(@text[i])
        if $game_switches[ESTRIOLE::TR_old_mode_switch] == true
          self.contents.draw_text(0, @line_index * self.contents.font.size, width - 32, 24, text, @align)
        else
          self.draw_text_ex_mod(0, @line_index * self.contents.font.size, text)
        end
      end
      @line_index += 1
    end      
  end

  def draw_text_ex_mod(x, y, text)
    #reset_font_settings
    text = convert_escape_characters(text)
    text_width = text_size(text).width
    win_width = width - 2 * standard_padding - 6
    case @align
    when 1
      #center align
      x = x + (win_width - text_width)/2
    when 2
      #right align
      x = x + win_width - text_width
    else
      #left align so do nothing
    end
    @pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, @pos) until text.empty?
  end

  def process_normal_character(c, pos)
    text_width = text_size(c).width
    draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
    pos[:x] += text_width
  end

  
  def decorate_text(text)
     a = text.scan(/(\[\/b\])/)
     if $1.to_s != ""
       self.contents.font.bold = false
       text.sub!(/\[\/b\]/) {}
     end
     
     a = text.scan(/(\[b\])/)
     if $1.to_s != ""
       self.contents.font.bold = true
       text.sub!(/\[b\]/) {}
     end
     
    a = text.scan(/(\[\/i\])/)
     if $1.to_s != ""
       self.contents.font.italic = false
       text.sub!(/\[\/i\]/) {}
     end
     
     a = text.scan(/(\[i\])/)
     if $1.to_s != ""
       self.contents.font.italic = true
       text.sub!(/\[i\]/) {}
     end
     
     a = text.scan(/(\[\/s\])/)
     if $1.to_s != ""
       self.contents.font.shadow = false
       text.sub!(/\[\/s\]/) {}
     end
     
     a = text.scan(/(\[s\])/)
     if $1.to_s != ""
       self.contents.font.shadow = true
       text.sub!(/\[s\]/) {}
     end
     
     a = text.scan(/(\[cen\])/)
     if $1.to_s != ""
       @align = 1
       text.sub!(/\[cen\]/) {}
     end
     
    a = text.scan(/(\[left\])/)
     if $1.to_s != ""
       @align = 0
       text.sub!(/\[left\]/) {}
     end
     
    a = text.scan(/(\[right\])/)
     if $1.to_s != ""
       @align = 2
       text.sub!(/\[right\]/) {}
     end
     
     return text
  end
end

######################## below is the note book section ########################

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and
# menus. Instances of this class are referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :notebook_entries
  attr_accessor :notebook_categories
  attr_accessor :notebook_sort_mode
  
  #--------------------------------------------------------------------------
  # Alias listing
  #--------------------------------------------------------------------------
  alias jet1835_initialize initialize
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(*args, &block)
    @notebook_entries = []
    @notebook_categories = ESTRIOLE::START_CATEGORY rescue []
    @notebook_categories = [] if !@notebook_categories.is_a?(Array)
    jet1835_initialize(*args, &block)
  end
end

class Game_Temp
  attr_accessor :notebook_entries_count
  attr_accessor :notebook_categories_count
  attr_accessor :notebook_entries_chosen
  attr_accessor :notebook_categories_chosen
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Add Notebook Entry to Database
  #--------------------------------------------------------------------------
  def add_entry(filename)
    unless $game_system.notebook_entries.include?(filename)
      if ESTRIOLE::USE_RVDATA_FILE
        file = load_data("Data/Notebook.rvdata2")[filename + ".txt"]
        test = true if file
      else
        test = FileTest.file?("#{ESTRIOLE::TEXT_FOLDER}#{filename}.txt")
      end      
      $game_system.notebook_entries.push(filename) if test
    end
  end
  def rem_entry(filename)
    $game_system.notebook_entries.delete(filename)
  end
  #--------------------------------------------------------------------------
  # * Add Notebook Category to Database
  #--------------------------------------------------------------------------
  def add_category(cat_name)
    $game_system.notebook_categories.push(cat_name) unless $game_system.notebook_categories.include?(cat_name)
  end
  def rem_category(cat_name)
    $game_system.notebook_categories.delete(cat_name)
  end
  #--------------------------------------------------------------------------
  # * Activate Notebook Scene
  #--------------------------------------------------------------------------
  def goto_notebook
    SceneManager.call(Scene_Notebook)
  end
end

#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#  This class performs the title screen processing.
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # Alias listing
  #--------------------------------------------------------------------------
  alias jet1934_initialize initialize unless $@
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(*args, &block)
    convert_txt if ESTRIOLE::DO_CONVERSION_TO_RVDATA && $TEST
    jet1934_initialize(*args, &block)
  end
  #--------------------------------------------------------------------------
  # * Convert text from .txt to .rvdata2
  #--------------------------------------------------------------------------
  def convert_txt
    file = Dir.entries("Notebook")
    file.reverse!
    2.times {|i| file.pop }
    file.reverse!
    if file.empty?
      p "No files found in Notebook, aborting conversion process."
    end
    text_hash = {}
    for txt in file
      text_hash[txt] = File.open("#{ESTRIOLE::TEXT_FOLDER}#{txt}", "r") {|a| a.read}
    end
    b = File.new("Data/Notebook.rvdata2", "wb")
    Marshal.dump(text_hash, b)
    b.close
    p "Notebook file successfully converted."
  end
end

#==============================================================================
# ** Scene_Gameover
#------------------------------------------------------------------------------
#  The string class. Can handle character sequences of arbitrary lengths.
# See String Literals for more information.
#==============================================================================

class String
  #--------------------------------------------------------------------------
  # * Split to each word
  #--------------------------------------------------------------------------
  def each_word
    array = self.split(" ")
    if block_given?
      array.each {|a| yield a }
    else
      return array
    end
  end
end

#==============================================================================
# ** Window_Notebook
#------------------------------------------------------------------------------
#  This window displays the note currently open. reserved maybe for something else
#==============================================================================

class Window_Notebook_Desc < Window_Help
  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end
  def refresh
    contents.clear
    draw_text(0, 0, width,24,@text,1)
  end  
end


class Window_Sort < Window_Command 
  def update
    super
    return unless @command_window
    return unless open? && active
    old_sort = @command_window.sort
    @command_window.sort = current_data[:name] if old_sort != current_data[:name]
  end
  def select_name(name)
    @list.each_index {|i| select(i) if @list[i][:name].upcase == name.upcase }
  end
  def window_width
    return Graphics.width/2
  end
  def command_window=(command_window)
    return if @command_window == command_window
    @command_window = command_window
    refresh
  end
  def alignment
    return 0
  end
  def make_command_list
    sorting = ESTRIOLE::SORTING_RULE.keys
    for sort in sorting
      add_command(sort, :sort)
    end
  end
end

class Window_CatCommand < Window_Command 
  def select_name(name)
    @list.each_index {|i| select(i) if @list[i][:name].upcase == name.upcase }
  end
  def window_width
    return Graphics.width
  end
  def alignment
    return 0
  end
  def make_command_list
    categories = $game_system.notebook_categories
    for cat in categories
      add_command(cat, :cat)
    end
    $game_temp.notebook_categories_count = categories.size
  end
end

#==============================================================================
# ** Window_NoteCommand
#------------------------------------------------------------------------------
#  This window is the selection window for the notebook entries.
#==============================================================================

class Window_NoteCommand < Window_Command
  def select_name(name)
    @list.each_index {|i| select(i) if @list[i][:name].upcase == name.upcase }
  end

  def window_width
    return Graphics.width
  end
  def alignment
    return 0
  end
  def cat
    @cat
  end
  def cat=(cat)
    return if @cat == cat
    @cat = cat
    refresh
  end
  def sort
    @sort
  end
  def sort=(sort)
    return if @sort == sort
    @sort = sort
    refresh
  end
  alias est_mags_process_handling process_handling
  def process_handling
    return unless open? && active
    est_mags_process_handling
    return call_handler(:shift) if handle?(:shift)   && Input.trigger?(:A)
  end    
  #--------------------------------------------------------------------------
  # * Form list of commands
  #--------------------------------------------------------------------------
  def make_command_list
    @cat = ESTRIOLE::ALL_TXT_CATEGORY.sample if !@cat
    entries = $game_system.notebook_entries.select {|entry|
    cat = ESTRIOLE::FILE_READER_SETTING[entry][:category].collect{|c| c.upcase} rescue ESTRIOLE::DEFAULT_TXT_CATEGORY.collect{|c| c.upcase}
    cat = cat + ESTRIOLE::ALL_TXT_CATEGORY.collect{|c| c.upcase}
    cat.uniq!
    a = cat.include?(@cat.upcase) rescue false
    }    
    if @sort
     chk = eval(ESTRIOLE::SORTING_RULE[@sort]) rescue nil
    end        
    for entry in entries
      add_command(entry, :entry)
    end
    $game_temp.notebook_entries_count = entries.size
  end
end

#==============================================================================
# ** Window_Entries
#------------------------------------------------------------------------------
#  This window displays the number of entries in the notebook database.
#==============================================================================

class Window_Entries < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def on_entry=(on_entry)
    return if @on_entry == on_entry
    @on_entry = on_entry
    refresh
  end  
  def initialize
    super(0, Graphics.height - 48, 160, 48)
    refresh
  end
  def update
    super
    refresh if @old_entries_size != $game_temp.notebook_entries_count
    @old_entries_size = $game_temp.notebook_entries_count
  end
  #--------------------------------------------------------------------------
  # * Refresh window
  #--------------------------------------------------------------------------
  def refresh
    $game_temp.notebook_entries_count = 0 if !$game_temp.notebook_entries_count
    $game_temp.notebook_categories_count = 0 if !$game_temp.notebook_entries_count
    contents.clear
    contents.font.color = system_color
    no_category = false
    no_category = true if !$game_system.notebook_categories || $game_system.notebook_categories.size == 0
    text = @on_entry || no_category ? "Entries:" : "Categories:"    
    number = @on_entry || no_category ? $game_temp.notebook_entries_count : $game_temp.notebook_categories_count
    contents.draw_text(0, 0, 100, 24, text)
    contents.font.color = normal_color
    contents.draw_text(104, 0, 40, 24, number, 1)
  end
end

class Window_Notebook_Title < Window_Base
  def initialize(line_number = 2,twh = nil)
    @wh = twh.nil?? Graphics.width : twh
    super(0, 0, @wh, fitting_height(line_number))
  end

  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end

  def clear
    set_text("")
  end

  def set_item(item)
    set_text(item ? item.description : "")
  end

  def refresh
    contents.clear
    draw_text(-24, 0, @wh,24,@text,2)
  end
  
end


class Scene_Notebook < Scene_Base
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    #if $game_system.notebook_entries.empty?
    #  return_scene
    #end
    super
    create_background if $mog_rgss3_wallpaper_ex == true    
    @help_window = Window_Help.new
    @no_category = true if !$game_system.notebook_categories || $game_system.notebook_categories.size == 0
    
    @command_window = Window_NoteCommand.new(0, 0)
    @command_window.set_handler(:ok,     method(:on_text_list_ok))
    @command_window.set_handler(:cancel, method(:on_text_list_cancel))
    @command_window.set_handler(:shift, method(:on_text_list_shift))
    @command_window.height = Graphics.height - 110
    @command_window.y = @help_window.height
    @command_window.sort = $game_system.notebook_sort_mode
    #test    
    
    @entries_window = Window_Entries.new
    @command_window.height = Graphics.height - (@entries_window.height +
    @help_window.height)

    @command_window.hide.deactivate
    
    @cat_window = Window_CatCommand.new(0,0)
    @cat_window.set_handler(:ok,     method(:on_cat_list_ok))
    @cat_window.set_handler(:cancel,     method(:return_scene))
    @cat_window.height = @command_window.height
    @cat_window.y = @command_window.y
    
    twh = Graphics.width - @entries_window.width
    @title_window = Window_Notebook_Title.new(1,twh)
    @title_window.x = @entries_window.width
    @title_window.y = @help_window.height + @command_window.height
    @title_window.set_text(ESTRIOLE::NOTEBOOK_NAME) if !@no_category
    @title_window.set_text("Press Shift to sort Entries") if @no_category
    
    @help_text = ""
    @help_window.set_text(@help_text)
    straight_to_entry if @no_category
    select_last
    
    @sort_window = Window_Sort.new(Graphics.width/2 - (Graphics.width/4),0)
    @sort_window.y = @command_window.y + (@command_window.height-@sort_window.height)/2
    @sort_window.command_window = @command_window
    @sort_window.set_handler(:ok,     method(:on_sort_list_ok))
    @sort_window.set_handler(:cancel,     method(:on_sort_list_cancel))
    @sort_window.hide.deactivate
  end
  
  def on_text_list_shift
    @command_window.deactivate
    @sort_window.show.activate
    Input.update
  end
  
  def on_sort_list_ok
    $game_system.notebook_sort_mode = @sort_window.current_data[:name]
    @command_window.sort = $game_system.notebook_sort_mode 
    @sort_window.hide.deactivate
    @command_window.activate
  end
  def on_sort_list_cancel
    @command_window.sort = $game_system.notebook_sort_mode
    @sort_window.hide.deactivate
    @command_window.activate    
  end
  
  def straight_to_entry
    @cat_window.hide.deactivate
    @command_window.show.activate
    @on_entry = true
  end
  def select_last
    @cat_window.select_name($game_temp.notebook_categories_chosen) if $game_temp.notebook_categories_chosen
    @command_window.cat = @cat_window.current_data[:name] if $game_temp.notebook_categories_chosen
    @command_window.select_name($game_temp.notebook_entries_chosen) if $game_temp.notebook_entries_chosen    
    @cat_window.hide.deactivate if $game_temp.notebook_entries_chosen    
    @command_window.show.activate if $game_temp.notebook_entries_chosen
  end
  #--------------------------------------------------------------------------
  # * Frame update
  #--------------------------------------------------------------------------
  def update
    old_index = @command_window.index
    super    
    if @on_entry
    file = @command_window.current_data[:name] if @command_window.current_data 
    setting = ESTRIOLE::FILE_READER_SETTING[file] if file
    @help_text = ESTRIOLE::DEFAULT_NOTEBOOK_FILE_DESC
    @help_text = setting[:desc] if setting[:desc] if setting
    @help_text = ESTRIOLE::NOTEBOOK_NO_ENTRY_DESC if !file
    @title_window.set_text("Press Shift to sort Entries")
    @entries_window.on_entry = @on_entry
    @help_window.set_text(@help_text)       
    else
    return if @no_category
    @entries_window.on_entry = @on_entry
    cat = @cat_window.current_data[:name] if @command_window.current_data 
    @help_text = ESTRIOLE::CATEGORY_HELP_TEXT[cat] ? ESTRIOLE::CATEGORY_HELP_TEXT[cat] : ESTRIOLE::CATEGORY_DEFAULT_HELP_TEXT
    @title_window.set_text(ESTRIOLE::NOTEBOOK_NAME)
    @help_window.set_text(@help_text)       
    end
  end
    
  def on_text_list_ok
    return if !@command_window.current_data
    @command_window.activate
    file = @command_window.current_data[:name]
    setting = ESTRIOLE::FILE_READER_SETTING[file]
    if setting
      type = setting[:type]
      face = setting[:face_id]
      text = setting[:text_title]
      font_size = setting[:font_size]
      old_mode = setting[:old_mode]
      common_event_id = setting[:common_event]
      common_event_after_id = setting[:common_event_after]
    end
    puts common_event_after_id
    $game_temp.notebook_entries_chosen = @command_window.current_data[:name]
    SceneManager.call(Text_Reader)
    SceneManager.scene.set_file(file)
    SceneManager.scene.set_type(type)
    SceneManager.scene.set_face(face)
    SceneManager.scene.set_text_title(text)
    SceneManager.scene.set_font_size(font_size) if font_size   
    SceneManager.scene.set_old_mode if old_mode        
    SceneManager.scene.set_common_event(common_event_id) if common_event_id
    SceneManager.scene.set_common_event_after(common_event_after_id) if common_event_after_id
  end
  def on_text_list_cancel
    $game_temp.notebook_entries_chosen = nil
    on_cat_list_cancel if @no_category
    @command_window.hide.deactivate
    @on_entry = false
    @cat_window.show.activate
  end

  def on_cat_list_ok
    $game_temp.notebook_categories_chosen = @cat_window.current_data[:name]
    @cat_window.hide.deactivate
    @on_entry = true
    old_cat = @command_window.cat
    @command_window.cat = @cat_window.current_data[:name]
    @command_window.select(0) if old_cat != @command_window.cat
    @command_window.show.activate
  end
  def on_cat_list_cancel
    $game_temp.notebook_categories_chosen = nil    
    return_scene
  end
  
end


#yami pop message compatibility
if $imported["YES-PopMessage"] == true
class Window_Message < Window_Base
  attr_reader :face_window
  def close_and_wait
    @face_window.hide_face if @face_window
    @bubble_sprite.opacity = 0 if @bubble_sprite
    yes_pop_message_close_and_wait
    cancel_pop_message
  end  
end
class Scene_Map
  alias est_notebook_yami_pop_patch_terminate terminate
  def terminate
  est_notebook_yami_pop_patch_terminate  
  chk = @message_window.face_window.dispose rescue nil
  end
end
end

#victor sfont safeguard method (when bitmap didn't use sfont it won't crash)

if $imported[:ve_sfonts]
class Window_Base < Window
  def change_color(color, enabled = true)
    change_color_ve_sfont(color, enabled)
    contents.sfont.alpha = enabled ? 255 : translucent_alpha if contents.sfont
  end  
end
end

if $imported["Galv_Menu_Themes"]
class Scene_Notebook < Scene_Base
  include Check_Theme
   
  alias est_gmenu_engine_sb_start start
  def start
    est_gmenu_engine_sb_start
    if SceneManager.themed_scene
      $game_temp.themed_scene = true
      create_background
      create_theme_backgrounds
    end
  end
 
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end

  
  def create_theme_backgrounds
    create_background1
    create_themebg2
  end
   
  def create_background1
    @background1 = Plane.new
    @background1.bitmap = Cache.gmenu(name + "_Background",$game_system.menu_theme) rescue
      Cache.gmenu("Background",$game_system.menu_theme)
    @background1.opacity = mtheme::BACK1_OPACITY
    @background1.z = -1
    @background_sprite.z = -2
  end
   
  def create_themebg2
    @themebg2 = Sprite.new
    if !SceneManager.scene_is?(Scene_Menu)
      @themebg2.bitmap = Cache.gmenu(name + "_Background2",$game_system.menu_theme) rescue
      Cache.gmenu("Scene_Generic_Background2",$game_system.menu_theme) rescue
      nil
    end
    @themebg2.opacity = mtheme::SCENE_BACK_OPACITY
    if @themebg2.bitmap
      @themebg2.x = [(Graphics.width - @themebg2.bitmap.width) / 2,0].max
    end
    @themebg2.z = 0
  end
   
  alias est_gmenu_engine_sb_update update
  def update
    est_gmenu_engine_sb_update
    if @background1
      @background1.ox -= mtheme::BACK1_XY[0]
      @background1.oy -= mtheme::BACK1_XY[1]
    end
  end
   
  alias est_gmenu_engine_sb_terminate terminate
  def terminate
    est_gmenu_engine_sb_terminate
    $game_temp.themed_scene = false
    @background1.dispose if @background1
    @themebg2.dispose if @themebg2
  end
   
  def name
    if self.to_s =~ /#<(.*):/i
      return $1
    else
      return ""
    end
  end
end # Scene_Base

end #end imported galv menu themes

#===============================================================================
#
# END OF SCRIPT
#
#===============================================================================