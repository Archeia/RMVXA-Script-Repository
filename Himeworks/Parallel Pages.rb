=begin
#==============================================================================
 ** Parallel Pages
 Author: Hime
 Date: Apr 16, 2014
------------------------------------------------------------------------------
 ** Change log
 Apr 16, 2014
   - fixed conflicting name issue between Custom Page Conditions
 Jul 30, 2013
   - updated regex
 Mar 6, 2013
   - fixed issue where forced move routes continue when time frozen
 Mar 5, 2013
   - Add-on for Jet's freeze-time to halt parallel page processing
   - Parallel page no longer restarts on scene change, but it does when
     changing event pages
   - fixed bug where parallel pages are still running even if the parall
     page conditions are not met
 Nov 17, 2012
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
 Allows you to designate an event page to be a "parallel page", which can
 be assigned to another page. The commands on the parallel page will be
 executed concurrently while the current event page is waiting on another
 trigger.
 
 The parallel page obeys all event conditions, so if the conditions are not
 met the parallel page will not execute.
 
 Two comments are required
 
 1: To designate a page as the parallel page, create a comment with the string
       
       <parallel page>
    
 2: Any pages that should use this page as the parallel page should have a
    comment with the string
    
       <parallel page: n>
       
    Where n is the page number of the designated parallel page
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ParallelPages"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module TH
  module Parallel_Pages
    Page_Regex = /<parallel[-_ ]page:\s*(\d+)>/i
    Regex = /<parallel[-_ ]page>/i
  end
end
#==============================================================================
# ** Rest of Script
#==============================================================================
module RPG
  class Event::Page
    
    # Parallel pages should not be executed normally
    def is_parallel_page?
      return @is_parallel_page unless @is_parallel_page.nil?
      return @is_parallel_page = @list.any? {|cmd|
        cmd.code == 108 && cmd.parameters[0] =~ TH::Parallel_Pages::Regex
      }
    end
    
    # The parallel page associated with this page. Currently each page
    # may have at most one parallel page
    def parallel_page
      return @parallel_page unless @parallel_page.nil?
      @list.each {|cmd|
        if cmd.code == 108 && res = cmd.parameters[0].match(TH::Parallel_Pages::Page_Regex)
          return @parallel_page = res[1].to_i
        end
      }
      return @parallel_page = 0
    end
  end
end

class Game_Event < Game_Character
  
  #-----------------------------------------------------------------------------
  # Parallel page does not run on its own.
  #-----------------------------------------------------------------------------
  alias :th_parallel_pages_conditions_met? :conditions_met?
  def conditions_met?(page)
    return false if page.is_parallel_page?
    return th_parallel_pages_conditions_met?(page)
  end
  
  #-----------------------------------------------------------------------------
  # When we change pages, we need to check our parallel page
  #-----------------------------------------------------------------------------
  alias :th_parallel_pages_setup_page_settings :setup_page_settings
  def setup_page_settings
    th_parallel_pages_setup_page_settings
    setup_parallel_page
  end
  
  #-----------------------------------------------------------------------------
  # New. Create a page interpreter
  #-----------------------------------------------------------------------------
  def setup_parallel_page
    @parallel_page = nil
    return unless @page
    @parallel_page_number = @page.parallel_page
    if @parallel_page_number > 0
      @parallel_page = @event.pages[@parallel_page_number - 1]
    end
    if @parallel_page && @parallel_page.is_parallel_page?
      @parallel_interpreter = Game_Interpreter.new
    else
      @parallel_interpreter = nil
    end
  end
  
  
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :th_parallel_pages_refresh :refresh
  def refresh
    th_parallel_pages_refresh
    setup_parallel_page unless @parallel_interpreter
  end
  
  #-----------------------------------------------------------------------------
  # When we change pages, we need to check our parallel page
  #-----------------------------------------------------------------------------
  alias :th_parallel_pages_update :update
  def update
    th_parallel_pages_update
    return unless @parallel_interpreter
    @parallel_interpreter.setup(@parallel_page.list, @event.id) unless @parallel_interpreter.running?
    @parallel_interpreter.update unless pause_update?
  end
  
  #-----------------------------------------------------------------------------
  # When we change pages, we need to check our parallel page
  #-----------------------------------------------------------------------------
  def pause_update?
    return true unless th_parallel_pages_conditions_met?(@parallel_page)
    false
  end
end

#-------------------------------------------------------------------------------
# Freeze time compatibility. Freeze Time must be placed above this script.
#-------------------------------------------------------------------------------
if Game_System.instance_methods.include?(:map_frozen)

  class Game_Event < Game_Character
    
    alias :th_freeze_time_update_routine_move :update_routine_move
    def update_routine_move
      th_freeze_time_update_routine_move unless $game_system.map_frozen
    end
    
    alias :th_freeze_time_pause_update? :pause_update?
    def pause_update?
      return true if $game_system.map_frozen
      th_freeze_time_pause_update?
    end
  end
end