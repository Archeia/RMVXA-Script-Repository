=begin
Include Battle Events from another Troop
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
No requirements
Allows you to include all the battle events from a troop 
in all the other troops.
----------------------
Instructions
----------------------
Choose which troop you wish to have the set events and 
set INCLUDE_EVENTS_TROOP_ID to its id
----------------------
Known bugs
----------------------
None
=end
module DataManager
  #--------------------------------------------------------------------------
  # ● Choose the troop whose events should be included in every battle
  #--------------------------------------------------------------------------
  INCLUDE_EVENTS_TROOP_ID = 1
  #--------------------------------------------------------------------------
  # ● Alias the loading methods
  #--------------------------------------------------------------------------
  class << self
    alias include_events_load_normal_database load_normal_database
    alias include_events_load_battle_test_database load_battle_test_database
  end
  #--------------------------------------------------------------------------
  # ● Load the original database and then inclde the additional events
  #--------------------------------------------------------------------------
  def self.load_normal_database
    include_events_load_normal_database
    include_battle_events
  end
  #--------------------------------------------------------------------------
  # ● Load the original database and then inclde the additional events
  #--------------------------------------------------------------------------
  def self.load_battle_test_database
    include_events_load_battle_test_database
    include_battle_events
  end
  #--------------------------------------------------------------------------
  # ● Include the first troops events in all other troops
  #--------------------------------------------------------------------------
  def self.include_battle_events
    for troop in $data_troops
      next if troop.nil?
      unless troop.id == INCLUDE_EVENTS_TROOP_ID
        troop.pages += $data_troops[INCLUDE_EVENTS_TROOP_ID].pages
      end
    end
  end
end