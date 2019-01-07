=begin
#===============================================================================
 Title: Counted loop
 Author: Hime
 Date: Mar 12, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 12, 2013
   - added support for variables
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to turn a while loop into a counted loop.
 
--------------------------------------------------------------------------------
 ** Usage 
 
 Immediately before a loop command, add a comment
    
    <loop count: x>
    
 For some integer x.
 The loop will then iterate x times
 
 You can use the syntax
 
    <loop count: v[i]>
    
 To use the value stored in the i'th game variable.   
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CountedLoops"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
module TH
  module Counted_Loops
    Regex = /<loop count: (\d+|v\[\d+\])>/i
    
    def self.eval_loop_count(string, v)
      Kernel.eval(string)
    end
  end
end

class Game_Interpreter
  
  alias :th_counted_loops_clear :clear
  def clear
    th_counted_loops_clear
    @loop_counts = []       # index by indentation
    @loop_times = []
  end
  
  #-----------------------------------------------------------------------------
  # Check previous command to see if this is a counted loop
  # The loop counts and loop times are stored in an array indexed by
  # indentation.
  #-----------------------------------------------------------------------------
  alias :th_counted_loops_command_112 :command_112
  def command_112
    prev_cmd = @list[@index-1]
    if prev_cmd.code == 108
      if prev_cmd.parameters[0] =~ TH::Counted_Loops::Regex
        @loop_counts[@indent] = TH::Counted_Loops.eval_loop_count($1, $game_variables)
      else
        @loop_counts[@indent] = -1
      end
    end
    @loop_times[@indent] = 0
    th_counted_loops_command_112
  end
  
  #-----------------------------------------------------------------------------
  # Check previous command to see if this is a counted loop
  #-----------------------------------------------------------------------------
  alias :th_counted_loops_command_413 :command_413
  def command_413
    th_counted_loops_command_413
    @loop_times[@indent] += 1
    
    # During a loop, you do not actually increment the indentation. Therefore,
    # the "loop start" and "repeat above" commands are on the same level.
    # In order to "break" from the loop, we simply skip over all of the
    # commands until we reach "loop end"
    if @loop_times[@indent] == @loop_counts[@indent]
      @indent += 1
      command_113
    end
  end
end