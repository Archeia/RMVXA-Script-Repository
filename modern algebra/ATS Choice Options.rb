#==============================================================================
#    ATS: Choice Options [VXA]
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 27 January 2013
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script improves your control over the choice box by permitting more 
#   than four choices in a box, each of which you can disable or remove 
#   contingent on the value of any given switch. Additionally, it also allows
#   you to extend the length of the choice beyond the editor's spacial 
#   limitations, allowing you to have long choices, and it adds an option for a
#   help window to assist in describing the choices. Aside from that dynamic 
#   control over multiple choice branches, you are also permitted to set the 
#   number of columns in the choice box, its size, and its position. There are 
#   other more minor features as well, which you can learn about in the 
#   instructions.
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
#    There are a lot of configuration options in this script, and I direct you 
#   to the Editable Region at line 102 for detailed comments on what each does
#   Here, I will just list them:
#
#          :append_choices                    :choice_column_num 
#          :choice_spacing                    :choice_win_padding
#          :choice_win_x                      :choice_win_y
#          :choice_win_x_offset               :choice_win_y_offset 
#          :choice_win_width                  :choice_win_height
#          :choice_help_win_lines             :choice_format
#          :choice_disabled_opacity
#
#    As with other ATS scripts, you can change the value of these options in
#   game with the following codes in a script call:
#
#      ats_next(:message_option, x)
#      ats_all(:message_option, x)
#
#   Where :message_option is the symbol you want and x is the value you want 
#   to change it to. ats_next will only change it for the very next message, 
#   while ats_all will change it for every message to follow.
#
#    If any of the values are set to an incorrect value, you will get a popup
#   telling you at the start of the game if you are test playing. If you are 
#   running the actual game, however, the popup will not occur, and neither 
#   will it occur if you pass a wrong value to the options through the ats_all
#   or ats_next commands.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  List of Special Message Codes:
#
#    The following is a complete list of the message codes at your disposal. 
#   Simply insert them into a choice text (or a comment, if specified).
#
# \a[L] - Aligns the text to the left for this choice. Can also use \a[0].
# \a[C] - Aligns the text to the centre for this choice. Can also use \a[1].
# \a[R] - Aligns the text to the right for this choice. Can also use \a[2].
# \s[n] - Will only draw choice if the switch with ID n is ON.
# \s![n] - Will only draw choice if the switch with ID n is OFF.
# \d[n] - Will disable choice if the switch with ID n is ON.
# \d![n] - Will disable choice if the switch with ID n is OFF.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Comment Codes:
#
# \+{text} - This code must be placed in a comment directly below a choice 
#     branch, and it will add the content of text to the choice.
# \h{text} - This code must be placed in a comment directly below a choice 
#     branch, and it will define the help text for that choice. If no help text
#     is set for any choice, then the help window will not show up.
#==============================================================================

$imported = {} unless $imported
$imported[:ATS_ChoiceOptions] = true

#==============================================================================
# ** Game_ATS
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variables - append_choices; choice_column_num;
#      choice_spacing; choice_win_padding; choice_win_x; choice_win_x_offset;
#      choice_win_y; choice_win_y_offset; choice_win_width; choice_win_height;
#      choice_help_win_lines; choice_format
#==============================================================================

class Game_ATS
  CONFIG ||= {}
  CONFIG[:ats_choice_options] = {
    ats_choice_options: true, 
    #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    #  EDITABLE REGION
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #  :append_choices - If true, subsequent choice commands in an event will
    # be joined together into one large choice box. If false, they won't be.
    append_choices:         true,
    #  :choice_column_num - The number of columns in a choice box
    choice_column_num:      1,
    #  :choice_spacing - If :choice_column_num is greater than one, this is
    # the number of pixels between columns
    choice_spacing:         8,
    #  :choice_win_padding - This determines the size of the choice window's
    # border. The default for most other windows is 12. 
    choice_win_padding:     12,
    #  :choice_win_x - This controls the horizontal position of the choice
    # window. It can be set to either :L, :R, :C, or an integer. If an integer, 
    # then it is set directly to that x-coordinate. If :L, it is flush with the 
    # left side of the message window. If :C, it is in the centre of the 
    # message window. If :R, it is flush with the right side of the message 
    # window.
    choice_win_x:           :R,
    #  :choice_win_x_offset - This is the number of pixels offset when
    # :choice_win_x is set to :L or :R. When :L, it is added. When :R, it is
    # subtracted.
    choice_win_x_offset:    0,
    #  :choice_win_y - This controls the vertical position of the choice window.
    # It can be set to either :T, :B, or an integer. If an integer, then it is 
    # set directly to that y-coordinate. If :T, it is flush with the top of the 
    # message window. If :B, it is flush with the bottom of the message window.
    choice_win_y:           :T,
    #  :choice_win_y_offset - This is the number of pixels offset when
    # :choice_win_y is set to :T or :B. When :T, it is added. When :B, it is
    # subtracted.
    choice_win_y_offset:    0,
    #  :choice_win_width - This is the width of the choice window. When it is
    # a range ( a..b ), then the window will be at least a pixels wide and at
    # most b pixels wide, but it will otherwise try to match the size of the
    # longest choice. If you want to set the width directly, just use a single
    # integer here, not a range.
    choice_win_width:       96..Graphics.width,
    #  :choice_win_height - This is the height of the choice window. When it is
    # a range ( a..b ), then the window will be at least a pixels high and at
    # most b pixels high, but it will otherwise try to match the total number
    # of rows in the choice window. If you want to set the height directly, 
    # just use a single integer here, not a range.
    choice_win_height:      48..120,
    #  :choice_help_win_lines - Number of lines that can fit in the help window
    choice_help_win_lines:  1,
    #  :choice_format - This allows you to set a format into which all choices
    # will be forced. It can be useful if you want all choices to be a specific
    # colour, or if you want all choices to be indented, but do not want to 
    # repeat the codes or spaces in every choice. Basically, it is a string, 
    # and somewhere in the string there needs to be %s. That is what will be
    # replaced by the actual choice text. EXAMPLES: If this is '\c[4]%s\c[0]',
    # and you had a choice: 'Yes', then it would be as if you input into the 
    # choice box the text: '\c[4]Yes\c[0]'
    choice_format:          '%s',
    #  :choice_disabled_opacity - This sets the opacity of disabled choices.
    # It is an integer between 0 (fully transparent) and 255 (fully opaque)
    choice_disabled_opacity: 128
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #  END EDITABLE REGION
    #////////////////////////////////////////////////////////////////////////
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  CONFIG[:ats_choice_options].keys.each { |key| attr_accessor key }
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

# If testing the game, alert the user if any configuration values are incorrect
if $TEST
  config = Game_ATS::CONFIG[:ats_choice_options]
  # Choices that must be a boolean
  if !!config[:append_choices] != config[:append_choices]
    msgbox("Configuration Error in ATS: Choice Options!\nThe :append_choices value should be set to either true or false.")
  end
  # Choices that must be a formatting string
  if !config[:choice_format].is_a?(String) || !config[:choice_format][/%s/]
    msgbox("Configuration Error in ATS: Choice Options!\nThe :choice_format value must be a string that includes %s.")
  end
  # Choices that must be Numeric
  [:choice_win_x_offset, :choice_win_y_offset, :choice_disabled_opacity].each { |option|
    if !config[option].is_a?(Numeric)
      msgbox("Configuration Error in ATS: Choice Options!\nThe #{option} value should be set to an integer.")
    end
  }
  # Choices that must be Numeric and greater than 0
  [:choice_column_num, :choice_help_win_lines, :choice_spacing, 
    :choice_win_padding].each { |option|
    if !config[option].is_a?(Numeric) || config[option] <= 0
      msgbox("Configuration Error in ATS: Choice Options!\nThe #{option} value should be set to an integer greater than 0.")
    end
  }
  # Choices that must be either Numeric or a Range
  [:choice_win_width, :choice_win_height].each { |option|
    if !config[option].is_a?(Numeric) && !config[option].is_a?(Range)
      msgbox("Configuration Error in ATS: Choice Options!\nThe #{option} value should be set to an integer greater than 0 or a range")
    end
  }
  # Choices that must be either Numeric or a Symbol
  [:choice_win_x, :choice_win_y].each { |option|
    if !config[option].is_a?(Numeric) && !config[option].is_a?(Symbol)
      msgbox("Configuration Error in ATS: Choice Options!\nThe #{option} value should be set to an integer or a symbol.")
    end
  }
end

#==============================================================================
# ** Game_Message
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variables - append_choices; choice_column_num;
#      choice_spacing; choice_win_padding; choice_win_x; choice_win_x_offset;
#      choice_win_y; choice_win_y_offset; choice_win_width; choice_win_height
#==============================================================================

class Game_Message
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Game_ATS::CONFIG[:ats_choice_options].keys.each { |key| attr_accessor key }
  attr_accessor :choice_help_texts
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Clear
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_clr_9vs5 clear
  def clear(*args)
    @choice_help_texts = []
    ma_clr_9vs5(*args) # Run Original Method
  end
end

#==============================================================================
# ** Game_Interpreter
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    overwritten method - command_403
#    aliased method - setup_choices
#    new methods - append_choice_branches; append_choice_process; choice_plus;
#      choice_plus_process; choice_plus_comment
#==============================================================================

class Game_Interpreter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Choices
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsco_setupchoics_3jx2 setup_choices
  def setup_choices(params, *args, &block)
    params[0].clear
    params = atsco_interpret_choice_branch(params, @index + 1)
    maatsco_setupchoics_3jx2(params, *args, &block) # Call original method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * When Cancel
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def command_403
    check = @list[@index].parameters[0].nil? ? 4 : @list[@index].parameters[0]
    command_skip if @branch[@indent] != check
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Interpret Choice Branch
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def atsco_interpret_choice_branch(params, index = @index)
    if params[2]
      params[1] = params[2]
    else
      params[2] = params[1]
    end
    loop do
      break unless @list[index]
      if @list[index].indent == @indent
        params, index = atsco_interpret_choice_command(params, index)
        break if @list[index].code == 404
      end
      index += 1
    end
    params
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Interpret Choice Command
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def atsco_interpret_choice_command(params, index)
    params, index = case @list[index].code
    when 102 then atsco_interpret_command_102(params, index) # Show Choices
    when 402 then atsco_interpret_command_402(params, index) # Choice Branch
    when 403 then atsco_interpret_command_403(params, index) # Cancel Branch
    when 404 then atsco_interpret_command_404(params, index) # End Branch
    end
    return params, index
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Append Choice
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def atsco_interpret_command_102(params, index)
    if $game_message.append_choices
      unless @list[index].parameters[1] == 0 # Unless no Cancel Branch
        params[1] = params[0].size + @list[index].parameters[1] # Set Cancel
        params[2] += @list[index].parameters[1]
      end
      # Remove Command from Event command list
      @list.delete_at(index)
      index -= 1
    end
    return params, index
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Append Choice
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def atsco_interpret_command_402(params, index)
    # Accomodate for incorrect configuration of choice_format
    $game_message.choice_format = "" unless $game_message.choice_format.is_a?(String)
    $game_message.choice_format += '%s' unless $game_message.choice_format[/%s/]
    # Choice Plus
    plus_text, help_text = atsco_process_choice_comment(index + 1)
    choice_name = sprintf($game_message.choice_format, @list[index].parameters[1] + plus_text)
    del = false
    # Switch Conditions
    choice_name.gsub!(/\\S(!?)\[\s*(\d+)\s*\]/i) {
      # Set to delete if any condition not met
      del = true if ($1.empty? ? !$game_switches[$2.to_i] : 
        $game_switches[$2.to_i]); "" }
    if del # If deleting
      @list[index].parameters[0] = -1
      # If cancel branch after this option
      if params[1] > params[0].size && params[1] < 1000
        params[1] -= 1 # Reduce ID of cancel
        params[1] = 0 if params[1] == params[0].size # If this was cancel, disable
      end
    else
      # Set index
      @list[index].parameters[0] = params[0].size
      # Add to choice array
      params[0].push(choice_name)
      # Add to Help Window
      $game_message.choice_help_texts.push(help_text)
    end
    return params, index
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Append Choice
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def atsco_interpret_command_403(params, index)
    # Only do this if no parameter already set
    if $game_message.append_choices 
      if !@list[index].parameters[0]
        # Set the cancel option to this branch
        params[1] += 1000
        @list[index].parameters[0] = params[1] - 1
      else
        params[1] = @list[index].parameters[0] + 1
      end
    end
    return params, index
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Append Choice
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def atsco_interpret_command_404(params, index)
    # Delete it if next code is a choice box
    next_command = @list[index + 1]
    if $game_message.append_choices && next_command.indent == @indent && next_command.code == 102
      @list.delete_at(index)
      index -= 1
    end
    return params, index
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process Comment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def atsco_process_choice_comment(index)
    # Collect Subsequent comments
    comment = ""
    while @list[index].code == 108 || @list[index].code == 408 
      comment += @list[index].parameters[0] 
      index += 1
    end
    return choice_plus_comment(comment, index), choice_help_comment(comment, index)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Choice + Processing
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def choice_plus_comment(comment, index)
    # Add the content of any \+{} code
    text = ""
    comment.scan(/\\\+{(.+?)}/im) { |str| text += str[0] }
    return text.gsub(/\n/, "")
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Choice Help Processing
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def choice_help_comment(comment, index)
    # Add the content of any \H{} code
    text = ""
    comment.scan(/\\H{(.+?)}/im) { |str| text += str[0] }
    return text.gsub(/\n/, "")
  end
end

unless $imported[:"MA_ParagraphFormat_1.0.1"] # Overwrite if earlier version
  #============================================================================
  # ** MA_Window_ParagraphFormat
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  This module inserts into Window_Base and provides a method to format the
  # strings so as to go to the next line if it exceeds a set limit. This is 
  # designed to work with draw_text_ex, and a string formatted by this method 
  # should go through that, not draw_text.
  #============================================================================

  module MA_Window_ParagraphFormat
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Calc Line Width
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def mapf_calc_line_width(line, tw = 0, contents_dummy = false)
      return tw if line.nil?
      line = line.clone
      unless contents_dummy
        real_contents = contents # Preserve Real Contents
        # Create a dummy contents
        self.contents = Bitmap.new(contents_width, 24)
        reset_font_settings
      end
      pos = {x: 0, y: 0, new_x: 0, height: calc_line_height(line)}
      test = @atsf_testing
      @atsf_testing = true # This 
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
      @atsf_testing = test
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
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Format Paragraph
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def mapf_format_paragraph(text, max_width = contents_width)
      text = text.clone
      #  Create a Dummy Contents - I wanted to boost compatibility by using the 
      # default process method for escape codes. It may have the opposite effect, 
      # for some :( 
      real_contents = contents # Preserve Real Contents
      self.contents = Bitmap.new(contents_width, 24)
      reset_font_settings
      paragraph = ""
      while !text.empty?
        oline, nline, tw = mapf_format_by_line(text.clone, max_width)
        # Replace old line with the new one
        text.sub!(/#{Regexp.escape(oline)}/m, nline)
        paragraph += text.slice!(/.*?(\n|$)/)
        text.lstrip!
      end
      contents.dispose # Dispose dummy contents
      self.contents = real_contents # Restore real contents
      return paragraph
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Format By Line
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def mapf_format_by_line(text, max_width = contents_width)
      oline, nline, tw = "", "", 0
      loop do
        #  Format each word until reach the width limit
        oline, nline, tw, done = mapf_format_by_word(text, nline, tw, max_width)
        return oline, nline, tw if done
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Format By Word
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def mapf_format_by_word(text, line, tw, max_width)
      return line, line, tw, true if text.nil? || text.empty?
      # Extract next word
      if text.sub!(/([ \t\r\f]*)(\S*)([\n\f]?)/, "") != nil
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
          return line, line, tw, true if !line_end.empty?
        end
      else
        return line, line, tw, true
      end
      return line, line, tw, false
    end
  end

  class Window_Base
    include MA_Window_ParagraphFormat unless $imported[:"MA_ParagraphFormat_1.0"]
  end

  $imported[:"MA_ParagraphFormat_1.0"] = true
  $imported[:"MA_ParagraphFormat_1.0.1"] = true
end

#==============================================================================
# ** Window_Message
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - create_all_windows
#==============================================================================

class Window_Message
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create All Windows
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsco_creatwindows_6bq3 create_all_windows
  def create_all_windows(*args)
    maatsco_creatwindows_6bq3(*args) # Call original method
    @atsmo_all_windows.push(@choice_window.help_window) if $imported[:ATS_MessageOptions]
  end
end

#==============================================================================
# ** Window_ChoiceList
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    overwritten methods - update_placement; max_choice_width; col_max
#    aliased method - start
#    new methods - all_line_widths
#==============================================================================

class Window_ChoiceList
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsco_iniz_4hb6 initialize
  def initialize(*args)
    @all_line_heights, @all_line_ys, @all_choice_widths = [], [], []
    maatsco_iniz_4hb6(*args)
    self.z = @message_window.z + 2 # Above Message Window and Name Window
    # Setup Help Window
    lines = $game_message.choice_help_win_lines
    self.help_window = Window_Help.new(lines > 0 ? lines : 1)
    help_window.z = self.z
    help_window.hide
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Start
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsco_start_3us4 start
  def start(*args, &block)
    format_choices
    maatsco_start_3us4(*args, &block) # Call original method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Command List
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsco_mkcmmndlist_7bc3 make_command_list
  def make_command_list(*args)
    maatsco_mkcmmndlist_7bc3(*args) # Call original method
    @list.each_with_index { |c, i| c[:enabled] = maatsco_choice_enabled?(i) }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsco_drwitm_3yh5 draw_item
  def draw_item(index, *args)
    @drawing_index = index  # Preserve Index to know whether to disable colour
    change_color(contents.font.color)
    maatsco_drwitm_3yh5(index, *args)
    @drawing_index = nil
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Change Text Drawing Color
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def change_color(colour, enabled = true, *args)
    super(colour, @drawing_index ? command_enabled?(@drawing_index) : enabled, *args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Choice Enabled?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maatsco_choice_enabled?(index)
    name = command_name(index)
    enabled = true
    # Disable Codes
    name.gsub!(/\e[Dd](!?)\[\s*(\d+)\s*\]/i) {
      # Disable if D! switch is ON or if D switch is OFF 
      enabled = false if ($1.empty? ? $game_switches[$2.to_i] : 
        !$game_switches[$2.to_i]); "" }
    enabled
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Format Choices
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def format_choices
    # Convert escape characters
    $game_message.choices.collect! {|s| 
      convert_escape_characters(s.gsub(/\s*\n\s*/, " ")) }
    @all_choice_widths = get_all_choice_widths
    @choice_width = max_choice_width
    # Get maximum in each line
    @choice_width = (calc_window_width - (padding*2) - (spacing*(col_max - 1))) / col_max
    $game_message.choices.collect! {|s| mapf_format_paragraph(s, @choice_width) }
    @all_line_heights = get_line_heights
    # Set up @all_line_ys
    @all_line_ys.clear
    ah = 0
    for h in @all_line_heights
      @all_line_ys.push(ah)
      ah += h
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Convert Escape Characters
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if instance_methods(false).include?(:convert_escape_characters)
    # If convert_escape_characters already defined in Window_Message, just alias
    alias maatsco_convertesc_5bs7 convert_escape_characters
    def convert_escape_characters(*args, &block)
      maatsco_convert_escape_characters(maatsco_convertesc_5bs7(*args, &block))
    end
  else
    # If convert_escape_characters undefined in Window_Message, call super method
    def convert_escape_characters(*args, &block)
      maatsco_convert_escape_characters(super(*args, &block))
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * ATS CO Convert Escape Characters
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maatsco_convert_escape_characters(text)
    text.gsub!(/\e(N|LB)/i, "\n") unless $imported[:ATS_SpecialMessageCodes]
    text.gsub!(/\eA\[([012])\]/i) { "\eALIGN\[#{$1}\]" }
    text.gsub!(/\eA\[([LRC])\]/i) { "\eALIGN\[#{$1.upcase == 'L' ? 0 : $1.upcase == 'C' ? 1 : 2}\]" }
    text
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process Escape Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if instance_methods(false).include?(:process_escape_character)
    # If convert_escape_characters already defined in Window_Message, just alias
    alias maatsco_processescchr_4bm8 process_escape_character
    def process_escape_character(code, text, pos, *args)
      maatsco_process_escape_character(code, text, pos)
      maatsco_processescchr_4bm8(code, text, pos, *args)
    end
  else
    # If convert_escape_characters undefined in Window_Message, call super method
    def process_escape_character(code, text, pos, *args)
      maatsco_process_escape_character(code, text, pos)
      super(code, text, pos, *args)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * ATS CO Process Escape Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maatsco_process_escape_character(code, text, pos)
    if code.upcase == 'ALIGN'
      align = (obtain_escape_param(text) % 3)
      return if @atsf_testing || align == 0
      nl = text[/.*/]
      return if !nl
      lw = mapf_calc_line_width(nl)
      spc = (@choice_width - (pos[:x] % (@choice_width + spacing))) - lw
      pos[:x] += spc / (align == 1 ? 2 : 1)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Window Position & Size
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_placement
    self.width = calc_window_width
    self.height = calc_window_height
    self.x = calc_window_x
    self.x = x < 0 ? 0 : x + width > Graphics.width ? Graphics.width - width : x
    self.y = calc_window_y
    self.y = y < 0 ? 0 : y + height > Graphics.height ? Graphics.height - height : y
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Calculate Window's Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def calc_window_width # Get the width
    r = $game_message.choice_win_width
    if r.is_a?(Range)
      # Auto setting
      w = (standard_padding*2) + (@choice_width*col_max) + (spacing*(col_max - 1))
      w < r.first ? r.first : w > r.last ? r.last : w
    else
      # Direct setting
      r > (standard_padding*2) ? r : standard_padding*2 + 24
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Calculate Window's Height
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def calc_window_height # Get the height
    r = $game_message.choice_win_height
    if r.is_a?(Range)
      # Auto Setting
      h = (standard_padding*2) + (@all_line_heights.inject(0, :+))
      h < r.first ? r.first : h > r.last ? r.last : h
    else 
      # Direct setting
      r > (standard_padding*2) ? r : standard_padding*2 + 24
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Calculate X Position
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def calc_window_x
    if $game_message.choice_win_x.is_a?(Symbol)
      # Auto Setting
      if !@message_window.close?
        # Message window is open
        mx, mw = @message_window.x, @message_window.width
        xo = $game_message.choice_win_x_offset
        case $game_message.choice_win_x.to_s.downcase.to_sym
        when :l, :left then mx + xo                            # Left
        when :c, :centre, :center then mx + ((mw - width) / 2) # Centre
        else mx + mw - width - xo                              # Right
        end
      else
        # Centre if Message window not shown
        (Graphics.width - width) / 2
      end
    else
      # Direct setting 
      $game_message.choice_win_x
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Calculate Y Position
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def calc_window_y
    if $game_message.choice_win_y.is_a?(Symbol) 
      # Auto Setting
      if !@message_window.close?
        # Message window is open
        my, mh = @message_window.y, @message_window.height
        yo = $game_message.choice_win_y_offset
        align = my + mh + height > Graphics.height ? :t : my - height < 0 ? :b : 
          $game_message.choice_win_y.to_s.downcase.to_sym
        case align
        when :b, :bottom then my + mh - yo # Bottom
        else my - height + yo              # Top
        end
      else
        # Centre if Message window not shown
        (Graphics.height - height) / 2
      end
    else
      # Direct setting 
      $game_message.choice_win_y
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Maximum Width of Choices
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def get_all_choice_widths
    # Create dummy bitmap
    real_contents = contents
    self.contents = Bitmap.new(contents_width, 24)
    reset_font_settings
    choice_widths = $game_message.choices.collect {|s| 
      s.split(/\n/).collect {|s2| mapf_calc_line_width(s2, 0, true) }.max}
    self.contents.dispose
    # Restore real bitmap
    self.contents = real_contents
    choice_widths
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Maximum Width of Choices
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def get_line_heights
    line_heights = Array.new(1 + (($game_message.choices.size - 1) / col_max), 0)
    for i in 0...$game_message.choices.size
      h = $game_message.choices[i].split(/\n/).inject(0) {|sum, s2| sum + calc_line_height(s2) }
      line_heights[i / col_max] = h if h > line_heights[i / col_max]
    end
    line_heights
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Rectangle for Drawing Items
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = @all_line_heights.empty? ? item_height : @all_line_heights[index / col_max]
    rect.x = index % col_max * (rect.width + spacing)
    rect.y = @all_line_ys.empty? ? index / col_max * rect.height : @all_line_ys[index / col_max]
    rect
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Maximum Width of Choices
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def max_choice_width
    ($game_message.choices.empty? || @all_choice_widths.empty?) ? 12 : (@all_choice_widths.max + 8)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Bottom Padding
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_padding_bottom(*args)
    if @all_line_ys.empty?
      super(*args)
    else
      ah = 0
      max = oy + height - (2*standard_padding)
      for h in @all_line_heights
        break if ah + h > max
        ah += h
      end
      self.padding_bottom = padding + (max - ah)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Calculate Height of Window Contents
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def contents_height(*args)
    @all_line_heights.empty? ? super(*args) : @all_line_heights.inject(0, :+)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Top Row
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def top_row(*args)
    r = @all_line_ys.empty? ? nil : @all_line_ys.index(oy)
    r ? r : super(*args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Top Row
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = @all_line_ys.empty? ? row * item_height : @all_line_ys[row]
    update_padding_bottom
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Number of Rows Displayable on 1 Page
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def page_row_max(*args)
    if @all_line_ys.empty?
      super(*args)
    else
      r = top_row
      hmax = oy + height - (2*standard_padding)
      loop do
        break if r >= @all_line_ys.size
        break if @all_line_ys[r] + @all_line_heights[r] > hmax
        r += 1
      end
      [r - top_row, 1].max
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Number of columns
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def col_max
    [[$game_message.choices.size, $game_message.choice_column_num].min, 1].max
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Translcent Opacity
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def translucent_opacity(*args)
    o = $game_message.choice_disabled_opacity
    o.is_a?(Numeric) ? o : super(*args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Standard Padding
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def standard_padding(*args)
    p = $game_message.choice_win_padding
    (p.is_a?(Numeric) && p > 0) ? p : super(*args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Spacing for Items Arranged Side by Side
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def spacing(*args)
    s = $game_message.choice_spacing
    (s.is_a?(Numeric) && s > 0) ? s : super(*args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Item Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def item_width(*args)
    @choice_width ? @choice_width : super(*args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Open
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def open
    super
    setup_help_window if $game_message.choice_help_texts.any? { |h| !h.empty? } 
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Close
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def close
    super
    help_window.hide
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Help Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def setup_help_window
    help_window.show
    r = 0...help_window.height
    bot = ((r === @message_window.y) || (r === y))
    help_window.y = bot ? Graphics.height - help_window.height : 0
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Help Text
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_help
    if index >= 0 && $game_message.choice_help_texts[index].is_a?(String)
      @help_window.set_text($game_message.choice_help_texts[index])
    else
      help_window.clear
    end
  end
end
