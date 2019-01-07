=begin
patch for SES Instance item with Mr. Bubble tactics ogre crafting system
put this patch below all yanfly script. since yanfly do lots of rewrites to 
class window itemlist draw item method...
(btw sorry for mispell Mr. Bubble :D)  
Author : Estriole
License: Free to use in all project (except the one containing pornography)
as long as i credited (ESTRIOLE).
=end

class Game_Party < Game_Unit
  def item_instances(item)
    type = :item if item.is_a?(RPG::Item)
    type = :weapon if item.is_a?(RPG::Weapon)
    type = :armor if item.is_a?(RPG::Armor)
    return [] if eval("$game_#{type}s.size < 1")
    array = []
    eval("$game_#{type}s.each do |obj|
    next if !obj
    array.push(obj) if obj.old_id == #{item.id} && $game_party.item_number(obj)>0
    end")
    return array
  end
  alias old_item_number item_number
  def item_number(item)
    return instance_number(item)
  end
  def instance_number(item)
    return 0 if item.nil?
    instances = item_instances(item)
      instances_amount = 0
       instances.each do |ins|
       instances_amount += old_item_number(ins)
       end
      party_amount = old_item_number(item) + instances_amount
  end
end

class Window_ItemList < Window_Selectable
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
      draw_item_number(rect, item) unless item.unique
    end
  end
  if $imported["YEA-CoreEngine"] == true
    def draw_item(index)
      item = @data[index]
      return if item.nil?
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item), rect.width - 24)
      draw_item_number(rect, item) unless item.unique
    end
  end
end

class Window_EquipItem < Window_ItemList
  if $imported["YEA-AceEquipEngine"] == true  
    def draw_item(index)
      item = @data[index]
      rect = item_rect(index)
      rect.width -= 4
      if item.nil?
        draw_remove_equip(rect)
        return
      end
      dw = contents.width - rect.x - 24
      draw_item_name(item, rect.x, rect.y, enable?(item), dw)
      draw_item_number(rect, item) unless item.unique
    end
  end
end

class Window_TOCraftingItemList < Window_ItemList
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
      draw_item_number(rect, item)
    end
  end
  if $imported["YEA-CoreEngine"] == true
    def draw_item(index)
      item = @data[index]
      return if item.nil?
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item), rect.width - 24)
      draw_item_number(rect, item)
    end
  end
end

class Scene_TOCrafting < Scene_MenuBase
  alias crafting_system_patch_instance_start start
  def start
    crafting_system_patch_instance_start
    create_instances_window
    @cancel_crafting = false
    @instance_pool = {}
  end
  def create_instances_window
    dx = @itemlist_window.x
    dy = @itemlist_window.y
    dw = @itemlist_window.width
    dh = @itemlist_window.height
    @instance_window = Window_TOCrafting_Instances.new(dx,dy,dw,dh)
    @instance_window.set_handler(:ok,     method(:on_instance_ok))
    @instance_window.set_handler(:cancel, method(:on_instance_cancel))    
  end  

  def on_instance_ok
    item = @instance_window.current_data
    @instance_pool[@ingre]= [] if !@instance_pool[@ingre]
    @instance_pool[@ingre].push(item)
    @counter -= 1
    @instance_window.activate if @counter != 0 
  end

  def on_instance_cancel
    @cancel_crafting = true
    @instance_pool = {}
    @counter = 0
  end  
  
  def lose_ingredients(item, number)
    item.ingredient_list.each do |ingredient|
      if ingredient.unique
        @instance_pool[ingredient].each do |ins|
        $game_party.lose_item(ins, 1)          
        end      
      else
      $game_party.lose_item(ingredient, number)
      end
    end
    @instance_pool = {}
  end
  
  def select_instance(item,number)
    item.ingredient_list.each do |ingredient|
      if ingredient.unique
        @counter = number
        @ingre = ingredient
        @instance_pool[ingredient] = [] if !@instance_pool[ingredient]
        instances = $game_party.item_instances(ingredient) - @instance_pool[ingredient]
        @instance_window.instances = instances
        @itemlist_window.visible = false
        @instance_window.show.activate
        update while @counter > 0
        @instance_window.visible = false
        return if @cancel_crafting == true
      end
    end    
  end
  
  def do_crafting(item, number)
    return unless item
    @cancel_crafting = false
    play_crafting_se(item)
    select_instance(item, number)
    return if @cancel_crafting == true
    lose_ingredients(item, number)
    pay_crafting_fee(item, number)
    gain_crafted_item(item, number)
  end

  def on_number_ok
    @number_window.close.hide
    @number_window.number
    do_crafting(@item, @number_window.number)
    if @cancel_crafting == true
    @gold_window.number = @info_window.number = 1
    @info_window.page_change = true
    return @itemlist_window.show.open.activate      
    end
    @result_window.set(@item, @number_window.number)
    @result_window.show.open.activate
    @itemlist_window.show.open
    @info_window.page_change = true    
    @gold_window.number = @info_window.number = 1
    refresh
    @result_window.show.open.activate
  end
  
end #end class scene_tocrafting
  
class Window_TOCrafting_Instances < Window_Command
  def initialize(dx,dy,dw,dh)
    @height = dh
    @width = dw
    super(dx,dy)
    @instances = []
    self.visible = false
    self.active = false
  end
  def instances=(ins)
    return if @instances == ins
    @instances = ins
    make_command_list
    select(0)
    refresh
  end
  def make_command_list
    return @list = [] if @instances.nil?
    return @list = @instances.collect{|ins|ins.name}
  end
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    dx = item_rect_for_text(index).x
    dy = item_rect_for_text(index).y
    draw_icon(@instances[index].icon_index,dx-4,dy)
    draw_text(dx+20,dy,width-(3*standard_padding),line_height, command_name(index), alignment)
  end
  def current_data;index >= 0 ? @instances[index] : nil;end
  def instances;@instances;end  
  def window_width; return @width ;end
  def window_height; return @height;end
  def command_name(index); @list[index]; end  
  def current_item_enabled?; true; end  
  def command_enabled?(index); true; end
  def ok_enabled?; true; end
  def call_ok_handler;call_handler(:ok);end
  def alignment;0;end
end