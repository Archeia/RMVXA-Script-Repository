#encoding:UTF-8
# Window_EquipStatus
#==============================================================================
# ** Window_EquipStatus
#------------------------------------------------------------------------------
#  This window displays actor parameter changes on the equipment screen, etc.
#==============================================================================

class Window_EquipStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x     : window X coordinate
  #     y     : window Y corrdinate
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(x, y, actor)
    super(x, y, 208, WLH * 5 + 32)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_name(@actor, 4, 0)
    draw_parameter(0, WLH * 1, 0)
    draw_parameter(0, WLH * 2, 1)
    draw_parameter(0, WLH * 3, 2)
    draw_parameter(0, WLH * 4, 3)
  end
  #--------------------------------------------------------------------------
  # * Set Parameters After Equipping
  #     new_atk : attack after equipping
  #     new_def : defense after equipping
  #     new_spi : spirit after equipping
  #     new_agi : agility after equipping
  #--------------------------------------------------------------------------
  def set_new_parameters(new_atk, new_def, new_spi, new_agi)
    if @new_atk != new_atk or @new_def != new_def or
       @new_spi != new_spi or @new_agi != new_agi
      @new_atk = new_atk
      @new_def = new_def
      @new_spi = new_spi
      @new_agi = new_agi
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Get Post Equip Parameter Drawing Color
  #     old_value : parameter before equipment change
  #     new_value : parameter after equipment change
  #--------------------------------------------------------------------------
  def new_parameter_color(old_value, new_value)
    if new_value > old_value      # Get stronger
      return power_up_color
    elsif new_value == old_value  # No change
      return normal_color
    else                          # Get weaker
      return power_down_color
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Parameters
  #     x    : draw spot x-coordinate
  #     y    : draw spot y-coordinate
  #     type : type of parameter (0 - 3)
  #--------------------------------------------------------------------------
  def draw_parameter(x, y, type)
    case type
    when 0
      name = Vocab::atk
      value = @actor.atk
      new_value = @new_atk
    when 1
      name = Vocab::def
      value = @actor.def
      new_value = @new_def
    when 2
      name = Vocab::spi
      value = @actor.spi
      new_value = @new_spi
    when 3
      name = Vocab::agi
      value = @actor.agi
      new_value = @new_agi
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x + 4, y, 80, WLH, name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 90, y, 30, WLH, value, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(x + 122, y, 20, WLH, ">", 1)
    if new_value != nil
      self.contents.font.color = new_parameter_color(value, new_value)
      self.contents.draw_text(x + 142, y, 30, WLH, new_value, 2)
    end
  end
end
