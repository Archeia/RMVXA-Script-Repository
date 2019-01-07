=begin
SES Instance Item compatibility patch with Modern Algebra Receipt Window
author : Estriole
License: Free to use in all project (except the one containing pornography)
as long as i credited (ESTRIOLE).
=end

class Game_Party < Game_Unit
  alias receipt_window_affix_patch_gain_gold gain_gold
  def gain_gold(amount)
    receipt_window_affix_patch_gain_gold(amount)
    add_to_receipt([:G, amount]) if $game_temp.affix_gain_item_event_flag == true
  end

  def gain_item(*args)
    oitem = args[0] if !args[0].nil?
    item = oitem
    args[1].times do
      if item && item.unique
        args[0] = if item.is_a?(RPG::Weapon) then new_item(item, :weapon)
        elsif item.is_a?(RPG::Armor) then args[0] = new_item(item, :armor)
        elsif item.is_a?(RPG::Item) then args[0] = new_item(item, :item) end
      end
      old_value = $game_party.marw_item_number_plus_equips(args[0])
      trade_item(args[0], 1)
      new_value = $game_party.marw_item_number_plus_equips(args[0])      
      if $game_temp.affix_gain_item_event_flag == true
      update_item_receipt(:W,args[0].id,new_value,old_value) if item.is_a?(RPG::Weapon) && item.unique
      update_item_receipt(:A,args[0].id,new_value,old_value) if item.is_a?(RPG::Armor) && item.unique
      update_item_receipt(:I,args[0].id,new_value,old_value) if item.is_a?(RPG::Item) && item.unique
      end
    end
    if item && !item.unique && $game_temp.affix_gain_item_event_flag == true
    update_item_receipt(:W,args[0].id,args[1],0) if item.is_a?(RPG::Weapon)
    update_item_receipt(:A,args[0].id,args[1],0) if item.is_a?(RPG::Armor)
    update_item_receipt(:I,args[0].id,args[1],0) if item.is_a?(RPG::Item)
    end
  end
  
  def update_item_receipt(code, id, new_value, old_value)
    if new_value != old_value && !$game_switches[MARW_CONFIGURATION[:manual_switch]]
      add_to_receipt([code, id, new_value - old_value])
    end
  end  
  
  def add_to_receipt(*items)
    items.each {|item| $game_map.add_to_receipt(marw_format_item_array(item)) }
  end
  
  def marw_format_item_array(item_array)
    if item_array.is_a?(RPG::BaseItem)
      return [item_array.icon_index, item_array.name]
    elsif item_array.is_a?(Array)
      amount = (item_array[2].is_a?(Integer) ? sprintf(MARW_CONFIGURATION[:vocab_amount], item_array[2]) : "")
      return case item_array[0]
      when :I, :i, :item,    :Item,    0
        item = $data_items[item_array[1]]
        [item.icon_index, item.name, amount]
      when :W, :w, :weapon,  :Weapon,  1
        item = $data_weapons[item_array[1]]
        [item.icon_index, item.name, amount]
      when :A, :a, :armor,   :Armor,   2
        item = $data_armors[item_array[1]]
        [item.icon_index, item.name, amount]
      when :G, :g, :gold,    :Gold,    3
        [MARW_CONFIGURATION[:gold_icon], "", sprintf(MARW_CONFIGURATION[:vocab_amount], item_array[1])]
      when :S, :s, :special, :Special, 4
        item_array[3] = sprintf(MARW_CONFIGURATION[:vocab_amount], item_array[3]) if item_array[3].is_a?(Integer)
        item_array.drop(1)
      else item_array
      end
    else
      item_array
    end
  end

end

class Game_Temp
  attr_accessor :affix_gain_item_event_flag
end

class Game_Interpreter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Gold
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def command_125(*args, &block)
    $game_temp.affix_gain_item_event_flag = true
    marw_command125_8qu7(*args, &block) # Call Original Method
    $game_temp.affix_gain_item_event_flag = false
  end
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def command_126(*args, &block)
    $game_temp.affix_gain_item_event_flag = true
    marw_command126_8qu7(*args, &block) # Call Original Method
    $game_temp.affix_gain_item_event_flag = false
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Weapon
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def command_127(*args, &block)
    $game_temp.affix_gain_item_event_flag = true
    marw_command127_8qu7(*args, &block) # Call Original Method
    $game_temp.affix_gain_item_event_flag = false
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Armor
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def command_128(*args, &block)
    $game_temp.affix_gain_item_event_flag = true
    marw_command128_8qu7(*args, &block) # Call Original Method
    $game_temp.affix_gain_item_event_flag = false
  end
end