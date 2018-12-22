=begin
===============================================================================
 Fantasy Bestiary v3.3 (20/11/2014)
-------------------------------------------------------------------------------
 Created By: Shadowmaster/Shadowmaster9000/Shadowpasta
 (www.crimson-castle.co.uk)
 
===============================================================================
 Information
-------------------------------------------------------------------------------
 This script adds a Bestiary that allows you to view enemy information. It can
 be accessed either from the main menu or through a script call. This Bestiary
 uses a design heavily inspired by the types of Bestiaries used in the Final
 Fantasy series (hence the name).
 
 The Bestiary is split up into two sections. The first section contains a
 vertical listing of enemies. When an enemy is selected, you are taken to
 the enemy's page (the second section), where you can view the enemy's sprite,
 as well as various statistics.
 
 Each enemy can have any number of pages to display various information, which
 can be toggled with the confirm button. While on an enemy's page, you can still
 scroll to other enemies.
 
===============================================================================
 How to Use
-------------------------------------------------------------------------------
 Place this script under Materials. You can call the Bestiary scene by using the
 script call:
 
 SceneManager.call(Scene_Bestiary)
 
 Further down are some options you can change to your liking.

===============================================================================
 Note Tags
-------------------------------------------------------------------------------
 Place any of these note tags within an enemy in the database.
 
 <hide from bestiary>
 Enemies with this notetag will automatically be hidden when you start up the
 beginning of the game. (This will not work for old save files, in which case
 you will need to use the Hide Enemy script call.) Hidden enemies do not count
 towards the Completion tracker. You can still unhide this enemy later on by
 using the Unhide Enemy script call.
 
 <hide hp>
 <hide mp>
 <hide stats>
 <hide spoils>
 Enemies with the hide hp and hide mp notetags will have their hp and mp values
 hidden respectively. Enemies with the hide stats notetag will have their ATK,
 DEF, MAT, MDF, AGI and LUK values hidden. Enemies with the hide spoils notetag
 will have their Gold, Exp and Drops hidden.
 
 <bestiary image: "string">
 When using this notetag, instead of using the image used in the database, the
 enemy will use the image set in this notetag, where "string" is the filename of
 image to be used from the battler folder (excluding the file format extension).
 
 <bestiary hue: n>
 When using the besitary image tag, you can use this tag to set a hue for the
 bestiary image, where n is the value of the hue used.
 
 <mirror bestiary image>
 When using this notetag, the enemy's image in the Bestiary will be mirrored.
 
 <bestiary holders pose: n1 n2>
 If using Holders Battlers with Battle Engine Symphony, you can use this
 notetag to determine the enemy's pose in the Bestiary, where n1 is the line
 and n2 is the frame.
 
 <bestiary bgm: "string" n1 n2>
 Loading up the enemy's entry will play the bgm stored in this notetag, where
 "string" is the filename of the bgm (exluding the file format extension), n1
 is the volume and n2 is the pitch. You do not need to include the n1 and n2
 variables.
 
 <x offset: n>
 <y offset: n>
 Allows you to adjust the enemy sprite's x or y position, where n is the number
 you want to adjust it by. Using a positive number for x moves the enemy to the
 right, using a negative number for y moves them to the left. Using a positive
 number for y moves the enemy down, using a negative number for y moves them up.
 
 <battleback1: "string">
 <battleback2: "string">
 Loads up a battleback behind the enemy sprite, where "string" is the file of
 the battleback (excluding the file format extension). battleback1 loads the
 battleback from the Battlebacks1 folder, while battleback2 loads the battleback
 from the Battlebacks2 folder.
 
 <battleback x offset: n>
 <battleback y offset: n>
 If the battlebacks are not set to cover the entire screen, these tags
 allow you to adjust the enemy's battleback x or y position, where n is the
 number you want to adjust it by. Using a positive number for x moves the
 battleback to the right, using a negative number for x moves the battleback to
 the left. Using a positive number for y moves the battleback down, using a
 negative number for y moves it up.
 
 <completion bonus: n>
 Sets the enemy's completion bonus, where n is the number you want to set it to.
 At default, all enemies have a completion bonus of 0. If an enemy has a
 completion bonus of 1, they add +1% to the completion percentage. Using this
 will allow you to exceed the standard maximum completion total. Ignore this if
 you dont plan on displaying the Completion Total as a percentage.
 
 <bestiary icon: n>
 Lets you set an icon for the enemy, where n is the index number of the icon
 you want to use. You can also change an enemy's bestiary icon in mid-play
 by using the script call change_bestiary_icon(enemy id, index).
 
 <bestiary level: n>
 Sets the enemy's level, where n is the level number. This number is purely
 for cosmetic purposes and does not increase the enemy's base stats the
 higher the number. If the enemy's level is set to be viewed in the Bestiary
 and that enemy has no level tag, their level will simply appear as "???". You
 can also change the enemy's level mid-play by using the script call
 change_enemy_level(enemy id, level).
 
 <type: "string">
 <location: "string">
 <elem weak: "string">
 <elem resist: "string">
 <elem immune: "string">
 <elem absorb: "string">
 <state weak: "string">
 <state resist: "string">
 <state immune: "string">
 <skills pg1: "string">
 <skills pg2: "string">
 <skills pg3: "string">
 <long desc: "string">
 Replace string with anything you want. You can set a new line within a string
 by using \L. Other control characters can be used such as using \I[n] for
 displaying icons. If any of those tags are not set up for an enemy, the next
 in that respective area will simply appear as "None".
   
 <desc: "string">
 Replace string with anything you want. You can set a new line within a string
 by using \L. Only 2 lines of space are available. You can ignore this if you
 have set up the description window to not show up.

===============================================================================
 Script Calls
-------------------------------------------------------------------------------
 
 reveal_enemy(enemy id)
 Reveals the enemy in the Bestiary. If the enemy has been set to hide, you
 will still not see the enemy in the Bestiary until you unhide them.
 
 unreveal_enemy(enemy id)
 Unreveals the enemy in the Bestiary. They are still set to be tracked by the
 Bestiary and will still count towards your Completion total. If you want the
 enemy you just unrevealed to not count towards your Completion total, use the
 Hide Enemy script call.
 
 hide_enemy(enemy id)
 Removes the enemy from the Bestiary listings. The enemy will no longer be
 tracked by the Completion tracker regardless of whether the enemy was revealed
 beforehand or not.
 
 unhide_enemy(enemy id)
 Adds the hidden enemy back onto the Bestiary listings. If they were revealed
 before being hidden, they will return back onto the Bestiary as revealed.
 If they were unrevealed before being hidden, they will stay unrevealed until
 you reveal them.
 
 change_enemy_level(enemy id, level)
 Changes the enemy's level that appears in the Bestiary. If you want to remove
 an enemy's level, replace level with nil.
 
 change_bestiary_icon(enemy id, index)
 Changes the enemy's icon that appears in the Bestiary. Use an value of 0 for
 index if you want to remove the enemy's icon.
 
===============================================================================
 Required
-------------------------------------------------------------------------------
 Nothing.

===============================================================================
 Other User Script Features
-------------------------------------------------------------------------------
 I've added some extra functionality to the Bestiary when using certain scripts:
 
 Yanfly Ace Engine Core
 ----------------------
 Also when using the Yanfly Engine Ace Core script, if grouping numbers is
 enabled, this script will group the numbers on the first status page for
 enemies in the Bestiary.
 
 Battle Engine Symphony
 ----------------------
 The Bestiary can read any Holders Battlers notetags and will load that
 enemy's holders battler image instead of their normal image. This image
 will automatically be mirrored, but can be un-mirrored using the
 <mirror bestiary image> tag. You can also use the <bestiary holders pose: n1 n2>
 tag to determine what pose the enemy uses in the Bestiary.
 
 If you don't wish to use the enemy's holders battler image for the bestiary,
 use the <bestiary image: "string"> notetag inside of the enemy's notetag area.

===============================================================================
 Change log
-------------------------------------------------------------------------------
 v3.3: Fixed a bug where the BGM played by the Bestiary wasn't affected by any
 settings from Yanfly's System Options script. (20/11/2014)
 v3.2: Slightly reduced number of lines used and changed how various data is
 called to help make it compatible with the New Game Plus Add-On. (10/9/2014)
 v3.1: Fixed an error where using the Bestiary on an old save file and killing
 an enemy before viewing the Bestiary will throw up an error. Also fixed the
 Defeated, Level, Gold and Exp strings so you can now use control characters in
 them. (01/8/2014)
 v3.0: You can now set how many pages you want and how which sections you want
 on each page. Also added new sections such as State information, Skills info
 and an additional information section for anyone who doesn't want to use the
 descriptipn window. Icon implementation has changed so you can now insert icons
 anywhere in section titles you want. Also changed \N to \L to insert linebreaks
 to allow for actor name implementation with \N[i]. You can now set a default
 battleback for all enemies. Fixed a bug where if replaying map bgm was disabled,
 the map bgm still played. This has now been corrected. Also fixed the description
 notetag so the script guidelines now show the correct description notetag.
 New enemies added to the database should now work correctly for old save files.
 (27/7/2014)
 v2.0: Added icon support for various areas of the Bestiary, you can now set
 icons for individual enemies, category titles and category areas. You can
 also change an enemy's level and icon mid-play using script calls. Users now
 the option of easily adding a second tracker and can give any name to both
 completion trackers. Completion variables now also work while the Completion
 values aren't displayed as a percentage. Finally, users of Battle Engine Symphony
 Holders Battlers can now set what pose they want for each individual enemy in
 the Bestiary. (22/10/2013)
 v1.5: Added various enemy viewing options. You can now set an alternate picture
 for the enemy to use with a note tag. Added an option to allow the battleback
 to stretch across the entire screen and not just be kept inside of the enemy
 picture window. Added the option to mirror enemy images using a notetag. I've
 also added compatibility with Battle Engine Symphony Holders Battlers, where
 this script will detect a enemy's holders battlers name and use that image
 as the enemy's image in the Bestiary. (21/10/2013)
 v1.1: Added ability to tie Completion Percentage to a variable and give enemies
 a completion bonus. (15/05/2013)
 v1.0: First release. (04/05/2013)

===============================================================================
 Terms of Use
-------------------------------------------------------------------------------
 * Free to use for both commercial and non-commerical projects.
 * Credit me if used.
 * Do not claim this as your own.
 * You're free to post this on other websites, but please credit me and keep
 the header intact.
 * If you want to release any modifications/add-ons for this script, you must
 use the same Terms of Use as this script uses.
 * If you're making any compatibility patches or scripts to help this script
 work with other scripts, the Terms of Use for the compatibility patch does
 not matter so long as the compatibility patch still requires this script to
 run.
 * If you want to use your own seperate Terms of Use for your version or
 add-ons of this script, you must contact me at http://www.rpgmakervxace.net
 or www.crimson-castle.co.uk

===============================================================================
=end
$imported = {} if $imported.nil?
$imported["FantasyBestiary"] = true

module FantasyBestiary
  
#==============================================================================
# ** Menu Access
#------------------------------------------------------------------------------
#  If set to true, the Bestiary can be accessed from the main menu, and will be
#  placed under all of the main commands (Item, Skill, Equip and Status). If
#  set to false, you will need to call the Bestiary scene through a script call:
#  
#  SceneManager.call(Scene_Bestiary)
#==============================================================================
  
  Menu_Access = true

#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This allows you to change the names for various stats, headers and other
#  pieces of text.
#
#  For all strings with the exception of Besitary_Name, you can insert various
#  control characters such as icons \I[N] in the string. The string for
#  Bestiary_Name must be contained in "". All other strings must be contained
#  in '' instead.
#==============================================================================
 
 Bestiary_Name = "Bestiary"
 Defeated = 'Defeated'
 Level = 'Level'
 Exp = 'Exp'
 Currency = '$'
 Drops_Name = 'Drops'
 Type = 'Skills'
 Location = 'Location'
 Elem_Weak = 'Weaknesses'
 Elem_Resist = 'Resistances'
 Elem_Immune = 'Immunities'
 Elem_Absorb = 'Absorption'
 State_Weak = 'Status Weaknesses'
 State_Resist = 'Status Resistances'
 State_Immune = 'Status Immunities'
 Skills_1 = 'Skills Page 1'
 Skills_2 = 'Skills Page 2'
 Skills_3 = 'Skills Page 3'
 Long_Desc = 'Information'
 Empty_Text = 'None'
 Toggle_Status_Text = ''
 
#==============================================================================
# ** Drop Icon Options
#------------------------------------------------------------------------------
#  If Show_Drop_Icons is set to true, icons for the enemy's droppable items
#  will appear next to the drop name if the spoils haven't been hidden.
#==============================================================================
 
 Show_Drop_Icons = false
 
#==============================================================================
# ** Reveal and Kill Options
#------------------------------------------------------------------------------
#  When Spot_Reveal is set to true, the enemy will reveal itself in the Bestiary
#  as soon as you see it in battle (unless if the enemy is set to hidden, in
#  which case it will still not show up).
#
#  When Kill_Reveal is set to true, when you kill an enemy that enemy is
#  automatically set to reveal itself in the Bestiary (unless if the enemy is
#  set to hidden, in which case it will still not show up).
#
#  If both Spot_Reveal & Kill_Reveal are set to false, you will have to manually
#  reveal each enemy yourself using the script call:
#
#  reveal_enemy(id)
#
#  When Show_Kill is set to true, you will see the kill count for all
#  enemies even if they are unrevealed. If set to false, the kill count
#  for any unrevealed enemies will simply show up as "?".
#==============================================================================
 
 Spot_Reveal = true
 Kill_Reveal = true
 Show_Kill = true

#==============================================================================
# ** Completion Window Options
#------------------------------------------------------------------------------
#  Setting Completion_Window to true will make the Completion Window appear on
#  the first page showing how much of the Bestiary you have completed. Setting
#  this to false will give the enemy listing more space on the first page.
#
#  Completion_Percent when set to true will display how much of the Bestiary
#  you have completed as a percentage.
#
#  When Completion_Variable is set to any value higher than 0, the Completion
#  Tracker will instead display the value currently set for the Variable ID
#  equal to Completion_Variable's value.
#
#  When Second_Tracker is set to true, a second tracker will show up, which
#  can be used to track other things related to the enemies. It is recommended
#  to use Second_Tracker_Variable with this, otherwise both Completion_Window
#  and Second_Tracker will show the same data.
#
#  Completion_Align sets how the Completion text is aligned in its window:
#
#  0 = Left
#  1 = Middle
#  2 = Right
#
#  The effects of Completion_Align are disabled while Second_Tracker is
#  activated.
#==============================================================================
  
 Completion_Window = true
 Completion_Name = "Completed: "
 Completion_Percent = false
 Completion_Variable = 0
 Second_Tracker = false
 Second_Tracker_Name = "Marked: "
 Second_Tracker_Percent = true
 Second_Tracker_Variable = 0
 Completion_Align = 1

#==============================================================================
# ** Enemy Status Window Options
#------------------------------------------------------------------------------
#  Status_Page_Width Determines the width of the status page. The larger the
#  status page, the more space your stats will have, but at the same time, this
#  will also give you less space to view the enemy sprite.
#
#  Default_Battleback1 and Default_Battleback2 sets default battlebacks for
#  any enemies lacking battleback notetags. If you don't want to use any
#  default battlebacks, leave an empty string like "".
#
#  When Battleback_Full_Screen is set to true, the window frame for the enemy
#  and battleback images will disappear and the battleback images will cover
#  the background of the entire screen instead of just the enemy image window.
#
#  When Battleback_Full_Screen is set to false, Enemy_Picture_Padding Determines
#  the padding for the enemy's sprite and battleback inside its window. The
#  higher the padding is, the more that will be cut off of the enemy sprite and
#  battleback. This is useful if in case you are using any custom window
#  designs. For the default window design, the default value is 6.
#
#  When Global_Mirror is set to true, all enemies in the Bestiary will
#  have their images mirrored. This is useful for when using a custom battle
#  system that automatically flips an enemy's image. You can still use the
#  <mirror bestiary image> tag to un-mirror an enemy.
#==============================================================================
  
 Status_Page_Width = 200
 Default_Battleback1 = "Default"
 Default_Battleback2 = ""
 Battleback_Full_Screen = true
 Enemy_Picture_Padding = 6
 Global_Mirror = false
 
#==============================================================================
# ** Replay Map BGM when Enemy has no BGM
#------------------------------------------------------------------------------
#  If set to true, when viewing an enemy that has no Bestiary BGM assigned to
#  it through notetagging, the Map BGM will be replayed. If set to false, when
#  viewing an enemy with no BGM, all music will be turned off.
#
#  Regardless of whether this is set to true or false, the Map BGM will always
#  replay whenever you return to the first screen of the Bestiary.
#==============================================================================
  
 Replay_Map_BGM = true
 
#==============================================================================
# ** Page Structure
#------------------------------------------------------------------------------
#  This is where you can insert how many pages you want in the Bestiary, along
#  with which sections you want on each page. Below are the list of strings
#  available and what they add to the page:
#
#  "Space" = Adds a line break between sections.
#  "Line" = Adds a line bar between sections.
#  "Kill Count" = Shows how many of that enemy have been defeated.
#  "Level" = Shows the enemy's level that has been assigned to the enemy.
#  "HP" = Shows enemy's max HP.
#  "MP" = Shows enemy's max MP.
#  "Stats" = Shows the enemy's parameters. There is an option below that lets
#  you set how many parameters you want to be viewable.
#  "Exp" = Shows how much Exp the enemy gives.
#  "Gold" = Shows how much Gold the enemy gives.
#  "Drop Title" = Shows the Drop title.
#  "Drop" = Shows what items the enemy can drop.
#  "Type Title" = Shows the Types title.
#  "Type" = Shows a list of the types assigned to the enemy through the
#  <type: "string"> notetag.
#  "Location Title" = Shows the Location title.
#  "Location" = Shows a list of the locations assigned to the enemy through the
#  <location: "string"> notetag.
#  "Elem Weak Title" = Shows the Elemental Weaknesses title.
#  "Elem Weak" = Shows a list of elemental weaknesses assigned to the enemy
#  through the <elem weak: "string"> notetag.
#  "Elem Resist Title" = Shows the Elemental Resistances title.
#  "Elem Resist" = Shows a list of elemental resistances assigned to the enemy
#  through the <elem resist: "string"> notetag.
#  "Elem Immune Title" = Shows the Elemental Immunities title.
#  "Elem Immune" = Shows a list of elemental immunities assigned to the enemy
#  through the <elem immune: "string"> notetag.
#  "Elem Absorb Title" = Shows the Elemental Absorptions title.
#  "Elem Absorb" = Shows a list of elemental absorptions assigned to the enemy
#  through the <elem absorb: "string"> notetag.
#  "State Weak Title" = Shows the State Weaknesses title.
#  "State Weak" = Shows a list of state weaknesses assigned to the enemy
#  through the <elem weak: "string"> notetag.
#  "State Resist Title" = Shows the State Resistances title.
#  "State Resist" = Shows a list of state resistances assigned to the enemy
#  through the <elem resist: "string"> notetag.
#  "State Immune Title" = Shows the State Immunities title.
#  "State Immune" = Shows a list of state immunities assigned to the enemy
#  through the <elem immune: "string"> notetag.
#  "Skills 1 Title" = Shows the Skills Page 1 title.
#  "Skills 1" = A section that can be used to show the enemy's skills that
#  are written in the <skills pg1: "string"> notetag.
#  "Skills 2 Title" = Shows the Skills Page 2 title.
#  "Skills 2" = An additional section that can be used to show the enemy's
#  skills that are written in the <skills pg2: "string"> notetag.
#  "Skills 3 Title" = Shows the Skills Page 3 title.
#  "Skills 3" = An additional section that can be used to show the enemy's
#  skills that are written in the <skills pg3: "string"> notetag.
#  "Long Desc Title" = Shows the Long Description title.
#  "Long Desc" = A miscellaneous section that be used to write additional
#  info about the enemy with the <long desc: "string"> notetag if you do not
#  want to use the dedicated description window.
#
#  If you ever get confused or mess up your page structures, below is the
#  default Pages array:
#
#  Pages =[ # Do not remove!
#    ["Kill Count", "Space", "Level", "HP", "MP", "Stats", "Exp", "Gold"],
#    ["Drop Title", "Line", "Drop", "Space", "Type Title", "Line", "Type", "Space", "Location Title", "Line", "Location"],
#    ["Elem Weak Title", "Line", "Elem Weak", "Space", "Elem Resist Title", "Line", "Elem Resist", "Space", "Elem Immune Title", "Line", "Elem Immune"],
#  ] # Do not remove!
#
#==============================================================================

 Pages =[ # Do not remove!
   ["Kill Count", "Space", "HP", "Stats", "Exp"],
   ["Elem Weak Title", "Line", "Elem Weak", "Space", "Space", "Elem Resist Title", "Line", "Elem Resist"],
   ["Type Title", "Line", "Type"],
 ] # Do not remove!
 
#==============================================================================
# ** Additional Enemy Status Displays
#------------------------------------------------------------------------------
#  When Show_Desc_Window set to true, this will make a window appear that
#  allows you to write a description about the enemy you are viewing. Setting
#  this to false will allow you to view more of an enemy and its battleback.
#
#  Stats_To_Display sets how many stats you want to display, from ATK to LUK.
#  (Unless if you have made any custom params, do not set this value any higher
#  than 6!)
#==============================================================================
  
 Show_Desc_Window = true
 Stats_To_Display = 6
 
#==============================================================================
# ** Horizontal Line Opacity
#------------------------------------------------------------------------------
#  Sets the horizontal line opacity that shows up on the second status page for
#  an enemy. This number can range from 0-255.
#==============================================================================
  
 Horz_Line_Opac = 48

#==============================================================================
# ** DO NOT edit anything below this unless if you know what you're doing!
#==============================================================================
    
end

#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  This module manages the database and game objects. Almost all of the 
# global variables used by the game are initialized by this module.
#==============================================================================

module DataManager
  #--------------------------------------------------------------------------
  # * Load Database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_fantasybestiary load_database; end
  def self.load_database
    load_database_fantasybestiary
    load_notetags_fantasybestiary
  end
  #--------------------------------------------------------------------------
  # * Load Notetags for Fantasy Bestiary
  #--------------------------------------------------------------------------
  def self.load_notetags_fantasybestiary
    groups = [$data_enemies]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_fantasybestiary
      end
    end
  end
end

#==============================================================================
# ** RPG::Enemy
#------------------------------------------------------------------------------
#  This class defines attributes for enemies. Its superclass is RPG::BaseItem.
#==============================================================================

class RPG::Enemy
  #--------------------------------------------------------------------------
  # Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :bestiary_bgm
  attr_accessor :bgm_volume
  attr_accessor :bgm_pitch
  attr_accessor :bestiary_image
  attr_accessor :bestiary_hue
  attr_accessor :bestiary_mirror
  attr_accessor :x_offset
  attr_accessor :y_offset
  attr_accessor :battleback1
  attr_accessor :battleback2
  attr_accessor :bb_x_offset
  attr_accessor :bb_y_offset
  attr_accessor :hide_from_start
  attr_accessor :hide_hp
  attr_accessor :hide_mp
  attr_accessor :hide_stats
  attr_accessor :hide_spoils
  attr_accessor :completion_bonus
  attr_accessor :bestiary_level
  attr_accessor :elem_weak
  attr_accessor :elem_resist
  attr_accessor :elem_immune
  attr_accessor :elem_absorb
  attr_accessor :state_weak
  attr_accessor :state_resist
  attr_accessor :state_immune
  attr_accessor :type
  attr_accessor :location
  attr_accessor :skillspg1
  attr_accessor :skillspg2
  attr_accessor :skillspg3
  attr_accessor :description
  attr_accessor :long_desc
  attr_accessor :bestiary_icon
  attr_accessor :holders_line
  attr_accessor :holders_frame
  #--------------------------------------------------------------------------
  # Defining Attributes
  #--------------------------------------------------------------------------
  def load_notetags_fantasybestiary
    @bgm_volume = 100
    @bgm_pitch = 100
    @bestiary_hue = 0
    @bestiary_mirror = false
    @x_offset = 0
    @y_offset = 0
    @bb_x_offset = 0
    @bb_y_offset = 0
    @completion_bonus = 0
    @hide_from_start = false
    @hide_hp = false
    @hide_mp = false
    @hide_stats = false
    @hide_spoils = false
    @elem_weak = ""
    @elem_resist = ""
    @elem_immune = ""
    @elem_absorb = ""
    @state_weak = ""
    @state_resist = ""
    @state_immune = ""
    @type = ""
    @location = ""
    @skillspg1 = ""
    @skillspg2 = ""
    @skillspg3 = ""
    @description = ""
    @long_desc = ""
    @bestiary_icon = 0
    @holders_line = 0
    @holders_frame = 0
    if @hide_from_start == false
      if @note =~ /<bestiary bgm: "(.+?)\">/i
          @bestiary_bgm = $1.to_s
      end
      if @note =~ /<bestiary bgm: "(.+?)\" (.*)>/i
          @bestiary_bgm = $1.to_s
          @bgm_volume = $2.to_i
          @bgm_volume = 100 if @bgm_volume > 100
          @bgm_volume = 0 if @bgm_volume < 0
      end
      if @note =~ /<bestiary bgm: "(.+?)\" (.*) (.*)>/i
          @bestiary_bgm = $1.to_s
          @bgm_volume = $2.to_i
          @bgm_pitch = $3.to_i
          @bgm_volume = 100 if @bgm_volume > 100
          @bgm_volume = 0 if @bgm_volume < 0
          @bgm_pitch = 150 if @bgm_pitch > 150
          @bgm_volume = 50 if @bgm_pitch < 50
      end
      if @note =~ /<bestiary image: "(.+?)\">/i
          @bestiary_image = $1.to_s
      end
      if @note =~ /<bestiary hue: (.*)>/i
          @bestiary_hue = $1.to_i
      end
      if @note =~ /<mirror bestiary image>/i
          @bestiary_mirror = true
      end
      if @note =~ /<x offset: (.*)>/i
          @x_offset = $1.to_i
      end
      if @note =~ /<y offset: (.*)>/i
          @y_offset = $1.to_i
      end
      if @note =~ /<battleback1: "(.+?)\">/i
          @battleback1 = $1.to_s
      end
      if @note =~ /<battleback2: "(.+?)\">/i
          @battleback2 = $1.to_s
      end
      if @note =~ /<battleback x offset: (.*)>/i
          @bb_x_offset = $1.to_i
      end
      if @note =~ /<battleback y offset: (.*)>/i
          @bb_y_offset = $1.to_i
      end
      if @note =~ /<completion bonus: (.*)>/i
          @completion_bonus = $1.to_i
      end
      if @note =~ /<bestiary level: (.*)>/i
          @bestiary_level = $1.to_i
      end
      if note[/<(elem weak: )\"(.+?)\">/im]
          @elem_weak = $2
          @elem_weak.gsub!(/[\r\n]/, "")
          @elem_weak.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(elem resist: )\"(.+?)\">/im]
          @elem_resist = $2
          @elem_resist.gsub!(/[\r\n]/, "")
          @elem_resist.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(elem immune: )\"(.+?)\">/im]
          @elem_immune = $2
          @elem_immune.gsub!(/[\r\n]/, "")
          @elem_immune.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(elem absorb: )\"(.+?)\">/im]
          @elem_absorb = $2
          @elem_absorb.gsub!(/[\r\n]/, "")
          @elem_absorb.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(state weak: )\"(.+?)\">/im]
          @state_weak = $2
          @state_weak.gsub!(/[\r\n]/, "")
          @state_weak.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(state resist: )\"(.+?)\">/im]
          @state_resist = $2
          @state_resist.gsub!(/[\r\n]/, "")
          @state_resist.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(state immune: )\"(.+?)\">/im]
          @state_immune = $2
          @state_immune.gsub!(/[\r\n]/, "")
          @state_immune.gsub!(/\\[Ll]/, "\n")
      end  
      if note[/<(type: )\"(.+?)\">/im]
          @type = $2
          @type.gsub!(/[\r\n]/, "")
          @type.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(location: )\"(.+?)\">/im]
          @location = $2
          @location.gsub!(/[\r\n]/, "")
          @location.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(skills pg1: )\"(.+?)\">/im]
          @skillspg1 = $2
          @skillspg1.gsub!(/[\r\n]/, "")
          @skillspg1.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(skills pg2: )\"(.+?)\">/im]
          @skillspg2 = $2
          @skillspg2.gsub!(/[\r\n]/, "")
          @skillspg2.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(skills pg3: )\"(.+?)\">/im]
          @skillspg3 = $2
          @skillspg3.gsub!(/[\r\n]/, "")
          @skillspg3.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(desc: )\"(.+?)\">/im]
          @description = $2
          @description.gsub!(/[\r\n]/, "")
          @description.gsub!(/\\[Ll]/, "\n")
      end
      if note[/<(long desc: )\"(.+?)\">/im]
          @long_desc = $2
          @long_desc.gsub!(/[\r\n]/, "")
          @long_desc.gsub!(/\\[Ll]/, "\n")
      end
      if @note =~ /<hide hp>/i
          @hide_hp = true
      end
      if @note =~ /<hide mp>/i
          @hide_mp = true
      end
      if @note =~ /<hide stats>/i
          @hide_stats = true
      end
      if @note =~ /<hide spoils>/i
          @hide_spoils = true
      end
      if @note =~ /<bestiary icon: (.*)>/i
          @bestiary_icon = $1.to_i
      end
      if @note =~ /<bestiary holders pose: (.*) (.*)>/i
          @holders_line = $1.to_i - 1
          @holders_frame = $2.to_i - 1
      end
      if @note =~ /<hide from bestiary>/i
          @hide_from_start = true
      end
    end
  end
end

#==============================================================================
# ** Numeric
#------------------------------------------------------------------------------
#  The abstract class for numbers.
#==============================================================================

class Numeric
  #--------------------------------------------------------------------------
  # * Group Digits
  #--------------------------------------------------------------------------
  unless $imported["YEA-CoreEngine"]
  def group; return self.to_s; end
  end # $imported["YEA-CoreEngine"]
end

#==============================================================================
# ** Window_MenuCommand
#------------------------------------------------------------------------------
#  This command window appears on the menu screen.
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Add Main Commands to List
  #--------------------------------------------------------------------------
  alias bestiary_add_main_commands add_main_commands
  def add_main_commands
    bestiary_add_main_commands
    if FantasyBestiary::Menu_Access
      add_command(FantasyBestiary::Bestiary_Name, :fantasy_bestiary)
    end
  end
end

#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs the menu screen processing.
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  alias bestiary_create_command_window create_command_window
  def create_command_window
    bestiary_create_command_window
    @command_window.set_handler(:fantasy_bestiary, method(:command_fantasy_bestiary))
  end
  #--------------------------------------------------------------------------
  # * [Journal] Command
  #--------------------------------------------------------------------------
  def command_fantasy_bestiary
    SceneManager.call(Scene_Bestiary)
  end
end

#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemies. It used within the Game_Troop class 
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Alias: Object Initialization
  #--------------------------------------------------------------------------
  alias initialize_bestiary initialize
  def initialize(index, enemy_id)
    initialize_bestiary(index, enemy_id)
    if FantasyBestiary::Spot_Reveal
      $game_party.add_found(enemy_id)
      $game_party.enemies_revealed.push(enemy_id) unless $game_party.enemies_hidden.include?(enemy_id)
    end
  end
  #--------------------------------------------------------------------------
  # * Knock Out
  #--------------------------------------------------------------------------
  def die
    super
    $game_party.add_kill(enemy)
  end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles parties. Information such as gold and items is included.
# Instances of this class are referenced by $game_party.
#==============================================================================

class Game_Party < Game_Unit 
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :kill_count
  attr_accessor :bestiary_level
  attr_accessor :bestiary_icon
  attr_accessor :enemies_revealed
  attr_accessor :enemies_hidden
  attr_accessor :enemies_found
  attr_accessor :enemies_total
  attr_accessor :completion_bonus
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias beastiary_initialize initialize
  def initialize
    beastiary_initialize
    @enemies_found = 0
    @enemies_total = 0
    @completion_bonus = 0
    @kill_count = []
    @bestiary_level = []
    @bestiary_icon = []
    @enemies_revealed = []
    @enemies_hidden = []
    for i in 0..$data_enemies.size
      @kill_count[i] = 0
    end
    $data_enemies.compact.each { |enemy| @enemies_hidden.push(enemy.id) if enemy.hide_from_start
    @enemies_total += 1 if !enemy.hide_from_start
    @bestiary_level.push(enemy.id)
    @bestiary_level[enemy.id] = enemy.bestiary_level
    @bestiary_icon.push(enemy.id)
    @bestiary_icon[enemy.id] = enemy.bestiary_icon}
  end
  #--------------------------------------------------------------------------
  # * Check Nil Values
  #--------------------------------------------------------------------------
  def check_nil_values
    if @enemies_found == nil
      @enemies_found = 0
    end
    if @enemies_total == nil
      @enemies_total = 0
    end
    if @completion_bonus == nil
      @completion_bonus = 0
    end
    if @kill_count == nil
      @kill_count = []
      for i in 0..$data_enemies.size
      @kill_count[i] = 0
    end
    end
    if @enemies_revealed == nil
      @enemies_revealed = []
    end
    if @enemies_hidden == nil
      @enemies_hidden = []
    end
    if @bestiary_level == nil
      @bestiary_level = []
    end
    if @bestiary_icon == nil
      @bestiary_icon = []
    end
  end
  #--------------------------------------------------------------------------
  # * Hide New Enemies from Start
  #--------------------------------------------------------------------------
  def hide_new_enemies_from_start
    groups = [$data_enemies]
    for group in groups
      for obj in group
        next if obj.nil?
        next if @bestiary_icon[obj.id] != nil
        @enemies_hidden.push(obj.id) if obj.hide_from_start
        @enemies_total += 1 if !obj.hide_from_start
        @bestiary_icon.push(obj.id)
        @bestiary_icon[obj.id] = obj.bestiary_icon
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Remove found for hidden Enemy
  #--------------------------------------------------------------------------
  def hide_found(enemy)
    @bonus = $data_enemies[enemy].completion_bonus
    @enemies_total -= 1 if !@enemies_hidden.include?(enemy)
    @enemies_found -= 1 if @enemies_revealed.include?(enemy) && !@enemies_hidden.include?(enemy)
    @completion_bonus -= @bonus if @enemies_revealed.include?(enemy) && !@enemies_hidden.include?(enemy)
  end
  #--------------------------------------------------------------------------
  # * Add found for unhidden Enemy if revealed
  #--------------------------------------------------------------------------
  def unhide_found(enemy)
    @bonus = $data_enemies[enemy].completion_bonus
    @enemies_total += 1 if @enemies_hidden.include?(enemy)
    @enemies_found += 1 if @enemies_revealed.include?(enemy) && @enemies_hidden.include?(enemy)
    @completion_bonus += @bonus if @enemies_revealed.include?(enemy) && @enemies_hidden.include?(enemy)
  end
  #--------------------------------------------------------------------------
  # * Add found for Enemy when revealed
  #--------------------------------------------------------------------------
  def add_found(enemy)
    @bonus = $data_enemies[enemy].completion_bonus
    @enemies_found += 1 if !@enemies_revealed.include?(enemy) && !@enemies_hidden.include?(enemy)
    @completion_bonus += @bonus if !@enemies_revealed.include?(enemy) && !@enemies_hidden.include?(enemy)
  end
  #--------------------------------------------------------------------------
  # * Remove found for Enemy when unrevealed
  #--------------------------------------------------------------------------
  def remove_found(enemy)
    @bonus = $data_enemies[enemy].completion_bonus
    @enemies_found -= 1 if @enemies_revealed.include?(enemy) && !@enemies_hidden.include?(enemy)
    @completion_bonus -= @bonus if @enemies_revealed.include?(enemy) && !@enemies_hidden.include?(enemy)
  end
  #--------------------------------------------------------------------------
  # * Add to Enemy Kill Count
  #--------------------------------------------------------------------------
  def add_kill(enemy)
    check_nil_values
    if @kill_count[enemy.id] == nil
      @kill_count[enemy.id] = 0
    end
    if @kill_count[enemy.id] < 999
      @kill_count[enemy.id] += 1
      if FantasyBestiary::Kill_Reveal && !FantasyBestiary::Spot_Reveal
        @enemies_found += 1 unless @enemies_hidden.include?(enemy.id) || @enemies_revealed.include?(enemy.id)
        @bonus = $data_enemies[enemy.id].completion_bonus
        @completion_bonus += @bonus unless @enemies_hidden.include?(enemy.id) || @enemies_revealed.include?(enemy.id)
        @enemies_revealed.push(enemy.id) unless @enemies_hidden.include?(enemy.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Define Change Level for Enemy
  #--------------------------------------------------------------------------
  def change_enemy_level(id, level)
    @bestiary_level[id] = level
  end
  #--------------------------------------------------------------------------
  # * Define Change Icon for Enemy
  #--------------------------------------------------------------------------
  def change_enemy_icon(id, index)
    @bestiary_icon[id] = index
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Hide Enemy
  #--------------------------------------------------------------------------
  def hide_enemy(enemy)
    $game_party.hide_found(enemy)
    $game_party.enemies_hidden.push(enemy)
  end
  #--------------------------------------------------------------------------
  # * Unhide Enemy
  #--------------------------------------------------------------------------
  def unhide_enemy(enemy)
    $game_party.unhide_found(enemy)
    $game_party.enemies_hidden.delete(enemy)
  end
  #--------------------------------------------------------------------------
  # * Reveal Enemy
  #--------------------------------------------------------------------------
  def reveal_enemy(enemy)
    $game_party.add_found(enemy)
    $game_party.enemies_revealed.push(enemy)
  end
  #--------------------------------------------------------------------------
  # * Unreveal Enemy
  #--------------------------------------------------------------------------
  def unreveal_enemy(enemy)
    $game_party.remove_found(enemy)
    $game_party.enemies_revealed.delete(enemy)
  end
  #--------------------------------------------------------------------------
  # * Change Enemy Level
  #--------------------------------------------------------------------------
  def change_enemy_level(id, level)
    $game_party.change_enemy_level(id, level)
  end
  #--------------------------------------------------------------------------
  # * Change Bestiary Icon for Enemy
  #--------------------------------------------------------------------------
  def change_bestiary_icon(id, index)
    $game_party.change_enemy_icon(id, index)
  end
end

#==============================================================================
# ** Window_EnemyList
#------------------------------------------------------------------------------
#  This window displays a list of enemies on the first Bestiary screen.
#==============================================================================

class Window_EnemyList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @data = []
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # * Update Cursor
  #--------------------------------------------------------------------------
  def update_cursor
    if @cursor_all
      cursor_rect.set(0, 0, contents.width, row_max * item_height)
      self.top_row = 0
    elsif @index < 0
      cursor_rect.empty
    else
      ensure_cursor_visible
      bx = (index % col_max * (item_width + spacing))
      by = index / col_max * item_height
      cursor_rect.set(bx  + (((contents.width / 7) * 2) - 74), by, (item_width / 7) * 5, item_height)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # * Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    item.is_a?(RPG::Enemy) && !$game_party.enemies_hidden.include?(item.id)
  end
  #--------------------------------------------------------------------------
  # * Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    $game_party.enemies_revealed.include?(item.id)
  end
  #--------------------------------------------------------------------------
  # * Create Item List
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $data_enemies.select {|item| include?(item)}
    @data.push(nil) if include?(nil)
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index($game_party.last_item.object) || 0)
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    x = 0
    y = index / col_max  * 24
    item = @data[index]
    if item 
      text = sprintf("%01d", index + 1).to_s  + "."
      text = sprintf("%02d", index + 1).to_s  + "." if $game_party.enemies_total >= 10
      text = sprintf("%03d", index + 1).to_s  + "." if $game_party.enemies_total >= 100
      draw_text(x + (((contents.width / 7) * 2) - 70), y, 50, line_height, text, 0)
      if !$game_party.enemies_revealed.include?(item.id)
        enemy_name = "??????"
        if $game_party.kill_count[item.id] == nil
          $game_party.kill_count[item] = 0
        end
        kill_count = $game_party.kill_count[item.id].to_s if FantasyBestiary::Show_Kill
        kill_count = "?" if !FantasyBestiary::Show_Kill
      else
        if $game_party.bestiary_icon[item.id] == nil
          $game_party.change_enemy_level(item.id, item.bestiary_level) if item.bestiary_level != nil && $game_party.bestiary_level[item.id] == nil
          $game_party.change_enemy_icon(item.id, item.bestiary_icon)
        end
        draw_icon($game_party.bestiary_icon[item.id], x + (((contents.width / 7) * 2) - 98), y) if $game_party.bestiary_icon[item.id] > 0
        enemy_name = item.name
        if $game_party.kill_count[item.id] == nil
          $game_party.kill_count[item] = 0
        end
        kill_count = $game_party.kill_count[item.id].to_s
      end
      draw_text(x + ((contents.width / 7) * 2), y, (contents.width / 7) * 4, line_height, enemy_name, 0)
      draw_text(x + (((contents.width / 7) * 5) + 20), y, 50, line_height, kill_count, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # * Processing When OK Button Is Pressed
  #--------------------------------------------------------------------------
  def process_ok
    if current_item_enabled?
      Sound.play_ok
      Input.update
      deactivate
      call_ok_handler
    else
      Sound.play_buzzer
    end
  end
end

#==============================================================================
# ** Window_Completion
#------------------------------------------------------------------------------
#  This window shows how much of the Bestiary you have completed with a
#  percent.
#==============================================================================

class Window_Completion < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(line_number = 2)
    super(0, 0, Graphics.width, fitting_height(line_number))
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    contents.font.size = 32
    if FantasyBestiary::Completion_Percent
      percent = (100*$game_party.enemies_found/$game_party.enemies_total) + $game_party.completion_bonus
      percent = $game_variables[FantasyBestiary::Completion_Variable] if FantasyBestiary::Completion_Variable > 0
      text = sprintf(FantasyBestiary::Completion_Name + "%1.0f%%", percent)
    else
      found = $game_party.enemies_found.to_s
      found = $game_variables[FantasyBestiary::Completion_Variable] if FantasyBestiary::Completion_Variable > 0
      total = $game_party.enemies_total.to_s
      text = FantasyBestiary::Completion_Name + found + "/" + total
    end
    if FantasyBestiary::Second_Tracker
      @width = (contents.width / 2)
      draw_text(0, 0, @width, contents.height, text, FantasyBestiary::Completion_Align)
    else
      draw_text(0, 0, contents.width, contents.height, text, FantasyBestiary::Completion_Align)
    end
    if FantasyBestiary::Second_Tracker
      if FantasyBestiary::Second_Tracker_Percent
        percent = (100*$game_party.enemies_found/$game_party.enemies_total) + $game_party.completion_bonus
        percent = $game_variables[FantasyBestiary::Second_Tracker_Variable] if FantasyBestiary::Second_Tracker_Variable > 0
        text = sprintf(FantasyBestiary::Second_Tracker_Name + "%1.0f%%", percent)
      else
        found = $game_party.enemies_found.to_s
        found = $game_variables[FantasyBestiary::Second_Tracker_Variable] if FantasyBestiary::Second_Tracker_Variable > 0
        total = $game_party.enemies_total.to_s
        text = FantasyBestiary::Second_Tracker_Name + found + "/" + total
      end
      draw_text(@width, 0, @width, contents.height, text, FantasyBestiary::Completion_Align)
    end
  end
end

#==============================================================================
# ** Window_EnemyHorzList
#------------------------------------------------------------------------------
#  This window displays a horizontal list of enemies on an enemy's page.
#==============================================================================

class Window_EnemyHorzList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width, window_height)
    @data = []
    @width = width
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    return 1
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # * Get Spacing for Items Arranged Side by Side
  #--------------------------------------------------------------------------
  def spacing
    return 8
  end
  #--------------------------------------------------------------------------
  # * Calculate Width of Window Contents
  #--------------------------------------------------------------------------
  def contents_width
    (item_width + spacing) * item_max - spacing
  end
  #--------------------------------------------------------------------------
  # * Calculate Height of Window Contents
  #--------------------------------------------------------------------------
  def contents_height
    item_height
  end
  #--------------------------------------------------------------------------
  # * Get Leading Digits
  #--------------------------------------------------------------------------
  def top_col
    ox / (item_width + spacing)
  end
  #--------------------------------------------------------------------------
  # * Set Leading Digits
  #--------------------------------------------------------------------------
  def top_col=(col)
    col = 0 if col < 0
    self.ox = col * (item_width + spacing)
  end
  #--------------------------------------------------------------------------
  # * Get Trailing Digits
  #--------------------------------------------------------------------------
  def bottom_col
    top_col + col_max - 1
  end
  #--------------------------------------------------------------------------
  # * Set Trailing Digits
  #--------------------------------------------------------------------------
  def bottom_col=(col)
    self.top_col = col - (col_max - 1)
  end
  #--------------------------------------------------------------------------
  # * Scroll Cursor to Position Within Screen
  #--------------------------------------------------------------------------
  def ensure_cursor_visible
    self.top_col = index if index < top_col
    self.bottom_col = index if index > bottom_col
  end
  #--------------------------------------------------------------------------
  # * Get Rectangle for Displaying Items
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index * (item_width + spacing)
    rect.y = 0
    rect
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Right
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
      select((index + 1) % item_max)
      if !enable?(item)
        cursor_right
      end
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Left
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
      select((index - 1 + item_max) % item_max)
      if !enable?(item)
        cursor_left
      end
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Down
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Move Mouse Cursor
  #--------------------------------------------------------------------------
  def mouse_update_cursor(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Mouse Update
  #--------------------------------------------------------------------------
  def update_mouse(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Up
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Move Cursor One Page Down
  #--------------------------------------------------------------------------
  def cursor_pagedown
  end
  #--------------------------------------------------------------------------
  # * Move Cursor One Page Up
  #--------------------------------------------------------------------------
  def cursor_pageup
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item_id
    @data[index].id
  end
  #--------------------------------------------------------------------------
  # * Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    item.is_a?(RPG::Enemy) && !$game_party.enemies_hidden.include?(item.id)
  end
  #--------------------------------------------------------------------------
  # * Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    $game_party.enemies_revealed.include?(item.id)
  end
  #--------------------------------------------------------------------------
  # * Create Item List
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $data_enemies.select {|item| include?(item)}
    @data.push(nil) if include?(nil)
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index($game_party.last_item.object) || 0)
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    x = 0
    y = index / col_max  * 24
    item = @data[index]
    if item 
      text = sprintf("%01d", index + 1).to_s  + ". "
      text = sprintf("%02d", index + 1).to_s  + ". " if $game_party.enemies_total >= 10
      text = sprintf("%03d", index + 1).to_s  + ". " if $game_party.enemies_total >= 100
      if $game_party.bestiary_icon[item.id] != nil
        draw_icon($game_party.bestiary_icon[item.id], index * @width - 16 * index, 0) if $game_party.bestiary_icon[item.id] > 0
      end
      draw_text(item_rect_for_text(index), text + item.name, 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
end

#==============================================================================
# ** Window_BestiaryStatusBase
#------------------------------------------------------------------------------
#  The base window for the various status pages for the selected enemy.
#==============================================================================

class Window_BestiaryStatusBase < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
  end
  #--------------------------------------------------------------------------
  # * Draw Text with Control Characters
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  #--------------------------------------------------------------------------
  # * Calculate Line Height
  #     restore_font_size : Return to original font size after calculating
  #--------------------------------------------------------------------------
  def calc_line_height(text, restore_font_size = true)
    result = [@smline_height, contents.font.size].max
    last_font_size = contents.font.size
    text.slice(/^.*$/).scan(/\e[\{\}]/).each do |esc|
      make_font_bigger  if esc == "\e{"
      make_font_smaller if esc == "\e}"
      result = [result, contents.font.size].max
    end
    contents.font.size = last_font_size if restore_font_size
    result
  end
  #--------------------------------------------------------------------------
  # * Character Processing
  #     c    : Characters
  #     text : A character string buffer in drawing processing (destructive)
  #     pos  : Draw position {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_character(c, text, pos)
    case c
    when "\n"   # New line
      process_new_line(text, pos)
      @dy += @smline_height
    when "\f"   # New page
      process_new_page(text, pos)
    when "\e"   # Control character
      process_escape_character(obtain_escape_code(text), text, pos)
    else        # Normal character
      process_normal_character(c, pos)
    end
  end
  #--------------------------------------------------------------------------
  # * Normal Character Processing
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    if @toggletext == true
      text_width = text_size(c).width
      draw_text(pos[:x], pos[:y], text_width * 1.2, pos[:height], c)
      pos[:x] += (text_width * 0.75)
    else
      text_width = text_size(c).width
      draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
      pos[:x] += text_width
    end
  end
  #--------------------------------------------------------------------------
  # * Icon Drawing Process by Control Characters
  #--------------------------------------------------------------------------
  def process_draw_icon(icon_index, pos)
    draw_icon(icon_index, pos[:x], pos[:y])
    pos[:x] += @icon_size
  end
  #--------------------------------------------------------------------------
  # * Draw Horizontal Line
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + @smline_height / 4 - 2
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
    @dy += @smline_height / 4 + 2 #- 2
  end
  #--------------------------------------------------------------------------
  # * Get Color of Horizontal Line
  #--------------------------------------------------------------------------
  def line_color
    color = normal_color
    color.alpha = FantasyBestiary::Horz_Line_Opac
    color
  end
  #--------------------------------------------------------------------------
  # * Draw Icon
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    target = Rect.new(x , y, @icon_size, @icon_size)
    contents.stretch_blt(target, bitmap, rect)
  end
  #--------------------------------------------------------------------------
  # * Draw Number of Defeated
  #--------------------------------------------------------------------------
  def draw_defeated(dx, dy, dw)
    change_color(normal_color)
    draw_text_ex(dx, dy, FantasyBestiary::Defeated)
    draw_text(dx + 120, dy, contents.width - 120, @smline_height + 2, $game_party.kill_count[@item.id], 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Level
  #--------------------------------------------------------------------------
  def draw_level(dx, dy, dw)
    change_color(system_color)
    draw_text_ex(dx, dy, FantasyBestiary::Level)
    change_color(normal_color)
    if $game_party.bestiary_level[@item.id] != nil
      draw_text(dx + 120, dy, contents.width - 120, @smline_height + 2, $game_party.bestiary_level[@item.id].group, 2)
    else
      draw_text(dx + 120, dy, contents.width - 120, @smline_height + 2, "???", 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw HP
  #--------------------------------------------------------------------------
  def draw_hp(dx, dy, dw)
    change_color(system_color)
    draw_text(dx, dy, 120, @smline_height + 2, Vocab::hp, 0)
    change_color(normal_color)
    if !@item.hide_hp
      draw_text(dx + 120, dy, contents.width - 120, @smline_height + 2, @item.params[0].group, 2)
    else
      draw_text(dx + 120, dy, contents.width - 120, @smline_height + 2, "???", 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw MP
  #--------------------------------------------------------------------------
  def draw_mp(dx, dy, dw)
    change_color(system_color)
    draw_text(dx, dy, 120, @smline_height + 2, Vocab::mp, 0)
    change_color(normal_color)
    if !@item.hide_mp
      draw_text(dx + 120, dy, contents.width - 120, @smline_height + 2, @item.params[1].group, 2)
    else
      draw_text(dx + 120, dy, contents.width - 120, @smline_height + 2, "???", 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw other Stats
  #--------------------------------------------------------------------------
  def draw_stats(dx, dy)
    FantasyBestiary::Stats_To_Display.times {|i| draw_enemy_param(dx, dy + @smline_height * i, i + 2) }
  end
  #--------------------------------------------------------------------------
  # * Draw Parameters
  #--------------------------------------------------------------------------
  def draw_enemy_param(x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 120, @smline_height + 2, Vocab::param(param_id))
    change_color(normal_color)
    if !@item.hide_stats
      draw_text(x + 120, y, contents.width - 120, @smline_height + 2, @item.params[(param_id)].group, 2)
    else
      draw_text(x + 120, y, contents.width - 120, @smline_height + 2, "???", 2)
    end
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Exp
  #--------------------------------------------------------------------------
  def draw_exp(dx, dy, dw)
    change_color(system_color)
    draw_text_ex(dx, dy, FantasyBestiary::Exp)
    change_color(normal_color)
    if !@item.hide_spoils
      draw_text(dx + 120, dy, contents.width - 120, @smline_height + 2, @item.exp.group, 2)
    else
      draw_text(dx + 120, dy, contents.width - 120, @smline_height + 2, "???", 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Gold
  #--------------------------------------------------------------------------
  def draw_gold(dx, dy, dw)
    change_color(system_color)
    draw_text_ex(dx, dy, FantasyBestiary::Currency)
    change_color(normal_color)
    if !@item.hide_spoils
      draw_text(dx + 120, dy, contents.width - 120, @smline_height + 2, @item.gold.group, 2)
    else
      draw_text(dx + 120, dy, contents.width - 120, @smline_height + 2, "???", 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Drop Name
  #--------------------------------------------------------------------------
  def draw_dropname(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Drops_Name
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Drops
  #--------------------------------------------------------------------------
  def draw_drops(dx, dy, dw)
    change_color(normal_color)
    if !@item.hide_spoils
    drop = 0
         for i in @item.drop_items
            next if i.kind == 0
            drop += 1 
            dropname = $data_items[i.data_id] if i.kind == 1
            dropname = $data_weapons[i.data_id] if i.kind == 2
            dropname = $data_armors [i.data_id] if i.kind == 3
            ddy = dy + (@smline_height * (drop - 1))
            if FantasyBestiary::Show_Drop_Icons
              draw_icon(dropname.icon_index, dx, ddy)
              self.contents.draw_text(dx + @icon_size, ddy, contents.width, @smline_height, " " + dropname.name.to_s, 0)
            else
              self.contents.draw_text(dx, ddy, contents.width, @smline_height, dropname.name.to_s, 0)
            end
            @dy += @smline_height
          end
          @dy -= @smline_height
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text) if drop == 0
      @dy += @smline_height if drop == 0
    else
      draw_text(dx, dy, contents.width, @smline_height + 2, "???", 0)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Type Name
  #--------------------------------------------------------------------------
  def draw_type_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Type
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Types
  #--------------------------------------------------------------------------
  def draw_types(dx, dy, dw)
    change_color(normal_color)
    if @item.type == "" || @item.type == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.type)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Location Name
  #--------------------------------------------------------------------------
  def draw_location_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Location
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Locations
  #--------------------------------------------------------------------------
  def draw_locations(dx, dy, dw)
    change_color(normal_color)
    if @item.location == "" || @item.location == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.location)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Elemental Weakness Name
  #--------------------------------------------------------------------------
  def draw_elem_weak_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Elem_Weak
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Elemental Weaknesses
  #--------------------------------------------------------------------------
  def draw_elem_weak(dx, dy, dw)
    change_color(normal_color)
    if @item.elem_weak == "" || @item.elem_weak == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.elem_weak)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Elemental Resistance Name
  #--------------------------------------------------------------------------
  def draw_elem_resist_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Elem_Resist
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Elemental Resistances
  #--------------------------------------------------------------------------
  def draw_elem_resist(dx, dy, dw)
    change_color(normal_color)
    if @item.elem_resist == "" || @item.elem_resist == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.elem_resist)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Elemental Immunity Name
  #--------------------------------------------------------------------------
  def draw_elem_immune_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Elem_Immune
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Elemental Immunities
  #--------------------------------------------------------------------------
  def draw_elem_immune(dx, dy, dw)
    change_color(normal_color)
    if @item.elem_immune == "" || @item.elem_immune == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.elem_immune)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Elemental Absorption Name
  #--------------------------------------------------------------------------
  def draw_elem_absorb_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Elem_Absorb
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Elemental Absorptions
  #--------------------------------------------------------------------------
  def draw_elem_absorb(dx, dy, dw)
    change_color(normal_color)
    if @item.elem_absorb == "" || @item.elem_absorb == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.elem_absorb)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw State Weakness Name
  #--------------------------------------------------------------------------
  def draw_state_weak_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::State_Weak
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw State Weaknesses
  #--------------------------------------------------------------------------
  def draw_state_weak(dx, dy, dw)
    change_color(normal_color)
    if @item.state_weak == "" || @item.state_weak == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.state_weak)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw State Resistance Name
  #--------------------------------------------------------------------------
  def draw_state_resist_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::State_Resist
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw State Resistances
  #--------------------------------------------------------------------------
  def draw_state_resist(dx, dy, dw)
    change_color(normal_color)
    if @item.state_resist == "" || @item.state_resist == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.state_resist)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw State Immunity Name
  #--------------------------------------------------------------------------
  def draw_state_immune_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::State_Immune
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw State Immunities
  #--------------------------------------------------------------------------
  def draw_state_immune(dx, dy, dw)
    change_color(normal_color)
    if @item.state_immune == "" || @item.state_immune == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.state_immune)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Skills 1 Title
  #--------------------------------------------------------------------------
  def draw_skills1_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Skills_1
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Skills 1
  #--------------------------------------------------------------------------
  def draw_skills1(dx, dy, dw)
    change_color(normal_color)
    if @item.skillspg1 == "" || @item.skillspg1 == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.skillspg1)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Skills 2 Title
  #--------------------------------------------------------------------------
  def draw_skills2_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Skills_2
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Skills 2
  #--------------------------------------------------------------------------
  def draw_skills2(dx, dy, dw)
    change_color(normal_color)
    if @item.skillspg2 == "" || @item.skillspg2 == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.skillspg2)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Skills 3 Title
  #--------------------------------------------------------------------------
  def draw_skills3_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Skills_3
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Skills 3
  #--------------------------------------------------------------------------
  def draw_skills3(dx, dy, dw)
    change_color(normal_color)
    if @item.skillspg3 == "" || @item.skillspg3 == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.skillspg3)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Long Description Title
  #--------------------------------------------------------------------------
  def draw_long_desc_title(dx, dy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Long_Desc
    draw_text_ex(dx, dy, text)
    @dy += @smline_height
  end
  #--------------------------------------------------------------------------
  # * Draw Long Description
  #--------------------------------------------------------------------------
  def draw_long_desc(dx, dy, dw)
    change_color(normal_color)
    if @item.long_desc == "" || @item.long_desc == nil
      text = FantasyBestiary::Empty_Text
      draw_text_ex(dx, dy, text)
    else
      draw_text_ex(dx, dy, @item.long_desc)
    end
    @dy += (@smline_height / 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Toggle Description
  #--------------------------------------------------------------------------
  def draw_toggle(dx, bdy, dw)
    change_color(normal_color)
    text = FantasyBestiary::Toggle_Status_Text
    draw_text_ex(dx, bdy + 4, text)
  end
end

#==============================================================================
# ** Window_BestiaryStatus
#------------------------------------------------------------------------------
#  This window displays the first status page for the selected enemy.
#==============================================================================

class Window_BestiaryStatus < Window_BestiaryStatusBase
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(dx, dy, width, height, enemyhorzlist_window)
    super(dx, dy, width, height)
    @enemyhorzlist_window = enemyhorzlist_window
    @item = nil
    @page_num = 1
    contents.clear
    reset_font_settings
    draw_enemy_info
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_item(@enemyhorzlist_window.item)
  end
  #--------------------------------------------------------------------------
  # * Update Item Window
  #--------------------------------------------------------------------------
  def update_item(item)
    return if @item == item
    @item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    reset_font_settings
    draw_enemy_info
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh2
    contents.clear
    reset_font_settings
    @page_num += 1
    @page_num = 1 if @page_num > FantasyBestiary::Pages.size
    draw_enemy_info
  end
  #--------------------------------------------------------------------------
  # * Reset Page Number Parameter
  #--------------------------------------------------------------------------
  def resetpage_num
    @page_num = 1
  end
  #--------------------------------------------------------------------------
  # * Stats Font Size
  #--------------------------------------------------------------------------
  def stat_font_size
    @smline_height = 24
    contents.font.size = 24
    @icon_size = 20
  end
  #--------------------------------------------------------------------------
  # * Title Font Size
  #--------------------------------------------------------------------------
  def title_font_size
    @smline_height = 24
    contents.font.size = 24
    @icon_size = 20
  end
  #--------------------------------------------------------------------------
  # * Text Font Size
  #--------------------------------------------------------------------------
  def text_font_size
    @smline_height = 20
    contents.font.size = 20
    @icon_size = 20
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Information
  #--------------------------------------------------------------------------
  def draw_enemy_info
    return unless @item.is_a?(RPG::Enemy)
    dx = 0
    @dy = 0
    bdy = contents.height - contents.font.size
    dw = 0
    @toggletext = false
    size = 0
    pages = FantasyBestiary::Pages
    for page in pages
      size += 1
      if size == @page_num
        for info in page
          case info
          when "Space"
            @dy += @smline_height
          when "Line"
            draw_horz_line(@dy)
          when "Kill Count"
            stat_font_size
            draw_defeated(dx, @dy, dw)
            @dy += @smline_height
          when "Level"
            stat_font_size
            draw_level(dx, @dy, dw)
            @dy += @smline_height
          when "HP"
            stat_font_size
            draw_hp(dx, @dy, dw)
            @dy += @smline_height
          when "MP"
            stat_font_size
            draw_mp(dx, @dy, dw)
            @dy += @smline_height
          when "Stats"
            stat_font_size
            draw_stats(dx, @dy)
            @dy += @smline_height
          when "Exp"
            stat_font_size
            draw_exp(dx, @dy, dw)
            @dy += @smline_height
          when "Gold"
            stat_font_size
            draw_gold(dx, @dy, dw)
            @dy += @smline_height
          when "Drop Title"
            title_font_size
            draw_dropname(dx, @dy, dw)
          when "Drop"
            text_font_size
            draw_drops(dx, @dy, dw)
          when "Type Title"
            title_font_size
            draw_type_title(dx, @dy, dw)
          when "Type"
            text_font_size
            draw_types(dx, @dy, dw)
          when "Location Title"
            title_font_size
            draw_location_title(dx, @dy, dw)
          when "Location"
            text_font_size
            draw_locations(dx, @dy, dw)
          when "Elem Weak Title"
            title_font_size
            draw_elem_weak_title(dx, @dy, dw)
          when "Elem Weak"
            text_font_size
            draw_elem_weak(dx, @dy, dw)
          when "Elem Resist Title"
            title_font_size
            draw_elem_resist_title(dx, @dy, dw)
          when "Elem Resist"
            text_font_size
            draw_elem_resist(dx, @dy, dw)
          when "Elem Immune Title"
            title_font_size
            draw_elem_immune_title(dx, @dy, dw)
          when "Elem Immune"
            text_font_size
            draw_elem_immune(dx, @dy, dw)
          when "Elem Absorb Title"
            title_font_size
            draw_elem_absorb_title(dx, @dy, dw)
          when "Elem Absorb"
            text_font_size
            draw_elem_absorb(dx, @dy, dw)
          when "State Weak Title"
            title_font_size
            draw_state_weak_title(dx, @dy, dw)
          when "State Weak"
            text_font_size
            draw_state_weak(dx, @dy, dw)
          when "State Resist Title"
            title_font_size
            draw_state_resist_title(dx, @dy, dw)
          when "State Resist"
            text_font_size
            draw_state_resist(dx, @dy, dw)
          when "State Immune Title"
            title_font_size
            draw_state_immune_title(dx, @dy, dw)
          when "State Immune"
            text_font_size
            draw_state_immune(dx, @dy, dw)
          when "Skills 1 Title"
            title_font_size
            draw_skills1_title(dx, @dy, dw)
          when "Skills 1"
            text_font_size
            draw_skills1(dx, @dy, dw)
          when "Skills 2 Title"
            title_font_size
            draw_skills2_title(dx, @dy, dw)
          when "Skills 2"
            text_font_size
            draw_skills2(dx, @dy, dw)
          when "Skills 3 Title"
            title_font_size
            draw_skills3_title(dx, @dy, dw)
          when "Skills 3"
            text_font_size
            draw_skills3(dx, @dy, dw)
          when "Long Desc Title"
            title_font_size
            draw_long_desc_title(dx, @dy, dw)
          when "Long Desc"
            text_font_size
            draw_long_desc(dx, @dy, dw)
          end
        end
      end
    end
    @icon_size = 1
    @smline_height = 6
    contents.font.size = 6
    @toggletext = true
    draw_toggle(dx, bdy, dw) if FantasyBestiary::Pages.size > 1
  end
end

#==============================================================================
# ** Window_BestiaryPic
#------------------------------------------------------------------------------
#  This window displays the enemy's sprite as well as any battlebacks they are
#  tied to.
#==============================================================================

class Window_BestiaryPic < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(dx, dy, width, height, enemyhorzlist_window)
    super(dx, dy, width, height)
    @window_x = dx
    @window_y = dy
    @window_width = width
    @window_height = height
    @enemyhorzlist_window = enemyhorzlist_window
    @item = nil
    self.opacity = 0 if FantasyBestiary::Battleback_Full_Screen
    self.back_opacity = 0 if FantasyBestiary::Battleback_Full_Screen
    refresh
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_item(@enemyhorzlist_window.item)
  end
  #--------------------------------------------------------------------------
  # * Get Standard Padding Size
  #--------------------------------------------------------------------------
  def standard_padding
    return FantasyBestiary::Enemy_Picture_Padding
  end
  #--------------------------------------------------------------------------
  # * Update Item Window
  #--------------------------------------------------------------------------
  def update_item(item)
    return if @item == item
    @item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    clear_sprite if @enemypic != nil
    reset_font_settings
    draw_battleback1
    draw_battleback2
    draw_enemy_sprite
  end
  #--------------------------------------------------------------------------
  # *  Enemy Battleback 1
  #--------------------------------------------------------------------------
  def draw_battleback1
    if FantasyBestiary::Default_Battleback1 == ""
      return unless @item.is_a?(RPG::Enemy) && @item.battleback1 != nil
    end
    return unless @item.is_a?(RPG::Enemy)
    if FantasyBestiary::Battleback_Full_Screen
      @bb1viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    else
      @bb1w_x = @window_x + (FantasyBestiary::Enemy_Picture_Padding)
      @bb1w_y = @window_y + (FantasyBestiary::Enemy_Picture_Padding)
      @bb1w_width = @window_width - (FantasyBestiary::Enemy_Picture_Padding * 2)
      @bb1w_height = @window_height - (FantasyBestiary::Enemy_Picture_Padding * 2)
      @bb1viewport = Viewport.new(@bb1w_x, @bb1w_y, @bb1w_width, @bb1w_height)
    end
    @bb1viewport.z = 1
    @bb1viewport.z = 1000 if !FantasyBestiary::Battleback_Full_Screen
    @bb1pic = Sprite.new(@bb1viewport)
    @dbb1pic = FantasyBestiary::Default_Battleback1
    @dbb1pic = @item.battleback1 if @item.battleback1 != nil
    @bb1pic.bitmap = Cache.battleback1(@dbb1pic)
    x = @bb1viewport.rect.width / 2
    y = @bb1viewport.rect.height / 2
    bbx = @bb1pic.bitmap.width / 2
    bby = @bb1pic.bitmap.height / 2
    @bb1pic.x = x - bbx
    @bb1pic.y = y - bby
    @bb1pic.x += @item.bb_x_offset if !FantasyBestiary::Battleback_Full_Screen
    @bb1pic.y += @item.bb_y_offset if !FantasyBestiary::Battleback_Full_Screen
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Battleback 2
  #--------------------------------------------------------------------------
  def draw_battleback2
    if FantasyBestiary::Default_Battleback2 == ""
      return unless @item.is_a?(RPG::Enemy) && @item.battleback2 != nil
    end
    return unless @item.is_a?(RPG::Enemy)
    if FantasyBestiary::Battleback_Full_Screen
      @bb2viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    else
      @bb2w_x = @window_x + (FantasyBestiary::Enemy_Picture_Padding)
      @bb2w_y = @window_y + (FantasyBestiary::Enemy_Picture_Padding)
      @bb2w_width = @window_width - (FantasyBestiary::Enemy_Picture_Padding * 2)
      @bb2w_height = @window_height - (FantasyBestiary::Enemy_Picture_Padding * 2)
      @bb2viewport = Viewport.new(@bb2w_x, @bb2w_y, @bb2w_width, @bb2w_height)
    end
    @bb2viewport.z = 2
    @bb2viewport.z = 1001 if !FantasyBestiary::Battleback_Full_Screen
    @bb2pic = Sprite.new(@bb2viewport)
    @dbb2pic = FantasyBestiary::Default_Battleback2
    @dbb2pic = @item.battleback2 if @item.battleback2 != nil
    @bb2pic.bitmap = Cache.battleback2(@dbb2pic)
    x = @bb2viewport.rect.width / 2
    y = @bb2viewport.rect.height / 2
    bbx = @bb2pic.bitmap.width / 2
    bby = @bb2pic.bitmap.height / 2
    @bb2pic.x = x - bbx
    @bb2pic.y = y - bby
    @bb2pic.x += @item.bb_x_offset if !FantasyBestiary::Battleback_Full_Screen
    @bb2pic.y += @item.bb_y_offset if !FantasyBestiary::Battleback_Full_Screen
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Sprite
  #--------------------------------------------------------------------------
  def draw_enemy_sprite
    @holders = false
    return unless @item.is_a?(RPG::Enemy)
    if FantasyBestiary::Battleback_Full_Screen
      @ew_x = @window_x
      @ew_y = @window_y
      @enemyviewport = Viewport.new(@ew_x, @ew_y, Graphics.width, Graphics.height)
    else
      @ew_x = @window_x + (FantasyBestiary::Enemy_Picture_Padding)
      @ew_y = @window_y + (FantasyBestiary::Enemy_Picture_Padding)
      @ew_width = @window_width - (FantasyBestiary::Enemy_Picture_Padding * 2)
      @ew_height = @window_height - (FantasyBestiary::Enemy_Picture_Padding * 2)
      @enemyviewport = Viewport.new(@ew_x, @ew_y, @ew_width, @ew_height)
    end
    @enemyviewport.z = 3
    @enemyviewport.z = 1002 if !FantasyBestiary::Battleback_Full_Screen
    @enemypic = Sprite.new(@enemyviewport)
    if @item.bestiary_image != nil
      @enemypic.bitmap = Cache.battler(@item.bestiary_image, @item.bestiary_hue)
      ex = @enemyviewport.rect.width / 2
      ey = @enemyviewport.rect.height / 2
      ebx = @enemypic.bitmap.width / 2
      eby = @enemypic.bitmap.height / 2
    elsif $imported["BattleSymphony-HB"] && @item.holders_name != nil
      @holders = true
      @enemypic.bitmap = Cache.character(@item.holders_name)
      @cw = @enemypic.src_rect.width / 4
      @ch = @enemypic.src_rect.height / 14
      sx = @item.holders_frame * @cw
      sy = @item.holders_line * @ch
      @enemypic.src_rect.set(sx, sy, @cw, @ch)
      ebx = @enemypic.bitmap.width / 8
      eby = @enemypic.bitmap.height / 28
    else   
      @enemypic.bitmap = Cache.battler(@item.battler_name, @item.battler_hue)
      ebx = @enemypic.bitmap.width / 2
      eby = @enemypic.bitmap.height / 2
    end
    if FantasyBestiary::Battleback_Full_Screen
      ex = @window_width / 2
      ey = @window_height / 2
      @enemypic.x = ex - ebx + @item.x_offset
      @enemypic.y = ey - eby + @item.y_offset
    else
      ex = @enemyviewport.rect.width / 2
      ey = @enemyviewport.rect.height / 2
      @enemypic.x = ex - ebx + @item.x_offset
      @enemypic.y = ey - eby + @item.y_offset
    end
    @enemypic.mirror = true if @holders || @item.bestiary_mirror || FantasyBestiary::Global_Mirror
    @enemypic.mirror = false if @holders && FantasyBestiary::Global_Mirror
    @enemypic.mirror = false if @holders && @item.bestiary_mirror
    @enemypic.mirror = false if @item.bestiary_mirror && FantasyBestiary::Global_Mirror
    @enemypic.mirror = true if @holders && @item.bestiary_mirror && FantasyBestiary::Global_Mirror
  end
  #--------------------------------------------------------------------------
  # * Clear Enemy Sprite
  #--------------------------------------------------------------------------
  def clear_sprite
    @enemypic.dispose
    @bb1pic.dispose if @bb1pic != nil
    @bb2pic.dispose if @bb2pic != nil
  end
end

#==============================================================================
# ** Scene_Bestiary
#------------------------------------------------------------------------------
#  This class performs the Bestiary screen processing.
#==============================================================================

class Scene_Bestiary < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    $game_party.check_nil_values
    $game_party.hide_new_enemies_from_start
    create_help_window if FantasyBestiary::Show_Desc_Window
    create_completion_window if FantasyBestiary::Completion_Window
    create_enemylist_window
    @enemylist_window.activate
    @enemylist_window.select(0)
    create_enemyhorzlist_window
    @playing_bgm = false
    create_status_window
    create_enemypic_window
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    refresh_bgm if @old_index != @enemyhorzlist_window.index && @playing_bgm == true
  end
  #--------------------------------------------------------------------------
  # * Refresh BGM
  #--------------------------------------------------------------------------
  def refresh_bgm
    RPG::BGM.stop if @old_index == -2
    @old_index = @enemyhorzlist_window.index
    if @enemyhorzlist_window.current_item_enabled? and 
        (@name != @enemyhorzlist_window.item.bestiary_bgm or
         @volume != @enemyhorzlist_window.item.bgm_volume or
         @pitch != @enemyhorzlist_window.item.bgm_pitch)
         @name = @enemyhorzlist_window.item.bestiary_bgm
         @volume = @enemyhorzlist_window.item.bgm_volume
         @pitch = @enemyhorzlist_window.item.bgm_pitch
    end
    RPG::BGM.new(@name, @volume, @pitch).play rescue nil
    if @name == nil && FantasyBestiary::Replay_Map_BGM && @old_index != -3
      @map_bgm.replay
      @map_bgs.replay
    else if @name == nil && !FantasyBestiary::Replay_Map_BGM && @old_index != -3
      RPG::BGM.stop
    end
    end
  end
  #--------------------------------------------------------------------------
  # * Create Enemy List Window
  #--------------------------------------------------------------------------
  def create_enemylist_window
    wh = Graphics.height - @completion_window.height if FantasyBestiary::Completion_Window
    wh = Graphics.height if !FantasyBestiary::Completion_Window
    @enemylist_window = Window_EnemyList.new(0, 0, Graphics.width, wh)
    @enemylist_window.viewport = @viewport
    @enemylist_window.set_handler(:ok, method(:on_enemylist_ok))
    @enemylist_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * Create Enemy Horz List Window
  #--------------------------------------------------------------------------
  def create_enemyhorzlist_window
    ww = Graphics.width - FantasyBestiary::Status_Page_Width
    @enemyhorzlist_window = Window_EnemyHorzList.new(0, 0, ww) 
    @enemyhorzlist_window.viewport = @viewport
    @enemyhorzlist_window.help_window = @help_window
    @enemyhorzlist_window.set_handler(:ok, method(:on_enemyhorzlist_ok)) if FantasyBestiary::Pages.size > 1
    @enemyhorzlist_window.set_handler(:cancel, method(:on_enemyhorzlist_cancel))
    @enemyhorzlist_window.hide.deactivate
  end
  #--------------------------------------------------------------------------
  # * Create Status Window
  #--------------------------------------------------------------------------
  def create_status_window
    wx = Graphics.width - FantasyBestiary::Status_Page_Width
    ww = FantasyBestiary::Status_Page_Width
    wh = Graphics.height - @help_window.height if FantasyBestiary::Show_Desc_Window
    wh = Graphics.height if !FantasyBestiary::Show_Desc_Window
    @status_window = Window_BestiaryStatus.new(wx, 0, ww, wh, @enemyhorzlist_window)
    @status_window.viewport = @viewport
    @status_window.hide
  end
  #--------------------------------------------------------------------------
  # * Create Enemy Picture Window
  #--------------------------------------------------------------------------
  def create_enemypic_window
    wy = @enemyhorzlist_window.y + @enemyhorzlist_window.height
    ww = @enemyhorzlist_window.width
    wh = Graphics.height - wy - @help_window.height if FantasyBestiary::Show_Desc_Window
    wh = Graphics.height - wy if !FantasyBestiary::Show_Desc_Window
    @enemypic_window = Window_BestiaryPic.new(0, wy, ww, wh, @enemyhorzlist_window)
    @enemypic_window.viewport = @viewport
    @enemypic_window.hide
  end
  #--------------------------------------------------------------------------
  # * Create Help Window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.y = Graphics.height - @help_window.height
    @help_window.viewport = @viewport
    @help_window.hide
  end
  #--------------------------------------------------------------------------
  # * Create Completion Window
  #--------------------------------------------------------------------------
  def create_completion_window
    @completion_window = Window_Completion.new
    @completion_window.y = Graphics.height - @completion_window.height
    @completion_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * Enemy List [OK]
  #--------------------------------------------------------------------------
  def on_enemylist_ok
    @selected = @enemylist_window.index
    @enemylist_window.hide.deactivate
    @completion_window.hide if FantasyBestiary::Completion_Window
    @enemyhorzlist_window.show.activate
    @enemyhorzlist_window.select(@selected)
    @status_window.show
    @enemypic_window.show
    @help_window.show if FantasyBestiary::Show_Desc_Window
    @playing_bgm = true
    @map_bgm = RPG::BGM.last
    @map_bgs = RPG::BGS.last
    refresh_bgm
  end
  #--------------------------------------------------------------------------
  # * Enemy Horz List [OK]
  #--------------------------------------------------------------------------
  def on_enemyhorzlist_ok
    @status_window.refresh2
    @enemyhorzlist_window.activate
  end
  #--------------------------------------------------------------------------
  # * Enemy Horz List [Cancel]
  #--------------------------------------------------------------------------
  def on_enemyhorzlist_cancel
    @selected = @enemyhorzlist_window.index
    @enemyhorzlist_window.unselect
    @enemyhorzlist_window.hide.deactivate
    @status_window.hide
    @status_window.resetpage_num
    @old_index = -2
    @old_index = -3 if @name == nil && FantasyBestiary::Replay_Map_BGM
    @playing_bgm = false
    @enemypic_window.clear_sprite
    @enemypic_window.hide
    @help_window.hide if FantasyBestiary::Show_Desc_Window
    @completion_window.show if FantasyBestiary::Completion_Window
    @enemylist_window.show.activate
    @enemylist_window.select(@selected)
    @map_bgm.replay
    @map_bgs.replay
  end
end