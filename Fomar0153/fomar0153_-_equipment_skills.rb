=begin
Equipment Skills System Script
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Requires an AP System if you want characters to
learn skills pernamently.
If using my Custom Equipment Slots script then
make sure this script is above the Equipment Slots Script
and make sure you have the compatability patch.
Allows learning of skills by equipment with the
option to learn skills pernamently.
----------------------
Instructions
----------------------
Set Learn_Skills to false if you want the skills to
only be temporary.
If you can learn skills then you need to set up AP for
each skill you put on an item.
In the notes section put:
AP:n
where n is the ap required to learn pernamently.
Then follow the instructions below about how to add skills
to weapons and armor.
----------------------
Known bugs
----------------------
None
=end


module Equipment_Skills

  # If set to false then characters will not
  # learn the skills pernamently and you will
  # not need an ap system
  Learn_Skills = true

  Weapons = []
  # Add weapon skills in this format
  # Weapons[weapon_id] = [skillid1, skillid2]
  Weapons[1] = [7,8]

  Armors = []
  # Add weapon skills in this format
  # Armors[armor_id] = [skillid1, skillid2]
  Armors[3] = [5]

  def self.get_ap_cost(skill_id)
    t = $data_skills[skill_id].note
    if t.include?("AP:")
      ap = /AP:(\d+)/.match(t)
      ap = ap[0].split(":")
      return ap[1].to_i
    end
    return 999
  end

end

class Game_Actor < Game_Battler
  attr_reader   :ap
  #--------------------------------------------------------------------------
  # ● Aliases setup
  #--------------------------------------------------------------------------
  alias eqskills_setup setup
  def setup(actor_id)
    eqskills_setup(actor_id)
    if Equipment_Skills::Learn_Skills
      @ap = []
    end
  end
  #--------------------------------------------------------------------------
  # ● Rewrites change_equip
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    return unless trade_item_with_party(item, equips[slot_id])
    if equips[slot_id].is_a?(RPG::Weapon)
      unless Equipment_Skills::Weapons[equips[slot_id].id] == nil
        for skill in Equipment_Skills::Weapons[equips[slot_id].id]
          if Equipment_Skills::Learn_Skills
            if @ap[skill] == nil
              @ap[skill] = 0
            end
            unless @ap[skill] >= Equipment_Skills.get_ap_cost(skill)
              forget_skill(skill)
            end
          else
            forget_skill(skill)
          end
        end
      end
    end
    if equips[slot_id].is_a?(RPG::Armor)
      unless Equipment_Skills::Armors[equips[slot_id].id] == nil
        for skill in Equipment_Skills::Armors[equips[slot_id].id]
          if Equipment_Skills::Learn_Skills
            if @ap[skill] == nil
              @ap[skill] = 0
            end
            unless @ap[skill] >= Equipment_Skills.get_ap_cost(skill)
              forget_skill(skill)
            end
          else
            forget_skill(skill)
          end
        end
      end
    end
    return if item && equip_slots[slot_id] != item.etype_id
    @equips[slot_id].object = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ● New Method or Rewrites gain_ap
  #--------------------------------------------------------------------------
  def gain_ap(ap)
    if Equipment_Skills::Learn_Skills
      for item in self.equips
        if item.is_a?(RPG::Weapon)
          unless Equipment_Skills::Weapons[item.id] == nil
            for skill in Equipment_Skills::Weapons[item.id]
              if @ap[skill] == nil
                @ap[skill] = 0
              end
              last_ap = @ap[skill]
              @ap[skill] += ap
              if last_ap < Equipment_Skills.get_ap_cost(skill) and Equipment_Skills.get_ap_cost(skill) <= @ap[skill]
                SceneManager.scene.add_message(actor.name + " learns " + $data_skills[skill].name + ".")
              end
            end
          end
        end
        if item.is_a?(RPG::Armor)
          unless Equipment_Skills::Armors[item.id] == nil
            for skill in Equipment_Skills::Armors[item.id]
              if @ap[skill] == nil
                @ap[skill] = 0
              end
              @ap[skill] += ap
            end
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Aliases refresh
  #--------------------------------------------------------------------------
  alias eqskills_refresh refresh
  def refresh
    eqskills_refresh
    for item in self.equips
      if item.is_a?(RPG::Weapon)
        unless Equipment_Skills::Weapons[item.id] == nil
          for skill in Equipment_Skills::Weapons[item.id]
            learn_skill(skill)
          end
        end
      end
      if item.is_a?(RPG::Armor)
        unless Equipment_Skills::Armors[item.id] == nil
          for skill in Equipment_Skills::Armors[item.id]
            learn_skill(skill)
          end
        end
      end
    end
    # relearn any class skills you may have forgotten
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level <= @level
    end
  end
end


class Window_EquipItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● Rewrites col_max
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● Aliases update_help
  #--------------------------------------------------------------------------
  alias eqskills_update_help update_help
  def update_help
    eqskills_update_help
    if @actor && @status_window
      @status_window.refresh(item)
    end
  end
end

class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● Rewrites create_item_window
  #--------------------------------------------------------------------------
  alias eqskills_create_item_window create_item_window
  def create_item_window
    wx = @status_window.width # Edited line if you need to merge
    wy = @slot_window.y + @slot_window.height
    ww = @slot_window.width  # Edited line if you need to merge
    wh = Graphics.height - wy
    @item_window = Window_EquipItem.new(wx, wy, ww, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.status_window = @status_window
    @item_window.actor = @actor
    @item_window.set_handler(:ok,    method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @slot_window.item_window = @item_window
  end
end


class Window_EquipStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● Rewrites window_height
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height - (2 * line_height + standard_padding * 2)#fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # ● Aliases refresh
  #--------------------------------------------------------------------------
  alias eqskills_refresh refresh
  def refresh(item = nil)
    eqskills_refresh
    contents.clear
    draw_actor_name(@actor, 4, 0) if @actor
    6.times {|i| draw_item(0, line_height * (1 + i), 2 + i) }
      unless item == nil
      if item.is_a?(RPG::Weapon)
        unless Equipment_Skills::Weapons[item.id] == nil
          skills = Equipment_Skills::Weapons[item.id]
        end
      end
      if item.is_a?(RPG::Armor)
        unless Equipment_Skills::Armors[item.id] == nil
          skills = Equipment_Skills::Armors[item.id]
        end
      end
      unless skills == nil
        change_color(normal_color)
        draw_text(4, 168, width, line_height, "Equipment Skills")
        change_color(system_color)
        i = 1
        for skill in skills
          draw_text(4, 168 + 24 * i, width, line_height, $data_skills[skill].name)
          if @actor.ap[skill] == nil
            @actor.ap[skill] = 0
          end
          i = i + 1
          if Equipment_Skills::Learn_Skills
            draw_current_and_max_values(4, 168 + 24 * i, width - 50, [@actor.ap[skill],Equipment_Skills.get_ap_cost(skill)].min, Equipment_Skills.get_ap_cost(skill), system_color, system_color)
            i = i + 1
          end
        end
      end
    end
  end
end


class Window_EquipSlot < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Aliases update
  #--------------------------------------------------------------------------
  alias eqskills_update update
  def update
    eqskills_update
    @status_window.refresh(self.item) if self.active == true
  end
end


class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● New method add_text
  #--------------------------------------------------------------------------
  def add_message(text)
    $game_message.add('\.' + text)
  end
end