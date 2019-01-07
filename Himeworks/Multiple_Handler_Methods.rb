=begin
#===============================================================================
 Title: Multiple Handler Methods
 Author: Hime
 Date: Jul 14, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jul 14, 2013
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
 
 This script allows you to assign multiple methods to a single window handler.
 All assigned methods will be executed when the handler is called.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 When assigning methods to handlers, simply re-use the same handle as such:
 
   set_handler(:ok, method(first_ok))
   set_handler(:ok, method(second_ok))
   
 All methods will be executed when the handler is called.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_MultipleHandlerMethods"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Multiple_Handler_Methods
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
class Window_Selectable < Window_Base
  
  #-----------------------------------------------------------------------------
  # Overwrite to store methods as a list
  #-----------------------------------------------------------------------------
  def set_handler(symbol, method)
    @handler[symbol] ||= []
    @handler[symbol].push(method)
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite to store methods as a list
  #-----------------------------------------------------------------------------
  def call_handler(symbol)
    @handler[symbol].each {|method| method.call } if handle?(symbol)
  end
end