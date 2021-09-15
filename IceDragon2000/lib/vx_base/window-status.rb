#encoding:UTF-8
# Window_Status
#==============================================================================
# ** Window_Status
#------------------------------------------------------------------------------
#  This window displays full status specs on the status screen.
#==============================================================================

class Window_Status < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 0, 544, 416)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_name(@actor, 4, 0)
    draw_actor_class(@actor, 128, 0)
    draw_actor_face(@actor, 8, 32)
    draw_basic_info(128, 32)
    draw_parameters(32, 160)
    draw_exp_info(288, 32)
    draw_equipments(288, 160)
  end
  #--------------------------------------------------------------------------
  # * Draw Basic Information
  #     x : Draw spot X coordinate
  #     y : Draw spot Y coordinate
  #--------------------------------------------------------------------------
  def draw_basic_info(x, y)
    draw_actor_level(@actor, x, y + WLH * 0)
    draw_actor_state(@actor, x, y + WLH * 1)
    draw_actor_hp(@actor, x, y + WLH * 2)
    draw_actor_mp(@actor, x, y + WLH * 3)
  end
  #--------------------------------------------------------------------------
  # * Draw Parameters
  #     x : Draw spot X coordinate
  #     y : Draw spot Y coordinate
  #--------------------------------------------------------------------------
  def draw_parameters(x, y)
    draw_actor_parameter(@actor, x, y + WLH * 0, 0)
    draw_actor_parameter(@actor, x, y + WLH * 1, 1)
    draw_actor_parameter(@actor, x, y + WLH * 2, 2)
    draw_actor_parameter(@actor, x, y + WLH * 3, 3)
  end
  #--------------------------------------------------------------------------
  # * Draw Experience Information
  #     x : Draw spot X coordinate
  #     y : Draw spot Y coordinate
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s1 = @actor.exp_s
    s2 = @actor.next_rest_exp_s
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y + WLH * 0, 180, WLH, Vocab::ExpTotal)
    self.contents.draw_text(x, y + WLH * 2, 180, WLH, s_next)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y + WLH * 1, 180, WLH, s1, 2)
    self.contents.draw_text(x, y + WLH * 3, 180, WLH, s2, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Equipment
  #     x : Draw spot X coordinate
  #     y : Draw spot Y coordinate
  #--------------------------------------------------------------------------
  def draw_equipments(x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, WLH, Vocab::equip)
    for i in 0..4
      draw_item_name(@actor.equips[i], x + 16, y + WLH * (i + 1))
    end
  end
end
