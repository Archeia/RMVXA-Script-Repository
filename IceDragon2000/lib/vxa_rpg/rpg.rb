module RPG
  class BaseItem
    class Feature
      def initialize(code = 0, data_id = 0, value = 0)
        @code = code
        @data_id = data_id
        @value = value
      end
      attr_accessor :code
      attr_accessor :data_id
      attr_accessor :value
    end
  end
end

module RPG
  class BaseItem
    def initialize
      @id = 0
      @name = ''
      @icon_index = 0
      @description = ''
      @features = []
      @note = ''
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_index
    attr_accessor :description
    attr_accessor :features
    attr_accessor :note
  end
end

module RPG
  class Actor < BaseItem
    def initialize
      super
      @nickname = ''
      @class_id = 1
      @initial_level = 1
      @max_level = 99
      @character_name = ''
      @character_index = 0
      @face_name = ''
      @face_index = 0
      @equips = [0,0,0,0,0]
    end
    attr_accessor :nickname
    attr_accessor :class_id
    attr_accessor :initial_level
    attr_accessor :max_level
    attr_accessor :character_name
    attr_accessor :character_index
    attr_accessor :face_name
    attr_accessor :face_index
    attr_accessor :equips
  end
end
module RPG
  class Animation
    class Frame
      def initialize
        @cell_max = 0
        @cell_data = Table.new(0, 0)
      end

      attr_accessor :cell_max
      attr_accessor :cell_data
    end
  end
end
module RPG
  class AudioFile
    def initialize(name = '', volume = 100, pitch = 100)
      @name = name
      @volume = volume
      @pitch = pitch
    end
    attr_accessor :name
    attr_accessor :volume
    attr_accessor :pitch
  end
end

module RPG
  class SE < AudioFile
    def play
      unless @name.empty?
        Audio.se_play('Audio/SE/' + @name, @volume, @pitch)
      end
    end
    def self.stop
      Audio.se_stop
    end
  end
end

module RPG
  class Animation
    class Timing
      def initialize
        @frame = 0
        @se = RPG::SE.new('', 80)
        @flash_scope = 0
        @flash_color = Color.new(255, 255, 255, 255)
        @flash_duration = 5
      end

      attr_accessor :frame
      attr_accessor :se
      attr_accessor :flash_scope
      attr_accessor :flash_color
      attr_accessor :flash_duration
    end
  end
end

module RPG
  class Animation
    def initialize
      @id = 0
      @name = ''
      @animation1_name = ''
      @animation1_hue = 0
      @animation2_name = ''
      @animation2_hue = 0
      @position = 1
      @frame_max = 1
      @frames = [RPG::Animation::Frame.new]
      @timings = []
    end

    def to_screen?
      @position == 3
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :animation1_name
    attr_accessor :animation1_hue
    attr_accessor :animation2_name
    attr_accessor :animation2_hue
    attr_accessor :position
    attr_accessor :frame_max
    attr_accessor :frames
    attr_accessor :timings
  end
end

module RPG
  class EquipItem < BaseItem
    def initialize
      super
      @price = 0
      @etype_id = 0
      @params = Array.new(8, 0)
    end
    attr_accessor :price
    attr_accessor :etype_id
    attr_accessor :params
  end
end

module RPG
  class Armor < EquipItem
    def initialize
      super
      @atype_id = 0
      @etype_id = 1
      @features.push(RPG::BaseItem::Feature.new(22, 1, 0))
    end

    def performance
      params[3] + params[5] + params.inject(0) {|r, v| r += v }
    end

    attr_accessor :atype_id
  end
end

module RPG
  class BGM < AudioFile
    @@last = RPG::BGM.new

    def play(pos = 0)
      if @name.empty?
        Audio.bgm_stop
        @@last = RPG::BGM.new
      else
        Audio.bgm_play('Audio/BGM/' + @name, @volume, @pitch, pos)
        @@last = self.clone
      end
    end

    def replay
      play(@pos)
    end

    def self.stop
      Audio.bgm_stop
      @@last = RPG::BGM.new
    end

    def self.fade(time)
      Audio.bgm_fade(time)
      @@last = RPG::BGM.new
    end

    def self.last
      @@last.pos = Audio.bgm_pos
      @@last
    end

    attr_accessor :pos
  end
end

module RPG
  class BGS < RPG::AudioFile
    @@last = RPG::BGS.new

    def play(pos = 0)
      if @name.empty?
        Audio.bgs_stop
        @@last = RPG::BGS.new
      else
        Audio.bgs_play('Audio/BGS/' + @name, @volume, @pitch, pos)
        @@last = self.clone
      end
    end

    def replay
      play(@pos)
    end

    def self.stop
      Audio.bgs_stop
      @@last = RPG::BGS.new
    end

    def self.fade(time)
      Audio.bgs_fade(time)
      @@last = RPG::BGS.new
    end

    def self.last
      @@last.pos = Audio.bgs_pos
      @@last
    end

    attr_accessor :pos
  end
end

module RPG
  class Class < RPG::BaseItem
    class Learning
      def initialize
        @level = 1
        @skill_id = 1
        @note = ''
      end
      attr_accessor :level
      attr_accessor :skill_id
      attr_accessor :note
    end
  end
end

module RPG
  class Class < BaseItem
    def initialize
      super
      @exp_params = [30, 20, 30, 30]
      @params = Table.new(8, 100)
      (1..99).each do |i|
        @params[0, i] = 400 + i * 50
        @params[1, i] = 80 + i * 10
        (2..5).each {|j| @params[j, i] = 15 + i * 5 / 4 }
        (6..7).each {|j| @params[j, i] = 30 + i * 5 / 2 }
      end
      @learnings = []
      @features.push(RPG::BaseItem::Feature.new(23, 0, 1))
      @features.push(RPG::BaseItem::Feature.new(22, 0, 0.95))
      @features.push(RPG::BaseItem::Feature.new(22, 1, 0.05))
      @features.push(RPG::BaseItem::Feature.new(22, 2, 0.04))
      @features.push(RPG::BaseItem::Feature.new(41, 1))
      @features.push(RPG::BaseItem::Feature.new(51, 1))
      @features.push(RPG::BaseItem::Feature.new(52, 1))
    end

    def exp_for_level(level)
      lv = level.to_f
      basis = @exp_params[0].to_f
      extra = @exp_params[1].to_f
      acc_a = @exp_params[2].to_f
      acc_b = @exp_params[3].to_f
      return (basis * ((lv - 1) ** (0.9 + acc_a / 250)) * lv * (lv + 1) /
             (6 + lv ** 2 / 50 / acc_b) + (lv - 1) * extra).round.to_i
    end

    attr_accessor :exp_params
    attr_accessor :params
    attr_accessor :learnings
  end
end
module RPG
  class EventCommand
    def initialize(code = 0, indent = 0, parameters = [])
      @code = code
      @indent = indent
      @parameters = parameters
    end
    attr_accessor :code       # Integer
    attr_accessor :indent     # Integer
    attr_accessor :parameters # Array
  end
end

module RPG
  class CommonEvent
    def initialize
      @id = 0
      @name = ''
      @trigger = 0
      @switch_id = 1
      @list = [RPG::EventCommand.new]
    end

    def autorun?
      @trigger == 1
    end

    def parallel?
      @trigger == 2
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :trigger
    attr_accessor :switch_id
    attr_accessor :list
  end
end

module RPG
  class Enemy < BaseItem
    class Action
      def initialize
        @skill_id = 1
        @condition_type = 0
        @condition_param1 = 0
        @condition_param2 = 0
        @rating = 5
      end
      attr_accessor :skill_id
      attr_accessor :condition_type
      attr_accessor :condition_param1
      attr_accessor :condition_param2
      attr_accessor :rating
    end
  end
end

module RPG
  class Enemy < BaseItem
    class DropItem
      def initialize
        @kind = 0
        @data_id = 1
        @denominator = 1
      end
      attr_accessor :kind
      attr_accessor :data_id
      attr_accessor :denominator
    end
  end
end

module RPG
  class Enemy < BaseItem
    def initialize
      super
      @battler_name = ''
      @battler_hue = 0
      @params = [100,0,10,10,10,10,10,10]
      @exp = 0
      @gold = 0
      @drop_items = Array.new(3) { RPG::Enemy::DropItem.new }
      @actions = [RPG::Enemy::Action.new]
      @features.push(RPG::BaseItem::Feature.new(22, 0, 0.95))
      @features.push(RPG::BaseItem::Feature.new(22, 1, 0.05))
      @features.push(RPG::BaseItem::Feature.new(31, 1, 0))
    end
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :params
    attr_accessor :exp
    attr_accessor :gold
    attr_accessor :drop_items
    attr_accessor :actions
  end
end
module RPG
  class Event
    class Page
      class Condition
        def initialize
          @switch1_valid = false
          @switch2_valid = false
          @variable_valid = false
          @self_switch_valid = false
          @item_valid = false
          @actor_valid = false
          @switch1_id = 1
          @switch2_id = 1
          @variable_id = 1
          @variable_value = 0
          @self_switch_ch = 'A'
          @item_id = 1
          @actor_id = 1
        end
        attr_accessor :switch1_valid
        attr_accessor :switch2_valid
        attr_accessor :variable_valid
        attr_accessor :self_switch_valid
        attr_accessor :item_valid
        attr_accessor :actor_valid
        attr_accessor :switch1_id
        attr_accessor :switch2_id
        attr_accessor :variable_id
        attr_accessor :variable_value
        attr_accessor :self_switch_ch
        attr_accessor :item_id
        attr_accessor :actor_id
      end
    end
  end
end
module RPG
  class Event
    class Page
      class Graphic
        def initialize
          @tile_id = 0
          @character_name = ''
          @character_index = 0
          @direction = 2
          @pattern = 0
        end
        attr_accessor :tile_id
        attr_accessor :character_name
        attr_accessor :character_index
        attr_accessor :direction
        attr_accessor :pattern
      end
    end
  end
end
module RPG
  class MoveCommand
    def initialize(code = 0, parameters = [])
      @code = code
      @parameters = parameters
    end
    attr_accessor :code
    attr_accessor :parameters
  end
end

module RPG
  class MoveRoute
    def initialize
      @repeat = true
      @skippable = false
      @wait = false
      @list = [RPG::MoveCommand.new]
    end
    attr_accessor :repeat
    attr_accessor :skippable
    attr_accessor :wait
    attr_accessor :list
  end
end


module RPG
  class Event
    class Page
      def initialize
        @condition = RPG::Event::Page::Condition.new
        @graphic = RPG::Event::Page::Graphic.new
        @move_type = 0
        @move_speed = 3
        @move_frequency = 3
        @move_route = RPG::MoveRoute.new
        @walk_anime = true
        @step_anime = false
        @direction_fix = false
        @through = false
        @priority_type = 0
        @trigger = 0
        @list = [RPG::EventCommand.new]
      end

      # @return [RPG::Event::Page::Condition]
      attr_accessor :condition
      # @return [RPG::Event::Page::Graphic]
      attr_accessor :graphic
      # @return [Integer]
      attr_accessor :move_type
      # @return [Integer]
      attr_accessor :move_speed
      # @return [Integer]
      attr_accessor :move_frequency
      # @return [RPG::MoveRoute]
      attr_accessor :move_route
      # @return [Boolean]
      attr_accessor :walk_anime
      # @return [Boolean]
      attr_accessor :step_anime
      # @return [Boolean]
      attr_accessor :direction_fix
      # @return [Boolean]
      attr_accessor :through
      # @return [Integer]
      attr_accessor :priority_type
      # @return [Integer]
      attr_accessor :trigger
      # @return [Array<RPG::EventCommand>]
      attr_accessor :list
    end
  end
end

module RPG
  class Event
    def initialize(x, y)
      @id = 0
      @name = ''
      @x = x
      @y = y
      @pages = [RPG::Event::Page.new]
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :x
    attr_accessor :y
    attr_accessor :pages
  end
end

module RPG
  class UsableItem < BaseItem
    class Damage
      def initialize
        @type = 0
        @element_id = 0
        @formula = '0'
        @variance = 20
        @critical = false
      end

      def none?
        @type == 0
      end

      def to_hp?
        [1,3,5].include?(@type)
      end

      def to_mp?
        [2,4,6].include?(@type)
      end

      def recover?
        [3,4].include?(@type)
      end

      def drain?
        [5,6].include?(@type)
      end

      def sign
        recover? ? -1 : 1
      end

      def eval(a, b, v)
        [Kernel.eval(@formula), 0].max * sign rescue 0
      end

      # @return [Integer]
      attr_accessor :type
      # @return [Integer]
      attr_accessor :element_id
      # @return [String]
      attr_accessor :formula
      # @return [Integer]
      attr_accessor :variance
      # @return [Boolean]
      attr_accessor :critical
    end
  end
end

module RPG
  class UsableItem < BaseItem
    class Effect
      def initialize(code = 0, data_id = 0, value1 = 0, value2 = 0)
        @code = code
        @data_id = data_id
        @value1 = value1
        @value2 = value2
      end

      # @return [Integer]
      attr_accessor :code
      # @return [Integer]
      attr_accessor :data_id
      # @return [Integer]
      attr_accessor :value1
      # @return [Integer]
      attr_accessor :value2
    end
  end
end

module RPG
  class UsableItem < BaseItem
    def initialize
      super
      @scope = 0
      @occasion = 0
      @speed = 0
      @success_rate = 100
      @repeats = 1
      @tp_gain = 0
      @hit_type = 0
      @animation_id = 0
      @damage = RPG::UsableItem::Damage.new
      @effects = []
    end

    def for_opponent?
      [1, 2, 3, 4, 5, 6].include?(@scope)
    end

    def for_friend?
      [7, 8, 9, 10, 11].include?(@scope)
    end

    def for_dead_friend?
      [9, 10].include?(@scope)
    end

    def for_user?
      @scope == 11
    end

    def for_one?
      [1, 3, 7, 9, 11].include?(@scope)
    end

    def for_random?
      [3, 4, 5, 6].include?(@scope)
    end

    def number_of_targets
      for_random? ? @scope - 2 : 0
    end

    def for_all?
      [2, 8, 10].include?(@scope)
    end

    def need_selection?
      [1, 7, 9].include?(@scope)
    end

    def battle_ok?
      [0, 1].include?(@occasion)
    end

    def menu_ok?
      [0, 2].include?(@occasion)
    end

    def certain?
      @hit_type == 0
    end

    def physical?
      @hit_type == 1
    end

    def magical?
      @hit_type == 2
    end

    attr_accessor :scope
    attr_accessor :occasion
    attr_accessor :speed
    attr_accessor :animation_id
    attr_accessor :success_rate
    attr_accessor :repeats
    attr_accessor :tp_gain
    attr_accessor :hit_type
    attr_accessor :damage
    attr_accessor :effects
  end
end


module RPG
  class Item < UsableItem
    def initialize
      super
      @scope = 7
      @itype_id = 1
      @price = 0
      @consumable = true
    end

    def key_item?
      @itype_id == 2
    end

    attr_accessor :itype_id
    attr_accessor :price
    attr_accessor :consumable
  end
end
module RPG
  class Map
    class Encounter
      def initialize
        @troop_id = 1
        @weight = 10
        @region_set = []
      end

      # @return [Integer]
      attr_accessor :troop_id
      # @return [Integer]
      attr_accessor :weight
      # @return [Array<Integer>]
      attr_accessor :region_set
    end
  end
end

module RPG
  class Map
    def initialize(width, height)
      @display_name = ''
      @tileset_id = 1
      @width = width
      @height = height
      @scroll_type = 0
      @specify_battleback = false
      @battleback1_name = ''
      @battleback2_name = ''
      @autoplay_bgm = false
      @bgm = RPG::BGM.new
      @autoplay_bgs = false
      @bgs = RPG::BGS.new('', 80)
      @disable_dashing = false
      @encounter_list = []
      @encounter_step = 30
      @parallax_name = ''
      @parallax_loop_x = false
      @parallax_loop_y = false
      @parallax_sx = 0
      @parallax_sy = 0
      @parallax_show = false
      @note = ''
      @data = Table.new(width, height, 4)
      @events = {}
    end

    attr_accessor :display_name
    attr_accessor :tileset_id
    attr_accessor :width
    attr_accessor :height
    attr_accessor :scroll_type
    attr_accessor :specify_battleback
    attr_accessor :battleback1_name
    attr_accessor :battleback2_name
    attr_accessor :autoplay_bgm
    attr_accessor :bgm
    attr_accessor :autoplay_bgs
    attr_accessor :bgs
    attr_accessor :disable_dashing
    attr_accessor :encounter_list
    attr_accessor :encounter_step
    attr_accessor :parallax_name
    attr_accessor :parallax_loop_x
    attr_accessor :parallax_loop_y
    attr_accessor :parallax_sx
    attr_accessor :parallax_sy
    attr_accessor :parallax_show
    attr_accessor :note
    attr_accessor :data
    attr_accessor :events
  end
end
module RPG
  class MapInfo
    def initialize
      @name = ''
      @parent_id = 0
      @order = 0
      @expanded = false
      @scroll_x = 0
      @scroll_y = 0
    end
    attr_accessor :name
    attr_accessor :parent_id
    attr_accessor :order
    attr_accessor :expanded
    attr_accessor :scroll_x
    attr_accessor :scroll_y
  end
end

module RPG
  class ME < AudioFile
    def play
      if @name.empty?
        Audio.me_stop
      else
        Audio.me_play('Audio/ME/' + @name, @volume, @pitch)
      end
    end

    def self.stop
      Audio.me_stop
    end

    def self.fade(time)
      Audio.me_fade(time)
    end
  end
end

module RPG
  class Skill < UsableItem
    def initialize
      super
      @scope = 1
      @stype_id = 1
      @mp_cost = 0
      @tp_cost = 0
      @message1 = ''
      @message2 = ''
      @required_wtype_id1 = 0
      @required_wtype_id2 = 0
    end

    attr_accessor :stype_id
    attr_accessor :mp_cost
    attr_accessor :tp_cost
    attr_accessor :message1
    attr_accessor :message2
    attr_accessor :required_wtype_id1
    attr_accessor :required_wtype_id2
  end
end

module RPG
  class State < BaseItem
    def initialize
      super
      @restriction = 0
      @priority = 50
      @remove_at_battle_end = false
      @remove_by_restriction = false
      @auto_removal_timing = 0
      @min_turns = 1
      @max_turns = 1
      @remove_by_damage = false
      @chance_by_damage = 100
      @remove_by_walking = false
      @steps_to_remove = 100
      @message1 = ''
      @message2 = ''
      @message3 = ''
      @message4 = ''
    end

    attr_accessor :restriction
    attr_accessor :priority
    attr_accessor :remove_at_battle_end
    attr_accessor :remove_by_restriction
    attr_accessor :auto_removal_timing
    attr_accessor :min_turns
    attr_accessor :max_turns
    attr_accessor :remove_by_damage
    attr_accessor :chance_by_damage
    attr_accessor :remove_by_walking
    attr_accessor :steps_to_remove
    attr_accessor :message1
    attr_accessor :message2
    attr_accessor :message3
    attr_accessor :message4
  end
end
module RPG
  class System
    class Terms
      def initialize
        @basic = Array.new(8) {''}
        @params = Array.new(8) {''}
        @etypes = Array.new(5) {''}
        @commands = Array.new(23) {''}
      end

      # @return [Array<String>]
      attr_accessor :basic
      # @return [Array<String>]
      attr_accessor :params
      # @return [Array<String>]
      attr_accessor :etypes
      # @return [Array<String>]
      attr_accessor :commands
    end
  end
end
module RPG
  class System
    class TestBattler
      def initialize
        @actor_id = 1
        @level = 1
        @equips = [0,0,0,0,0]
      end

      # @return [Integer]
      attr_accessor :actor_id
      # @return [Integer]
      attr_accessor :level
      # @return [Array<Integer>]
      attr_accessor :equips
    end
  end
end
module RPG
  class System
    class Vehicle
      def initialize
        @character_name = ''
        @character_index = 0
        @bgm = RPG::BGM.new
        @start_map_id = 0
        @start_x = 0
        @start_y = 0
      end

      # @return [String]
      attr_accessor :character_name
      # @return [Integer]
      attr_accessor :character_index
      # @return [RPG::BGM]
      attr_accessor :bgm
      # @return [Integer]
      attr_accessor :start_map_id
      # @return [Integer]
      attr_accessor :start_x
      # @return [Integer]
      attr_accessor :start_y
    end
  end
end

module RPG
  class System
    def initialize
      @game_title = ''
      @version_id = 0
      @japanese = true
      @party_members = [1]
      @currency_unit = ''
      @elements = [nil, '']
      @skill_types = [nil, '']
      @weapon_types = [nil, '']
      @armor_types = [nil, '']
      @switches = [nil, '']
      @variables = [nil, '']
      @boat = RPG::System::Vehicle.new
      @ship = RPG::System::Vehicle.new
      @airship = RPG::System::Vehicle.new
      @title1_name = ''
      @title2_name = ''
      @opt_draw_title = true
      @opt_use_midi = false
      @opt_transparent = false
      @opt_followers = true
      @opt_slip_death = false
      @opt_floor_death = false
      @opt_display_tp = true
      @opt_extra_exp = false
      @window_tone = Tone.new(0,0,0)
      @title_bgm = RPG::BGM.new
      @battle_bgm = RPG::BGM.new
      @battle_end_me = RPG::ME.new
      @gameover_me = RPG::ME.new
      @sounds = Array.new(24) { RPG::SE.new }
      @test_battlers = []
      @test_troop_id = 1
      @start_map_id = 1
      @start_x = 0
      @start_y = 0
      @terms = RPG::System::Terms.new
      @battleback1_name = ''
      @battleback2_name = ''
      @battler_name = ''
      @battler_hue = 0
      @edit_map_id = 1
    end
    attr_accessor :game_title
    attr_accessor :version_id
    attr_accessor :japanese
    attr_accessor :party_members
    attr_accessor :currency_unit
    attr_accessor :skill_types
    attr_accessor :weapon_types
    attr_accessor :armor_types
    attr_accessor :elements
    attr_accessor :switches
    attr_accessor :variables
    attr_accessor :boat
    attr_accessor :ship
    attr_accessor :airship
    attr_accessor :title1_name
    attr_accessor :title2_name
    attr_accessor :opt_draw_title
    attr_accessor :opt_use_midi
    attr_accessor :opt_transparent
    attr_accessor :opt_followers
    attr_accessor :opt_slip_death
    attr_accessor :opt_floor_death
    attr_accessor :opt_display_tp
    attr_accessor :opt_extra_exp
    attr_accessor :window_tone
    attr_accessor :title_bgm
    attr_accessor :battle_bgm
    attr_accessor :battle_end_me
    attr_accessor :gameover_me
    attr_accessor :sounds
    attr_accessor :test_battlers
    attr_accessor :test_troop_id
    attr_accessor :start_map_id
    attr_accessor :start_x
    attr_accessor :start_y
    attr_accessor :terms
    attr_accessor :battleback1_name
    attr_accessor :battleback2_name
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :edit_map_id
  end
end
module RPG
  class Tileset
    def initialize
      @id = 0
      @mode = 1
      @name = ''
      @tileset_names = Array.new(9) { '' }
      @flags = Table.new(8192)
      @flags[0] = 0x0010
      (2048..2815).each { |i| @flags[i] = 0x000F }
      (4352..8191).each { |i| @flags[i] = 0x000F }
      @note = ''
    end

    attr_accessor :id
    attr_accessor :mode
    attr_accessor :name
    attr_accessor :tileset_names
    attr_accessor :flags
    attr_accessor :note
  end
end
module RPG
  class Troop
    class Member
      def initialize
        @enemy_id = 1
        @x = 0
        @y = 0
        @hidden = false
      end

      # @return [Integer]
      attr_accessor :enemy_id
      # @return [Integer]
      attr_accessor :x
      # @return [Integer]
      attr_accessor :y
      # @return [Boolean]
      attr_accessor :hidden
    end
  end
end
module RPG
  class Troop
    class Page
      class Condition
        def initialize
          @turn_ending = false
          @turn_valid = false
          @enemy_valid = false
          @actor_valid = false
          @switch_valid = false
          @turn_a = 0
          @turn_b = 0
          @enemy_index = 0
          @enemy_hp = 50
          @actor_id = 1
          @actor_hp = 50
          @switch_id = 1
        end

        # @return [Boolean]
        attr_accessor :turn_ending
        # @return [Boolean]
        attr_accessor :turn_valid
        # @return [Boolean]
        attr_accessor :enemy_valid
        # @return [Boolean]
        attr_accessor :actor_valid
        # @return [Boolean]
        attr_accessor :switch_valid
        # @return [Integer]
        attr_accessor :turn_a
        # @return [Integer]
        attr_accessor :turn_b
        # @return [Integer]
        attr_accessor :enemy_index
        # @return [Integer]
        attr_accessor :enemy_hp
        # @return [Integer]
        attr_accessor :actor_id
        # @return [Integer]
        attr_accessor :actor_hp
        # @return [Integer]
        attr_accessor :switch_id
      end
    end
  end
end

module RPG
  class Troop
    class Page
      def initialize
        @condition = RPG::Troop::Page::Condition.new
        @span = 0
        @list = [RPG::EventCommand.new]
      end

      # @return [RPG::Troop::Page::Condition]
      attr_accessor :condition
      # @return [Integer]
      attr_accessor :span
      # @return [Array<RPG::EventCommand>]
      attr_accessor :list
    end
  end
end

module RPG
  class Troop
    def initialize
      @id = 0
      @name = ''
      @members = []
      @pages = [RPG::Troop::Page.new]
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :members
    attr_accessor :pages
  end
end

module RPG
  class Weapon < EquipItem
    def initialize
      super
      @wtype_id = 0
      @animation_id = 0
      @features.push(RPG::BaseItem::Feature.new(31, 1, 0))
      @features.push(RPG::BaseItem::Feature.new(22, 0, 0))
    end

    def performance
      params[2] + params[4] + params.inject(0) {|r, v| r += v }
    end

    attr_accessor :wtype_id
    attr_accessor :animation_id
  end
end
