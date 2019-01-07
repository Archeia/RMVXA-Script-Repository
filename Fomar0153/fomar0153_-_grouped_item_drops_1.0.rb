=begin
Grouped Item Drops
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Groups item drops.
----------------------
Instructions
----------------------
Plug and play edit the vocab if you want.
----------------------
Known bugs
----------------------
None
=end

module Vocab
  ObtainItem      = "%sx%s found!"
end


module BattleManager
  #--------------------------------------------------------------------------
  # * Dropped Item Acquisition and Display
  #--------------------------------------------------------------------------
  def self.gain_drop_items
    items = {}
    weapons = {}
    armours = {}
    $game_troop.make_drop_items.each do |item|
      if item.is_a?(RPG::Item)
        items[item.id] = 0 unless items[item.id]
        items[item.id] += 1
      end
      if item.is_a?(RPG::Weapon)
        weapons[item.id] = 0 unless weapons[item.id]
        weapons[item.id] += 1
      end
      if item.is_a?(RPG::Armor)
        armours[item.id] = 0 unless armours[item.id]
        armours[item.id] += 1
      end
    end
    items.each_key {|key|
      $game_party.gain_item($data_items[key], items[key])
      if items[key] == 1
        $game_message.add(sprintf(Vocab::ObtainItem, $data_items[key].name))
      else
        $game_message.add(sprintf(Vocab::ObtainItem, $data_items[key].name, items[key]))
      end
    }
    weapons.each_key {|key|
      $game_party.gain_item($data_items[key], weapons[key])
      if items[key] == 1
        $game_message.add(sprintf(Vocab::ObtainItem, $data_weapons[key].name))
      else
        $game_message.add(sprintf(Vocab::ObtainItem, $data_weapons[key].name, weapons[key]))
      end
    }
    armours.each_key {|key|
      $game_party.gain_item($data_items[key], armours[key])
      if items[key] == 1
        $game_message.add(sprintf(Vocab::ObtainItem, $data_armors[key].name))
      else
        $game_message.add(sprintf(Vocab::ObtainItem, $data_armors[key].name, armours[key]))
      end
    }
    wait_for_message
  end
end