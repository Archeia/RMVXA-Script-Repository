#==============================================================================
# [VXACE] Advance Text Reader EX by Estriole
#-------------------------------------------------------------------------
# EST - Advance Text Reader
# Version: 1.2
# Released on: 26/07/2012
# Author : Estriole (yin_estriole@yahoo.com)
# also credits : Woratana for VX version
#
#
=begin
################################################################################
# Version History:
#  v 1.00 - 2012.07.22 > First relase
#  v 1.01 - 2012.07.23 > replace the old decorate text with escape code usage  
#  v 1.02 - 2012.07.26 > make switch togle between old decorate text and new
#                                               escape code version
###############################################################################

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
"default"          - just draw face window (if there is no actorid) without info window then draw text reader window
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
   TR_old_mode_switch = 12 # switch if on use old decorate text mode change to 0
                                                  # you dont want to use the decorate text mode at all
   TEXT_FOLDER = "Texts/" # Folder for Text Files -> this means at your project folder/text
   OPEN_SPEED = 30 # Open/Close Speed of Reader Window (Higher = Faster)
   SCROLL_SPEED = 30 # Scroll Up/Down Speed
end

#===========================================================================
# do not edit below this line except you know what you're doing
#===========================================================================

module SceneManager
  def self.callplus(scene_class,filename,actor = nil,type="default",infocontent="")
        @stack.push(@scene)
        @scene = scene_class.new(filename,actor,type,infocontent)
  end  
end



class Text_Reader < Scene_MenuBase

  OPEN_SPEED = ESTRIOLE::OPEN_SPEED
  SCROLL_SPEED = ESTRIOLE::SCROLL_SPEED
  TEXT_FOLDER = ESTRIOLE::TEXT_FOLDER  
  def initialize(file_name,actor = nil,type="default",infocontent="",mode = 0)
        @filename = file_name
        @infocontent = infocontent
        if actor == nil
        @actorx = nil
        else
        @actorx = $game_actors[actor]
        end
        @mode = mode
        @type = type
  end

  def start
        super
        file = File.open(TEXT_FOLDER + @filename)
        @text = []
        for i in file.readlines
          @text.push i.sub(/\n/) {}
        end
        if @mode == 1
          @text[0] = @text[0].sub(/^./m) {}
        end
        
        @window = Window_Reader.new(@text,@actorx,@type)
        @window.visible = true
        
        if @actorx == nil
          
        else
        @actor_face_window = Window_Top_Reader_Face.new(@actorx)
        end

        case @type
        when "default"
        else;
          @info_window = Window_Top_Reader_Info.new(@actorx,@type,@infocontent)
        end

  end
          
  def update
        super
        @window.update
        process_exit if Input.trigger?(:B)/> or Input.trigger?(:C)
        process_down if Input.repeat?(:DOWN)
        process_up if Input.repeat?(:UP)
  end

  def process_exit
          Sound.play_cancel
          SceneManager.call(Scene_Map)
  end

  def process_down
          Sound.play_cursor if (@window.oy + 272) < @window.contents.height
          @window.oy += SCROLL_SPEED if (@window.oy + 272) < @window.contents.height
  end

  def process_up
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
        super(0,0,544,116)
        @infowidth = 544
        else
        super(116,0,428,116)
        @infowidth = 428
        end
        case type
        when "simple_status"
          draw_actor_simple_status(actor, 20, 20) if actor != nil
        when "text_title"
          make_font_bigger
          make_font_bigger if actor == nil
          change_color(text_color(6))
          draw_text(0, 28, @infowidth - 40, 40, infocontent, 1) if actor == nil
          draw_text(0, 32, @infowidth - 40, 32, infocontent, 1) if actor != nil
        else;
        end
  end
end

class Window_Reader < Window_Base
  attr_accessor :firstline, :nowline

  def initialize(text,actorx,type)
        if actorx == nil
          case type
                when "default"
                  super(0,0,544,416)
                else;
                  super(0,116,544,300)  
          end
        else
          case type
                when "default"
                  super(0,0,544,416)
                else;
                  super(0,116,544,300)  
          end
        end

        #
        @firstline = @nowline = 0
        @text = text
        @align = 0
        @extra_lines = 0
        @line_index = 0
        draw_text_reader
  end

  def update
        if self.openness < 255
          self.openness += Text_Reader::OPEN_SPEED
        end
  end

  def draw_text_reader
        self.contents = Bitmap.new(width - 32, @text.size * 24 + 32)
        @line_index = 0
        for i in 0..@text.size
          if @text[i] == nil
          else
                text = decorate_text(@text[i])
                if $game_switches[ESTRIOLE::TR_old_mode_switch] == true
                  self.contents.draw_text(0, @line_index * 24, width - 32, 24, text, @align)
                else
                  self.draw_text_ex_mod(0, @line_index * 24, text)
                end
          end
          @line_index += 1
        end       
  end

  def draw_text_ex_mod(x, y, text)
        #reset_font_settings
        text = convert_escape_characters(text)
        @pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
        process_character_mod(text.slice!(0, 1), text, @pos) until text.empty?
  end

  def process_character_mod(c, text, pos)
        if pos[:x] >500
          process_new_line(text, pos)
          @line_index += 1
          @extra_lines += 1
        end
        case c
        when "\n"  
          process_new_line(text, pos)
        when "\f"  
          process_new_page(text, pos)
        when "\e"  
          process_escape_character(obtain_escape_code(text), text, pos)
        else            
          process_normal_character(c, pos)
        end
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