=begin
#===============================================================================
 Title: Convert Code: Eval
 Author: Hime
 Date: Nov 25, 2013
 URL: http://himeworks.com/2013/09/17/battle-reactions/
--------------------------------------------------------------------------------
 ** Change log
 Nov 25, 2013
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
 
 This script adds a new convert code to your project called "eval".
 
 You can use this to evaluate arbitrary formulas inside your show text
 commands.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 

 In your show text command, use the convert code
 
    \eval{< FORMULA >}

 The formula will be evaluated when the message is being processed and the
 appropriate value will be displayed.
 
 The following formula variables are available
 
   p - game party
   t - game troop
   s - game switches
   v - game variables
 
 Note that the text is not automatically re-positioned to fill in the gaps.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ConvertCodeEval"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
class Window_Base < Window
  
  alias :th_convert_code_eval_convert_escape_characters :convert_escape_characters
  def convert_escape_characters(text)
    result = th_convert_code_eval_convert_escape_characters(text)
    result.gsub!(/\eEVAL{<(.*?)>}/i) { eval_convert_code($1) }
    result
  end
  
  def eval_convert_code(formula, p=$game_party, t=$game_troop, s=$game_switches, v=$game_variables)
    eval(formula)
  end
end