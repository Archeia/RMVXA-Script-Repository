=begin
#===============================================================================
 Title: Jump to Label
 Author: Hime
 Date: Apr 13, 2013
--------------------------------------------------------------------------------
 ** Change log
 Apr 13, 2013
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
 
 This script allows you to use a script call to jump to a label in the
 event list. You can pass in anything as long as it evaluates to a string,
 such as variables.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Make a script call
 
   jump_to_label(label_name, match_substring, ignore_case)
   
 Where
 `label_name` is the name of the label you want to jump to
 `match_substring` is a boolean that determines whether partial matching is ok
 `ignore_case` is a boolean that allows you to ignore label casing.
 
 For example if you have a label called "test label", then the following calls
 will all jump to that label
 
   jump_to_label("test label")
   jump_to_label("test", true)
   jump_to_label("TEST LAbeL", false, true)
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_JumpToLabel"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Interpreter
  def jump_to_label(label, match_substring=false, ignore_case=false)
    label = label.to_s
    label.downcase! if ignore_case
    @list.size.times do |i|
      if @list[i].code == 118 && (
          match_substring && @list[i].parameters[0] =~ /#{label}/ ||
          ignore_case && @list[i].parameters[0].downcase == label ||
          @list[i].parameters[0] == label \
        )
        @index = i
        return
      end
    end
  end
end