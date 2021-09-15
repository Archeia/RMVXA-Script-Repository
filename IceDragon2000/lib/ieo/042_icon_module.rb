#encoding:UTF-8
# IEO-0??(Icon Module)
# 02/17/2011
#==============================================================================#
# IEO::Icon
#==============================================================================#
module IEO
  module Icon
    
    module_function 
    
    def scope(num)
      case num
      when 0  ; return 672 # (0:  None) 
      when 1  ; return 673 # (1:  One Enemy) 
      when 2  ; return 674 # (2:  All Enemies) 
      when 3  ; return 675 # (3:  One Enemy Dual) 
      when 4  ; return 676 # (4:  One Random Enemy)
      when 5  ; return 677 # (5:  2 Random Enemies)  
      when 6  ; return 678 # (6:  3 Random Enemies) 
      when 7  ; return 679 # (7:  One Ally) 
      when 8  ; return 680 # (8:  All Allies)  
      when 9  ; return 681 # (9:  One Ally (Dead))  
      when 10 ; return 682 # (10: All Allies (Dead))  
      when 11 ; return 683 # (11: The User)  
      else    ; return 0  
      end  
    end
    
    def stat(cstat)
      case cstat
        # UsableItem
      when :spi_f ; return 640 # (Spi_F)
      when :atk_f ; return 641 # (Atk_F)
      when :skl_p ; return 557 # (SkillPoints)
      when :skl_u ; return 642 # (SkillPoints - LevelRequirement)
      when :speed ; return 643 # (Action Speed)
      when :hit_r ; return 644 # (Hit Rate)
      when :based ; return 645 # (Base Damage)
      when :varia ; return 646 # (Variance)
      when :heal_ ; return 647 # (Heal Type - Base Damage)
        # Properties
      when :physa ; return 648 # (Physical Attack)
      when :dam_m ; return 649 # (Damage to Mp)
      when :dam_a ; return 650 # (Absorb Damage)
      when :i_def ; return 651 # (Ignore Defense)
        # Occasion
      when :alway ; return 652 # (Always)
      when :battl ; return 653 # (Battle Only)
      when :menuo ; return 654 # (Menu Only)
      when :never ; return 655 # (Never)
       # Battle Stats  
      when :hp_ic ; return 656 # (Hp)
      when :mp_ic ; return 657 # (Mp)
      when :atk_i ; return 658 # (Atk)
      when :def_i ; return 659 # (Def)
      when :spi_i ; return 660 # (Spi)
      when :agi_i ; return 661 # (Agi)
      when :hitra ; return 662 # (Hit Rate)
      when :evasi ; return 663 # (Evasion Rate)
      when :criti ; return 99  # (Critical)  
       # Other
      when :exp_i ; return 985 # (Exp)     
      else ; return 0
      end  
    end
    
    def element(elid)
      case elid
      when 1  ; return 11
      when 2  ; return 1
      when 3  ; return 4
      when 4  ; return 14
      when 5  ; return 16
      when 6  ; return 12
      when 7  ; return 119
      when 8  ; return 136
      when 9  ; return 104
      when 10 ; return 105
      when 11 ; return 106
      when 12 ; return 107
      when 13 ; return 108
      when 14 ; return 109
      when 15 ; return 110
      when 16 ; return 111
      else    ; return 98
      end  
    end
    
    def cost(stat) 
      case stat
      when :hp, :maxhp ; return 291
      when :mp, :maxmp ; return 290
      end  
      return 0 
    end  
    
    def actor_command(actor, command)
      case command
      when :attack      ; return 359
      when :skill       ; return 520
      when :guard       ; return 551
      when :item        ; return 434
      when :escape      ; return 48  
      when :mp_recharge ; return 452
      when :wait        ; return 188  
      end
      return 0
    end  
    
    def party_command(party, command)
      case command
      when :fight       ; return 869
      when :escape      ; return 48
      when :formation   ; return 844
      # //
      when :for_forward ; return 586
      when :for_backward; return 587
      when :for_invert  ; return 589
      when :for_reverse ; return 577
      # // 
      when :for_cancel  ; return 98
      end
      return 0
    end
    
    def battle_action(actor, action)
      case action.kind
      when 0
        case action.basic
        when 0 
          if $imported["IEO-Handy"]
            return actor.act_weapon.nil? ? 0 : actor.act_weapon.icon_index 
          else  
            return actor_command(actor, :attack)     # Attack
          end  
        when 1 ; return actor_command(actor, :guard) # Guard
        when 2 ; return actor_command(actor, :escape)# Escape
        when 3 ; return actor_command(actor, :wait)  # Wait
        end
      when 1   # Skill
        return action.skill.icon_index if action.skill.icon_index > 0 
        return actor_command(actor, :skill)
      when 2   # Item
        return action.item.icon_index if action.item.icon_index > 0 
        return actor_command(actor, :item)
      when 3 
        case action.custom_action
        when :mp_recharge ; return actor_command(actor, :mp_recharge)
        end  
      end  
      return 98  
    end

    def navi(key) 
      case key.upcase 
      when "UP"    ; return 636
      when "RIGHT" ; return 637
      when "LEFT"  ; return 638
      when "DOWN"  ; return 639
      else ; return 0  
      end  
    end
    
    def clssys(obj)
      case obj
      when :class_p
        return 573
      when :class_exp  
        return 1004
      end
    end
    
    def class(n)
      case n
      when 1 ; return 804 # 1 (Warlock)
      when 2 ; return 739 # 2 (Juggernaut)
      when 3 ; return 730 # 3 (Geomancer)
      when 4 ; return 703 # 4 (Lotusmagi)
      else   ; return 0
      end  
    end
    
    def menu(command)
      case command
      when :item    ; return 416
      when :skill   ; return 1005
      when :equip   ; return 971
      when :status  ; return 982
      when :save    ; return 993
      when :system  ; return 1002
      else          ; return 0
      end  
    end
    
    def item_group(type) 
      case type
      when :all         ; return 1004 
      when :item        ; return 144
      when :equipment   ; return 891
      else              ; return 0   
      end
    end
    
  end  
end  
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#