#Weapon/Armor Randomization v1.7
#----------#
#Features: Allow the stats of an item to be randomized, yay! Also can tack
#           on random prefixes and suffixes. Oooh, fancy.
#
#Usage:    Basic Usage:
#
#           Note tags for weapons and armors:
#
#            <HP amount>  <HP% amount>  <ATK amount>  <ATK% amount>
#            <MP amount>  <MP% amount>  <DEF amount>  <DEF% amount>
#          <MAT amount>  <MAT% amount>  <MDF amount>  <MDF% amount>
#          <AGI amount>  <AGI% amount>  <LUK amount>  <LUK% amount>
#          <PRICE amount> <PRICE% amount>
#
#           Where amount is the amount to be randomly added on, with % being
#             a percentage instead of specific.
#           Examples: <HP 500>  or  <HP% 10>
#
#           Script calls:
#            add_armor(base_id, amount)
#            add_weapon(base_id, amount)
#          
#           These script calls create a new version of the item of the base_id
#            number, with randomized stats as set in their note.
#
#          Advanced Usage:
#          
#           Note tags for weapons and armors:
#
#            <SUFFIX# rarity>    <PREFIX# rarity>
#
#           Where # is the id number of the affix and rarity is the chance of it
#            occuring with 100 always occuring and 1 almost never occuring.
#            Multiple affix notes can be added and the first one that passes it's
#            rarity chance will be added.
#           Examples: <PREFIX1 50>  or  <SUFFIX2 90>
#
#          The Complicated Part: (Affixes)
#           See that AFFIXES hash down there? That's where you set these up.
#           Basic setup is:
#             ID => { :symbol => data, },
#           You can have as many different symbols in there as you want, each
#            seperated by a comma, and don't forget the comma between each AFFIX
#            id.
#
#           Usable Symbols:
#          :name = "name"               :color = Color.new(r,g,b)
#          :rarity = value              #Arbitrary value
#          :animation = id      
#          :icon = id
#          :desc = "description"
#           #Pdesc and Sdesc are added on to the current item description
#          :pdesc = "prefix description"
#          :sdesc = "suffix description"
#
#   :hp,   :mp,   :atk,   :def,   :mat,   :mdf,   :agi,   :luk    (random bonus)
#   :Shp,  :Smp,  :Satk,  :Sdef,  :Smat,  :Smdf,  :Sagi,  :Sluk   (static bonus)
#   :hpP,  :mpP,  :atkP,  :defP,  :matP,  :mdfP,  :agiP,  :lukP   (random % bonus)
#   :ShpP, :SmpP, :SatkP, :SdefP, :SmatP, :SmdfP, :SagiP, :SlukP  (static % bonus)
#
#   :price, :Sprice, :priceP, :SpriceP
#
#       each of these goes :symbol = value
#
#          The fun part, :features
#           You can have as many features as you want, set up in an array:
#           :features = [[code, id, value],[code, id, value]] etc...
#          But what are the codes, ids, and values?? Don't worry, I found out:
#
#           Element Rate   = 11, element_id, float value
#           Debuff Rate    = 12, param_id, float value
#           State Rate     = 13, state_id, float value
#           State Resist   = 14, state_id, 0
#
#           Parameter      = 21, param_id, float value
#           Ex-Parameter   = 22, exparam_id, float value
#           Sp-Parameter   = 23, spparam_id, float value
#
#           Atk Element    = 31, element_id, 0
#           Atk State      = 32, state_id, float value
#           Atk Speed      = 33, 0, value
#           Atk Times+     = 34, 0, value
#
#           Add Skill Type = 41, skill_type, 0
#          Seal Skill Type = 42, skill_type, 0
#           Add Skill      = 43, skill_id, 0
#           Seal Skill     = 44, skill_id, 0
#
#           Equip Weapon   = 51, weapon_skill, 0
#           Equip Armor    = 52, armor_skill, 0
#           Fix Equip      = 53, item_type, 0
#           Seal Equip     = 54, item_type, 0
#           Slot Type      = 55, 1, 0
#
#           Action Times+  = 61, 0, value
#           Special Flag   = 62, flag_id, 0
#          Collapse Effect = 62, flag_id, 0
#           Party Ability  = 63, flag_id, 0
#
#     float value = percentage value where 1 = 100%, 0.75 = 75%, and 1.25 = 125%
#     param_id, 0=hp, 1=mp, 2=atk, 3=def, 4=mat, 5=mdf, 6=agi, 7=luk
#
#     Examples: [21, 2, 1.5] which would increase atk to 150%
#               [62, 0, 0]   which makes the item give the auto-battle flag
#               [32, 1, 0.5] which gives a 50% of applying death state
#
#----------#
#-- Script by: Vlue of Daimonious Tails
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
$imported = {} if $imported.nil?
$imported[:Vlue_WARandom] = true

#If true, then weapons and armors dropped by enemies will be randomized
RANDOM_ENEMY_DROPS = true
#Pool Rarity (Instead of a first come first serve, each affix is given a chance)
POOL_RARITY = false
#If true, weapons and armors bought from shops will be randomized
WA_SHOP_RANDOM = false
#When shop items are specifically set to this price, they are randomized
SHOP_SPECIFIC_RANDOM = 998
#True if you are using Sleek Item Popup, and want those to popup!
USE_ITEM_POPUP = false
#Stack random weapons and armor, when false all equips are unique
STACK_SAME_EQUIP = false
 
AFFIXES = {
            #COLORS
            1 => { :color => Color.new(50,255,0),
            :ShpP => 10, :SmpP => 10, :SatkP => 10, :SdefP => 10,
            :SmatP => 10, :SmdfP => 10, :SagiP => 10, :SlukP => 10}, #UNCOMMON
            2 => { :color => Color.new(50,100,235),
            :ShpP => 20, :SmpP => 20, :SatkP => 20, :SdefP => 20,
            :SmatP => 20, :SmdfP => 20, :SagiP => 20, :SlukP => 20}, #RARE
            3 => { :color => Color.new(255,25,255),
            :ShpP => 35, :SmpP => 35, :SatkP => 35, :SdefP => 35,
            :SmatP => 35, :SmdfP => 35, :SagiP => 35, :SlukP => 35}, #EPIC
            4 => { :name => "Legendary ", :color => Color.new(255,175,75),
            :ShpP => 50, :SmpP => 50, :SatkP => 50, :SdefP => 50,
            :SmatP => 50, :SmdfP => 50, :SagiP => 50, :SlukP => 50}, #LEGENDARY
           
            #Shared Suffixes
            10 => { :name => "Powerful ", :Shp => 1,
                    :features => [[21,0,1.25]] },
            11 => { :name => "Fiery ", :Smp => 1,
                    :features => [[21,1,1.25]] },
            12 => { :name => " of Strength", :Satk => 1,
                    :features => [[21,2,1.25]] },
            13 => { :name => " of Defense", :Sdef => 1,
                    :features => [[21,3,1.25]] },
            14 => { :name => " of Intelligence", :Smat => 1,
                    :features => [[21,4,1.25]] },
            15 => { :name => " of Piety", :Smdf => 1,
                    :features => [[21,5,1.25]] },
            16 => { :name => " of Speed", :Sagi => 1,
                    :features => [[21,6,1.25]] },
            17 => { :name => " of Luck", :Sluk => 1,
                    :features => [[21,7,1.25]] },
            18 => { :name => " of the Soul", :Shp => 1, :Smp => 1,
                    :features => [[21,0,1.20],[21,1,1.20]] },
            19 => { :name => " of the Strong", :Satk => 1, :Sdef => 1,
                    :features => [[21,2,1.20],[21,3,1.20]] },
            20 => { :name => " of the Smart", :Smat => 1, :Smdf => 1,
                    :features => [[21,4,1.20],[21,5,1.20]] },
            21 => { :name => " of the Favoured", :Sagi => 1, :Sluk => 1,
                    :features => [[21,6,1.20],[21,7,1.20]] },
            22 => { :name => " of the Lord", :Satk => 1, :Sdef => 1, :Sagi => 1,
                    :features => [[21,2,1.15],[21,3,1.15],[21,6,1.15]] },
            23 => { :name => " of the Noble", :Smat => 1, :Smdf => 1, :Sluk => 1,
                    :features => [[21,4,1.15],[21,5,1.15],[21,7,1.15]] },
            24 => { :name => " of Legend",
                    :Smat => 1, :Smdf => 1, :Sluk => 1,
                    :Smat => 1, :Smdf => 1, :Sluk => 1,
                    :features => [[21,4,1.15],[21,5,1.15],[21,7,1.15],
                                  [21,2,1.15],[21,3,1.15],[21,6,1.15]], },  
                                 
            #Weapon Suffixes
            50 => { :name => "of Venom", :feature => [[32,2,0.25]] },
            51 => { :name => "of Darkness", :feature => [[32,3,0.25]] },
            52 => { :name => "of Silence", :feature => [[32,4,0.25]] },
            53 => { :name => "of Doom", :feature => [[32,1,0.05]] },
           
            60 => { :name => "of Flame", :SatkP => 10, :SmatP => 10,
                    :feature => [[31,4,0]] },
            61 => { :name => "of Ice", :SatkP => 10, :SmatP => 10,
                    :feature => [[31,5,0]] },
            62 => { :name => "of Earth", :SatkP => 10, :SmatP => 10,
                    :feature => [[31,5,0]] },
            63 => { :name => "of Wind", :SatkP => 10, :SmatP => 10,
                    :feature => [[31,5,0]] },
            64 => { :name => "of Light", :SatkP => 10, :SmatP => 10,
                    :feature => [[31,5,0]] },
            65 => { :name => "of the Void", :SatkP => 10, :SmatP => 10,
                    :feature => [[31,5,0]] },
                   
            70 => { :name => "of Quickness", :feature => [[34,0,1]] },
                   
            }
 
class Game_Interpreter
  def add_weapon(id, am)
    item = $game_party.add_weapon(id,am)
    popup(1,item.id,am) if USE_ITEM_POPUP
    item
  end
  def add_armor(id, am)
    item = $game_party.add_armor(id, am)
    popup(2,item.id,am) if USE_ITEM_POPUP
    item
  end
  def add_item(id, am)
    item = $game_party.add_item(id, am)
    popup(0,item.id,am) if USE_ITEM_POPUP
    item
  end
  def edit_affixes(item, subnote = nil)
    $game_party.edit_affixes(item, subnote)
  end
end
 
class Game_Party
  alias rig_initialize initialize
  def initialize
    rig_initialize
    @saved_weapons = $data_weapons
    @saved_armors = $data_armors
  end
  attr_accessor :saved_weapons
  attr_accessor :saved_armors
  def add_weapon(id, amount, false_add = false)
    item = Marshal.load(Marshal.dump($data_weapons[id]))
    edit_item(item)
    edit_affixes(item)
    if STACK_SAME_EQUIP
      $data_weapons.each do |base_item|
        next if base_item.nil?
        if ( item.params == base_item.params &&
            item.price == base_item.price &&
            item.name == base_item.name &&
            item.color == base_item.color)
          $game_party.gain_item(base_item, amount) unless false_add
          return base_item
        end
      end
    end
    item.note = $data_weapons[item.id].note
    item.set_original(item.id)
    item.id = $data_weapons.size
    $data_weapons.push(item)
    $game_party.gain_item(item, amount) unless false_add
    return item
  end
  def add_armor(id, amount, false_add = false)
    item = Marshal.load(Marshal.dump($data_armors[id]))
    edit_item(item)
    edit_affixes(item)
    if STACK_SAME_EQUIP
      $data_armors.each do |base_item|
        next if base_item.nil?
        if ( item.params == base_item.params &&
            item.price == base_item.price &&
            item.name == base_item.name &&
            item.color == base_item.color)
          $game_party.gain_item(base_item, amount) unless false_add
          return base_item
        end
      end
    end
    item.note = $data_armors[item.id].note
    item.set_original(item.id)
    item.id = $data_armors.size
    $data_armors.push(item)
    $game_party.gain_item(item, amount) unless false_add
    return item
  end
  def add_item(id, amount, false_add = false)
    item = Marshal.load(Marshal.dump($data_items[id]))
    edit_item(item)
    edit_affixes(item)
    $data_items.each do |base_item|
      next if base_item.nil?
      if (item.price == base_item.price &&
          item.name == base_item.name )
        $game_party.gain_item(base_item, amount) unless false_add
        return base_item
      end
    end
    item.note = $data_items[item.id].note
    item.set_original(item.id)
    item.id = $data_items.size
    $data_items.push(item)
    $game_party.gain_item(item, amount) unless false_add
    return item
  end
  def edit_affixes(item, subnote = nil)
    note = item.note.clone
    note = subnote.clone if subnote
    affix_pool = []
    while note.include?("<SUF")
      id = note =~ /<SUFFIX(\d+) (\d+)>/
      if !POOL_RARITY
        if !AFFIXES[$~[1].to_i].nil?
          break if add_affix(item, $~[1].to_i, false) if rand(100) < $2.to_i
          note[id] = "N"
        else
          msgbox("Affix #" + $1 + " doesn't exist. \nItem creation failed.")
          return
        end
      else
        if !AFFIXES[$~[1].to_i].nil?
          $2.to_i.times do
            affix_pool.push($1)
          end
          note[id] = "N"
        else
          msgbox("Affix #" + $1 + " doesn't exist. \nItem creation failed.")
          return
        end
      end
    end
    if !affix_pool.empty?
      add_affix(item, affix_pool[rand(affix_pool.size)], false) if POOL_RARITY
    end
    affix_pool = []
    while note.include?("<PRE")
      id = note =~ /<PREFIX(\d+) (\d+)>/
      if !POOL_RARITY
        if !AFFIXES[$~[1].to_i].nil?
          break if add_affix(item, $~[1].to_i, true) if rand(100) < $2.to_i
          note[id] = "N"
        else
          msgbox("Affix #" + $1 + " doesn't exist. \nItem creation failed.")
          return
        end
      else
        if !AFFIXES[$~[1].to_i].nil?
          $2.to_i.times do
            affix_pool.push($1)
          end
          note[id] = "N"
        else
          msgbox("Affix #" + $1 + " doesn't exist. \nItem creation failed.")
          return
        end
      end
    end
    if !affix_pool.empty?
      add_affix(item, affix_pool[rand(affix_pool.size)], true) if POOL_RARITY
    end
  end
  def add_affix(item, id, prefix)
    affix = AFFIXES[id.to_i]
    if prefix && !affix[:name].nil?
      item.name = affix[:name] + item.name
    elsif !affix[:name].nil?
      item.name = item.name + affix[:name]  
    end
    if !affix[:rarity].nil?
      if item.rarity.nil? || item.rarity < affix[:rarity]
        item.set_color(affix[:color]) if !affix[:color].nil?
        item.rarity = affix[:rarity]
      end
    else
      item.set_color(affix[:color]) if !affix[:color].nil?
    end
   
    if !affix[:desc].nil?
      item.description = affix[:desc]
    end
    if !affix[:pdesc].nil?
      item.description = affix[:pdesc] + item.description
    end
    if !affix[:sdesc].nil?
      item.description = item.description + affix[:sdesc]
    end
   
   
    if !item.is_a?(RPG::Armor) && !affix[:animation].nil?
      item.animation_id = affix[:animation]
    end
   
    item.icon_index = affix[:icon] if !affix[:icon].nil?
   
    if !item.is_a?(RPG::Item)
      item.params[0] += rand(affix[:hp]) if !affix[:hp].nil?
      item.params[1] += rand(affix[:mp]) if !affix[:mp].nil?
      item.params[2] += rand(affix[:atk]) if !affix[:atk].nil?
      item.params[3] += rand(affix[:def]) if !affix[:def].nil?
      item.params[4] += rand(affix[:mat]) if !affix[:mat].nil?
      item.params[5] += rand(affix[:mdf]) if !affix[:mdf].nil?
      item.params[6] += rand(affix[:agi]) if !affix[:agi].nil?
      item.params[7] += rand(affix[:luk]) if !affix[:luk].nil?
    end
    item.price += rand(affix[:price]) if !affix[:price].nil?
   
    if !item.is_a?(RPG::Item)
      item.params[0] += affix[:Shp] if !affix[:Shp].nil?
      item.params[1] += affix[:Smp] if !affix[:Smp].nil?
      item.params[2] += affix[:Satk] if !affix[:Satk].nil?
      item.params[3] += affix[:Sdef] if !affix[:Sdef].nil?
      item.params[4] += affix[:Smat] if !affix[:Smat].nil?
      item.params[5] += affix[:Smdf] if !affix[:Smdf].nil?
      item.params[6] += affix[:Sagi] if !affix[:Sagi].nil?
      item.params[7] += affix[:Sluk] if !affix[:Sluk].nil?
    end
    item.price += affix[:Sprice] if !affix[:Sprice].nil?
   
    if !item.is_a?(RPG::Item)
      item.params[0] += item.params[0] * (rand(affix[:hpP])) / 100 if !affix[:hpP].nil?
      item.params[1] += item.params[1] * (rand(affix[:mpP])) / 100 if !affix[:mpP].nil?
      item.params[2] += item.params[2] * (rand(affix[:atkP])) / 100 if !affix[:atkP].nil?
      item.params[3] += item.params[3] * (rand(affix[:defP])) / 100 if !affix[:defP].nil?
      item.params[4] += item.params[4] * (rand(affix[:matP])) / 100 if !affix[:matP].nil?
      item.params[5] += item.params[5] * (rand(affix[:mdfP])) / 100 if !affix[:mdfP].nil?
      item.params[6] += item.params[6] * (rand(affix[:agiP])) / 100 if !affix[:agiP].nil?
      item.params[7] += item.params[7] * (rand(affix[:lukP])) / 100 if !affix[:lukP].nil?
    end
    item.price += item.price * (rand(affix[:priceP])) / 100 if !affix[:priceP].nil?
   
    if !item.is_a?(RPG::Item)
      item.params[0] += item.params[0] * affix[:ShpP] / 100 if !affix[:ShpP].nil?
      item.params[1] += item.params[1] * affix[:SmpP] / 100 if !affix[:SmpP].nil?
      item.params[2] += item.params[2] * affix[:SatkP] / 100 if !affix[:SatkP].nil?
      item.params[3] += item.params[3] * affix[:SdefP] / 100 if !affix[:SdefP].nil?
      item.params[4] += item.params[4] * affix[:SmatP] / 100 if !affix[:SmatP].nil?
      item.params[5] += item.params[5] * affix[:SmdfP] / 100 if !affix[:SmdfP].nil?
      item.params[6] += item.params[6] * affix[:SagiP] / 100 if !affix[:SagiP].nil?
      item.params[7] += item.params[7] * affix[:SlukP] / 100 if !affix[:SlukP].nil?
    end
    item.price += item.price * affix[:SpriceP] / 100 if !affix[:SpriceP].nil?
   
    if !affix[:features].nil? && !item.is_a?(RPG::Item)
      for feature in affix[:features]
        new_feature = RPG::BaseItem::Feature.new(feature[0], feature[1], feature[2])
        item.features.push(new_feature)
      end
    end
   
    return true
  end
  def edit_item(item)
    if !item.is_a?(RPG::Item)
      item.note =~ /<HP (\d+)>/
      item.params[0] += rand($~[1].to_i) if $~
      item.note =~ /<MP (\d+)>/
      item.params[1] += rand($~[1].to_i) if $~
      item.note =~ /<ATK (\d+)>/
      item.params[2] += rand($~[1].to_i) if $~
      item.note =~ /<DEF (\d+)>/
      item.params[3] += rand($~[1].to_i) if $~
      item.note =~ /<MAT (\d+)>/
      item.params[4] += rand($~[1].to_i) if $~
      item.note =~ /<MDF (\d+)>/
      item.params[5] += rand($~[1].to_i) if $~
      item.note =~ /<AGI (\d+)>/
      item.params[6] += rand($~[1].to_i) if $~
      item.note =~ /<LUK (\d+)>/
      item.params[7] += rand($~[1].to_i) if $~
      item.note =~ /<PRICE (\d+)>/
    end
    item.price += rand($~[1].to_i) if $~
   
    if !item.is_a?(RPG::Item)
      item.note =~ /<HP% (\d+)>/
      item.params[0] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<MP% (\d+)>/
      item.params[1] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<ATK% (\d+)>/
      item.params[2] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<DEF% (\d+)>/
      item.params[3] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<MAT% (\d+)>/
      item.params[4] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<MDF% (\d+)>/
      item.params[5] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<AGI% (\d+)>/
      item.params[6] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<LUK% (\d+)>/
      item.params[7] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<PRICE% (\d+)>/
    end
    item.price += item.price * (rand($~[1].to_i)) / 100 if $~
  end
end
 
module BattleManager
  def self.gain_drop_items
    $game_troop.make_drop_items.each do |item|
      if RANDOM_ENEMY_DROPS
        if item.is_a?(RPG::Weapon)
          item = $game_party.add_weapon(item.id, 1)
        elsif item.is_a?(RPG::Armor)
          item = $game_party.add_armor(item.id, 1)
        else
          $game_party.gain_item(item, 1)
        end
      else
        $game_party.gain_item(item, 1)
      end
      $game_message.add(sprintf(Vocab::ObtainItem, item.name))
    end
    wait_for_message
  end
end
 
class Scene_Load
  alias rig_on_load_success on_load_success
  def on_load_success
    rig_on_load_success
    $data_weapons = $game_party.saved_weapons
    $data_armors = $game_party.saved_armors
  end
end
 
class Window_Base
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(item.color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
    change_color(normal_color)
  end
end
 
class RPG::BaseItem
  attr_accessor  :rarity
  def color
    return Color.new(255,255,255) unless @color
    @color
  end
  def set_color(color)
    @color = color
  end
  def original_id
    @original_id ? @original_id : @id
  end
  def set_original(new_id)
    @original_id = new_id
  end
end
 
class Scene_Shop
  alias wa_do_buy do_buy
  alias wa_prepare prepare
  def prepare(*args)
    wa_prepare(*args)
    iter = -1
    @goods.each do |array|
      iter += 1
      next unless array[2] == 1 && array[3] == SHOP_SPECIFIC_RANDOM
      item = $game_party.add_item(array[1],1,true) if array[0] == 0
      item = $game_party.add_weapon(array[1],1,true) if array[0] == 1
      item = $game_party.add_armor(array[1],1,true) if array[0] == 2
      @goods[iter] = [array[0],item.id,0,0]
    end
  end
  def do_buy(number)
    if WA_SHOP_RANDOM
      number.times do |i|
        $game_party.lose_gold(buying_price)
        $game_party.add_weapon(@item.id, 1) if @item.is_a?(RPG::Weapon)
        $game_party.add_armor(@item.id, 1) if @item.is_a?(RPG::Armor)
        $game_party.gain_item(@item, 1) if @item.is_a?(RPG::Item)
      end
    else
      wa_do_buy(number)
    end
  end
end