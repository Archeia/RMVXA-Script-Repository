#==============================================================================
#    ATS: Formatting [VXA]
#    Version: 1.1.5
#    Author: modern algebra (rmrk.net)
#    Date: 26 February 2015
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script essentially adds three features to your messages, all of which
#   may be familiar if you used the VX version of the ATS. The first feature is
#   paragraph formatting, and if that is on then the script will essentially
#   draw the text so that only as much text as can fit on a line is included.
#   In other words, if you have put so much text in a message such that it
#   would normally be cut off on the right, this script will make it so that
#   instead, if the text is in danger of being cut off, it will simply draw it
#   on the next line. Along with this, this script will also bring in a new
#   message code to start a new line (since the traditional line breaks are
#   wiped out when you use paragraph format).
#
#    The second feature is appended text, which in this context is really only
#   useful if you are using paragraph format. When you have this feature on,
#   what it will do is make it so that the text in any immediately subsequent
#   Display Text event command with the same settings will be joined to the
#   first text window, and then they will be shown in the same window if there
#   is room. What this means is that if, for instance, you have two messages,
#   and the first would only show two lines and the second would show three
#   lines, then in-game, if appended text is on, the first two lines of the
#   second command would be shown with the two lines of the first command, and
#   the next page would only show the last line of the second command. It is a
#   useful feature when using paragraph formatting, since otherwise when
#   writing long dialogues with the same character, you would need to be
#   writing in sets of four lines so that it doesn't have weird stops.
#
#    The third feature is text alignment, so you can now set it so that text is
#   aligned to the left, right or centre in the message box.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  ATS Series:
#
#    This script is part of the Advanced Text System series of scripts. These
#   scripts are based off the Advanced Text System for RMVX, but since RMVX Ace
#   has a much more sensibly designed message system, it is no longer necessary
#   that it be one large script. For that reason, and responding to feedback on
#   the ATS, I have split the ATS into multiple different scripts so that you
#   only need to pick up the components for the features that you want. It is
#   therefore easier to customize and configure.
#
#    To find more scripts in the ATS Series, please visit:
#      http://rmrk.net/index.php/topic,44525.0.html
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials. If you are using another message system, such as Yanfly's
#   Ace Message System, I recommend that this script be placed underneath it.
#
#    You can change the default setting for paragraph formatting at line 127.
#   Currently, it is set to true, which means that it will be operative in
#   every message unless you specifically turn it off. To change this default
#   value in-game, use one of the following codes in a script call:
#
#      ats_all(:paragraph_format, true)    # Turns paragraph format on
#      ats_all(:paragraph_format, false)   # Turns paragraph format off
#
#    Similarly, you can change it for just the very next display text command.  
#   Simply use one of the following codes in a script call:
#
#      ats_next(:paragraph_format, true)   # Turns paragraph format on
#      ats_next(:paragraph_format, false)  # Turns paragraph format off
#
#   Alternatively, you can turn paragraph format on or off for a message by
#   message codes. See the special message codes list at lines 96 and 97.
#
#    You can change the default setting for appended text at line 135. If true,
#   then any immediately subsequent display text commands with the same
#   same settings (same face, background, position) will be added to the
#   message shown.
#
#    Similar to paragraph format, you can use the following commands in a
#   script call
#
#      ats_all(:append_text, true)    # Turns default appended text on
#      ats_all(:append_text, false)   # Turns default appended text off
#      ats_next(:append_text, true)   # Turns appended text on for next message
#      ats_next(:append_text, false)  # Turns appended text off for next message
#
#    Finally, you can also change the alignment of text with the special
#   message codes listed below at lines 100, 101 & 102.
#
#    Lastly, I would draw your attention to the \n and \pn codes, which allows
#   you to make new lines and new pages, respectively. These are useful for
#   when you are using paragraph format and appended text, as it allows you
#   more control. They are described at line 98 and 99.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  List of Special Message Codes Added:
#
# \pf   - Turn on paragraph format for this message.
# /pf   - Turn off paragraph format for this message.
# \n    - Start a new line.
# \lb   - Start a new line.
# \pn   - Start a new page.
# \a[L] - Aligns the text to the left for this line. Can also use \a[0].
# \a[C] - Aligns the text to the centre for this line. Can also use \a[1].
# \a[R] - Aligns the text to the right for this line. Can also use \a[2].
#==============================================================================

$imported ||= {}
if !$imported[:ATS_Formatting]
$imported[:ATS_Formatting] = true

#==============================================================================
# ** Game_ATS
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variables - ats_paragraph_formatting; ats_alignment;
#      paragraph_format
#==============================================================================

class Game_ATS
  CONFIG ||= {}
  CONFIG[:ats_formatting] = {
    ats_formatting: true,
    ats_alignment: 0,
    #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    #  EDITABLE REGION
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #  Set the below value to either true or false. If true, then paragraph
    # format will be on by default. If false, then paragraph_format will be
    # off by default.
    paragraph_format: true,
    #  Set the below value to either true or false. If true, then any
    # immediately subsequent display text event commands with the same settings
    # will be joined together and they will show in the same message window if
    # there is space. This option is only useful if using paragraph format. If
    # you are using ATS: Message Options, it will only recognize the value of
    # :append_text set up in that script.
    append_text:      true,    
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #  END EDITABLE REGION
    #////////////////////////////////////////////////////////////////////////
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  CONFIG[:ats_formatting].delete(:append_text) if $imported[:ATS_MessageOptions]
  CONFIG[:ats_formatting].keys.each { |key| attr_accessor key }
end

#==============================================================================
#  Initialize Common ATS Data if no other ATS script interpreted first
#==============================================================================

if !$imported[:AdvancedTextSystem]
  #============================================================================
  # *** DataManager
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    aliased method - create_game_objects; make_save_contents;
  #      extract_save_contents
  #============================================================================
  module DataManager
    class << self
      alias modb_ats_crtgmobj_6yh7 create_game_objects
      alias mlba_ats_mksave_5tg9 make_save_contents
      alias ma_ats_extrcsvcon_8uj2 extract_save_contents
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Create Game Objects
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def self.create_game_objects(*args, &block)
      modb_ats_crtgmobj_6yh7(*args, &block)
      $game_ats = Game_ATS.new
      $game_ats.init_new_installs
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Make Save Contents
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def self.make_save_contents(*args, &block)
      contents = mlba_ats_mksave_5tg9(*args, &block)
      contents[:ats] = $game_ats
      contents
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Extract Save Contents
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def self.extract_save_contents(contents, *args, &block)
      ma_ats_extrcsvcon_8uj2(contents, *args, &block)
      $game_ats = contents[:ats] ? contents[:ats] : Game_ATS.new
      $game_ats.init_new_installs
    end
  end
 
  #============================================================================
  # ** Game_ATS
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  This class holds the default data for all scripts in the ATS series
  #============================================================================
 
  class Game_ATS
    def initialize; reset; end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Reset any or all installed ATS scripts
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def reset(script_name = nil)
      if script_name.is_a? (Symbol) # If script to reset specified
        CONFIG[script_name].each_pair { |key, value|
          self.send("#{key}=".to_sym, value)
          $game_message.send("#{key}=".to_sym, value)
        }
      else                          # Reset all ATS scripts
        CONFIG.keys.each { |script| reset(script) }
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Initialize any newly installed ATS scripts
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def init_new_installs
      CONFIG.keys.each { |script| reset(script) unless self.send(script) }
    end
  end
 
  #============================================================================
  # ** Game_Message
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    aliased method - clear
  #============================================================================
 
  class Game_Message
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Clear
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias mlb_ats_clrats_5tv1 clear
    def clear(*args, &block)
      mlb_ats_clrats_5tv1(*args, &block) # Run Original Method
      return if !$game_ats
      Game_ATS::CONFIG.values.each { |installed|
        installed.keys.each { |key| self.send("#{key}=".to_sym, $game_ats.send(key)) }
      }
    end
  end
 
  #============================================================================
  # ** Game_Interpreter
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    new methods - ats_all; ats_next
  #============================================================================
 
  class Game_Interpreter
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * ATS All
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def ats_all(sym, *args, &block)
      $game_ats.send("#{sym}=".to_sym, *args, &block)
      ats_next(sym, *args, &block)
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * ATS Next
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def ats_next(sym, *args, &block)
      $game_message.send("#{sym}=".to_sym, *args, &block)
    end
  end

  $imported[:AdvancedTextSystem] = true
end

# Fix the error with Escape codes
unless $imported[:MA_EscapeCodesFix]
  #============================================================================
  # ** Window_Base
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    aliased method - obtain_escape_code
  #============================================================================

  class Window_Base
    alias maatspf_obtainesccode_2jk3 obtain_escape_code
    def obtain_escape_code(*args, &block)
      code = maatspf_obtainesccode_2jk3(*args, &block)
      if code.nil?
        p "ERROR in #{self}:\nThere is no escaped code between \ and [ in your text."
        ""
      else
        code
      end
    end
  end
 
  $imported[:MA_EscapeCodesFix] = true
end

unless $imported[:"MA_ParagraphFormat_1.0.1"]
#==============================================================================
# ** MA_Window_ParagraphFormat
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module inserts into Window_Base and provides a method to format the
# strings so as to go to the next line if it exceeds a set limit. This is
# designed to work with draw_text_ex, and a string formatted by this method
# should go through that, not draw_text.
#==============================================================================

module MA_Window_ParagraphFormat
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Calc Line Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mapf_calc_line_width(line, tw = 0, contents_dummy = false)
    return tw if line.nil?
    line = line.clone
    unless contents_dummy
      real_contents = contents # Preserve Real Contents
      # Create a dummy contents
      self.contents = Bitmap.new(24, 24)
      reset_font_settings
    end
    pos = {x: 0, y: 0, new_x: 0, height: calc_line_height(line)}
    while line[/^(.*?)\e(.*)/]
      tw += text_size($1).width
      line = $2
      # Remove all ancillaries to the code, like parameters
      code = obtain_escape_code(line)
      # If direct setting of x, reset tw.
      tw = 0 if ($imported[:ATS_SpecialMessageCodes] && code.upcase == 'X') ||
        ($imported["YEA-MessageSystem"] && code.upcase == 'PX')
      #  If I need to do something special on the basis that it is testing,
      # alias process_escape_character and differentiate using @atsf_testing
      process_escape_character(code, line, pos)
    end
    #  Add width of remaining text, as well as the value of pos[:x] under the
    # assumption that any additions to it are because the special code is
    # replaced by something which requires space (like icons)
    tw += text_size(line).width + pos[:x]
    unless contents_dummy
      contents.dispose # Dispose dummy contents
      self.contents = real_contents # Restore real contents
    end
    return tw
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Format Paragraph
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mapf_format_paragraph(text, max_width = contents_width)
    text = text.clone
    #  Create a Dummy Contents - I wanted to boost compatibility by using the
    # default process method for escape codes. It may have the opposite effect,
    # for some :(
    real_contents = contents # Preserve Real Contents
    self.contents = Bitmap.new(24, 24)
    reset_font_settings
    paragraph = ""
    while !text.empty?
      text.lstrip!
      oline, nline, tw = mapf_format_by_line(text.clone, max_width)
      # Replace old line with the new one
      text.sub!(/#{Regexp.escape(oline)}/m, nline)
      paragraph += text.slice!(/.*?(\n|$)/)
    end
    contents.dispose # Dispose dummy contents
    self.contents = real_contents # Restore real contents
    return paragraph
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Format By Line
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mapf_format_by_line(text, max_width = contents_width)
    oline, nline, tw = "", "", 0
    loop do
      #  Format each word until reach the width limit
      oline, nline, tw, done = mapf_format_by_word(text, nline, tw, max_width)
      return oline, nline, tw if done
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Format By Word
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mapf_format_by_word(text, line, tw, max_width)
    return line, line, tw, true if text.nil? || text.empty?
    # Extract next word
    if text.sub!(/([ \t\r]*)(\S*)([\n\f]?)/, "") != nil
      prespace, word, line_end = $1, $2, $3
      ntw = mapf_calc_line_width(word, tw, true)
      pw = contents.text_size(prespace).width
      if (pw + ntw >= max_width)
        # Insert
        if line.empty?
          # If one word takes entire line
          return prespace + word, word + "\n", ntw, true
        else
          return line + prespace + word, line + "\n" + word, tw, true
        end
      else
        line += prespace + word
        tw = pw + ntw
        # If the line is force ended, then end
        return line, line, tw, true if !line_end.strip.empty?
      end
    else
      return line, line, tw, true
    end
    return line, line, tw, false
  end
end

class Window_Base
  include MA_Window_ParagraphFormat
end

  $imported[:"MA_ParagraphFormat_1.0"] = true
  $imported[:"MA_ParagraphFormat_1.0.1"] = true
end

#==============================================================================
# ** Game Message
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variables - ats_paragraph_formatting; paragraph_format;
#      ats_alignment; append_text
#    aliased method - all_text
#==============================================================================

class Game_Message
  Game_ATS::CONFIG[:ats_formatting].keys.each { |key| attr_accessor key }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * All Text
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsf_alltex_6hu7 all_text
  def all_text(*args, &block)
    result = maatsf_alltex_6hu7(*args, &block) # Call Original Method
    # Look for the Paragraph Format Code
    result.gsub!(/([\/\\])PF/i) { |match| self.paragraph_format = (match[0] == "\\"); "" }
    # Remove natural \n if paragraph format is ON
    result.gsub!(/\s*[\r\n\f]\s*/)  {" "} if paragraph_format
    result
  end
end

#==============================================================================
# ** Game_Interpreter
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - command_101; next_event_code
#    new method - maatsf_same_message_conditions?
#==============================================================================

if !$imported[:ATS_MessageOptions]
  class Game_Interpreter
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Display Text Message
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias maatsf_disptext_3jf5 command_101
    def command_101(*args, &block)
      @ats_appending_text = $game_message.append_text
      maatsf_disptext_3jf5(*args, &block) # Call Original Method
      @ats_appending_text = false
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Next Event Code
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias maatsf_nexcode_5rq9 next_event_code
    def next_event_code(*args, &block)
      result = maatsf_nexcode_5rq9(*args, &block) # Call Original Method
      if @ats_appending_text && result == 101
        if maats_same_message_conditions?(@index + 1)
          @index += 1
          result = next_event_code(*args, &block)
        end
      end
      result
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Same Message Conditions?
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def maats_same_message_conditions?(list_index)
      n_params = @list[list_index].parameters
      if ($imported[:MA_CompositeGraphics] || $imported[:ATS_FaceOptions]) &&
        @list[list_index + 1] && @list[list_index + 1].parameters[0][/^\\([AP])F\[(\d+)\]/i]
        param = $2.to_i
        actor = ($1 == 'A') ? $game_actors[param] : $game_party.members[param - 1]
        return (actor.face_name == $game_message.face_name &&
          actor.face_index == $game_message.face_index &&
          n_params[2] == $game_message.background && n_params[3] == $game_message.position)
      end
      n_params[0] == $game_message.face_name && n_params[1] == $game_message.face_index &&
        n_params[2] == $game_message.background && n_params[3] == $game_message.position
    end
  end
end

#==============================================================================
# *** Paragraph Formatting for Message Windows
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module is included in Window_Message and Window_ScrollText
#==============================================================================

module ATS_Formatting_WindowMessage
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Convert Escape Characters
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maatsf_convert_escape_characters(text, *args, &block)
    # Alignment
    text.gsub!(/\eA\[([012])\]/i) { "\eALIGN\[#{$1}\]" }
    text.gsub!(/\eA\[([LRC])\]/i) { "\eALIGN\[#{$1.upcase == 'L' ? 0 : $1.upcase == 'C' ? 1 : 2}\]" }
    text.gsub!(/\ePN/i,  "\f") # New Page
    # New Line
    text.gsub!(/\e(N|LB)/i, "\n") unless $imported[:ATS_SpecialMessageCodes]
    text
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Paragraph New Line
  #``````````````````````````````````````````````````````````````````````````
  # This adds processing for paragraph format and alignment to these methods
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maatsf_paragraph_new_line(orig_method, text, pos, *args, &block)
    tw = nil
    tw = maatsf_set_next_line(text, pos) if $game_message.paragraph_format && !text.nil? && !text.empty?
    orig_method.call(text, pos, *args, &block) # Call original Method
    # Alignment
    next_line = text[/^[^\n\f]*/]
    align = maatsf_line_alignment(next_line)
    if align != 0 # If not left aligned
      if tw.nil?
        @atsf_testing = true
        tw = mapf_calc_line_width(next_line)
        @atsf_testing = false
      end
      space = maatsf_total_line_width(pos[:y]) - tw
      pos[:x] = [pos[:x] + (space / (align == 1 ? 2 : 1)), pos[:x]].max
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Paragraph Line
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maatsf_set_next_line(text, pos)
    text.gsub!(/^[ \t\r\f]*/, "")
    max_width = maatsf_total_line_width(pos[:y])
    #  Create a Dummy Contents
    real_contents = contents # Preserve Real Contents
    self.contents = Bitmap.new(24, 24)
    self.contents.font = real_contents.font.dup
    @atsf_testing = true
    # Do everything
    oline, nline, tw = mapf_format_by_line(text.clone, max_width)
    # Replace old line with the new one
    text.sub!(/#{Regexp.escape(oline)}/m, nline)
    contents.dispose # Dispose dummy contents
    self.contents = real_contents # Restore real contents
    @atsf_testing = false
    return tw
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Alignment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maatsf_line_alignment(line)
    line[/\eALIGN\[([012])\]/] != nil ? $1.to_i : $game_message.ats_alignment
  end
end

#==============================================================================
# ** Window_Message
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - convert_escape_characters; new_page; process_new_line;
#      wait; wait_for_one_character; input_pause; process_escape_character
#    new methods - maatsf_set_next_line; mapf_format_by_word;
#      mapf_calc_line_width; maatsf_total_line_width;
#      maatsf_line_alignment; maats_convert_escape_characters;
#      maatsf_paragraph_new_line
#==============================================================================

class Window_Message
  include ATS_Formatting_WindowMessage
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Convert Escape Characters
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if instance_methods(false).include?(:convert_escape_characters)
    # If convert_escape_characters already defined in Window_Message, just alias
    alias maatsf_convrtescchars_8ju5 convert_escape_characters
    def convert_escape_characters(*args, &block)
      maatsf_convert_escape_characters(maatsf_convrtescchars_8ju5(*args, &block))
    end
  else
    # If convert_escape_characters undefined in Window_Message, call super method
    def convert_escape_characters(*args, &block)
      maatsf_convert_escape_characters(super(*args, &block))
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * New Page / Process New Line
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  [:new_page, :process_new_line].each { |meth|
    alias_method(:"maatsf_#{meth}_3wj9", meth)
    define_method(meth) do |*args|
      maatsf_paragraph_new_line(method(:"maatsf_#{meth}_3wj9"), *args)
    end
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Wait / Wait for One Character / Process Input
  #``````````````````````````````````````````````````````````````````````````
  # Do not permit these to run when testing
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  [:wait, :wait_for_one_character, :input_pause].each { |meth|
    alias_method(:"maatsf_#{meth}_2hd4", meth)
    define_method(meth) do |*args|
      send(:"maatsf_#{meth}_2hd4", *args) unless @atsf_testing
    end
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process Escape Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsf_proceschar_4fq6 process_escape_character
  def process_escape_character(code, text, *args, &block)
    if code.upcase == 'ALIGN'
      $game_message.ats_alignment = obtain_escape_param(text)
    else
      maatsf_proceschar_4fq6(code, text, *args, &block) # Call Original Method
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Total Line Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maatsf_total_line_width(y = 0)
    contents_width - new_line_x
  end
end

#==============================================================================
# ** Window_ScrollText
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - convert_escape_characters; process_new_line;
#      update_all_text_height
#    new methods - maatsf_set_next_line; mapf_format_by_word;
#      mapf_calc_line_width; maatsf_total_line_width;
#      maatsf_line_alignment; maats_convert_escape_characters;
#      maatsf_paragraph_new_line
#==============================================================================

class Window_ScrollText
  include ATS_Formatting_WindowMessage
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Convert Escape Characters
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsf_convescchrs_3wv5 convert_escape_characters
  def convert_escape_characters(*args, &block)
    maatsf_convert_escape_characters(maatsf_convescchrs_3wv5(*args, &block))
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process New Line
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsf_procenewlin_2gv5 process_new_line
  def process_new_line(*args, &block)
    maatsf_paragraph_new_line(method(:maatsf_procenewlin_2gv5), *args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Has to be done in process Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsf_updalltextheight_2sd8 update_all_text_height
  def update_all_text_height(*args, &block)
    text = convert_escape_characters(@text)
    if $game_message.paragraph_format
      new_text = ""
      pos = { x: 4, y: 0, new_x: 4, height: fitting_height(1) }
      while !text.nil? && !text.empty?
        maatsf_set_next_line(text, pos)
        if text.sub!(/^([^\n\f]*)([\n\f])/, "")
          new_text += $1 + $2
        else
          new_text += text
          break
        end
      end
      @text = new_text
    end
    maatsf_updalltextheight_2sd8(*args, &block) # Run Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process Escape Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsf_processesc_2hk8 process_escape_character
  def process_escape_character(code, text, *args, &block)
    if code.upcase == 'ALIGN'
      $game_message.ats_alignment = obtain_escape_param(text)
    else
      maatsf_processesc_2hk8(code, text, *args, &block) # Call Original Method
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Total Line Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maatsf_total_line_width(y = 0)
    contents_width
  end
end
else
  p "You have two copies of ATS: Formatting installed. Please remove one."
end