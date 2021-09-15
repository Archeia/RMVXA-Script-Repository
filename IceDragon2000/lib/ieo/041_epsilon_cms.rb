#==============================================================================#
# ** IEO(Icy Engine Omega) - Epsilon CMS
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (Message System)
# ** Script Type   : Custom Message System
# ** Date Created  : 03/07/2011
# ** Date Modified : 07/09/2011
# ** Script Tag    : IEO-041(Epsilon CMS)
# ** Difficulty    : Easy, Medium
# ** Version       : 1.2
# ** IEO ID        : 041
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
# Some code was taken from YEM (Created by Yanfly)
# Please credit him also if you use this script.
#
# You may:
# Edit and Adapt this script as long you credit aforementioned author(s).
#
# You may not:
# Claim this as your own work, or redistribute without the consent of the author.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#-*--------------------------------------------------------------------------*-#
#
# >O< YES I HAS FINALLY DONE EEEEEEET.
# I has my own Message System NOAH!!! :3
# Nothing much to say, just your everyday message system.
#
# Use IEO041-Primary to jump to the configuration part.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTRUCTIONS
#-*--------------------------------------------------------------------------*-#
#
# So yeah, there are a few switches and variables that need setting up.
#
#-*--------------------------------------------------------------------------*-#
# // Text Commands
#-*--------------------------------------------------------------------------*-#
# \v[n]      (Default Variable, replaces with the value of variable n)
# \n[n]      (Default Name, replaces with the name of actor n)
# \c[n]      (Default Color Command, changes the text color to n)
#
# \wt[n]     (Wait Command, sets the text to wait n frames (60frames == 1 second))
#
# \di[n]     (Draw Icon Comand, draw icon n)
# \dwi[n]    (Draw Weapon Icon Comand, draw weapon n's icon)
# \dai[n]    (Draw Armor Icon Comand, draw armor n's icon)
# \dii[n]    (Draw Item Icon Comand, draw item n's icon)
# \dski[n]   (Draw Skill Icon Comand, draw skill n's icon)
# \dsti[n]   (Draw State Icon Comand, draw state n's icon)
#
# \fs[n]     (Font Size Command, sets the font size to n, 0 will reset it)
# \fn[s]     (Font Name Command, sets the font to s)
# \fb        (Font Bold Command, sets the font to bold)
# \fi        (Font Italic Command, sets the font to italic)
# \fh        (Font Shadow Command, sets the font to shadowing)
#
# \al[n]     (Align Command, changes the alignment to n (0 - left, 1 - center, 2 - right))
#
# \pn[n]     (Party Member Name, replaces with party member n's name)
# \wn[n]     (Weapon Name, replaces with weapon n's name)
# \an[n]     (Armor Name, replaces with armor n's name)
# \in[n]     (Item Name, replaces with item n's name)
# \en[n]     (Enemy Name, replaces with enemy n's name)
# \skn[n]    (Skill Name, replaces with skill n's name)
# \stn[n]    (Weapon Name, replaces with weapon n's name)
#
# \dpf[n]    (Draw Party Member Face, draws party member n's face)
# \daf[n]    (Draw Actor Face, draws actor n's face)
#
# \voc[s]    (Allows you to get Vocab.'s' commands, like Vocab.gold)
#
# Not too sure about these:
# \p[n]      (Shows the message window over n event's head (-2 disable, -1 Current event, 0 Player, 1 and above all other events))
#
# \ani[n, n2]   (Animation n2, on n event)
# \wani[n, n2]  (Weapon Animation n2, on n event)
# \iani[n, n2]  (Item Animation n2, on n event)
# \skani[n, n2] (Skill Animation n2, on n event)
#
# Choice Window Only
# \li        (breaks the text unto a new line)
#
#
# Script Commands
#   clear_extra_choices()
#     Call this before doing any choice related commands
#   add_choice("text")
#     Adds a new choice to the choice window list
#   set_multi_line(n)
#     Changes the number of lines a command takes, default 1
#   set_choice_columns(n)
#     Changes the number of columns in the choice window.
#
# NOTE*
#   You have to reset all of these at the end by yourself @___@ Sorry about that
#     clear_extra_choices()
#     set_multi_line(1)
#     set_choice_columns(1)
#   To save yourself the trouble creating a common event for this would be nice.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Overwrites large portions of the Default Message System.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#-*--------------------------------------------------------------------------*-#
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
#
#-*--------------------------------------------------------------------------*-#
# Below
#   Materials
#
# Above
#   Main
#   Anything that makes changes to:
#   Window_Message (class)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   Game_Message
#   Game_Interpreter
#   Window_Message
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  03/07/2011 - V1.0  Started Script and Finished Initial Script
#  05/11/2011 - V1.0  Code rearrangement
#  06/07/2011 - V1.1  Added Choice Window from (IRS002)
#  07/09/2011 - V1.2  Fixed Input Pause problem when changing the max line
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Noting at the moment.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
$imported ||= {}
$imported["IEO-EpsilonCMS"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
$ieo_script = {} if $ieo_script == nil
$ieo_script[[41, "EpsilonCMS"]] = 1.2
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# IEO::EPSILON - IEO041-Primary
#==============================================================================#
module IEO
  module EPSILON
#==============================================================================#
#                      Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#

    VARIABLES = {
      :max_line => 10, # // Used to manipulate total rows of the message window
      :event_id => 11, # // Stores the current event's id
      :x        =>  8, # // Controls the message window's x Position
      :width    => 12, # // Controls the message window's width
      :height   => 13, # // ?___? I don't exactly remember why this is still here...
      :overevent=> 14, # // Used with the mini window popping
    } # DO NOT REMOVE
    # // Switches
    SWITCHES = {
      :face_window => 13, # // Switch for Enabling the Face Window
    }

    TEXT_SOUND = [ "XINFX-Pickup01", 60, 100 ] #[ "SYS-Click001", 80, 100 ]
    TEXT_SOUND_VARIANCE = 0
    PAUSE_SOUND= [ "XINFX-Interface0E002", 100, 100 ]

    # // I was too lazy to add these to the VARIABLES Hash so... meh..
    # // Copied from IRS002 - MultiChoice
    # // Game Variables
    CHOICE_SIZE_VARIABLE      = 15 # // An Autoset Variable, from the choices size
    CHOICE_VARIABLE           = 16 # // An Autoset Variable, from the choices index, starts from 1
    CHOICE_WINX_VARIABLE      = 17 # // Variable for the X Position of the Choice Window
    CHOICE_WINY_VARIABLE      = 18 # // Variable for the Y Position of the Choice Window
    CHOICE_WINWIDTH_VARIABLE  = 19 # // Variable for the Width of the Choice Window
    CHOICE_WINHEIGHT_VARIABLE = 20 # // Variable for the Height of the Choice Window
    # // Switches
    USE_CHOICE_WINDOW         = 11 # // Switch for enabling the Choice Window
    OVERRIDE_NORMAL_CHOICES   = 12 # // Switch for Overriding Normal Choices
#==============================================================================#
#                        End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# Game_Interpreter
#==============================================================================#
class Game_Interpreter ; attr_accessor :event_id end

#==============================================================================#
# Window_Message - Class Method
#==============================================================================#
class Window_Message < Window_Selectable

  def self.convert_regex_characters(text)
    gp = $game_party
    ga = $game_actors
    # ----------------------------------------------------------------- #
    # // Defaults
    # // Variable Substitute1
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    # // Variable Substitute2
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    # // Actor Name
    text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    # // Color Text
    text.gsub!(/\\C\[([0-9]+)\]/i) { "\x01[#{$1}]" }
    # // Show Gold Window
    text.gsub!(/\\G/)              { "\x02" }
    text.gsub!(/\\\./)             { "\x03" }
    text.gsub!(/\\\|/)             { "\x04" }
    text.gsub!(/\\!/)              { "\x05" }
    text.gsub!(/\\>/)              { "\x06" }
    text.gsub!(/\\</)              { "\x07" }
    text.gsub!(/\\\^/)             { "\x08" }
    text.gsub!(/\\\\/)             { "\\" }
    # ----------------------------------------------------------------- #
    # // Extended
    # // Wait
    text.gsub!(/\\WT\[([0-9]+)\]/i)   { "\x09[#{$1}]" }

    # // Draw_Icon
    text.gsub!(/\\DI\[([0-9]+)\]/i)   { "\x10[#{$1}]" }
    # // Draw Weapon Icon
    text.gsub!(/\\DWI\[([0-9]+)\]/i)  { "\x10[#{$data_weapons[$1.to_i].icon_index}]" }
    # // Draw Armor Icon
    text.gsub!(/\\DAI\[([0-9]+)\]/i)  { "\x10[#{$data_armors[$1.to_i].icon_index}]" }
    # // Draw Item Icon
    text.gsub!(/\\DII\[([0-9]+)\]/i)  { "\x10[#{$data_items[$1.to_i].icon_index}]" }
    # // Draw Skill Icon
    text.gsub!(/\\DSKI\[([0-9]+)\]/i) { "\x10[#{$data_skills[$1.to_i].icon_index}]" }
    # // Draw State Icon
    text.gsub!(/\\DSTI\[([0-9]+)\]/i) { "\x10[#{$data_states[$1.to_i].icon_index}]" }

    # // Font Size
    text.gsub!(/\\FS\[(\d+)\]/i)   { "\x11[#{$1}]" }
    # // Font Name
    text.gsub!(/\\FN\[(.*?)\]/i)   { "\x12[#{$1}]" }
    # // Font Bold
    text.gsub!(/\\FB/i)            { "\x13" }
    # // Font Italic
    text.gsub!(/\\FI/i)            { "\x14" }
    # // Font Shadowed
    text.gsub!(/\\FH/i)            { "\x15" }

    # // Aligment Change
    text.gsub!(/\\AL\[(\d+)\]/i)   { "\x16[#{$1}]" }
    # ----------------------------------------------------------------- #
    # // Subs
    # // Party Member Name
    text.gsub!(/\\PN\[([0-9]+)\]/i)  { $game_party.members[$1.to_i].name }
    # // Weapon Name
    text.gsub!(/\\WN\[([0-9]+)\]/i)  { $data_weapons[$1.to_i].name }
    # // Armor Name
    text.gsub!(/\\AN\[([0-9]+)\]/i)  { $data_armors[$1.to_i].name }
    # // Item Name
    text.gsub!(/\\IN\[([0-9]+)\]/i)  { $data_items[$1.to_i].name }
    # // Enemy Name
    text.gsub!(/\\EN\[([0-9]+)\]/i)  { $data_enemies[$1.to_i].name }
    # // Skill Name
    text.gsub!(/\\SKN\[([0-9]+)\]/i) { $data_skills[$1.to_i].name }
    # // State Name
    text.gsub!(/\\STN\[([0-9]+)\]/i) { $data_states[$1.to_i].name }

    # // Script Sub !!! Unstable !!!
    text.gsub!(/\\SCR\[(.*)\]/i)     { eval($1) }
    # // Vocab - Prototype
    text.gsub!(/\\VOC\[(\w+)\]/i)    { Vocab.send($1) }
    # ----------------------------------------------------------------- #
    # // Message Window Operations
    # // Draw_Face
    text.gsub!(/\\DF\[(.*),[ ]*([0-9]+)\]/i)   { "\x17[#{$1}, #{$2}]" }
    # // Draw Party Face
    text.gsub!(/\\DPF\[([0-9]+)\]/i)   {
      "\x17[#{gp.members[$1.to_i].face_name}, #{gp.members[$1.to_i].face_index}]" }
    # // Draw Actor Face
    text.gsub!(/\\DAF\[([0-9]+)\]/i)   {
      "\x17[#{ga[$1.to_i].face_name}, #{ga[$1.to_i].face_index}]" }
    # ----------------------------------------------------------------- #
    # // External Operations
    # // Balloon
    text.gsub!(/\\BALL\[([\+\-]?\d+)[ ],[ ]([0-9]+)\]/i) { "\x82[#{$1}, #{$2}]" }

    # // Animation
    text.gsub!(/\\ANI\[([\+\-]?\d+)[ ],[ ]([0-9]+)\]/i)  { "\x83[#{$1}, #{$2}]" }
    # // Weapon Animation
    text.gsub!(/\\WANI\[([\+\-]?\d+)[ ],[ ]([0-9]+)\]/i) { "\x83[#{$1}, #{$data_weapons[$2.to_i].animation_id}]" }
    # // Item Animation
    text.gsub!(/\\IANI\[([\+\-]?\d+)[ ],[ ]([0-9]+)\]/i) { "\x83[#{$1}, #{$data_items[$2.to_i].animation_id}]" }
    # // Skill Animation
    text.gsub!(/\\SKANI\[([\+\-]?\d+)[ ],[ ]([0-9]+)\]/i){ "\x83[#{$1}, #{$data_skills[$2.to_i].animation_id}]" }

    # // Pop Up
    text.gsub!(/\\P\[([\+\-]?\d+)\]/i) do
      id = $1.to_i
      case id
      when -1
        eid = $game_map.interpreter.event_id
      else
        eid = id
      end
      $game_variables[::IEO::EPSILON::VARIABLES[:overevent]] = eid ;
      $game_message.window_need_reset = true
      ""
    end
    # ----------------------------------------------------------------- #
    # // REGEX Complete
    # ----------------------------------------------------------------- #
    #// Return Text
    return text
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_message
  #--------------------------------------------------------------------------#
  def finish_message
    if $game_message.choice_max > 0
      start_choice
    elsif $game_message.num_input_variable_id > 0
      start_number_input
    elsif @pause_skip
      terminate_message
    else
      self.pause = true
    end
    $game_message.pause_sound.play
    @wait_count = 10
    @text = nil
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_message
  #--------------------------------------------------------------------------#
  def update_message()
    loop do
      c = @text.slice!(/./m)            # Get next text character
      case c
      when nil                          # There is no text that must be drawn
        finish_message                  # Finish update
        break
      when "\x00"                       # New line
        new_line
        if @line_count >= max_line()      # If line count is maximum
          unless @text.empty?           # If there is more
            self.pause = true           # Insert number input
            break
          end
        end
      # // Defaults
      # \C[n]  (text character color change)
      when "\x01"
        @text.sub!(/\[([0-9]+)\]/, "")
        contents.font.color = text_color($1.to_i)
        next
      # \G  (gold display)
      when "\x02"
        @gold_window.refresh
        @gold_window.open
      # \.  (wait 1/4 second)
      when "\x03"
        @wait_count = 15
        break
      # \|  (wait 1 second)
      when "\x04"
        @wait_count = 60
        break
      # \!  (Wait for input)
      when "\x05"
        $game_message.pause_sound.play
        self.pause = true
        break
      # \>  (Fast display ON)
      when "\x06"
        @line_show_fast = true
      # \<  (Fast display OFF)
      when "\x07"
        @line_show_fast = false
      # \^  (No wait for input)
      when "\x08"
        @pause_skip = true
      # // Extended
      # \wt[n]  (Wait n frames)
      when "\x09"
        @text.sub!(/\[([0-9]+)\]/, "")
        @wait_count = $1.to_i
        break
      # \di[n]  (Draw Icon n)
      when "\x10"
        @text.sub!(/\[([0-9]+)\]/, "")
        draw_icon($1.to_i, @contents_x, @contents_y)
        @contents_x += 24
        next
      # \fs Font Size Change
      when "\x11"
        @text.sub!(/\[(\d+)\]/, "")
        size = $1.to_i
        if size <= 0 # If 0, revert back to the default font size.
          size = Font.default_size
        end
        self.contents.font.size = size
        text_height = [size + (size / 5), WLH].max
      # \fn Font Name Change
      when "\x12"
        @text.sub!(/\[(.*?)\]/, "")
        name = $1.to_s
        if name == "0" # If 0, revert back to the default font.
          name = Font.default_name
        end
        self.contents.font.name = name
      # \fb Font bold
      when "\x13"
        self.contents.font.bold = self.contents.font.bold ? false : true
      # \fi Font italic
      when "\x14"
        self.contents.font.italic = self.contents.font.italic ? false : true
      # \fi Font shadowed
      when "\x15"
        self.contents.font.shadow = self.contents.font.shadow ? false : true
      # Alignment change, for special choice boxes only.
      when "\x16"
        @text.sub!(/\[(\d+)\]/, "")
      # \df[n]  (Draw Face n)
      when "\x17"
        @text.sub!(/\[(.*)[ ],[ ]([0-9]+)\]/, "")
        $game_message.face_name = $1
        $game_message.face_index = $2.to_i
        next
      # \ball[id, n]  (Balloon)
      when "\x82"
        @text.sub!(/\\x82\[(.*)[ ],[ ]([0-9]+)\]/, "")
        did = $2.to_i
        case $1.to_i
        when -1
          $game_map.events[current_event_id].balloon_id = did
        when 0
          $game_player.balloon_id = did
        else
          $game_map.events[$1.to_i].balloon_id = did
        end
        next
      # \ani[id, n]  (Animation)
      when "\x83"
        @text.sub!(/\\x83\[(.*)[ ],[ ]([0-9]+)\]/, "")
        did = $2.to_i
        case $1.to_i
        when -1
          $game_map.events[current_event_id].animation_id = did
        when 0
          $game_player.animation_id = did
        else
          $game_map.events[$1.to_i].animation_id = did
        end
        next
      # // Draw_Text
      else                              # Normal text character
        snd = $game_message.text_sound.clone
        var = rand([$game_message.text_sound_var,1].max)
        if rand(2) == 0
          snd.pitch -= var
        else
          snd.pitch += var
        end
        snd.play()
        contents.draw_text(@contents_x, @contents_y, 40, WLH, c)
        c_width = contents.text_size(c).width
        @contents_x += c_width
      end
      break unless @show_fast or @line_show_fast
    end
  end

end

#==============================================================================#
# Game_Message
#==============================================================================#
class Game_Message

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :window_need_reset
  attr_accessor :choice_text
  attr_accessor :multi_line_choice
  attr_accessor :choice_columns
  attr_accessor :text_sound
  attr_accessor :text_sound_var
  attr_accessor :pause_sound

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo0aa_gmsg_initialize :initialize unless $@
  def initialize()
    @choice_text       = []
    @window_need_reset = false
    @multi_line_choice = 1
    @choice_columns    = 1
    @text_sound_var    = ::IEO::EPSILON::TEXT_SOUND_VARIANCE
    @text_sound        = RPG::SE.new(*::IEO::EPSILON::TEXT_SOUND)
    @pause_sound       = RPG::SE.new(*::IEO::EPSILON::PAUSE_SOUND)
    ieo0aa_gmsg_initialize()
  end

  #--------------------------------------------------------------------------#
  # * new method :setup_variables
  #--------------------------------------------------------------------------#
  def setup_variables()
    @window_need_reset = false
    # // Default Variables
    $game_variables[::IEO::EPSILON::VARIABLES[:max_line]]      = 4
    $game_variables[::IEO::EPSILON::VARIABLES[:event_id]]      = -1
    $game_variables[::IEO::EPSILON::VARIABLES[:x]]             = 0
    $game_variables[::IEO::EPSILON::VARIABLES[:width]]         = Graphics.width
    $game_variables[::IEO::EPSILON::VARIABLES[:height]]        = 96
    $game_variables[::IEO::EPSILON::VARIABLES[:overevent]]     = -1
    # // Default Switches
    $game_switches[::IEO::EPSILON::SWITCHES[:face_window]]     = false

    # // Multi Choice Variables/Switches
    # // Game Variables
    $game_variables[::IEO::EPSILON::CHOICE_SIZE_VARIABLE]      = 0
    $game_variables[::IEO::EPSILON::CHOICE_VARIABLE]           = 0
    $game_variables[::IEO::EPSILON::CHOICE_WINX_VARIABLE]      = 0
    $game_variables[::IEO::EPSILON::CHOICE_WINY_VARIABLE]      = 0
    $game_variables[::IEO::EPSILON::CHOICE_WINWIDTH_VARIABLE]  = 256
    $game_variables[::IEO::EPSILON::CHOICE_WINHEIGHT_VARIABLE] = 256
    # // Switches
    $game_switches[::IEO::EPSILON::USE_CHOICE_WINDOW]          = false
    $game_switches[::IEO::EPSILON::OVERRIDE_NORMAL_CHOICES]    = false
  end

  #--------------------------------------------------------------------------#
  # * alias method :clear
  #--------------------------------------------------------------------------#
  alias :ieo0aa_gmsg_clear :clear unless $@
  def clear()
    #@choice_text = []
    ieo0aa_gmsg_clear()
  end

end

#==============================================================================#
# Game_Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * new method :set_cancel_index
  #--------------------------------------------------------------------------#
  def set_cancel_index(new_index) # << Need to work on this
  end

  #--------------------------------------------------------------------------#
  # * new method :clear_extra_choices
  #--------------------------------------------------------------------------#
  def clear_extra_choices()
    $game_message.choice_text.clear()
  end

  #--------------------------------------------------------------------------#
  # * new method :add_choice
  #--------------------------------------------------------------------------#
  def add_choice(text)
    $game_message.choice_text << text
  end

  #--------------------------------------------------------------------------#
  # * new method :set_multi_line
  #--------------------------------------------------------------------------#
  def set_multi_line(new_line)
    $game_message.multi_line_choice = [ new_line, 1 ].max
  end

  #--------------------------------------------------------------------------#
  # * new method :set_choice_columns
  #--------------------------------------------------------------------------#
  def set_choice_columns(new_columns)
    $game_message.choice_columns = [ new_columns, 1 ].max
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :command_101 (Show Text)
  #--------------------------------------------------------------------------#
  def command_101()
    unless $game_message.busy
      $game_message.face_name  = @params[0]
      $game_message.face_index = @params[1]
      $game_message.background = @params[2]
      $game_message.position   = @params[3]
      flow = true
      loop {
        if @list[@index].code == 101 and meet_stringing_conditions and flow
          @index += 1
        else
          break
        end
        flow = @row_check
        while @list[@index].code == 401 and meet_stringing_conditions
          $game_message.texts.push(@list[@index].parameters[0])
          @index += 1
        end }
      if @list[@index].code == 102 # Show choices
        setup_choices(@list[@index].parameters)
      elsif @list[@index].code == 103 # Number input processing
        setup_num_input(@list[@index].parameters)
      end
      set_message_waiting # Set to message wait state
    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :setup_choices
  #--------------------------------------------------------------------------#
  def setup_choices(params)
    var = $game_variables[::IEO::EPSILON::VARIABLES[:max_line]]
    rows = (var <= 0) ? 4 : var
    return unless $game_message.texts.size <= rows - params[0].size
    $game_message.choice_start = $game_message.texts.size
    $game_message.choice_max = params[0].size
    for s in params[0]
      $game_message.texts.push(s)
    end
    $game_message.choice_cancel_type = params[1]
    $game_message.choice_proc = Proc.new { |n| @branch[@indent] = n }
    @index += 1
  end

  #--------------------------------------------------------------------------#
  # * new method :meet_stringing_conditions
  #--------------------------------------------------------------------------#
  def meet_stringing_conditions()
    var = $game_variables[::IEO::EPSILON::VARIABLES[:max_line]]
    rows = (var <= 0) ? 4 : var
    @row_check = (rows > 4) ? true : false
    return true if rows > $game_message.texts.size
    return false
  end

end

#==============================================================================#
# Window_MessageFace
#==============================================================================#
class Window_MessageFace < Window_Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :face_name
  attr_accessor :face_index

  #--------------------------------------------------------------------------#
  # * super method :initialize
  #--------------------------------------------------------------------------#
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @face_name  = ""
    @face_index = 0
  end

  #--------------------------------------------------------------------------#
  # * super method :draw_face
  #--------------------------------------------------------------------------#
  def draw_face(face_name, face_index, x, y, size = 96)
    super(face_name, face_index, x, y, size)
    @face_name  = face_name
    @face_index = face_index
  end

  #--------------------------------------------------------------------------#
  # * super method :draw_face
  #--------------------------------------------------------------------------#
  def dispose()
    self.viewport.dispose unless self.viewport.nil?()
    self.viewport = nil
    super()
  end

end

#==============================================================================#
# Window_MessageChoice
#==============================================================================#
class Window_MessageChoice < Window_Selectable

  include ::IEO::EPSILON

  #--------------------------------------------------------------------------#
  # * super method :initialize
  #--------------------------------------------------------------------------#
  def initialize()
    x      = $game_variables[CHOICE_WINX_VARIABLE]
    y      = $game_variables[CHOICE_WINY_VARIABLE]
    width  = $game_variables[CHOICE_WINWIDTH_VARIABLE]
    height = $game_variables[CHOICE_WINHEIGHT_VARIABLE]
    super(x, y, width, height)
    @commands  = []
    self.index = 0
    refresh()
  end

  #--------------------------------------------------------------------------#
  # * new method :refresh
  #--------------------------------------------------------------------------#
  def refresh()
    @commands  = []
    for tx in $game_message.choice_text.clone()
      @commands += [Window_Message.convert_regex_characters(tx)]
    end
    @item_max   = @commands.size
    @column_max = $game_message.choice_columns
    @spacing    = 4
    self.x      = $game_variables[CHOICE_WINX_VARIABLE]
    self.y      = $game_variables[CHOICE_WINY_VARIABLE]
    self.width  = $game_variables[CHOICE_WINWIDTH_VARIABLE]
    self.height = $game_variables[CHOICE_WINHEIGHT_VARIABLE]
    $game_variables[CHOICE_SIZE_VARIABLE] = @item_max
    create_contents()
    for i in 0...@item_max ; draw_item(i) ; end
  end

  #--------------------------------------------------------------------------#
  # * Get rectangle for displaying items
  #     index : item number
  #--------------------------------------------------------------------------#
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = (WLH * $game_message.multi_line_choice)
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * (WLH * $game_message.multi_line_choice)
    return rect
  end

  #--------------------------------------------------------------------------#
  # * new method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled=true)
    rect = item_rect(index)
    tx = @commands[index].clone()
    align = 0; icon = 0; rect.width -= 8 ; ix = rect.x ; rect.height = 24
    texts= tx.split(/\\li/i)
    texts.each { |text|
    # \c[n]   (Text Color)
    text.gsub!(/\x01\[(\d+)\]/i) {
      self.contents.font.color = text_color($1.to_i); ""}
    # \di[n]  (Draw Icon n)
    text.gsub!(/\x10\[(\d+)\]/i) {
      icon = $1.to_i; rect.x += 24; ""}
    # \fs[n]   (Font Size n)
    text.gsub!(/\x11\[(\d+)\]/i) {
      size = $1.to_i
      if size <= 0 # If 0, revert back to the default font size.
        size = Font.default_size
      end
      self.contents.font.size = size ; "" }
    # \fn[n]   (Font Name)
    text.gsub!(/\x12\[(.*?)\]/i) {
      self.contents.font.name = $1.to_s; ""}
    # \fb      (Font Bold)
    text.gsub!(/\x13/i) {
      self.contents.font.bold = !self.contents.font.bold; ""}
    # \fi      (Font Italic)
    text.gsub!(/\x14/i) {
      self.contents.font.italic = !self.contents.font.italic; ""}
    # \fh      (Font Shadow)
    text.gsub!(/\x15/i) {
      self.contents.font.shadow = !self.contents.font.shadow; ""}
    # \al[n]   (Align)
    text.gsub!(/\x16\[(\d+)\]/i) {
      align = $1.to_i; ""}
    rect.x += 4 if icon == 0
    draw_icon(icon, ix, rect.y) if icon > 0
    self.contents.draw_text(rect, text, align)
    rect.y += WLH
    }
  end

  #--------------------------------------------------------------------------#
  # * super method :update
  #--------------------------------------------------------------------------#
  def update()
    super()
    self.x      = $game_variables[CHOICE_WINX_VARIABLE]
    self.y      = $game_variables[CHOICE_WINY_VARIABLE]
    self.width  = $game_variables[CHOICE_WINWIDTH_VARIABLE]
    self.height = $game_variables[CHOICE_WINHEIGHT_VARIABLE]
    $game_variables[CHOICE_VARIABLE] = self.index + 1
  end

end

#==============================================================================#
# Window_Message
#==============================================================================#
class Window_Message < Window_Selectable

  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias :ieo041_wmsg_initialize :initialize unless $@
  def initialize()
    ieo041_wmsg_initialize()
    create_face_window()
    @face_window.openness = 0
    self.width = Graphics.width
    self.x = 0
    self.y = Graphics.height-self.height
  end

  #--------------------------------------------------------------------------#
  # * new method :create_face_window
  #--------------------------------------------------------------------------#
  def create_face_window()
    if @face_window.nil?()
      @face_window = Window_MessageFace.new(self.x, self.y, 128, 128)
      @face_window.viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    end
    @face_window.viewport.z = 200
    @face_window.contents.clear
    name  = $game_message.face_name
    index = $game_message.face_index
    @face_window.draw_face(name, index, 0, 0)
  end

  #--------------------------------------------------------------------------#
  # * alias method :dispose
  #--------------------------------------------------------------------------#
  alias :ieo041_wmsg_dispose :dispose unless $@
  def dispose()
    ieo041_wmsg_dispose()
    # //
    @face_window.dispose unless @face_window.nil?()
  end

  #--------------------------------------------------------------------------#
  # * new method :update
  #--------------------------------------------------------------------------#
  def update
    super
    if $game_message.window_need_reset
      reset_window() ; $game_message.window_need_reset = false
    end
    update_face_window()
    update_gold_window()
    update_number_input_window()
    update_back_sprite()
    update_show_fast()
    unless @opening or @closing             # Window is not opening or closing
      if @wait_count > 0                    # Waiting within text
        @wait_count -= 1
      elsif self.pause                      # Waiting for text advancement
        input_pause
      elsif self.active                     # Inputting choice
        input_choice
      elsif @number_input_window.visible    # Inputting number
        input_number
      elsif @text != nil                    # More text exists
        update_message                        # Update message
      elsif continue?                       # If continuing
        start_message                         # Start message
        open                                  # Open window
        $game_message.visible = true
      else                                  # If not continuing
        close                                 # Close window
        $game_message.visible = @closing
        @face_window.close unless @face_window.nil?
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :update_face_window
  #--------------------------------------------------------------------------#
  def update_face_window()
    unless @face_window.nil?
        @face_window.update
      case $game_message.position
      when 1, 2
        @face_window.x = self.x + 16
        @face_window.y = self.y - 112
      when 0
        @face_window.x = self.x + 16
        @face_window.y = self.y + self.height - 16
      end
      name  = $game_message.face_name
      index = $game_message.face_index
      # // Faceupdate
      if @face_window.face_name != name || @face_window.face_index != index
        @face_window.contents.clear
        @face_window.draw_face(name, index, 0, 0)
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_show_fast
  #--------------------------------------------------------------------------#
  def update_show_fast()
    if self.pause or self.openness < 255
      @show_fast = false
    elsif Input.trigger?(Input::C) and @wait_count < 2
      @show_fast = true
    elsif not Input.press?(Input::C)
      @show_fast = false
    end
    if @show_fast and @wait_count > 0
      @wait_count -= 1
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :new_page
  #--------------------------------------------------------------------------#
  def new_page()
    contents.clear()
    if $game_message.face_name.empty?
      @contents_x = 0
      @face_window.close unless @face_window.nil?()
    else
      @contents_x = 0
      if $game_switches[::IEO::EPSILON::SWITCHES[:face_window]]
        create_face_window
        @face_window.open unless @face_window.nil?()
      else
        name = $game_message.face_name
        index = $game_message.face_index
        draw_face(name, index, 0, 0)
        @contents_x = 112
      end
    end
    @contents_y = 0
    @line_count = 0
    @show_fast = false
    @line_show_fast = false
    @pause_skip = false
    contents.font.color = text_color(0)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :new_line
  #--------------------------------------------------------------------------#
  def new_line()
    if $game_message.face_name.empty?()
      @contents_x = 0
    else
      @contents_x = $game_switches[::IEO::EPSILON::SWITCHES[:face_window]] ? 0 : 112
    end
    @contents_y += WLH
    @line_count += 1
    @line_show_fast = false
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :convert_special_characters
  #--------------------------------------------------------------------------#
  def convert_special_characters()
    @text = Window_Message.convert_regex_characters(@text.clone)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :reset_window
  #--------------------------------------------------------------------------#
  def reset_window()
    @background = $game_message.background
    @position = $game_message.position
    if @background == 0   # Normal window
      self.opacity = 255
    else                  # Dim Background and Make it Transparent
      self.opacity = 0
    end
    self.x      = var_x()
    self.height = (max_line * 24) + 32
    self.width  = var_width()
    case @position
    when 0  # Top
      self.y = 0
      @gold_window.y = 360
    when 1  # Middle
      self.y = (Graphics.height - self.height) / 2
      @gold_window.y = 0
    when 2  # Bottom
      self.y = (Graphics.height - self.height)
      @gold_window.y = 0
    end
    if $scene.is_a?(Scene_Map)
      case $game_variables[IEO::EPSILON::VARIABLES[:overevent]]
      when 0
        setWindowXY($game_player)
      else
        if $game_variables[IEO::EPSILON::VARIABLES[:overevent]] > 0
          setWindowXY($game_map.events[$game_variables[IEO::EPSILON::VARIABLES[:overevent]]])
        end
      end
    end
    create_contents()
  end

  #--------------------------------------------------------------------------#
  # * new method :current_event_id
  #--------------------------------------------------------------------------#
  def current_event_id()
    return $game_variables[IEO::EPSILON::VARIABLES[:event_id]]
  end

  #--------------------------------------------------------------------------#
  # * new method :max_line
  #--------------------------------------------------------------------------#
  def max_line()
    return $game_variables[IEO::EPSILON::VARIABLES[:max_line]]
  end

  #--------------------------------------------------------------------------#
  # * new method :var_x
  #--------------------------------------------------------------------------#
  def var_x()
    return $game_variables[::IEO::EPSILON::VARIABLES[:x]]
  end

  #--------------------------------------------------------------------------#
  # * new method :var_width
  #--------------------------------------------------------------------------#
  def var_width()
    return $game_variables[IEO::EPSILON::VARIABLES[:width]]
  end

  #--------------------------------------------------------------------------#
  # * new method :var_height
  #--------------------------------------------------------------------------#
  def var_height()
    return $game_variables[IEO::EPSILON::VARIABLES[:height]]
  end

  #--------------------------------------------------------------------------
  # * Text Advancement Input
  #--------------------------------------------------------------------------
  def input_pause
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      self.pause = false
      if @text != nil and not @text.empty?
        new_page if @line_count >= max_line()
      else
        terminate_message
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :setWindowXY
  #--------------------------------------------------------------------------#
  def setWindowXY(obj, y = nil)
    calc_height = 56
    #calc_height += 64 unless $game_message.face_name.empty?
    add_w = 32
    #add_w = 112 unless $game_message.face_name.empty?
    if obj.is_a?(Game_Character)
      viewx, viewy, viewwidth, viewheight = 0, 0, Graphics.width, Graphics.height
      self.width = self.contents.text_size(@text).width + 96 + add_w
      self.height = calc_height #56
      subx = 0 ; suby = 0
      subx = (self.width / 2) if obj.screen_x < viewwidth - (self.width / 2)
      suby = self.height+40 if obj.screen_y > 96
      self.x = obj.screen_x - subx ; self.y = obj.screen_y - suby
      self.x = [self.x, 0].max ; self.y = [self.y, 0].max
      self.x = [viewwidth - (self.width), 0].max if (self.x+self.width) > viewwidth
      self.y = [viewheight - (self.height), 0].max if (self.y+self.height) > viewheight
      if $imported["IEO-BugFixesUpgrades"]
        self.x += Game_Map::GAMEVIEWX
        self.y += Game_Map::GAMEVIEWY
      end
    else
      self.x = obj.to_i ; self.y = y.to_i
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :start_message
  #--------------------------------------------------------------------------#
  def start_message()
    @text = ""
    cho = []
    for i in 0...$game_message.texts.size
      if i >= $game_message.choice_start && $game_switches[IEO::EPSILON::USE_CHOICE_WINDOW]
        cho += [$game_message.texts[i].clone]
      else
        @text += "    " if i >= $game_message.choice_start
        @text += $game_message.texts[i].clone + "\x00"
      end
    end
    if $game_switches[::IEO::EPSILON::OVERRIDE_NORMAL_CHOICES]
      $game_message.choice_text = $game_message.choice_text
    else
      $game_message.choice_text = cho + $game_message.choice_text
    end
    @item_max = 0
    @item_max = $game_message.choice_max unless $game_switches[IEO::EPSILON::USE_CHOICE_WINDOW]
    convert_special_characters()
    reset_window()
    new_page()
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :start_choice
  #--------------------------------------------------------------------------#
  def start_choice()
    create_choice_window() if $game_switches[IEO::EPSILON::USE_CHOICE_WINDOW]
    self.active = true
    self.index  = -1
    self.index  = 0 unless $game_switches[IEO::EPSILON::USE_CHOICE_WINDOW]
  end

  #--------------------------------------------------------------------------#
  # * new method :create_choice_window
  #--------------------------------------------------------------------------#
  def create_choice_window()
    @choice_window = Window_MessageChoice.new()
  end

  #--------------------------------------------------------------------------#
  # * new method :dispose_choice_window
  #--------------------------------------------------------------------------#
  def dispose_choice_window()
    @choice_window.dispose() unless @choice_window.nil?()
    @choice_window = nil
  end

  #--------------------------------------------------------------------------#
  # * new method :update_choice_window
  #--------------------------------------------------------------------------#
  def update_choice_window()
    @choice_window.update() unless @choice_window.nil?()
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :input_choice
  #--------------------------------------------------------------------------#
  def input_choice()
    update_choice_window()
    if Input.trigger?(Input::B)
      if $game_message.choice_cancel_type > 0
        Sound.play_cancel
        $game_message.choice_proc.call($game_message.choice_cancel_type - 1)
        dispose_choice_window()
        terminate_message()
      end
    elsif Input.trigger?(Input::C)
      Sound.play_decision()
      index = self.index
      index = @choice_window.index unless @choice_window.nil?()
      $game_message.choice_proc.call(index)
      unless $game_switches[IEO::EPSILON::USE_CHOICE_WINDOW]
        $game_variables[IEO::EPSILON::CHOICE_VARIABLE] = self.index + 1
      end
      dispose_choice_window()
      terminate_message()
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :start_number_input
  #--------------------------------------------------------------------------#
  def start_number_input()
    digits_max = $game_message.num_input_digits_max
    number = $game_variables[$game_message.num_input_variable_id]
    @number_input_window.digits_max = digits_max
    @number_input_window.number = number
    if $game_message.face_name.empty?
      @number_input_window.x = x
    else
      xo = $game_switches[::IEO::EPSILON::SWITCHES[:face_window]] ? 0 : 112
      @number_input_window.x = x + xo
    end
    @number_input_window.y = y + @contents_y
    @number_input_window.active = true
    @number_input_window.visible = true
    @number_input_window.update
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_cursor
  #--------------------------------------------------------------------------#
  def update_cursor()
    if @index >= 0
      xo = $game_switches[::IEO::EPSILON::SWITCHES[:face_window]] ? 0 : 112
      x = $game_message.face_name.empty? ? 0 : xo
      y = ($game_message.choice_start + @index) * WLH
      self.cursor_rect.set(x, y, contents.width - x, WLH)
    else
      self.cursor_rect.empty()
    end
  end

end

#==============================================================================#
# Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias method :create_game_objects
  #--------------------------------------------------------------------------#
  alias :ieo041_sct_create_game_objects :create_game_objects unless $@
  def create_game_objects()
    ieo041_sct_create_game_objects()
    $game_message.setup_variables()
  end

end
#==============================================================================#
IEO::REGISTER.log_script(41, "EpsilonCMS", 1.2) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
