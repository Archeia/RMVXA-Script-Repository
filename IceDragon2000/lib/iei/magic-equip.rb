$simport.r 'iei/magic_equip', '1.0.0', 'IEI Magic Equip'

module IEI
  module MagicEquip

  end
end

module IEI::MagicEquip::Include
  def all_skills
    (@skills | added_skills).sort.map {|id| $data_skills[id] }
  end

  def equipped_skills
    @equip_skills.map { |sid| $data_skills[sid] }
  end

  def init_equipped_skills
    @equip_skills ||= []
  end

  # // 02/23/2012
  def has_skill? skill_id
    return true if skill_id == 0
    all_skills.any?{|s|s.id==skill_id}
  end

  def equipped_skill?(skill_id)
    return @equip_skills.include?(skill_id)
  end

  def setup_equipped_skills
    flush_equipped_skills
  end

  def flush_equipped_skills
    @equip_skills.map! { |a| (a && has_skill?(a)) ? a : 0 }
    @equip_skills.pad!(equip_skill_size, 0)
  end

  def equip_skill_size
    6
  end

  def change_equip_skill(skill_id, index)
    change_equip_skill! skill_id,index if has_skill? skill_id
  end

  def change_equip_skill!(skill_id, index)
    @equip_skills[index] = skill_id
  end

  def equip_skill(skill, index)
    change_equip_skill (skill ? skill.id : 0), index
  end

  def equip_available_skills
    skills = all_skills
    (0...arts_equip_size).select{|i|@equip_skills[i]==0||@equip_skills[i].nil?}.each do |i|
      equip_skill skills.shift,i
    end
  end

  def optimize_skill_equips
  end
end

class Window::MagicEquipCommand < Window::Command
  attr_reader :unit

  def window_width
    return 160
  end

  def make_command_list
    add_command("Equip"   , :equip)
    add_command("Unequip" , :unequip)
    add_command("Optimize", :optimize)
    add_command("List"    , :list)
  end

  def unit=(unit)
    return if @unit == unit
    @unit = unit
    refresh
    #select_last
  end
end

class Window::MagicEquip < Window::SkillList
  def current_item=(item)
    return if @unit.nil?
    @unit.equip_skill(item,self.index)
    refresh
  end

  def enable?(*args, &block)
    return true
  end

  def current_item_enabled?
    return true
  end

  def active_fading?
    true
  end
end

class Window::MagicList < Window::FullSkillList
  def enable?(*args, &block)
    return true
  end

  def current_item_enabled?
    return true
  end

  def active_fading?
    true
  end
end

class Sprite::MagicIcon < Sprite::ItemIcon
  def fadein
    self.opacity += 255 / 30.0
  end

  def fadeout
    self.opacity -= 255 / 30.0
  end

  def icon_index=(*args,&block)
    super(*args,&block)
    self.opacity = 0
  end

  def update
    super
    fadein unless self.opacity == 198
    self.opacity = self.opacity.clamp(0,198)
  end
end

module Scene
  class SkillEquip < MenuUnitBase
    def start
      super
      create_canvas
      create_all_windows

      @item_icon = Sprite::MagicIcon.new(@viewport, nil)
      @item_icon.z = 999
    end

    def terminate
      @item_icon.dispose
      super
    end

    def create_all_windows
      super
      create_command_window
      create_status_window
      create_equip_window
      create_element_window
      create_item_window
    end

    def create_command_window
      @command_window = Window::MagicEquipCommand.new(@help_window.x,@help_window.y2)
      @command_window.help_window = @help_window
      @command_window.unit = @unit
      @command_window.set_handler :equip   , method(:command_equip)
      @command_window.set_handler :unequip , method(:command_unequip)
      @command_window.set_handler :optimize, method(:command_optimize)
      @command_window.set_handler :list    , method(:command_list)
      @command_window.set_handler :cancel  , method(:return_scene)
      @command_window.set_handler :pagedown, method(:next_unit)
      @command_window.set_handler :pageup  , method(:prev_unit)

      window_manager.add(@command_window)
    end

    def create_equip_window
      @equip_window = Window::MagicEquip.new(@command_window.x,@command_window.y2,@help_window.width/2)
      @equip_window.set_mode 0
      @equip_window.stype_id = -1
      @equip_window.unit = @unit
      @equip_window.help_window = @help_window

      window_manager.add(@equip_window)
    end

    def create_element_window
      @element_window = Window::ElementSelect.new(@equip_window.x2,@equip_window.y,@equip_window.width)
      #@element_window.unit = @unit

      window_manager.add(@element_window)
    end

    def create_item_window
      @item_window = Window::MagicList.new(@element_window.x,@element_window.y2,@element_window.width)
      @item_window.set_mode 1
      @item_window.unit = @unit
      @item_window.help_window = @help_window
      @item_window.height = @canvas.y2-@item_window.y
      @element_window.skill_window = @item_window

      window_manager.add(@item_window)
    end

    def create_status_window
      @status_window = Window::SkillStatus.new(@command_window.x2, @help_window.y2, @help_window.width-@command_window.width)
      @status_window.unit = @unit

      window_manager.add(@status_window)
    end

    def command_equip
      @item_window.set_handler(:ok,       method(:equip_current_item))
      @item_window.set_handler(:cancel,   method(:end_item_selection))
      @item_window.set_handler(:pageup,   method(:pred_element))
      @item_window.set_handler(:pagedown, method(:succ_element))

      @equip_window.set_handler(:ok,      method(:start_item_selection))
      @equip_window.set_handler(:cancel,  method(:end_equip_selection))

      @equip_window.activate
    end

    def command_unequip
      @equip_window.set_handler(:ok,     method(:unequip_current_item))
      @equip_window.set_handler(:cancel, method(:end_equip_selection))
      @equip_window.activate
    end

    def command_optimize
      @status_window.unit.optimize_skill_equips
      pop_quick_text_centered "Optimize Complete"
      @command_window.activate
    end

    def command_list
      @item_window.set_handler(:ok,     method(:show_item_full_info))
      @item_window.set_handler(:cancel, method(:end_item_list))
      @item_window.activate
    end

    def start_item_selection
      @item_window.activate
    end

    def end_item_selection
      @equip_window.activate
    end

    def equip_current_item
      @equip_window.current_item = @item_window.item
      @equip_window.activate
    end

    def unequip_current_item
      @equip_window.current_item = nil
      @equip_window.activate
    end

    def end_equip_selection
      @command_window.activate
    end

    def show_item_full_info
    end

    def end_item_list
      @command_window.activate
    end

    def succ_element
      @element_window.succ_index
      @item_window.activate
    end

    def pred_element
      @element_window.pred_index
      @item_window.activate
    end

    def update
      super
      r = @equip_window.current_item_to_screen()
      @item_icon.item = @item_window.active ? @item_window.item : nil
      @item_icon.x, @item_icon.y = r.x, r.y
      @item_icon.x += 2
      @item_icon.y += 2
      @item_icon.update
    end

    def on_unit_change
      @command_window.unit = @unit
      @item_window.unit = @equip_window.unit = @status_window.unit = @unit
      @command_window.activate
    end
  end
end
