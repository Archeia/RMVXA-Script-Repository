###--------------------------------------------------------------------------###
#  Text Alignment and Face Flip script                                         #
#  Version 2.1                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neon Black                                                #
#  Modified by:                                                                #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V2.1 - 10.15.2012                                                           #
#   General script cleanup                                                     #
#  V2.0 - 3.17.2012                                                            #
#   Added Advanced Mode                                                        #
#   Modified several old commands                                              #
#   Added "short" commands                                                     #
#   Fixed an error related to alignment                                        #
#  V1.1 - 10.24.2011                                                           #
#   Fixed an error related to choice boxes                                     #
#   Fixed an error related to battle messages                                  #
#   Added the \trans[x] command                                                #
#   Added the \keep command                                                    #
#   Did general code cleanup                                                   #
#  V1.0 - 10.1.2011                                                            #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Window_Message: initialize                                    #
#  Overwrites  - Window_Message: update, start_message, new_page, new_line,    #
#                                start_number_input, update_cursor             #
#  New Objects - Window_Base: draw_message_face, get_facebox                   #
#                Window_Message: get_face_flip, get_alignment, align_my_text,  #
#                                check_lbl, check_lbl2, get_line_speed,        #
#                                ghost_face_check, check_face_trans,           #
#                                dispose_keep                                  #
#      Advanced Mode Compatibility:                                            #
#  Alias       - Bitmap: draw_text                                             #
#  Overwrites  - Window_Base: draw_face                                        #
#                Window_Message: convert_special_characters, update_message    #
#                                                                              #
#  If you are using any Yanfly Engine Custom Message System, play this script  #
#  ABOVE the Yanfly CMS or the Yanfly script will not work properly.  This     #
#  script will not work with any Yanfly CMS if Advanced Mode is enabled.       #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script is pretty much plug and play with a few options available to    #
#  change below.  Several additional text commands have become available and   #
#  are described below in detail.  Each configuration option is described in   #
#  detail where it is to be defined.                                           #
#                                                                              #
#  A new feature added in version 2.0 is that the text box can use larger and  #
#  smaller face sets than what are normally allowed.  Face sets must still     #
#  contain 8 faces (4 horizontally and 2 vertically) but they can now be any   #
#  size.  Alternatively, you can use a single graphic for face sets by adding  #
#  a "$" to the file name.                                                     #
#                                                                              #
#      Commands: (All the following commands must be LOWERCASE to work.)       #
#      Box Alignment Codes:                                                    #
#                Place these codes anywhere in a message to change the         #
#                 alignment of the entire box.  If more than one is present    #
#                 the higher code on the list takes higher priority.  These    #
#                 codes will work with the Line Alignment Code.                #
#                                                                              #
# long      short                                                              #
#  \alil     \al -   Aligns all text to the left of the box.                   #
#  \alic     \ac -   Aligns all text to the center of the box.                 #
#  \alir     \ar -   Aligns all text to the right of the box.                  #
#                                                                              #
#      Line Alignment Code:                                                    #
#                Place this code anywhere in a message to change the           #
#                 alignment of a designated line.  You may use this code as    #
#                 many times as you need to align each line.  This code will   #
#                 work with the Box Alignment Codes.                           #
#                                                                              #
#  \pos[x:y] -   Aligns line "x" to alignment "y".                             #
#                 X: May be any value from 1 to 4.                             #
#                 Y: 0 - Left align, 1 - Center align, 2 - Right align.        #
#                 Example: "\ali[2:3]" aligns line 2 to the right.             #
#                                                                              #
#      Face Position Codes:                                                    #
#                Place these codes anywhere in your message to change the      #
#                 position and mirroring of the message face in a text box.    #
#                 If more than one code is present the higher code on the      #
#                 list takes priority.  These work with all alignment codes.   #
#                 "Swap" and "Flip" codes are made to work together.           #
#                                                                              #
# long      short                                                              #
#  \keep     \k    -   Saves face for next message or choice.                  #
#  \trans[x] \t[x] -   Sets face transparency to value "x".                    #
#  \swap     \s>   -   Place the face on the right side of the textbox.        #
#  \uswap    \s<   -   Place the face on the left side of the textbox.         #
#  \flip     \f>   -   Mirrors the face in the textbox.                        #
#  \uflip    \f<   -   Unmirrors the face's direction in the textbox.          #
#  \right    \r    -   Places the face on the right side and flips it.         #
#  \left     \l    -   Places the face on the left side and un-flips it.       #
#                                                                              #
###-----                                                                -----###
#      Advanced Section                                                        #
#  The advanced section contains some additional commands and features not     #
#  used by standard.  It is important to note that if you choose to use the    #
#  advanced commands and options, this message system loses some of it's       #
#  compatibility.  This script will no longer be compatible with scripts such  #
#  as Yanfly's CMS which it had previously been compatible with, but it gains  #
#  several commands that it did not previously have.  In order for any of the  #
#  advanced commands to work, advanced mode must be set to TRUE in the config  #
#  section of this script.                                                     #
#                                                                              #
#      Features:                                                               #
#  Here is a list of additional features that become available when using      #
#  advanced mode.                                                              #
#      Faceset Upgrades:                                                       #
#  Advanced mode will overwrite how faces are displayed by the "draw_face"     #
#  scripting command.  This allows you to use facesets of different sizes.     #
#  Please remember that a faceset must still contain 8 faces, 4 horizontal     #
#  and 2 vertical.  You may, however, now use single face graphics simply by   #
#  adding a "$" to the graphic name.  This will cause the entire graphic to    #
#  be used as a single face.                                                   #
#      Text Draw Upgrades:                                                     #
#  Modified how text is drawn on screen.  You can now change the shadows       #
#  under text to be in different positions and different colors.  You can      #
#  also choose for text to be outlined rather than shadowed.  This option can  #
#  be turned off if you do not want to alter how text is drawn.                #
#      More Text Commands:                                                     #
#  Several new text commands were added that only become available with        #
#  advanced mode turned on.  This also fixes a "text insensative" glitch with  #
#  the "\G" command.  All these commands will work both uppercase and          #
#  lowercase.                                                                  #
#                                                                              #
#  \icon[x]  \ICON[x] - Display icon "x" in the message box.                   #
#  \b        \B       - Toggle bold text.  DOES NOT ALIGN PROPERLY!            #
#  \i        \I       - Toggle italic text.                                    #
#  \fi[x]    \FI[x]   - Changes the face displayed to face "x" in the current  #
#                        faceset where "x" is a value from 0-7.  Does nothing  #
#                        when using facesets with "$".  Useful when you want   #
#                        to change a character's emotion mid sentence.         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP   # Do not edit                                                      #
module CMS  #  these two lines.                                                #
#                                                                              #
###-----                                                                -----###
# The default alignment to use for game windows.  Using higher or lower        #
# values than designated may have undesired results.                           #
# 0 = Left, 1 = Center, 2 = Right                                              #
DEFAULT_ALIGNMENT = 0 # Default = 0                                            #
#                                                                              #
# A fix for the messages that appear at the start and end of battle.  Use a    #
# text command here to control the alignment of battle message text if you do  #
# not want it to display with the default alignment.                           #
BATTLE_MESSAGE_FIX = "\al" # Default = "\al"                                   #
#                                                                              #
# Sets if you want the text to type out (default) or display instantly.        #
# false = type out, true = display instantly                                   #
TEXT_TYPE_OR_SKIP = false # Default = false                                    #
#                                                                              #
# Sets the face position and flipping of the face by default.  Swapping is     #
# left and right position in the textbox while flipping mirrors the face in    #
# the textbox.                                                                 #
# SWAPPING: false = left side, true = right side                               #
# FLIPPING: false = normal, true = flip face                                   #
DEFAULT_SWAPPING = false # Default = false                                     #
DEFAULT_FLIPPING = false # Default = false                                     #
#                                                                              #
# Offset used by the CMS when facesets larger than 96x96 are used.  It's       #
# important to note that facesets will use the bottom left corner as the       #
# point of origin so POSITIVE Y values move the image UP.  X value is          #
# automatically recalculated for "swapped" faces.                              #
X_OFFSET = 0 # Default = 0                                                     #
Y_OFFSET = 0 # Default = 0                                                     #
#                                                                              #
# The X offset for text when a face is displayed.  Can be used to correct      #
# text placement when large facesets are used.  When the DEFAULT_FACE_LAY is   #
# set to false, this much of the text box is trimmed off.                      #
TEXT_OFFSET = 0 # Default = 0                                                  #
#                                                                              #
# Places the displayed face over the textbox.  Changing this value to false    #
# will cause the face to display UNDER the textbox.  This is useful when       #
# large portrait type faces.                                                   #
DEFAULT_FACE_LAY = true # Default = true                                       #
#                                                                              #
###-----                                                                -----###
#      Advanced Mode:                                                          #
#  Advanced mode options.  These options are only in effect if advanced mode   #
#  is enabled.  See the instructions above for the changes this has.           #
#                                                                              #
# Turns advanced mode on an off.  No other advanced options will have any      #
# effect if this is set to false.                                              #
ADVANCED_MODE = false # Default = false                                        #
#                                                                              #
# Enable or disable the face set upgrade.  See above to read on what it does.  #
# Big facesets are available in message boxes even if this is turned off.      #
# This can be disabled in case of compatibility errors.                        #
FACE_MOD = true # Default = true                                               #
#                                                                              #
# Enable or disable the additional text commands.  See above to read on what   #
# commands were added.  Alignment and other simple codes will work even with   #
# this set to disabled.  This can be disabled in case of compatibility         #
# errors.                                                                      #
TEXT_MOD = true # Default = true                                               #
#                                                                              #
# Modifies how text shadows are drawn.  Shadows can be moved around or text    #
# can be outlined.  Any values other than those below will prevnt any shadow   #
# from being drawn.                                                            #
# 0 = standard shadows, 1 = modified shadow, 2 = outlined                      #
TEXT_STYLE = 0 # Default = 0                                                   #
#                                                                              #
# The X and Y offset used when drawing a shadow.  Changing these moves the     #
# position of the shadow.                                                      #
SHADOW_X = 1 # Default = 1                                                     #
SHADOW_Y = 1 # Default = 1                                                     #
#                                                                              #
# The color used for the shadow.  These values represent the red, green, and   #
# blue values used by the shadow.  Alpha level is determined by default.       #
SHADOW_COLOR = [0, 0, 0] # Default = [0, 0, 0]                                 #
#                                                                              #
#                                                                              #
end # Don't edit                                                               #
end #  either of these.                                                        #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


$imported = {} if $imported == nil
$imported["CP_TAAFF"] = true

module Vocab  # May add an additional mode of customization, so saving this.
  # Basic Battle Messages
  Emerge          += CP::CMS::BATTLE_MESSAGE_FIX
  Preemptive      += CP::CMS::BATTLE_MESSAGE_FIX
  Surprise        += CP::CMS::BATTLE_MESSAGE_FIX
  EscapeStart     += CP::CMS::BATTLE_MESSAGE_FIX
  EscapeFailure   += CP::CMS::BATTLE_MESSAGE_FIX

  # Battle Ending Messages
  Victory         += CP::CMS::BATTLE_MESSAGE_FIX
  Defeat          += CP::CMS::BATTLE_MESSAGE_FIX
  ObtainExp       += CP::CMS::BATTLE_MESSAGE_FIX
  ObtainGold      += CP::CMS::BATTLE_MESSAGE_FIX
  ObtainItem      += CP::CMS::BATTLE_MESSAGE_FIX
  LevelUp         += CP::CMS::BATTLE_MESSAGE_FIX
  ObtainSkill     += CP::CMS::BATTLE_MESSAGE_FIX
end

if CP::CMS::ADVANCED_MODE && CP::CMS::TEXT_MOD && CP::CMS::TEXT_STYLE != 0
class Bitmap
  alias cp_cms_draw_text draw_text unless $@
  def draw_text(*args)
    unless self.font.shadow
      cp_cms_draw_text(*args)
    else
      case args.size
      when 2, 3
        rect = args[0]
        text = args[1]
        align = args[2] ? args[2] : 0
      else
        rect = Rect.new(args[0], args[1], args[2], args[3])
        text = args[4]
        align = args[5] ? args[5] : 0
      end
      fcolor = self.font.color.clone
      trans = self.font.color.alpha
      self.font.shadow = false
      sc = CP::CMS::SHADOW_COLOR
      self.font.color = Color.new(sc[0], sc[1], sc[2], trans)
      if CP::CMS::TEXT_STYLE == 1
        xo = CP::CMS::SHADOW_X
        yo = CP::CMS::SHADOW_Y
        cp_cms_draw_text(rect.x+xo,rect.y+yo,rect.width,rect.height,text,align)
      elsif CP::CMS::TEXT_STYLE == 2
        cp_cms_draw_text(rect.x+1,rect.y+1,rect.width,rect.height,text,align)
        cp_cms_draw_text(rect.x-1,rect.y-1,rect.width,rect.height,text,align)
        cp_cms_draw_text(rect.x-1,rect.y+1,rect.width,rect.height,text,align)
        cp_cms_draw_text(rect.x+1,rect.y-1,rect.width,rect.height,text,align)
      end
      self.font.color = fcolor
      cp_cms_draw_text(rect, text, align)
      self.font.shadow = true
    end
  end
end
end

class Window_Base < Window

  # New object  -  Called by the "new_page" object.  Used instead of the
  #                "draw_face" object to draw a sprite as the face.
  def draw_message_face(face_name, face_index, x, y, opacity = 255,
                        facesw = false, flipf = false)
    @face_sprite.z = CP::CMS::DEFAULT_FACE_LAY ? 211 : 199
    @face_sprite.bitmap = Cache.face(face_name)
    rect = Rect.new(0, 0, 0, 0)
    sign = face_name[/^[\$]./]
    if sign != nil and sign.include?('$')
      fsizex = @face_sprite.bitmap.width
      fsizey = @face_sprite.bitmap.height
      rect.x = 0
      rect.y = 0
    else
      fsizex = @face_sprite.bitmap.width / 4
      fsizey = @face_sprite.bitmap.height / 2
      rect.x = face_index % 4 * fsizex
      rect.y = face_index / 4 * fsizey
    end
    rect.width = fsizex
    rect.height = fsizey
    
    xo = (fsizex < 96) ? ((96 - fsizex) / 2) : 0
    yo = (fsizey < 96) ? ((96 - fsizey) / 2) : 0
    xs = CP::CMS::X_OFFSET
    ys = CP::CMS::Y_OFFSET
    mp = $game_message.position * ((Graphics.height-128)/2)
    
    @face_sprite.x = x + 16 + xo + xs
    @face_sprite.x = Graphics.width - 16 - rect.width - xo - xs if facesw
    @face_sprite.y = y + 112 + mp - rect.height - yo - ys
    
    @face_sprite.opacity = opacity
    @face_sprite.src_rect = rect
    @face_sprite.mirror = flipf
    @face_sprite.visible = false if self.openness < 255
    ot = CP::CMS::TEXT_OFFSET
    rvalue = CP::CMS::DEFAULT_FACE_LAY ? (16 + rect.width + xs + xo + ot) : 0
    return rvalue
  end
  
  #####------
  ## Overwrites "draw_face" to improve how facesets are handled.  
  if CP::CMS::ADVANCED_MODE
  def draw_face(face_name, face_index, x, y, size = nil)
    bitmap = Cache.face(face_name)
    rect = Rect.new(0, 0, 0, 0)
    sign = face_name[/^[\$]./]
    if sign != nil and sign.include?('$')
      fsizex = bitmap.width
      fsizey = bitmap.height
      sizex = get_facebox(fsizex, size)
      sizey = get_facebox(fsizey, size)
      rect.x = 0 + (fsizex - sizex) / 2
      rect.y = 0 + (fsizey - sizey) / 2
    else
      fsizex = bitmap.width / 4
      fsizey = bitmap.height / 2
      sizex = get_facebox(fsizex, size)
      sizey = get_facebox(fsizey, size)
      rect.x = face_index % 4 * fsizex + (fsizex - sizex) / 2
      rect.y = face_index / 4 * fsizey + (fsizey - sizey) / 2
    end
    rect.width = sizex
    rect.height = sizey
    mx = x + (size - sizex) / 2
    my = y + (size - sizey) / 2
    self.contents.blt(mx, my, bitmap, rect)
  end
  end #advanced
  
  def get_facebox(fsize, size)
    return fsize if size == nil
    if size > fsize
      rsize = fsize
    else
      rsize = fsize - (fsize - size)
    end
    return rsize
  end
end

class Window_Message < Window_Selectable

  alias flip_face_init initialize unless $@  # Alias initialize
  def initialize
    flip_face_init
    @face_sprite = Sprite.new
    @face_offset = 0
    unless CP::CMS::DEFAULT_FACE_LAY
      self.width = Graphics.width - CP::CMS::TEXT_OFFSET
      self.x = CP::CMS::TEXT_OFFSET
      create_contents
    end
  end

  def update  # Overwrite update
    super
    update_gold_window
    update_number_input_window
    update_back_sprite
    update_show_fast
    unless @opening or @closing
      @face_sprite.visible = true if !@face_sprite.visible
      if @wait_count > 0
        @wait_count -= 1
      elsif self.pause
        input_pause
      elsif self.active
        input_choice
      elsif @number_input_window.visible
        input_number
      elsif @text
        update_message
      elsif continue?
        start_message
        open
        $game_message.visible = true
      else
        close           # Next line removes the displayed face
        @face_sprite.bitmap.dispose if @face_sprite.bitmap
        dispose_keep
        $game_message.visible = @closing
      end
    else
      @face_sprite.visible = false if @face_sprite.visible
    end
  end

  # New object  -  Called during the "update" object.  Clears out the keep
  #                variables at the end of use.
  def dispose_keep
    @savename = nil
    @saveindex = nil
    @saveghost = nil
    @saveswap = nil
    @saveflip = nil
  end
  
  def start_message  # Overwrite start_message
    @text = ""
    @clone = []
    for i in 0...$game_message.texts.size
      @text += "    " if i >= $game_message.choice_start
      @text += $game_message.texts[i].clone
      @text += "    " if i >= $game_message.choice_start
      @text += "\x00"
      @clone[i] = ""
      @clone[i] += "    " if i >= $game_message.choice_start
      @clone[i] += $game_message.texts[i].clone
      @clone[i] += "    " if i >= $game_message.choice_start
    end
    @item_max = $game_message.choice_max
    convert_special_characters
    reset_window
    get_alignment
    check_lbl
    new_page
  end

  def new_page  # Overwrite new_page
    contents.clear
    ghost_face_check
    get_face_flip
    if $game_message.face_name.empty?
      @contents_x = 0
      @face_sprite.bitmap.dispose if @face_sprite.bitmap != nil
    else
      name = $game_message.face_name
      index = $game_message.face_index
      @face_offset = draw_message_face(name,index,0,0,@ghostme,@swapme,@flipme)
      @contents_x = @face_offset
      unless CP::CMS::DEFAULT_FACE_LAY
        self.width = Graphics.width - CP::CMS::TEXT_OFFSET
        self.x = CP::CMS::TEXT_OFFSET
        self.x = 0 if @swapme
      end
    end
    @contents_y = 0
    @line_count = 0
    contents.font.bold = false
    contents.font.italic = false
    align_my_text
    @show_fast = false
    get_line_speed
    @pause_skip = false
    contents.font.color = text_color(0)
  end
  
  def new_line  # Overwrite new_line
    if $game_message.face_name.empty?
      @contents_x = 0
      @face_sprite.bitmap.dispose if @face_sprite.bitmap != nil
    else
      @contents_x = @face_offset
    end
    @contents_y += WLH
    @line_count += 1
    align_my_text
    get_line_speed
  end
  
  if CP::CMS::ADVANCED_MODE and CP::CMS::TEXT_MOD
  def convert_special_characters # Overwrite convert_special_characters
    @text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    @text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    @text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    @text.gsub!(/\\C\[([0-9]+)\]/i) { "\x01[#{$1}]" }
    @text.gsub!(/\\G/i)             { "\x02" }
    @text.gsub!(/\\\./)             { "\x03" }
    @text.gsub!(/\\\|/)             { "\x04" }
    @text.gsub!(/\\!/)              { "\x05" }
    @text.gsub!(/\\>/)              { "\x06" }
    @text.gsub!(/\\</)              { "\x07" }
    @text.gsub!(/\\\^/)             { "\x08" }
    @text.gsub!(/\\\\/)             { "\\" }
    @text.gsub!(/\\IC\[([0-9]+)\]/i){ "\x09[#{$1}]" }
    @text.gsub!(/\\B/i)             { "\x10" }
    @text.gsub!(/\\I/i)             { "\x11" }
    @text.gsub!(/\\FI\[([0-9]+)\]/i){ "\x12[#{$1}]" }
  end

  def update_message # Overwrite update_message statement
    loop do
      c = @text.slice!(/./m)            # Get next text character
      case c
      when nil                          # There is no text that must be drawn
        finish_message                  # Finish update
        break
      when "\x00"                       # New line
        new_line
        if @line_count >= MAX_LINE      # If line count is maximum
          unless @text.empty?           # If there is more
            self.pause = true           # Insert number input
            break
          end
        end
      when "\x01"                       # \C[n]  (text character color change)
        @text.sub!(/\[([0-9]+)\]/, "")
        contents.font.color = text_color($1.to_i)
        next
      when "\x02"                       # \G  (gold display)
        @gold_window.refresh
        @gold_window.open
      when "\x03"                       # \.  (wait 1/4 second)
        @wait_count = 15
        break
      when "\x04"                       # \|  (wait 1 second)
        @wait_count = 60
        break
      when "\x05"                       # \!  (Wait for input)
        self.pause = true
        break
      when "\x06"                       # \>  (Fast display ON)
        @line_show_fast = true
      when "\x07"                       # \<  (Fast display OFF)
        @line_show_fast = false
      when "\x08"                       # \^  (No wait for input)
        @pause_skip = true
      when "\x09"                       # \Icon[n]  (Displays an icon)
        @text.sub!(/\[([0-9]+)\]/, "")
        icon_index_num = $1.to_i
        @contents_x += 2
        draw_icon(icon_index_num, @contents_x, @contents_y)
        @contents_x += 26
      when "\x10"                       # \B  (toggles bold display)
        contents.font.bold = !contents.font.bold
      when "\x11"                       # \I  (toggles italic display)
        contents.font.italic = !contents.font.italic
      when "\x12"
        @text.sub!(/\[([0-9]+)\]/, "")
        findex = $1.to_i
        fname = $game_message.face_name
        draw_message_face(fname,findex,0,0,@ghostme,@swapme,@flipme)
      else                              # Normal text character
        contents.draw_text(@contents_x, @contents_y, 40, WLH, c)
        c_width = contents.text_size(c).width
        @contents_x += c_width
      end
      break unless @show_fast or @line_show_fast
    end
  end
  end # Advanced Mode

  def start_number_input  # Overwrite start_number_input
    digits_max = $game_message.num_input_digits_max
    number = $game_variables[$game_message.num_input_variable_id]
    @number_input_window.digits_max = digits_max
    @number_input_window.number = number
    @number_input_window.x = ($game_message.face_name.empty? || @swapme) ? x : x + @face_offset
    @number_input_window.y = y + @contents_y
    @number_input_window.active = true
    @number_input_window.visible = true
    @number_input_window.update
  end
  
  def update_cursor  # Overwrite update_cursor
    if @index >= 0
      x = ($game_message.face_name.empty? || @swapme) ? 0 : @face_offset
      y = ($game_message.choice_start + @index) * WLH
      minussize = @swapme ? @face_offset : 0
      self.cursor_rect.set(x, y, contents.width - x - minussize, WLH)
    else
      self.cursor_rect.empty
    end
  end

  
  # New object  -  Called during the "new_page" object.  Used to check if there
  #                are any codes that modify the position of the face.
  def get_face_flip
    @swapme = CP::CMS::DEFAULT_SWAPPING              # Sets swapping to default
    @flipme = CP::CMS::DEFAULT_FLIPPING              # Sets flipping to default
    @swapme = @saveswap if @saveswap != nil
    @flipme = @saveflip if @saveflip != nil
    @text.gsub!(/\\(?:right|r)/){"\\swap\\flip"}     # Single code for one side
    @text.gsub!(/\\(?:left|l)/){"\\uswap\\uflip"}
    @text.gsub!(/\\f</){"\\uflip"}                   # Substitutes new codes
    @text.gsub!(/\\s</){"\\uswap"}
    @text.gsub!(/\\f>/){"\\flip"}
    @text.gsub!(/\\s>/){"\\swap"}
    @swapme = false if @text.include?("\\uswap")     # Unsets swapping if true
    @flipme = false if @text.include?("\\uflip")     # Unsets flipping if true
    @swapme = true if @text.include?("\\swap")       # Sets swapping if true
    @flipme = true if @text.include?("\\flip")       # Sets flipping if true
    @text.gsub!(/\\swap/) {""}                       # Clears swapping modifiers
    @text.gsub!(/\\uswap/) {""}                        
    @text.gsub!(/\\flip/) {""}                       # Clears flipping modifiers
    @text.gsub!(/\\uflip/) {""}                            
    @saveswap = @keepme ? @swapme : nil              # Keep me variables
    @saveflip = @keepme ? @flipme : nil
  end

  # New object  -  Called during the "new_page" object.  Checks to see if any
  #                alignment modifier codes are present in the text and sets the
  #                new alignment accordingly.
  def get_alignment
    @halign = CP::CMS::DEFAULT_ALIGNMENT            # Sets alignment to default
    @halign = 2 if @text.include?("\\alir")         # Sets alignment to right
    @halign = 2 if @text.include?("\\ar")
    @halign = 1 if @text.include?("\\alic")         # Sets alignment to center
    @halign = 1 if @text.include?("\\ac")
    @halign = 0 if @text.include?("\\alil")         # Sets alignment to left
    @halign = 0 if @text.include?("\\al")
    @text.gsub!(/\\(?:alil|alic|alir|ar|ac|al)/){""}# Clears alignment modifiers
  end
  
  # New object  -  Called during the "new_page" object.  Sets the opacity to
  #                255 and then checks if it should be changed.
  def ghost_face_check
    @ghostme = 255
    @ghostme = @saveghost if @saveghost != nil
    @keepme = false
    if $game_message.face_name.empty?
      $game_message.face_name = @savename if @savename != nil
      $game_message.face_index = @saveindex if @saveindex != nil
    end
    @keepme = true if @text.include?("\\keep")       # Sets keeping if true
    @keepme = true if @text.include?("\\k")
    @text.gsub!(/\\keep/) {""}                       # Clears keeping modifiers
    @text.gsub!(/\\k/) {""}
    @savename = @keepme ? $game_message.face_name : nil  # Keep me variables
    @saveindex = @keepme ? $game_message.face_index : nil
    @text.gsub!(/\\(?:trans|t)\[(\d+)\]/i) {         # Sets transparency
      check_face_trans($1.to_i) }
    @saveghost = @keepme ? @ghostme : nil
  end
  
  # New object  -  Called curing the "new_page" and "new_line" objects.  Sets
  #                the X position of the text based on the alignment defined in
  #                the "get_alignment" object.
  def align_my_text
    unless @clone[@line_count].nil?
      @clone[@line_count].gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
      @clone[@line_count].gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
      @clone[@line_count].gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
      @clone[@line_count].gsub!(/\\(?:alil|alic|alir|ar|ac|al)/){""}
      @clone[@line_count].gsub!(/\\(?:keep|k|trans|t)/){""}
      @clone[@line_count].gsub!(/\\(?:swap|uswap|flip|uflip|right|left)/){""}
      @clone[@line_count].gsub!(/\\(?:s>|s<|f>|f<|f|l)/){""}
      @clone[@line_count].gsub!(/\\IC\[([0-9]+)\]/i){"[..]"}
      @clone[@line_count].gsub!(/\\(?:C|FI)\[([0-9]+)\]/i){""}
      @clone[@line_count].gsub!(/\\(?:G|B|I)/i){""}
      @clone[@line_count].gsub!(/\\(?:>|<|\.|\\|\^|\||!)/){""}
      @clone[@line_count].gsub!(/\\pos\[(\d+):(\d+)\]/i){""}
      linewidth = Graphics.width - 32 - @contents_x  # Sets the width of a line
      textwidth = contents.text_size(@clone[@line_count]).width# Gets text width
    else
      linewidth = Graphics.width - 32 - @contents_x
      textwidth = contents.text_size(@text).width
    end
    
    if @lineali[@line_count]                  # Gets space for alignment
      newwidth = (linewidth - textwidth) / 2 * @lineali[@line_count]
    else
      newwidth = (linewidth - textwidth) / 2 * @halign
    end
    
    if @swapme                                       # Sets the new alignment
      @contents_x = newwidth
    else
      @contents_x += newwidth     
    end
  end
  
  # New object  -  Called during the "start_message" object.  Checks for any
  #                "line by line" alignment modifying codes.
  def check_lbl
    @lineali = []
    @text.gsub!(/\\pos\[(\d+):(\d+)\]/i) {
      check_lbl_2($1.to_i, $2.to_i) }
  end
  
  # New object  -  Called during the "check_lbl" object.  Sets any available
  #                alignments and then returns a null text.
  def check_lbl_2(linen, align)
    case linen
    when 1, 2, 3, 4
      @lineali[linen-1] = align
    end
    retme = ""
    return retme
  end
  
  # New object  -  Called during the "ghost_face_check" object.  Checks if a
  #                new transparencty is called for the face.
  def check_face_trans(ghostme)
    @ghostme = ghostme
    retme = ""
    return retme
  end
  # New object  -  Called during the "new_page" and "new_line" objects.  Checks
  #                what the line speed is currently set to.  May change this in
  #                the future so saving this for space.
  def get_line_speed
    @line_show_fast = CP::CMS::TEXT_TYPE_OR_SKIP
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###