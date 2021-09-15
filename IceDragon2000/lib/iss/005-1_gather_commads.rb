#encoding:UTF-8
# ISS005 - GatherCommads
module ISS
  module SRE

    def create_Gather_set(max)
      set  = SACS.new()
      set.list        << SAC.new("ANIMATION", [3])
      set.list        << SAC.new("GATHER", [max])
      set.list        << SAC.new("WAIT", [12])
      set.skip_procs  << get_defScript("FALSE")
      set.break_procs << SCR.new(["character"], "character.rts_object.resource.maxed?()")
      set.type = :loop
      return set
    end

    def create_Drop_set(max)
      scomm= SAC.new( "SCRIPT",
        ["$game_variables[20] = [$game_variables[20] + 1, $game_variables[19]].min"] )
      set  = SACS.new()
      set.list        << SAC.new("ANIMATION", [2])
      set.list        << SAC.new("UNGATHER", [max])
      set.list        << scomm
      set.list        << SAC.new("WAIT", [12])
      set.skip_procs  << get_defScript("FALSE")
      set.break_procs << SCR.new(["character"], "character.rts_object.resource.min?()")
      set.type = :loop
      return set
    end

    def create_ChangeTile_set()
      scomm= SAC.new( "SCRIPT",
        ["character.dungeon_obj.change_tile"] )
      set  = SACS.new()
      set.list        << SAC.new("ANIMATION", [2])
      set.list        << scomm
      set.list        << SAC.new("WAIT", [12])
      set.skip_procs  << get_defScript("FALSE")
      set.break_procs << SCR.new(["character"], '$game_map.data[character.x, character.y, 0] == 1568')
      set.type = :one_shot
      return set
    end

    def create_Gather_ref(max, trg = [0, 0], ret = [0, 0])
      ref    = SACR.new()
      mvset1 = create_Moveto_set(trg[0], trg[1], false)
      mvset2 = create_Moveto_set(ret[0], ret[1], false)
      gthr   = create_Gather_set(max)
      drp    = create_Drop_set  (max)
      mvset1.name = "MoveToTarget"
      mvset2.name = "Return"
      gthr.name   = "Gather"
      drp.name    = "Dropoff"
      ref.phase_actions  = [mvset1, gthr, mvset2, drp]
      ref.phase_size     = 4
      ref.type           = :loop
      return ref
    end

    def create_Marktile_set(script)
      comm = SAC.new("SCRIPT", [script])
      set  = SACS.new()
      set.list        << comm
      set.skip_procs  << get_defScript("FALSE")
      str = %Q(
        data = character.dungeon_obj.get_next_tile()
        data = [-1, -1] if data.nil?
        $game_map.data[data[0], data[1], 1] == 1538
      )
      set.break_procs << SCR.new(["character"], str)
      set.type = :one_shot
      return set
    end

    def create_WallRemove_ref()
      ref    = SACR.new()
      mvset1 = create_ScriptMoveto_set("character.dungeon_obj.get_next_tile()")
      mvset1.skip_procs.unshift(SCR.new( ["character"], '$tile_markers.empty?()' ))
      chng   = create_ChangeTile_set()
      mark = create_Marktile_set( %Q(
        data = character.dungeon_obj.get_next_tile()
        data = [-1, -1] if data.nil?
        $game_map.data[data[0], data[1], 1] = 1538) )
      retn = create_ScriptMoveto_set("character.dungeon_obj.home_xy")
      retn.break_procs.clear()
      retn.break_procs << SCR.new(["character"], '!$tile_markers.empty?()')

      mvset1.name = "MoveToTarget"
      chng.name   = "ChangeTile"
      mark.name   = "MarkNextTile"
      retn.name   = "ReturnHome"
      ref.phase_actions  = [mark, mvset1, chng, retn]
      ref.phase_size     = 4
      ref.type           = :loop
      return ref
    end

    def setup_gather_event(event, targ_xy, ret_xy)
      event.setup_rts()
      r = create_Gather_ref(event.rts_object.resource.max, targ_xy, ret_xy)
      event.rts_engine.action_ref = r
    end

    def setup_digger_event(event)
      event.setup_rts() ; event.setup_dungeon()
      r = create_WallRemove_ref() ; event.rts_engine.action_ref = r
    end

  end
end
