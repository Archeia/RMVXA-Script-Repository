#===============================================================================
# Compatibility with SES - Instance Items
#===============================================================================
if $imported["SES - Instance Items"]  
  class Game_Inventory
    [:items, :weapons, :armors].each do |i|
      define_method(i) do
        eval("@#{i}.keys.sort.collect { |id| $game_#{i}[id] }")
      end
    end
  end
  
  class Game_Party < Game_Unit
    def gain_item(*args)
      oitem = args[0] if !args[0].nil?
      args[1].times do
        item = oitem
        if item && item.unique
          args[0] = if item.is_a?(RPG::Weapon) then new_item(item, :weapon)
          elsif item.is_a?(RPG::Armor) then args[0] = new_item(item, :armor)
          elsif item.is_a?(RPG::Item) then args[0] = new_item(item, :item) end
          end
        @inventory.gain_item(args[0], 1)
      end
    end
    
    def lose_item(*args)
      args[1] *= -1
      @inventory.gain_item(*args)
    end
  end
end