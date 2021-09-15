#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - CraftSystem"
#-define HDR_GDC :dc=>"03/12/2012"
#-define HDR_GDM :dm=>"06/12/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"1.0"
#-inject gen_script_header HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
$simport.r 'iei/craft_system', '1.0.0', 'IEI Craft System'
#-inject gen_module_header 'IEI::CraftSystem'
=begin
# ● How To Use
#     In an Item, Weapon, or Armor notebox use this tag:
#     <crafting: Nid>
#     <crafting: Nid, Nid, Nid..>
#     Replace N with:
#       A - For Armor
#       W - For Weapon
#       I - For Item
#     Replace id with well the object's Id
#
#     EG:
#     <crafting: W1, I1>
#        That creates a healing axe, using Weapon 1 and Item 1
#     You can add as many crafting tags as you like, so you can have
#     several recipes and 1 outcome
#
#     Pressing L/R in the input window will switch to the output window
#
=end
module IEI
  module CraftSystem
    # // (JUMP:MaterialCount) find that if you need to change the material count
    # // Craft functions
    def self.item2craft item
      return [IEI.item_sym(item), item ? item.id : nil]
    end
    def self.craft2item craft
      return nil unless craft
      sym, id = craft
      case sym
      when :item   ; $data_items[id]
      when :skill  ; $data_skills[id]  # // Still not used
      when :weapon ; $data_weapons[id]
      when :armor  ; $data_armors[id]
      else         ; nil
      end
    end

    def self.sort_recipe recipe
      return recipe.sort_by{|a|craft2item(a).db_id}
    end

    def self.mk_recipe_list! items
      @recipe_list = mk_recipe_list_abs items unless @recipe_list
    end

    def self.mk_recipe_list_abs items
      recipe_list = {}
      pc = item = nil # // Forward Dec.
      items.each do |item| pc = item2craft item  # // Convert2Craft
        item.craft_recipes.each do |r|recipe_list[sort_recipe(r)]=pc ; end
      end
      return recipe_list
    end # // mk_recipe_list

    def self.item_from_recipe recipe
      return craft2item(@recipe_list[sort_recipe(recipe)])
    end

    def self.items2recipe items
      return items.map{|i|item2craft(i)}
    end

  end # // Craft System

  module REGEXP
    module BaseItem
      # // <crafting: i1, w2, a7>
      CRAFT_MATERIAL = /<CRAFTING:[ ]*((?:I|W|A)\d+(?:\s*,\s*(?:I|W|A)\d+)*)>/i
      CRAFT_ID       = /(I|W|A)(\d+)/i
    end
  end

  # // Core
  def self.item_sym item
    case item
    when RPG::Item  ; :item
    when RPG::Skill ; :skill # // Not used for craft
    when RPG::Weapon; :weapon
    when RPG::Armor ; :armor
    else            ; :nil
    end
  end
  # // Array to Count Hash
  def self.a2count_hash array
    array.inject(Hash.new){|hash,element|hash[element]=(hash[element]||0)+1;hash}
  end
end

#-inject gen_module_header 'DataManager'
module DataManager
  class << self
    alias iei020_load_database load_database
    def load_database *args,&block
      iei020_load_database *args,&block
      IEI::CraftSystem.mk_recipe_list!(
        (
        $data_items   + # // Support Items
        $data_weapons + # // Support Weapons
        $data_armors    # // Support Armors
        ).compact
      )
    end
  end
end

#-inject gen_module_header 'RPG::BaseItem'
class RPG::BaseItem
  # // Core
  def db_id
    # // Database ID - Used to sort items
    unless(@db_id)
      @db_id = case(self)
      # // Since the database has a limit of 999 items, you can use 1000 intervals
      when RPG::Item   ; 0
      when RPG::Skill  ; 1000
      when RPG::Weapon ; 2000
      when RPG::Armor  ; 3000
      else             ; 9000 # // Massive Offset D:
      end
      @db_id += self.id # // Add the item's id to the offset
    end
    return @db_id
  end
  attr_writer :db_id
  # // Craft
  def craft_recipes
    unless(@craft_recipes)
      @craft_recipes = []
      reg = IEI::REGEXP::BaseItem
      # // Forward Declaration
      recipe = []
      crft = nil
      self.note.scan(reg::CRAFT_MATERIAL).each do |n|
        # // I should have made an recipe object instead of nested arrays...
        recipe = [] # // Make a new recipe
        n[0].scan(reg::CRAFT_ID).each do |cid|
          l, id = cid.join("").match(reg::CRAFT_ID)[1,2]
          id = id.to_i
          # // The regex patterns(nID) are converted to craft arrays [:symbol, id]
          crft = case(l.upcase)
          when "I" ; [:item  ,id] # // Item
          when "W" ; [:weapon,id] # // Weapon
          when "A" ; [:armor ,id] # // Armor
          when "S" ; [:skill ,id] # // Skill # // Not supported but whatever.
          else     ; raise "Unknown type #{l}" # // Now how the hell did you do that?
          end
          recipe << crft # // Push this craft unto the list
        end
        @craft_recipes << recipe # // Add the new recipe to the list
      end
    end
    # // Array[Recipe[Crafts[:symbol, id]..]..]
    return @craft_recipes
  end
  attr_writer :craft_recipes
end

class Game::Party

  def recipe2items(recipe)
    recipe.map{|c|IEI::CraftSystem.craft2item(c)}
  end

  def items2recipe(items)
    IEI::CraftSystem.items2recipe(items)
  end

  def item_from_recipe(recipe)
    IEI::CraftSystem.item_from_recipe(recipe)
  end

  def has_these?(*items)
    hsh = IEI.a2count_hash(items)
    return hsh.keys.all?{|i|hsh[i]<=item_number(i)}
  end

  def crafted?(item)
    return (@crafted ||= {})[IEI::CraftSystem.item2craft(item)] == true
  end

  def correct_recipe?(target_item,recipe)
    item_from_recipe(recipe) == target_item
  end

  def craft(recipe, item=item_from_recipe(recipe))
    return false unless(item)
    return false unless(item_number(item)<max_item_number(item))
    return false unless(has_these?(*recipe2items(recipe)))
    craft!(recipe,item)
  end

  # // Dont care if its impossible, just DO IT
  def craft!(recipe,item=item_from_recipe(recipe))
    @crafted[IEI::CraftSystem.item2craft(item)] = true
    gain_item(item,1)
    recipe2items(recipe).each{|m|lose_item(m,1)}
    return true
  end

end

class Window::CraftItemList < Window::ItemList
  def col_max
    1
  end
  def item_max
    super + 1
  end
end

class Window::CraftOutput < Window::Selectable
  def initialize(x,y,w,h)
    super(x,y,w,h)
    select(0)
  end
  def craft!
    return Sound.play_buzzer unless($game.party.craft(@recipe))
    @input_window.craft! if(@input_window)
  end
  attr_reader :input_window
  def input_window=(n)
    @input_window = n
    refresh
  end
  attr_reader :item
  def change_recipe(recipe)
    @recipe = recipe.compact
    @item   = IEI::CraftSystem.item_from_recipe(@recipe)
    refresh
  end
  def refresh
    contents.clear
    return unless(@item)
    if($game.party.crafted?(@item))
      draw_item_name(@item,0,0)
    else
      rect = item_rect_for_text(0); rect.x += 24;rect.width-=24
      draw_text(rect,"?"*10)
    end
  end
  def item_max
    1
  end
  def col_max
    1
  end
  def update_help
    @help_window.set_item(item)
  end
end
class Window::CraftInput < Window::Selectable
  attr_reader :items
  def initialize(x,y,w,h)
    @items = []
    super(x,y,w,h)
    refresh
    select(0)
  end
  def craft!
    adjust_items
  end
  attr_reader :output_window
  def output_window=(n)
    @output_window = n
    refresh
  end
  def item(index=self.index)
    @items[index]
  end
  def change_item(index,n)
    @items[index] = n
    redraw_item(index)
    update_recipe
  end
  def change_current_item(n)
    change_item(self.index,n)
    call_update_help
  end
  def clear_items
    clear_items!
    update_recipe
  end
  def clear_items!
    @items.clear
    refresh
    call_update_help
  end
  def draw_item(index)
    rect = item_rect(index)
    item = @items[index]
    if(item)
      draw_item_name(item,rect.x,rect.y)
    else
      rect = item_rect_for_text(index)
      draw_text(rect.x+24,rect.y,rect.width-24,rect.height,"-"*10)
    end
  end
  def adjust_items
    hsh = IEI.a2count_hash(@items)
    @items.clear
    hsh.each_pair do |key,value|
      @items += [key] * [[0,value].max,$game.party.item_number(key)].min
    end
    update_recipe
  end
  def update_recipe
    if(@output_window)
      @output_window.change_recipe(IEI::CraftSystem.items2recipe(@items))
    end
  end
  def item_max
    5 # // (JUMP:MaterialCount)
  end
  def col_max
    1
  end
  def update_help
    @help_window.set_item(item)
  end
end

class Scene_Craft < Scene_MenuUnitBase
  def start
    super
    create_all_windows
  end
  def create_all_windows
    create_help_window
    create_category_window
    create_item_window
    create_output_window
    create_input_window
  end
  def create_category_window
    @category_window = Window::ItemCategory.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @help_window.height
    @category_window.set_handler(:ok,     method(:on_category_ok))
    #@category_window.set_handler(:cancel, method(:on_category_cancel))
    #@category_window.deactivate
  end
  def create_item_window
    wx = @category_window.width / 2
    wy = @category_window.y+@category_window.height
    ww = @category_window.width / 2
    wh = Graphics.height - wy - 48
    @item_window             = Window::CraftItemList.new(wx,wy,ww,wh)
    @item_window.viewport    = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok      , method(:on_item_ok))
    @item_window.set_handler(:cancel  , method(:on_item_cancel))
    @item_window.set_handler(:pageup  , method(:change_to_input))
    @item_window.set_handler(:pagedown, method(:change_to_input))
    @category_window.item_window = @item_window
  end
  def create_output_window
    wx = 0
    wy = @item_window.y + @item_window.height
    ww = @category_window.width
    wh = 24+24
    @coutput_window = Window::CraftOutput.new(wx,wy,ww,wh)
    @coutput_window.viewport    = @viewport
    @coutput_window.help_window = @help_window
    @coutput_window.set_handler(:ok      , method(:on_coutput_ok))
    @coutput_window.set_handler(:cancel  , method(:on_coutput_cancel))
    @coutput_window.set_handler(:pageup  , method(:change_to_input))
    @coutput_window.set_handler(:pagedown, method(:change_to_input))
  end
  def create_input_window
    wx = 0
    wy = @category_window.y+@category_window.height
    ww = @category_window.width / 2
    wh = @item_window.height
    @cinput_window               = Window::CraftInput.new(wx,wy,ww,wh)
    @cinput_window.viewport      = @viewport
    @cinput_window.help_window   = @help_window
    #@cinput_window.set_handler(:ok      , method(:on_cinput_ok))
    @cinput_window.set_handler(:cancel  , method(:on_cinput_cancel))
    @cinput_window.set_handler(:pageup  , method(:change_to_output))
    @cinput_window.set_handler(:pagedown, method(:change_to_output))
    @cinput_window.output_window = @coutput_window
    @coutput_window.input_window = @cinput_window
    @cinput_window.activate
  end
  def change_to_item
    @category_window.activate
  end
  def change_to_output
    @coutput_window.activate
    @category_window.deactivate
  end
  def change_to_input
    @cinput_window.activate
    @category_window.activate
  end
  def on_category_ok
    @cinput_window.deactivate
    @item_window.activate
    @item_window.select_last
  end
  def on_category_cancel
    @cinput_window.activate
  end
  def on_item_ok
    @cinput_window.change_current_item @item_window.item
    on_item_cancel
  end
  def on_item_cancel
    @cinput_window.activate
    @category_window.activate
  end
  def on_coutput_ok
    @coutput_window.craft!
    @cinput_window.refresh
    @coutput_window.refresh
    @item_window.refresh
    @coutput_window.activate
  end
  def on_coutput_cancel
    change_to_input
    #@cinput_window.activate
  end
  def on_cinput_ok
    @coutput_window.activate
  end
  def on_cinput_cancel
    return_scene
  end
end
#-inject gen_script_footer
