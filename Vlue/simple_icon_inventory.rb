#Simple Icon Inventory v1.0
#----------#
#Features: Look, Icons! Instead of a list! 
#
#Usage:    Plug and play.
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

class Window_ItemList < Window_Selectable
  def col_max
    (self.width - standard_padding) / 42
  end
  def page_row_max
    7
  end
  def item_height
    36
  end
  def item_width
    36
  end
  def contents_height
    [super - super % item_height, row_max * (item_height + spacing)].max
  end
  def spacing
    6
  end
  def top_row
    oy / (item_height + spacing)
  end
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * (item_height + spacing)
  end
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing) + spacing
    rect.y = index / col_max * (item_height + spacing) + spacing
    rect
  end
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      rect.x += 2
      big_rect = Rect.new(rect.x-1,rect.y-1,rect.width+2,rect.height+2)
      contents.fill_rect(big_rect, Color.new(0,0,0,255))
      contents.fill_rect(rect, Color.new(0,0,0,100))
      draw_icon(item.icon_index, rect.x+6, rect.y+6)
      contents.font.size = 12
      number = $game_party.item_number(item)
      if number > 1
        draw_text(rect.x + 20, rect.y + 28, 24, contents.font.size, "x" + number.to_s)
      end
    end
  end
end

class Scene_Item
  alias itemdetail_start start
  def start
    itemdetail_start
    @detail_window = Window_ItemDetail.new(Graphics.width/3*2,@item_window.y,Graphics.width/3,Graphics.height-@item_window.y)
  end
  def update
    super
    @detail_window.set_item(@item_window.item)
  end
  alias icon_ciw create_item_window
  def create_item_window
    icon_ciw
    @item_window.width = Graphics.width/3*2
  end
end

class Window_ItemDetail < Window_Base
  def initialize(x,y,w,h)
    super(x,y,w,h)
    @item = nil
  end
  def set_item(item)
    return if item == @item
    @item = item
    refresh
  end
  def refresh
    contents.clear
    contents.font.size = 18
    draw_item_name(@item,0,0,true,contents.width-24)
    contents.font.size = 24
    @yy = 48
    if @item.is_a?(RPG::EquipItem)
      8.times do |i|
        if @item.params[i] != 0
          change_color(system_color)
          draw_text(24,@yy,contents.width,24,Vocab::param(i) + ": ")
          change_color(normal_color)
          draw_text(24,@yy,contents.width/3*2,24,@item.params[i],2)
          @yy += 24
        end
      end
    end
    if @item.is_a?(RPG::UsableItem)
      cures = []
      @item.effects.each do |effect|
        if effect.code == 11
          if effect.value1 > 0
            draw_text_ex(24,@yy,'\c[1]HP\c[0] +' + (effect.value1 * 100).to_i.to_s + '%  ')
            @yy += 24
          end
          if effect.value2 > 0
            draw_text_ex(24,@yy,'\c[1]HP\c[0] +' + effect.value2.to_i.to_s + '  ')
            @yy += 24
          end
        end
        if effect.code == 12
          if effect.value1 > 0
            draw_text_ex(24,@yy,'\c[1]MP\c[0] +' + (effect.value1 * 100).to_i.to_s + '%  ')
            @yy += 24
          end
          if effect.value2 > 0
            draw_text_ex(24,@yy,'\c[1]MP\c[0] +' + effect.value2.to_i.to_s + '  ')
            @yy += 24
          end
        end
        if effect.code == 22
          cures.push(effect.data_id)
        end
      end
      if cures.size > 0
        draw_text_ex(24,@yy,'\c[1]Cures:\c[0] ')
        @yy += 24
        cures.each do |id|
          name = $data_states[id].name
          draw_text(48,@yy,contents.width-48,24,name)
          @yy += 24
        end
      end
    end
  end
end

class Scene_Equip
  alias icon_ciw create_item_window
  def create_item_window
    icon_ciw
    @item_window.width = Graphics.width/3*2
    @detail_window = Window_ItemDetail.new(Graphics.width/3*2,@item_window.y,Graphics.width/3,@item_window.height)
  end
  def update
    super
    @detail_window.set_item(@item_window.item)
  end
end