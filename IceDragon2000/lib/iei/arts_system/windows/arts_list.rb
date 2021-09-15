class Window::ArtsList < Window::Selectable
  include Mixin::UnitHost

  def initialize(x, y, width = window_width, height = window_height)
    @list = []
    super
    select 0
  end

  def on_unit_change
    refresh
    #select_last
  end

  def make_item_list
    case @unit
    when Game::PartyBase
      @list = @unit.arts
    else
      @list = @unit ? @unit.entity.arts : []
    end
  end

  def refresh
    make_item_list
    create_contents
    draw_all_items
    call_update_help

    # cursor fix
    old_index = @index
    @index = -1
    select(@index); select(old_index)
  end

  def item_max
    @list.size
  end

  def col_max
    2
  end

  def spacing
    0
  end

  def window_width
    (col_max * 96) + standard_padding * 2
  end

  def window_height
    (item_height * 4) + standard_padding * 2
  end

  def item_width
    (self.width - standard_padding * 2) / col_max
  end

  def item_height
    28#36
  end

  def item(index=self.index)
    @list[index]
  end

  def draw_item(index)
    entity = @unit.is_a?(Game::PartyBase) ? @unit : @unit.entity
    rect = item_rect(index).contract(anchor: 5, amount: 2)
    art  =  @list[index]
    artist.draw_art(entity, art, rect, true)
  end

  def current_item=(item)
    return unless @unit
    @unit.entity.equip_art(item, self.index)
    refresh
  end

  def update_help
    @help_window.set_item item
  end

  def active_fading?
    true
  end
end
