=begin
#==============================================================================
 Title: Key Item Trigger Labels
 Author: Hime
 Date: Nov 23, 2014
------------------------------------------------------------------------------
 ** Change log
 Dec 22, 2014
  - added support for post-trigger processing
 Nov 23, 2014
  - added support for "ANY" key items
 Nov 6, 2014
  - initial release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
------------------------------------------------------------------------------
 ** Description:
 
 This script is an add-on for Event Trigger Labels.
 It allows you to assign key items as trigger labels, allowing you to use
 key items to trigger events.
 
 You can add multiple key item triggers to an event, each with their own
 set of responses.

 ------------------------------------------------------------------------------
 ** Required
 
 Event Trigger Labels
 (http://himeworks.com/2012/10/event-trigger-labels/)
 
------------------------------------------------------------------------------
 ** Installation

 Place this script below Materials and above Main
 
------------------------------------------------------------------------------
 ** Usage
 
 Instead of treating your page as one list of commands, you should instead
 treat it as different sections of commands. Each section will have its own
 label, specified in a specific format.
 
 To create a section, add a Label command and then write
 
   keyitem?(ID)
   
 Where the ID is the ID of the item that you want this trigger label to respond
 to. 
 
 To set up your items for use as key items, in the item tab of the database,
 create an item, set the item type to "Key Item".
 
 -- Consumable Items --
 
 You can have it so that you will consume one key item when you successfully
 trigger an event.
 
 Simply set the item's consumable option to "Yes". If you don't want the item
 to be consumed, set it to "No".
 
 -- Checking any item --
 
 Sometimes you simply want the event to respond to a key item regardless what
 the key item is. You can use a special "ANY keyitem" trigger label which will
 be run if the event has no matching key item label for the key item you used.
 
 Use the trigger label
 
   keyitem?(ANY)
 
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_KeyItemTriggerLabels] = true
#==============================================================================
# ** Configuration
#==============================================================================
module TH
  module Key_Item_Trigger_Labels
    Key_Item_Format = "keyitem?"
    
    Enable_Key_Item_Trigger = true # set to false if you don't want this
    Key_Item_Variable = 1242  # just a random variable...
    Key_Item_Button = :Y      # Which button to press to open key item selection window

#===============================================================================
# ** Rest of the script
#===============================================================================   
    Key_Item_Regex = /#{Regexp.escape(Key_Item_Format)}\((\d+|ANY)\)/i    
  end
end

module RPG

  class Event::Page
    
    attr_accessor :key_item_labels
    
    def key_item_labels
      @key_item_labels ||= {}
    end
    
    alias :th_key_item_trigger_labels_trigger_label? :trigger_label?
    def trigger_label?(label)
      res = th_key_item_trigger_labels_trigger_label?(label)
      return true if res
      # Check for key item triggers
      keyitem = label.match(TH::Key_Item_Trigger_Labels::Key_Item_Regex)
      if keyitem
        id = keyitem[1].upcase
        if id == "ANY"
          self.key_item_labels[0] = true
        else
          self.key_item_labels[id.to_i] = true
        end
        return true
      end
      return false
    end
  end
end

class Game_Character
  def key_item_variable
    $game_variables[TH::Key_Item_Trigger_Labels::Key_Item_Variable]
  end
end

class Game_Player < Game_Character
  
  alias :th_key_item_trigger_label_pre_trigger_event_processing :pre_trigger_event_processing
  def pre_trigger_event_processing
    th_key_item_trigger_label_pre_trigger_event_processing
    show_key_item_selection if TH::Key_Item_Trigger_Labels::Enable_Key_Item_Trigger && Input.trigger?(TH::Key_Item_Trigger_Labels::Key_Item_Button)
  end
  
  alias :th_key_item_trigger_labels_post_trigger_event_processing :post_trigger_event_processing
  def post_trigger_event_processing(triggered)
    th_key_item_trigger_labels_post_trigger_event_processing(triggered)
    if $game_variables[TH::Key_Item_Trigger_Labels::Key_Item_Variable] > 0
      post_key_trigger_event_processing(triggered)
    end
  end
  
  def post_key_trigger_event_processing(triggered)
    item = $data_items[key_item_variable]
    $game_party.consume_item(item) if item
    $game_variables[TH::Key_Item_Trigger_Labels::Key_Item_Variable] = 0
  end
  
  # show key item selection
  def show_key_item_selection
    $game_message.item_choice_variable_id = TH::Key_Item_Trigger_Labels::Key_Item_Variable
  end
end

class Game_Event < Game_Character
  
  alias :th_key_item_trigger_label_get_trigger_label :get_trigger_label
  def get_trigger_label
    label = th_key_item_trigger_label_get_trigger_label
    return label if label
    
    label = check_key_item_trigger
    return label
  end
  
  #-----------------------------------------------------------------------------
  # New. Check whether the selected key item triggers the event
  #-----------------------------------------------------------------------------
  def check_key_item_trigger
    return unless key_item_trigger_met?
    if @page.key_item_labels.include?(key_item_variable)
      return "#{TH::Key_Item_Trigger_Labels::Key_Item_Format}(#{key_item_variable})"
    elsif @page.key_item_labels.include?(0)
      return "#{TH::Key_Item_Trigger_Labels::Key_Item_Format}(ANY)"
    end
  end
  
  def key_item_trigger_met?
    return false unless @page
    return false unless TH::Key_Item_Trigger_Labels::Enable_Key_Item_Trigger
    return false if @page.key_item_labels.empty?
    return false if key_item_variable == 0
    return true
  end
end

#===============================================================================
# Instance Items patch
#===============================================================================
if $imported["TH_InstanceItems"]
  class Window_KeyItem
    def on_ok
      result = item ? item.template_id : 0
      $game_variables[$game_message.item_choice_variable_id] = result
      close
    end
  end
end