=begin
#==============================================================================
 Title: Choice Options
 Author: Hime
 Date: Sep 13, 2015
------------------------------------------------------------------------------
 ** Change log 
 Sep 13, 2015
   - fixed cancel choice
 Jun 14, 2015
   - multiple conditional texts can be applied. The ones added later have 
     higher priority
 May 2, 2015
   - added support for conditional text
 Jan 2, 2015
   - fixed bug where choice window doesn't reflect choice size
 Nov 29, 2014
   - removed choice scrolling and visible choice limits
 Jul 6, 2014
   - fixed bug where disabling choices will produce incorrect cancel branching
 Jul 5, 2014
   - fixed bug where cancel branch was not included in the choices
 Nov 17, 2013
   - choice formulas are now evaluated in the interpreter (rather than
     Game_Message)
 Oct 18, 2013
   - added "disable_color" option
 Jun 9, 2013
   - bug fix: last choice was not colored correctly
 Apr 10, 2013
   - new lines automatically removed for "text" option
 Apr 9, 2013
   - added "text" choice option
 Mar 8, 2013
   - fixed a copy-by-reference issue
 Mar 6, 2013
   - hidden choice fixed
   - new script interface added
 Dec 6, 2012
   - removed multiple choice implementation to be more flexible
   - implemented scrolling choices
 Dec 4, 2012
   - added support for built-in choice editor
   - initial release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
------------------------------------------------------------------------------
 ** Description
 
 This script provides extended control over choices.
 
 You can add "choice options" to each choice for further control over how
 they should appear, when they should appear, ...
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
------------------------------------------------------------------------------
 ** Usage
 
 To add choice option, use one of the methods defined in the reference section.
 For example, if you want to hide a choice 1 if actor 1's level is less than 5,
 you would write
   
   hide_choice(1, "$game_actors[1].level < 5")
   
------------------------------------------------------------------------------
 ** Reference
 
 The following options are available
 
 Method: disable_choice
 Effect: disables choice if condition is met
 Usage:  Takes a string representing a boolean statement. For example,
         "$game_actors[1].level > 5" means that the condition will only be
         selectable if actor 1's level is greater than 5.
     
 Method: hide_choice
 Effect: hides choice if condition is met
 Usage:  Takes a string representing a boolean statement. For example,
         "$game_party.gold < 2000" means that the condition will not be shown
         if the party's gold is less than 2000
           
 Method: color_choice
 Effect: Very simple text color changing based on system colors
 Usage:  Takes an integer as the text color, based on the system colors.
         (eg: 2 is red by default). Check the "Window.png" file in your
         RTP folder to see the default colors
         
 Method: text_choice
 Effect: Sets the text of the choice to the custom text.
 Usage:  Takes a string that will replace whatever you place in the choice 
         editor. This allows you to exceed the 50-char limit. Additionally,
         you can specify a second string which is a condition. If the condition
         is met, only then will this text be applied. When multiple text choice
         calls are applied, priority is given to the last script call.
------------------------------------------------------------------------------
 ** Compatibility
 
 This script must be placed below Large Choices
------------------------------------------------------------------------------
 ** Credits
 
 Enelvon, for scrolling choices implementation
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ChoiceOptions"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module Tsuki
  module Choice_Options

  end
end
#==============================================================================
# ** Rest of the script
#==============================================================================
class Game_Message
  attr_reader   :choice_map
  attr_accessor :orig_choices
  attr_accessor :choice_options
  
  alias :th_choice_options_clear :clear
  def clear
    th_choice_options_clear
    clear_choice_options
    @choice_map = []
    @orig_choices = []
  end
  
  def clear_choice_map
    
  end
  
  # Hardcode...
  def clear_choice_options
    @choice_options = {}
    @choice_options[:condition] = {}
    @choice_options[:hidden] = {}
    @choice_options[:color] = {}
    @choice_options[:text] = {}
    @choice_options[:cond_text] = {}
    @choice_options[:disable_color] = {}
  end
  
  # Just hardcode. Refactor later.
  def set_choice_option(type, num, arg)
    case type
    when :condition
      @choice_options[type][num] = arg
    when :hidden
      @choice_options[type][num] = arg
    when :color
      @choice_options[type][num] = arg.to_i
    when :text
      arg[0].gsub!("\n", "")
      @choice_options[type][num] ||= []
      @choice_options[type][num] << arg
    when :disable_color
      @choice_options[type][num] = arg.to_i
    else
      return
    end
  end
  
  def get_choice_option(type, num)
    return @choice_options[type][num]
  end
  
  def choice_hidden?(num)
    return @choice_options[:hidden][num]
  end
end

class Game_Interpreter
  
  alias :th_choice_options_setup_choices :setup_choices
  def setup_choices(params)
    # start with our original choices
    th_choice_options_setup_choices(params)
    replace_choice_texts
    setup_choice_map
  end
  
  def replace_choice_texts
    $game_message.choices.size.times do |i|
      data = $game_message.get_choice_option(:text, i+1)  
      next unless data
      data.reverse.each do |text, cond|      
        if eval_choice_condition(cond)
          $game_message.choices[i] = text
          break
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # New. Go through hidden choices and map the indices appropriately.
  # The list of choices should only contain the list of visible choices
  # since other classes probably don't expect to have to check whether
  # a choice is hidden or not
  #-----------------------------------------------------------------------------
  def setup_choice_map
    $game_message.orig_choices = $game_message.choices.clone
    $game_message.choices.clear
    $game_message.orig_choices.each_with_index do |choice, i|
      next if choice_hidden?(i+1)
      $game_message.choices.push(choice)
      $game_message.choice_map.push(i)
    end
    
    # Add "branch" choice to the list. Remember to subtract 1 since it's always
    # the last one. The assumption here is that the branch choice is never
    # hidden...
    if $game_message.choice_cancel_type > 0
      $game_message.choice_map.push($game_message.orig_choices.size )
    end
    
    # We need to update the cancel choice.      
    # Cancel choice of 0 means it is disallowed.
    if $game_message.choice_cancel_type == 0
      ###
    
    # By default, the last choice is the branch choice, so we just set it to the
    # last one in our choice map
    elsif $game_message.choice_cancel_type == $game_message.orig_choices.size + 1
      $game_message.choice_cancel_type = $game_message.choice_map.size
    # Canceling is allowed, but the cancel choice is hidden, so we disallow
    # canceling by setting it to zero
    elsif choice_hidden?($game_message.choice_cancel_type) || choice_disabled?($game_message.choice_cancel_type)
      $game_message.choice_cancel_type = 0      
    end

    # redefine the choice proc
    $game_message.choice_proc = Proc.new {|n|
      @branch[@indent] = $game_message.choice_map[n] || 4
    }
  end
  
  # Return true if the choice is hidden
  def choice_hidden?(n)
    $game_message.get_choice_option(:hidden, n)
  end
  
  def choice_disabled?(n)
    $game_message.get_choice_option(:condition, n)
  end
  
  # add a choice option
  def choice_option(type, choice_num, arg)
    $game_message.set_choice_option(type.to_sym, choice_num, arg)
  end
  
  def hide_choice(choice_num, condition)
    $game_message.set_choice_option(:hidden, choice_num, eval_choice_condition(condition))
  end
  
  def disable_choice(choice_num, condition)
    $game_message.set_choice_option(:condition, choice_num, eval_choice_condition(condition))
  end
  
  def color_choice(choice_num, value)
    $game_message.set_choice_option(:color, choice_num, value)
  end
  
  def disable_color_choice(choice_num, value)
    $game_message.set_choice_option(:disable_color, choice_num, value)
  end
  
  def text_choice(choice_num, text, condition="")
    $game_message.set_choice_option(:text, choice_num, [text, condition])
  end
  
  def eval_choice_condition(condition, p=$game_party, t=$game_troop, s=$game_switches, v=$game_variables)
    return true if condition.empty?
    eval(condition)
  end
end

class Window_ChoiceList < Window_Command
  
  def update_placement
    self.width = [max_choice_width + 12, 96].max + padding * 2
    self.width = [width, Graphics.width].min
    self.height = fitting_height($game_message.choices.size)
    self.x = Graphics.width - width
    if @message_window.y >= Graphics.height / 2
      self.y = @message_window.y - height
    else
      self.y = @message_window.y + @message_window.height
    end
  end

  # Overwrite. Apply choice options when making text
  def make_command_list
    $game_message.orig_choices.each_with_index do |choice, i|
      next if $game_message.choice_hidden?(i+1)
      condition = $game_message.get_choice_option(:condition, i+1)
      condition_met = condition.nil? ? true : !condition
      add_command(choice, :choice, condition_met)
    end
  end
  
  # Apply font-related choice options when drawing choices
  alias :th_multiple_choice_draw_item :draw_item
  def draw_item(index)
    set_choice_color(index)
    th_multiple_choice_draw_item(index)
  end

  # I have my own font settings for each option so don't need the default
  def reset_font_settings
  end
  
  # New. Apply font settings
  def set_choice_color(index)
    color = $game_message.get_choice_option(:color, $game_message.choice_map[index] + 1)      
    disable_color = $game_message.get_choice_option(:disable_color, $game_message.choice_map[index] + 1)      
    if color && command_enabled?(index)
      change_color(text_color(color), command_enabled?(index))
    elsif disable_color && !command_enabled?(index)
      change_color(text_color(disable_color), command_enabled?(index))
    else
      change_color(normal_color, command_enabled?(index))
    end
  end
end