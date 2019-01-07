=begin
#==============================================================================
 Title Large Choices
 Author: Hime
 Date: Nov 18, 2013
------------------------------------------------------------------------------
 ** Change log
 Nov 18, 2013
   - updated to preserve the event page's original list
 Apr 10, 2013
   - added option to disable automatic show combining
 Mar 26, 2013
   - fixed bug where cancel choice was not properly updated
 Jan 12, 2013
   - fixed bug where the first set of nested options were numbered incorrectly
 Dec 7, 2012
   - implemented proper branch canceling
 Dec 6, 2012
   - Initial release
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
 
 This script combines groups of "show choice" options together as one large
 command. This allows you to create more than 4 choices by simply creating
 several "show choice" commands.
------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
------------------------------------------------------------------------------
 ** Usage
 
 Add a show choice command.
 If you want more choices, add another one, and fill it out as usual.
 
 Note that you should only specify one cancel choice (if you specify more than
 one, then the last one is taken).
 
 For "branch" canceling, note that *all* cancel branches are executed.
 You should only have a cancel branch on the last set of choices
 
 You can disable automatic choice combining by enabling the "Manual Combine"
 option, which will require you to make this script call before the first
 show choice command
 
    combine_choices
    
 In order to combine choices together
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_LargeChoices"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module TH
  module Large_Choices
    
    # Turning this option on will require you to manually specify that
    # a sequence of Show Choice options should be combined
    Manual_Combine = false
    
#==============================================================================
# ** Rest of the script
#==============================================================================     
    Code_Filter = [402, 403, 404]
    Regex = /<large choices>/i
  end
end

class Game_Temp
  
  # temp solution to get this working
  attr_accessor :branch_choice
  
  def branch_choice
    @branch_choice || 5
  end
end

class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  # Clean up
  #-----------------------------------------------------------------------------
  alias :th_large_choices_clear :clear
  def clear
    th_large_choices_clear
    @first_choice_cmd = nil
    @choice_search = 0
    @combine_choices = false
  end
  
  #-----------------------------------------------------------------------------
  # Prepare for more choices
  #-----------------------------------------------------------------------------
  alias :th_large_choices_setup_choices :setup_choices
  def setup_choices(params)
    
    # Make a copy of our list so we don't modify the original
    @list = Marshal.load(Marshal.dump(@list))
    
    # start with our original choices
    th_large_choices_setup_choices(params)
    
    return if TH::Large_Choices::Manual_Combine && !@combine_choices
    
    # store our "first" choice in the sequence
    @first_choice_cmd = @list[@index]
    
    # reset branch choice
    $game_temp.branch_choice = @first_choice_cmd.parameters[1]
    
    # Start searching for more choices
    @num_choices = $game_message.choices.size
    @choice_search = @index + 1
    search_more_choices
  end
  
  def combine_choices
    @combine_choices = true
  end
  
  #-----------------------------------------------------------------------------
  # New. Check whether the next command (after all branches) is another choice
  # command. If so, merge it with the first choice command.
  #-----------------------------------------------------------------------------
  def search_more_choices
    skip_choice_branches
    next_cmd = @list[@choice_search]
    
    # Next command isn't a "show choice" so we're done
    return if next_cmd.code != 102
    
    @choice_search += 1
    # Otherwise, push the choices into the first choice command to merge
    # the commands.
    @first_choice_cmd.parameters[0].concat(next_cmd.parameters[0])
    
    # Update all cases to reflect merged choices
    update_show_choices(next_cmd.parameters)
    update_cancel_choice(next_cmd.parameters)
    update_choice_numbers
    
    # delete the command to effectively merge the branches
    @list.delete(next_cmd)
    
    # Now search for more
    search_more_choices
  end

  #-----------------------------------------------------------------------------
  # New. Update the options for the first "show choice" command
  #-----------------------------------------------------------------------------
  def update_show_choices(params)
    params[0].each {|s| $game_message.choices.push(s) }
  end
  
  #-----------------------------------------------------------------------------
  # New. If cancel specified, update it to reflect merged choice numbers
  # The last one is taken if multiple cancel choices are specified
  #-----------------------------------------------------------------------------
  def update_cancel_choice(params)
    
    # disallow, just ignore
    return if params[1] == 0    
    
    # branch on cancel
    return update_branch_choice if params[1] == 5
    
    # num_choices is not one-based
    cancel_choice = params[1] + (@num_choices)
    # update cancel choice, as well as the first choice command
    $game_message.choice_cancel_type = cancel_choice
    @first_choice_cmd.parameters[1] = cancel_choice
  end
  
  #-----------------------------------------------------------------------------
  # New. Set the initial choice command to "branch cancel"
  #-----------------------------------------------------------------------------
  def update_branch_choice
    branch_choice = $game_message.choices.size + 1
    $game_message.choice_cancel_type = branch_choice
    $game_temp.branch_choice = branch_choice
    @first_choice_cmd.parameters[1] = branch_choice
  end
  
  def command_403
    command_skip if @branch[@indent] != $game_temp.branch_choice - 1
  end
  
  #-----------------------------------------------------------------------------
  # New. For each branch, update it to reflect the merged choice numbers.
  #-----------------------------------------------------------------------------
  def update_choice_numbers
    
    # Begin searching immediately after cmd 102 (show choice)
    i = @choice_search
    
    # Rough search for "When" commands. The search must skip nested commands
    while TH::Large_Choices::Code_Filter.include?(@list[i].code) || @list[i].indent != @indent
      if @list[i].code == 402 && @list[i].indent == @indent
        @list[i].parameters[0] = @num_choices 
        @num_choices += 1
      end
      i += 1
    end
  end
  
  #-----------------------------------------------------------------------------
  # New. Returns the next command after our choice branches
  #-----------------------------------------------------------------------------
  def skip_choice_branches
    # start search at the next command
    # skip all choice branch-related commands and any branches
    while TH::Large_Choices::Code_Filter.include?(@list[@choice_search].code) || @list[@choice_search].indent != @indent
      @choice_search += 1
    end
    return @choice_search
  end
end