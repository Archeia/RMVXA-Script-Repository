#encoding:UTF-8
module REI
  class BattlerUnit
    def current_room
      _map.room_at( self.x, self.y )
    end

    def alignment
      @alignment
    end

    def friend?(other_id=0)
      self.alignment == other_id
    end

    def foe?(other_id=0)
      self.alignment != other_id
    end

    def foe_character?( c )
      foe?(c.alignment)
    end

    def friendly_character?( c )
      friend?(c.alignment)
    end

    def passable_infront?( d )
      passable?( self.x, self.y, d )
    end

    def sorrounding_characters
      return _map.characters_xy_nt( self.x+1, self.y ) +
       _map.characters_xy_nt( self.x-1, self.y ) +
       _map.characters_xy_nt( self.x, self.y+1 ) +
       _map.characters_xy_nt( self.x, self.y-1 )
    end

    def get_enemies_sorrounding
      sorrounding_characters.select { |c| foe_character?( c ) }
    end

    def get_allies_sorrounding
      sorrounding_characters.select { |c| friendly_character?( c ) }
    end

    def get_alive_enemies_sorrounding
      get_enemies_sorrounding.select { |c| c.alive? }
    end

    def get_alive_allies_sorrounding
      get_allies_sorrounding.select { |c| c.alive? }
    end

    def get_dead_enemies_sorrounding
      get_enemies_sorrounding.select { |c| c.dead? }
    end

    def get_dead_allies_sorrounding
      get_allies_sorrounding.select { |c| c.dead? }
    end

    def xy_infront(x = @x, y = @y, d = @direction)
      return _map.round_x_with_direction(x,d), _map.round_y_with_direction(y,d)
    end

    def characters_infront( d=@direction )
      return _map.characters_xy_nt( *xy_infront )
    end

    def get_enemies_infront( d=@direction )
      characters_infront(d).select { |c| foe_character?( c ) }
    end

    def get_allies_infront( d=@direction )
      characters_infront(d).select { |c| friendly_character?( c ) }
    end

    def get_alive_enemies_infront( d=@direction )
      get_enemies_infront(d).select { |c| c.alive? }
    end

    def get_alive_allies_infront( d=@direction )
      get_allies_infront(d).select { |c| c.alive? }
    end

    def get_dead_enemies_infront( d=@direction )
      get_enemies_infront(d).select { |c| c.dead? }
    end

    def get_dead_allies_infront( d=@direction )
      get_allies_infront(d).select { |c| c.dead? }
    end

    def get_substitue_character
      get_allies_sorrounding.shuffle.find { |c| c.substitute? }
    end

    def get_characters_in( room )
      _map.characters.select { |c| c.current_room == room }
    end

    def distance_from( x, y )
      return distance_x_from( x ).abs + distance_y_from( y ).abs
    end

    def ai_get_closest_characters( group=false, search_range=@_ai.search_range )
      chs = (_map.characters-[self]).sort do |a, b|
        distance_from( a.x, a.y ) <=> distance_from( b.x, b.y )
      end.select do |c|
        search_range > 0 ? distance_from( c.x, c.y ) <= search_range : true
      end

      if group
        res = { :foes => [], :friends => [] }
        chs.each do |c|
          res[:foes] << c if foe_character?( c )
          res[:friends] << c if friendly_character?( c )
        end
        return res
      else
        return chs
      end
    end

    def ai_get_enemies
      return _map.characters.select { |c| foe_character?( c ) }
    end

    def ai_get_allies
      return _map.characters.select { |c| friendly_character?( c ) }
    end

    def ai_get_closest_enemies
      return ai_get_closest_characters( true )[:foes]
    end

    def ai_get_closest_allies
      return ai_get_closest_characters( true )[:friends]
    end

    def ai_get_closest_alive_enemies
      return ai_get_closest_enemies.select { |c| c.alive? }
    end

    def ai_get_closest_alive_allies
      return ai_get_closest_allies.select { |c| c.alive? }
    end

    def ai_get_closest_dead_enemies
      return ai_get_closest_enemies.select { |c| c.dead? }
    end

    def ai_get_closest_dead_allies
      return ai_get_closest_allies.select { |c| c.dead? }
    end

    def ai_same_room?( room )
      current_room == room
    end

    def ai_different_room?( room )
      current_room != room
    end

    def ai_possible_path?( tx, ty )
      !find_path( { :tx => tx, :ty => ty } ).empty?
    end

    def ai_can_heal_hp?
      (self.inventory.items+self.skills).select{|i|i.ai_tags.include?(:heal_hp)&&usable?(i)}
    end

    def ai_can_heal_mp?
      (self.inventory.items+self.skills).select{|i|i.ai_tags.include?(:heal_mp)&&usable?(i)}
    end

    def nearest_room_node( room )
      return (room.nodes.map { |n|
        [distance_from( n.real_x, n.real_y ), n]}).min { |a, b| a[0] <=> b[0] }
    end

    def ai_passable_sorrouding
      return [[self.x+1, self.y, 5],[self.x-1, self.y, 5],
       [self.x, self.y+1, 5],[self.x, self.y-1, 5]].select { |a| passable?( *a ) }
    end

    def ai_will_cause_move_lock?( x, y )
      ps = ai_passable_sorrouding.map { |pas| [pas[0], pas[1]] }
      return true if (ps.include?( [x, y] )) if ps.size == 1
      return false
    end

    def ai_set_move_to( tx, ty )
      unless distance_from( tx, ty ) > 1
        sx = distance_x_from( tx )
        sy = distance_y_from( ty )
        if sx.abs > sy.abs
          set_direction(sx > 0 ? 4 : 6)
          set_move_action
          return true
        elsif sy != 0
          set_direction(sy > 0 ? 8 : 2)
          set_move_action
          return true
        else
          return false
        end
      end
      trp_iq = @_ai.iq( Game::AI::TRAP_IQ )
      mov_iq = @_ai.iq( Game::AI::MOVE_IQ )
      inf = {
        :tx => tx,
        :ty => ty,
      }
      inf[:forced_xy] = []
      case mov_iq
      when 0 # // Nothing here
      when 1
        inf[:ignore_xy] = (ai_get_allies.map { |c| [c.x, c.y] }).select { |a|
          distance_from( a[0], a[1] ) > 3
        }
      end
      case trp_iq
      when 0
        inf[:forced_xy] = _map.visible_traps.map { |t| [t.x, t.y, 0] }
      when 1
        inf[:forced_xy] = (_map.visible_traps.select { |t| t.can_trigger? }).map { |t| [t.x, t.y, 0] }
      when 2
        inf[:forced_xy] = _map.traps.map { |t| [t.x, t.y, 0] }
      end
      inf[:forced_xy].select! { |a| !ai_will_cause_move_lock?( a[0], a[1]) }
      path = find_path( inf )
      #_map.clear_active_ranges
      #_map.add_ranges( path, Color.new(0, 198, 0).to_flash )
      node = path.pop
      node = path.pop if !node.nil? && (node[0] == self.x && node[1] == self.y)
      return false if node.nil?
      #_map.remove_ranges( [node] )
      #_map.add_ranges( [node], Color.new(0, 198, 178).to_flash )
      sx = distance_x_from( node[0] )
      sy = distance_y_from( node[1] )
      if sx.abs > sy.abs
        set_direction(sx > 0 ? 4 : 6)
        set_move_action
        return true
      elsif sy != 0
        set_direction(sy > 0 ? 8 : 2)
        set_move_action
        return true
      else
        return false
      end
    end

    class AITargetStruct
      attr_accessor :range
      attr_accessor :range_table
      attr_accessor :subject
      attr_reader :closest_foes
      attr_reader :closest_friends
      attr_reader :adjacent_foes
      attr_reader :adjacent_friends
      attr_reader :party_members
      attr_reader :party_members_es

      def initialize(subject)
        @subject = subject
      end

      def make_target_lists
        closest          = @subject.ai_get_closest_characters( true )
        @closest_foes    = closest[:foes]
        @closest_friends = closest[:friends]
        @closest_foes    = [@closest_foes, select_alive(@closest_foes), select_dead(@closest_foes)]
        @closest_friends = [@closest_friends, select_alive(@closest_friends), select_dead(@closest_friends)]
        @adjacent_foes   = @closest_foes.map{|a|select_adjacent(a)}
        @adjacent_friends= @closest_friends.map{|a|select_adjacent(a)}
        @party_members   = @subject.party.members
        @party_members_es= @party_members - [@subject]
        @party_members_es= [@party_members_es,select_alive(@party_members_es),select_dead(@party_members_es)]
        self
      end

      def select_alive(targets)
        targets.select{ |c| c.alive? }
      end

      def select_dead(targets)
        targets.select{ |c| c.dead? }
      end

      def select_adjacent(targets)
        targets.select{ |c| @subject.distance_from(c.x, c.y) == 1 }
      end

      def no_foes?
        @closest_foes[1].empty?
      end

      def no_friends?
        @closest_friends[1].empty?
      end

      def no_party_members?
        @party_members_es[0].empty?
      end

      def alive_party_members
        @party_members_es[1]
      end

      def dead_party_members
        @party_members_es[2]
      end

      def alive_foes
        @closest_foes[1]
      end
    end

    def ai_make_action
      ready_action
      puts "♥ #{@name} is making its action"
      (@ai_target_struct ||= AITargetStruct.new(self)).make_target_lists
      return if ai_iq_healing
      return if ai_iq_self_prev
      return if ai_iq_pickup
      return if ai_iq_party_support
      return if ai_iq_aggro
      return if ai_iq_patrol
      return if ai_iq_party_move
      set_skip_action
    end
  end
end
