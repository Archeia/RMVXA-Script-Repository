#encoding:UTF-8
module REI
  class BattlerUnit
    DEBUG_AI = false

    def ai_output_debug(*args, &block)
      puts *args, &block if DEBUG_AI
    end

    alias :_aod :ai_output_debug
    def ai_iq_healing
      case @_ai.iq Game::AI::HEALING_IQ
      when 0
        if hp_rate < 0.25
          if ia=ai_can_heal_hp?
            ite, = ia
            return false unless ite
            set_obj_action( ite ).set_effect_pos(*self.pos_a)
            _aod "► Healing self with #{ite.name} for #{(hp_rate*100).to_i}% HP (#{hp}/#{mhp})"
            return true
          end
        end
        if mp_rate < 0.25
          if ia=ai_can_heal_mp?
            ite, = ia
            return false unless ite
            set_obj_action( ite ).set_effect_pos(*self.pos_a)
            _aod "► Healing self with #{ite.name} for #{(mp_rate*100).to_i}% MP (#{mp}/#{mmp})"
            return true
          end
        end
      when 1
      when 2
      end
      return false
    end

    def ai_iq_self_prev
      return false unless @ai_target_struct.no_foes?
      case @_ai.iq( Game::AI::SELF_PREV_IQ )
      when 0
        return ai_iq_self_prev_do(0.80)
      when 1
        return ai_iq_self_prev_do(0.66)
      when 2
        return ai_iq_self_prev_do(0.33)
      end
      return false
    end

    def ai_iq_self_prev_do(comp_rate)
      return false unless hp_rate < comp_rate
      set_skip_action
      _aod "► Skipping Turn for #{(hp_rate*100).to_i}% HP (#{hp}/#{mhp})"
      return true
    end

    def ai_iq_pickup
      case @_ai.iq( Game::AI::PICKUP_IQ )
      when 0
        return false if(@ai_target_struct.alive_foes.any?{|c|distance_from(c.x,c.y)<5})
        return ai_iq_pickup_do(5)
      when 1
        return ai_iq_pickup_do(10)
      end
      return false
    end

    def ai_iq_pickup_do(dist)
      ites = _map.items.select{|i|!self.inventory.max_item_number?(i)}
      ites = ites.inject([]){|r,i|a=[distance_from(i.x,i.y),i];r<<a if(a[0]<dist);r}
      ites = ites.sort_by{|a|a[0]}
      itm, = ites
      return false unless(itm)
      tx, ty = itm[1].x, itm[1].y
      _aod "► Moving to (#{tx}, #{ty}) for item"
      ai_set_move_to( tx, ty )
      return true
    end

    def ai_iq_party_support
      return false if(@ai_target_struct.no_party_members?)
      case @_ai.iq( Game::AI::PARTY_SUPPORT_IQ )
      when 0
      when 1
        ptm,=@ai_target_struct.dead_party_members.sort_by{|a|distance_from(a.x,a.y)}
        return false unless ptm
        return false if @ai_target_struct.alive_foes.any? do |c|
          (c.distance_from( ptm.x, ptm.y ) < 3) && # // Close to target
          (distance_from( c.x, c.y ) < 3) # // Close to self
        end
        if distance_from( ptm.x, ptm.y ) > 1
          return false unless ai_possible_path?( ptm.x, ptm.y )
          ai_set_move_to( ptm.x, ptm.y )
          _aod "► Moving to (#{ptm.x}, #{ptm.y})#{ptm.name} for nudging"
          return true
        else
          turn_toward_character( ptm )
          _aod "► Nudging #{ptm.name}"
          set_nudge_action.set_effect_pos(*ptm.pos_a)
          return true
        end
      end
      return false
    end

    def ai_iq_aggro
      targets = @ai_target_struct.alive_foes.map{|c|[path_size(c.x,c.y),c]}
      targets.select!{|ca|ca[0]==0 ? distance_from(ca[1].x,ca[1].y) < 2 : true}
      targets.map!{|c|c[1]}
      @ai_target_struct.range = get_range($data_skills[attack_skill_id])
      @ai_target_struct.range_table =
        RPG::BaseItem::Range.mk_range_table(_map.adjust_range(
          @ai_target_struct.range.mk_range_a,self.x,self.y),_map.width,_map.height
        )
      case @_ai.iq( Game::AI::AGGRO_IQ )
      when 0
        target, = targets
        return false unless target
        return ai_iq_aggro_do(target)
      when 1, 2
        rt, = targets
        return false unless(rt)
        closest_targets = (targets-[rt]).select { |c|
          rt.distance_from( c.x, c.y ) < 4 }
        closest_targets.unshift(rt)
        closest_targets.sort! { |a, b| a.ko_exp <=> b.ko_exp }
        closest_targets.reverse! if ag == 1
        index = 0
        target = closest_targets[index]
        while index < closest_targets.size &&
            distance_from( target.x, target.y ) > 1
          index += 1
          target = closest_targets[index]
        end
        return ai_iq_aggro_do(target)
      end
      return false
    end

    def ai_iq_aggro_do(target)
      if (!ai_target_in_range?(target,@ai_target_struct.range_table))
        if @ai_target_struct.range.too_close?( *(pos_a+target.pos_a) )
          ai_set_move_to( *target.pos_a )
          _aod "► Moving to (#{target.x}, #{target.y})#{target.name} for attacking"
        else
          ai_set_move_to( *target.pos_a )
          _aod "► Moving to (#{target.x}, #{target.y})#{target.name} for attacking"
        end
        return true
      else
        set_attack_action.set_effect_pos(*target.pos_a)
        puts "► Attacking #{target.name}"
        return true
      end
      return false
    end

    def ai_target_in_range?(target, range_table)
      range_table[target.x,target.y] == 1
    end

    def ai_select_target(targets, range_table)
      targets
      range_table
    end

    def ai_iq_patrol
      case @_ai.iq( Game::AI::PATROL_IQ )
      when 0
        pos = current_room.random_floor_pos
        ai_set_move_to( pos[0], pos[1] )
        _aod "► Moving Randomly in room"
        return true
      when 1
      when 2
      end
      return false
    end

    def ai_iq_party_move
      return false unless leader=party.leader
      case @_ai.iq( Game::AI::PARTY_MOVE_IQ )
      when 0
        d  = leader.direction
        ax = _map.x_with_direction( 0, d )
        ay = _map.y_with_direction( 0, d )
        cx = _map.round_x( leader.x - (ax * party_index) )
        cy = _map.round_y( leader.y - (ay * party_index) )
        mx, my = cx, cy
        ai_set_move_to( mx, my )
        _aod "► Moving to (#{mx}, #{my}): To Follow Leader"
        return true
      when 1
      when 2
      end
      return false
    end
  end
end
