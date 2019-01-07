=begin
#===============================================================================
 Title: Custom Event Triggers
 Author: Hime
 Date: Jan 28, 2015
--------------------------------------------------------------------------------
 ** Change log
 Jan 28, 2015
   - updated to support checking for event to event trigger on event move
 Oct 31, 2013
   - fixed bug where an event that had an event-to-event trigger could only be
     triggered when another event touches them, not when they touch another
     event. Still follows the same rules for the extended data
 Aug 22, 2013
   - fixed bug with event-to-event player triggering
 Apr 9, 2013
   - implemented parallel processing for all custom triggers
 Apr 8, 2013
   - added "region enter" trigger
   - added "region leave" trigger
 Apr 5, 2013
   - added "event_to_event" trigger
 Apr 4, 2013
   - added "timer_expire" trigger
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
 
 This script provides additional event triggers.
 The built-in event triggers include
 
   Action Trigger
   Player Touch
   Event Touch
   Autorun
   Parallel Process
   
 This script provides additional triggers.
   
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 To specify a custom page trigger, create a comment of the form
 
   <page trigger: trigger_name>
   
 Where `trigger_name` is one of the available custom event triggers.
 
 -- Extended trigger data --
 
 This script adds "extended data" to the trigger.
 Certain triggers may use this data to determine how to run.
 
 The general format for extended trigger data is
 
   <page trigger: trigger_name ext_data>
   
 Where ext_data is any string. Check the reference to see what kinds of
 extended data may be required for each trigger.
 
 -- Parallel Triggers --
 
 All event pages using custom triggers can be set as parallel processes if
 you set the trigger to Parallel Process. However, the difference is that
 rather than running constantly, they will begin to run only when their
 activation condition is met. However, after they begin running they will
 continue to run until the page is changed.
 
--------------------------------------------------------------------------------
 ** Reference
 
 Here is a list of available triggers and their trigger timing. The timing
 indicates when the page will be checked.
 
 Name: Player_Leave
 Time: Triggered when the player steps off an event. Note that this means the
       event must have below-character priority.
  Ext: None
   
 Name: Timer_Expire
 Time: Triggered when the game timer expires (eg: it goes to zero) 
  Ext: None

 Name: Event_To_Event
 Time: Triggered when an event comes into contact with another event (using the
       "event touch" rules)
  Ext: Takes a list of event ID's. Only the specified event ID's can trigger
       this event. When no ext data is specified, then any event can
       trigger this event. Use -1 if you want the player to trigger it as well
     
 Name: Region_Enter
 Time: Triggered when a player enters a particular region. Does not check if
       the player is already in the region
  Ext: Takes a list of region ID's
  
 Name: Region_Leave
 Time: Triggered when a player leaves a particular region
  Ext: Takes a list of region ID's
   
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CustomEventTriggers"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Custom_Event_Triggers
    
#===============================================================================
# ** Rest of script
#===============================================================================
    Trigger_Table = {
      # default triggers
      :action_trigger    => 0,
      :player_touch      => 1,
      :event_touch       => 2,
      :autorun           => 3,
      :parallel_process  => 4,
      
      # custom triggers
      :player_leave      => 5,
      :timer_expire      => 6,
      :event_to_event    => 7,
      :region_enter      => 8,
      :region_leave      => 9
    }
    
    Regex = /<page[-_ ]trigger:\s*(\w+)\s*(.*)>/i
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
module RPG
  class Event::Page
    
    def parallel_process?
      return @old_trigger == 4
    end
    
    #---------------------------------------------------------------------------
    # Load any custom triggers, if necessary
    #---------------------------------------------------------------------------
    alias :th_custom_event_triggers_trigger :trigger
    def trigger
      parse_event_triggers unless @custom_event_triggers_checked
      th_custom_event_triggers_trigger
    end
    
    #---------------------------------------------------------------------------
    # Extended trigger data. Use depends on the trigger type
    #---------------------------------------------------------------------------
    def trigger_ext
      return @trigger_ext unless @trigger_ext.nil?
      parse_event_triggers unless @custom_event_triggers_checked
      return @trigger_ext
    end
    
    #---------------------------------------------------------------------------
    # Returns a symbol representing the trigger type. These are the keys in
    # the trigger table above
    #---------------------------------------------------------------------------
    def trigger_type
      return @trigger_type unless @trigger_type.nil?
      parse_event_triggers unless @custom_event_triggers_checked
      return @trigger_type
    end
    
    #---------------------------------------------------------------------------
    # Search for a page trigger comment
    #---------------------------------------------------------------------------
    def parse_event_triggers
      @old_trigger = @trigger
      @trigger_ext = ""
      @list.each do |cmd|
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Custom_Event_Triggers::Regex
          @trigger_type = $1.downcase.to_sym
          @trigger = TH::Custom_Event_Triggers::Trigger_Table[@trigger_type]
          @trigger_ext = parse_extended_trigger($2)
        end
      end
      @custom_event_triggers_checked = true
    end
    
    #---------------------------------------------------------------------------
    # Parse the extended data according to the trigger type. Different triggers
    # may expect different input
    #---------------------------------------------------------------------------
    def parse_extended_trigger(data)
      case @trigger_type
      when :event_to_event, :region_enter, :region_leave
        @trigger_ext = data.split.map{|val| val.to_i}
      else
        @trigger_ext = data
      end
    end
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Timer
  
  #-----------------------------------------------------------------------------
  # Check map events for any events that trigger on time expiry
  #-----------------------------------------------------------------------------
  alias :th_custom_event_triggers_on_expire :on_expire
  def on_expire
    th_custom_event_triggers_on_expire
    $game_map.events.each_value do |event|
      event.check_event_trigger_on_timer_expire([6])
    end
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Player < Game_Character
  
  attr_reader :last_region_id
  attr_reader :last_x
  attr_reader :last_y
  
  alias :th_custom_event_triggers_update :update
  def update
    store_previous_position unless moving?
    th_custom_event_triggers_update
  end
  
  alias :th_custom_event_triggers_update_nonmoving :update_nonmoving
  def update_nonmoving(last_moving)
    th_custom_event_triggers_update_nonmoving(last_moving)
    return if $game_map.interpreter.running?
    if last_moving
      check_player_leave_event 
      if @last_region_id != self.region_id
        check_player_region_enter_events
        check_player_region_leave_events
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Check for events with event-to-event trigger as well, in case the player
  # also triggers it
  #-----------------------------------------------------------------------------
  alias :th_custom_event_triggers_check_event_trigger_touch :check_event_trigger_touch
  def check_event_trigger_touch(x, y)
    th_custom_event_triggers_check_event_trigger_touch(x, y)
    return if $game_map.interpreter.running?
    check_event_to_event_touch(x, y, [7], true)
  end
  
  #-----------------------------------------------------------------------------
  # New. Keep track of most recent position
  #-----------------------------------------------------------------------------
  def store_previous_position
    @last_real_x = @real_x
    @last_real_y = @real_y
    @last_x = @x
    @last_y = @y
    @last_region_id = self.region_id
  end
  
  #-----------------------------------------------------------------------------
  # New. Determines if any events at the player's previous position should be
  # triggered
  #-----------------------------------------------------------------------------
  def check_player_leave_event
    check_event_trigger_before([5])
  end
  
  #-----------------------------------------------------------------------------
  # New. Check any events in the player's previous position
  #-----------------------------------------------------------------------------
  def check_event_trigger_before(triggers)
    start_map_event(@last_x, @last_y, triggers, false)
  end
  
  #-----------------------------------------------------------------------------
  # New. Check any events in the player's previous position
  #-----------------------------------------------------------------------------
  def check_player_region_enter_events
    $game_map.events.each_value do |event|
      event.check_event_trigger_on_region_enter
    end
  end
  
  def check_player_region_leave_events
    $game_map.events.each_value do |event|
      event.check_event_trigger_on_region_leave
    end
  end
  
  def check_event_to_event_touch(x, y, triggers, normal=false)
    $game_map.events_xy(x, y).each do |event|
      next unless event.trigger_in?(triggers) && event.normal_priority? == normal
      event.start if event.trigger_ext.empty? || event.trigger_ext.include?(-1)
    end
  end
end

class Game_Event < Game_Character
  
  alias :th_custom_event_triggers_start :start
  def start
    return if empty?
    if @page.parallel_process?
      @interpreter = Game_Interpreter.new
    else
      th_custom_event_triggers_start
    end
  end
  
  #-----------------------------------------------------------------------------
  # New. Returns the extended trigger data
  #-----------------------------------------------------------------------------
  def trigger_ext
    @page.nil? ? [] : @page.trigger_ext
  end
  
  #-----------------------------------------------------------------------------
  # Start an event if timer expires
  #-----------------------------------------------------------------------------
  def check_event_trigger_on_timer_expire(triggers)
    start if trigger_in?(triggers)
  end
  
  #-----------------------------------------------------------------------------
  # First check event touch with player, then event touch with event
  #-----------------------------------------------------------------------------
  alias :th_custom_event_triggers_check_event_trigger_touch :check_event_trigger_touch
  def check_event_trigger_touch(x, y)
    th_custom_event_triggers_check_event_trigger_touch(x, y)    
    return if $game_map.interpreter.running?  
    check_event_to_event_touch(x, y, [7])
  end
  
  #-----------------------------------------------------------------------------
  # Check whether events coming into contact should trigger. If the current
  #-----------------------------------------------------------------------------
  def check_event_to_event_touch(x, y, triggers)
    events = $game_map.events_xy(x, y)
    canStart = trigger_in?(triggers)
    events.each do |event|
      return if event == self
      # start this event if the other event can trigger this event
      start if !@starting && canStart && (trigger_ext.empty? || trigger_ext.include?(event.id))
      next unless event.trigger_in?(triggers)
      
      # start the other event if this event can trigger the other event
      event.start if event.trigger_ext.empty? || event.trigger_ext.include?(@id)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Check whether events should run due to player entering a region
  #-----------------------------------------------------------------------------
  def check_event_trigger_on_region_enter
    start if @trigger == 8 && trigger_ext.include?($game_player.region_id)
  end
  
  #-----------------------------------------------------------------------------
  # Check whether events should run due to player leaving a region
  #-----------------------------------------------------------------------------
  def check_event_trigger_on_region_leave
    start if @trigger == 9 && trigger_ext.include?($game_player.last_region_id)
  end
  
  alias :th_trigger_conditions_update :update
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    last_moving = moving?
    
    th_trigger_conditions_update    
    update_nonmoving(last_moving) unless moving?
  end
  
  def update_nonmoving(last_moving)
    if last_moving
      check_event_to_event_touch(x, y, [7])
    end
  end
end