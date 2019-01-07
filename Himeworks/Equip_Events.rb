=begin
#===============================================================================
 ** Equip Events
 Author: Hime
 Date: Feb 26, 2013
--------------------------------------------------------------------------------
 ** Change log
 Feb 26, 2014
   - re-ordered event execution .dequip event is executed before equip event.
 Jun 7, 2013
   - updated common event queue for backwards compatibility. common event ID
     returns the first element in the queue list
 Jun 6, 2013
   - equip events do not automatically run in scenes now. You will need
     the Scene Interpreter script
 May 20, 2013
   - common events now queue up and will be run automatically
 Feb 15, 2013
   - added support for dequipping items
 Sep 21
   - fixed bug where equipping nothing threw NoMethod error
 Sep 6, 2012
   - initial release
--------------------------------------------------------------------------------   
 ** Description
 
 Assign common events to equips and have them run when you change your equips.

--------------------------------------------------------------------------------   
 ** Installation
 
 Place this below Materials and above Main.
 
--------------------------------------------------------------------------------   
 ** Usage
 
 Tag your equips with
 
    <equip event: x>
    <dequip event: x>
    
 For some common event ID x.
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["Tsuki_EquipEvents"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module Tsuki
  module Equip_Events
    
    Equip_Regex = /<equip[-_ ]event:\s*(\d+)>/i
    Dequip_Regex = /<dequip[-_ ]event:\s*(\d+)>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class EquipItem
    
    def equip_event_id
      return @equip_event_id unless @equip_event_id.nil?
      res = Tsuki::Equip_Events::Equip_Regex.match(self.note)
      return @equip_event_id = res ? res[1].to_i : 0
    end
    
    def dequip_event_id
      return @dequip_event_id unless @dequip_event_id.nil?
      res = Tsuki::Equip_Events::Dequip_Regex.match(self.note)
      return @dequip_event_id = res ? res[1].to_i : 0
    end
  end
end

class Game_Actor
  
  alias :th_equip_events_change_equip :change_equip
  def change_equip(slot_id, item)
    old_item = @equips[slot_id].object
    th_equip_events_change_equip(slot_id, item)
    if @equips[slot_id].object == item
      $game_temp.reserve_common_event(old_item.dequip_event_id) if old_item
      $game_temp.reserve_common_event(item.equip_event_id) if item
    end
  end
end

unless $imported["TH_CommonEventQueue"]
  class Game_Temp

    attr_reader :reserved_common_events
    alias :th_common_event_queue_init :initialize
    def initialize
      th_common_event_queue_init
      @reserved_common_events = []
    end

    # re-write
    def reserve_common_event(common_event_id)
      @reserved_common_events.push(common_event_id) if common_event_id > 0
    end
    
    def common_event_id
      @reserved_common_events[0]
    end

    # Note that I don't actually need to clear it out. It's done
    # by the queue.

    # true if list is not empty
    def common_event_reserved?
      !@reserved_common_events.empty?
    end

    # Grab the first one, first-in-first-out order
    def reserved_common_event
      $data_common_events[@reserved_common_events.shift]
    end
  end
end