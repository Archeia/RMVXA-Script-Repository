class Window::ArtsCommand < Window::Command
  include Mixin::UnitHost

  def window_width
    return 160
  end

  def make_command_list
    add_command("Equip"   , :equip)
    add_command("Unequip" , :unequip)
    add_command("Clear"   , :clear)
    add_command("List"    , :list)
  end

  def on_unit_change
    refresh
  end
end
