=begin
Equipment Skills by Level
by Fomar0153
Version 1.1
----------------------
Notes
----------------------
Requires an AP System if you want characters to
learn skills pernamently.
Scripts should be in this order
Individual Equipment
Equipment Levels Up
Equipment Skills
Equipment Skills by Level
If using an AP script it should be above this script.
----------------------
Instructions
----------------------
Follow the instructions in all the other script and then
edit the Equipment_Skills module below to suit your needs.
----------------------
Change Log
----------------------
1.0 -> 1.1 Added a single character (@) to fix a bug where you 
           created new equipment when changing equipment.
----------------------
Known bugs
----------------------
None
=end
module Equipment_Skills
 
  Weapons = []
  # Add weapon skills in this format
  # Weapons[weapon_id, level] = [[level,skillid], [level,skillid]]
  Weapons[1] = [[1,8],[5,9]]
  
  Armors = []
  # Add weapon skills in this format
  # Armors[armor_id, level] = [[level,skillid],[level,skillid]]
  Armors[1] = [[1,10]]
 
end

class Game_Actor
  
  def change_equip(slot_id, item)
    return unless trade_item_with_party(item, @equips[slot_id])
    if equips[slot_id].is_a?(RPG::Weapon)
      unless Equipment_Skills::Weapons[equips[slot_id].id] == nil
        for skill in Equipment_Skills::Weapons[equips[slot_id].id]
          if Equipment_Skills::Learn_Skills
            if @ap[skill[1]] == nil
              @ap[skill[1]] = 0
            end
            unless @ap[skill[1]] >= Equipment_Skills.get_ap_cost(skill[1])
              forget_skill(skill[1])
            end
          else
            forget_skill(skill[1])
          end
        end
      end
    end
    if equips[slot_id].is_a?(RPG::Armor)
      unless Equipment_Skills::Armors[equips[slot_id].id] == nil
        for skill in Equipment_Skills::Armors[equips[slot_id].id]
          if Equipment_Skills::Learn_Skills
            if @ap[skill[1]] == nil
              @ap[skill[1]] = 0
            end
            unless @ap[skill[1]] >= Equipment_Skills.get_ap_cost(skill[1])
              forget_skill(skill[1])
            end
          else
            forget_skill(skill[1])
          end
        end
      end
    end
    return if item && equip_slots[slot_id] != item.etype_id
    if item.nil?
      @equips[slot_id] = Game_CustomEquip.new
    else
      @equips[slot_id] = item
    end
    refresh
  end
  
  def gain_ap(ap)
    if Equipment_Skills::Learn_Skills
      for item in @equips
        if item.is_weapon?
          unless Equipment_Skills::Weapons[item.id] == nil
            for skill in Equipment_Skills::Weapons[item.id]
              if @ap[skill[1]] == nil
                @ap[skill[1]] = 0
              end
              last_ap = @ap[skill[1]]
              @ap[skill[1]] += ap if skill[0] <= item.level
              if last_ap < Equipment_Skills.get_ap_cost(skill[1]) and Equipment_Skills.get_ap_cost(skill[1]) <= @ap[skill[1]]
                SceneManager.scene.add_message(actor.name + " learns " + $data_skills[skill[1]].name + ".")
              end
            end
          end
        end
        if item.is_armor?
          unless Equipment_Skills::Armors[item.id] == nil
            for skill in Equipment_Skills::Armors[item.id]
              if @ap[skill[1]] == nil
                @ap[skill[1]] = 0
              end
              last_ap = @ap[skill[1]]
              @ap[skill[1]] += ap if skill[0] <= item.level
              if last_ap < Equipment_Skills.get_ap_cost(skill[1]) and Equipment_Skills.get_ap_cost(skill[1]) <= @ap[skill[1]]
                SceneManager.scene.add_message(actor.name + " learns " + $data_skills[skill[1]].name + ".")
              end
            end
          end
        end
      end
    end
  end
  
  def refresh
    eqskills_refresh
    for item in @equips
      if item.is_weapon?
        unless Equipment_Skills::Weapons[item.id] == nil
          for skill in Equipment_Skills::Weapons[item.id]
            learn_skill(skill[1]) if skill[0] <= item.level
          end
        end
      end
      if item.is_armor?
        unless Equipment_Skills::Armors[item.id] == nil
          for skill in Equipment_Skills::Armors[item.id]
            learn_skill(skill[1]) if skill[0] <= item.level
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

class Game_CustomEquip < Game_BaseItem
  
  def level
    return @level
  end
  
end


class Window_EquipStatus < Window_Base
  
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
          draw_text(4, 168 + 24 * i, width, line_height, $data_skills[skill[1]].name + " (" + skill[0].to_s + ")")
          if Equipment_Skills::Learn_Skills and @actor.ap[skill[1]] == nil
            @actor.ap[skill[1]] = 0
          end
          i = i + 1
          if Equipment_Skills::Learn_Skills
            draw_current_and_max_values(4, 168 + 24 * i, width - 50, [@actor.ap[skill[1]],Equipment_Skills.get_ap_cost(skill[1])].min, Equipment_Skills.get_ap_cost(skill[1]), system_color, system_color)
            i = i + 1
          end
        end
      end
    end
  end
  
end