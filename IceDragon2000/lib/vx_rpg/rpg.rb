#
module RPG
  class AudioFile
    def initialize(name = "", volume = 100, pitch = 100)
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
  class BGM < AudioFile
    @@last = BGM.new
    def play
      if @name.empty?
        Audio.bgm_stop
        @@last = BGM.new
      else
        Audio.bgm_play("Audio/BGM/" + @name, @volume, @pitch)
        @@last = self
      end
    end
    def self.stop
      Audio.bgm_stop
      @@last = BGM.new
    end
    def self.fade(time)
      Audio.bgm_fade(time)
      @@last = BGM.new
    end
    def self.last
      @@last
    end
  end
end
module RPG
  class BGS < AudioFile
    @@last = BGS.new
    def play
      if @name.empty?
        Audio.bgs_stop
        @@last = BGS.new
      else
        Audio.bgs_play("Audio/BGS/" + @name, @volume, @pitch)
        @@last = self
      end
    end
    def self.stop
      Audio.bgs_stop
      @@last = BGS.new
    end
    def self.fade(time)
      Audio.bgs_fade(time)
      @@last = BGS.new
    end
    def self.last
      @@last
    end
  end
end
module RPG
  class ME < AudioFile
    def play
      if @name.empty?
        Audio.me_stop
      else
        Audio.me_play("Audio/ME/" + @name, @volume, @pitch)
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
  class SE < AudioFile
    def play
      unless @name.empty?
        Audio.se_play("Audio/SE/" + @name, @volume, @pitch)
      end
    end
    def self.stop
      Audio.se_stop
    end
  end
end
module RPG
  class Animation
    def initialize
      @id = 0
      @name = ""
      @animation1_name = ""
      @animation1_hue = 0
      @animation2_name = ""
      @animation2_hue = 0
      @position = 1
      @frame_max = 1
      @frames = [RPG::Animation::Frame.new]
      @timings = []
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
  class Animation
    class Timing
      def initialize
        @frame = 0
        @se = RPG::AudioFile.new("", 80)
        @flash_scope = 0
        @flash_color = Color.new(255,255,255,255)
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
  class Area
    def initialize
      @id = 0
      @name = ""
      @map_id = 0
      @rect = Rect.new(0,0,0,0)
      @encounter_list = []
      @order = 0
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :map_id
    attr_accessor :rect
    attr_accessor :encounter_list
    attr_accessor :order
  end
end
module RPG
  class BaseItem
    def initialize
      @id = 0
      @name = ""
      @icon_index = 0
      @description = ""
      @note = ""
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_index
    attr_accessor :description
    attr_accessor :note
  end
end
module RPG
  class Armor < BaseItem
    def initialize
      super
      @kind = 0
      @price = 0
      @eva = 0
      @atk = 0
      @def = 0
      @spi = 0
      @agi = 0
      @prevent_critical = false
      @half_mp_cost = false
      @double_exp_gain = false
      @auto_hp_recover = false
      @element_set = []
      @state_set = []
    end
    attr_accessor :kind
    attr_accessor :price
    attr_accessor :eva
    attr_accessor :atk
    attr_accessor :def
    attr_accessor :spi
    attr_accessor :agi
    attr_accessor :prevent_critical
    attr_accessor :half_mp_cost
    attr_accessor :double_exp_gain
    attr_accessor :auto_hp_recover
    attr_accessor :element_set
    attr_accessor :state_set
  end
end
module RPG
  class Weapon < BaseItem
    def initialize
      super
      @animation_id = 0
      @price = 0
      @hit = 95
      @atk = 0
      @def = 0
      @spi = 0
      @agi = 0
      @two_handed = false
      @fast_attack = false
      @dual_attack = false
      @critical_bonus = false
      @element_set = []
      @state_set = []
    end
    attr_accessor :animation_id
    attr_accessor :price
    attr_accessor :hit
    attr_accessor :atk
    attr_accessor :def
    attr_accessor :spi
    attr_accessor :agi
    attr_accessor :two_handed
    attr_accessor :fast_attack
    attr_accessor :dual_attack
    attr_accessor :critical_bonus
    attr_accessor :element_set
    attr_accessor :state_set
  end
end
module RPG
  class UsableItem < BaseItem
    def initialize
      super
      @scope = 0
      @occasion = 0
      @speed = 0
      @animation_id = 0
      @common_event_id = 0
      @base_damage = 0
      @variance = 20
      @atk_f = 0
      @spi_f = 0
      @physical_attack = false
      @damage_to_mp = false
      @absorb_damage = false
      @ignore_defense = false
      @element_set = []
      @plus_state_set = []
      @minus_state_set = []
    end
    def for_opponent?
      return [1, 2, 3, 4, 5, 6].include?(@scope)
    end
    def for_friend?
      return [7, 8, 9, 10, 11].include?(@scope)
    end
    def for_dead_friend?
      return [9, 10].include?(@scope)
    end
    def for_user?
      return [11].include?(@scope)
    end
    def for_one?
      return [1, 3, 4, 7, 9, 11].include?(@scope)
    end
    def for_two?
      return [5].include?(@scope)
    end
    def for_three?
      return [6].include?(@scope)
    end
    def for_random?
      return [4, 5, 6].include?(@scope)
    end
    def for_all?
      return [2, 8, 10].include?(@scope)
    end
    def dual?
      return [3].include?(@scope)
    end
    def need_selection?
      return [1, 3, 7, 9].include?(@scope)
    end
    def battle_ok?
      return [0, 1].include?(@occasion)
    end
    def menu_ok?
      return [0, 2].include?(@occasion)
    end
    attr_accessor :scope
    attr_accessor :occasion
    attr_accessor :speed
    attr_accessor :animation_id
    attr_accessor :common_event_id
    attr_accessor :base_damage
    attr_accessor :variance
    attr_accessor :atk_f
    attr_accessor :spi_f
    attr_accessor :physical_attack
    attr_accessor :damage_to_mp
    attr_accessor :absorb_damage
    attr_accessor :ignore_defense
    attr_accessor :element_set
    attr_accessor :plus_state_set
    attr_accessor :minus_state_set
  end
end
module RPG
  class Item < UsableItem
    def initialize
      super
      @scope = 7
      @price = 0
      @consumable = true
      @hp_recovery_rate = 0
      @hp_recovery = 0
      @mp_recovery_rate = 0
      @mp_recovery = 0
      @parameter_type = 0
      @parameter_points = 0
    end
    attr_accessor :price
    attr_accessor :consumable
    attr_accessor :hp_recovery_rate
    attr_accessor :hp_recovery
    attr_accessor :mp_recovery_rate
    attr_accessor :mp_recovery
    attr_accessor :parameter_type
    attr_accessor :parameter_points
  end
end
module RPG
  class Skill < UsableItem
    def initialize
      super
      @scope = 1
      @mp_cost = 0
      @hit = 100
      @message1 = ""
      @message2 = ""
    end
    attr_accessor :mp_cost
    attr_accessor :hit
    attr_accessor :message1
    attr_accessor :message2
  end
end
module RPG
  class Actor
    def initialize
      @id = 0
      @name = ""
      @class_id = 1
      @initial_level = 1
      @exp_basis = 25
      @exp_inflation = 35
      @character_name = ""
      @character_index = 0
      @face_name = ""
      @face_index = 0
      @parameters = Table.new(6,100)
      for i in 1..99
        @parameters[0,i] = 400+i*50
        @parameters[1,i] = 80+i*10
        @parameters[2,i] = 15+i*5/4
        @parameters[3,i] = 15+i*5/4
        @parameters[4,i] = 20+i*5/2
        @parameters[5,i] = 20+i*5/2
      end
      @weapon_id = 0
      @armor1_id = 0
      @armor2_id = 0
      @armor3_id = 0
      @armor4_id = 0
      @two_swords_style = false
      @fix_equipment = false
      @auto_battle = false
      @super_guard = false
      @pharmacology = false
      @critical_bonus = false
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :class_id
    attr_accessor :initial_level
    attr_accessor :exp_basis
    attr_accessor :exp_inflation
    attr_accessor :character_name
    attr_accessor :character_index
    attr_accessor :face_name
    attr_accessor :face_index
    attr_accessor :parameters
    attr_accessor :weapon_id
    attr_accessor :armor1_id
    attr_accessor :armor2_id
    attr_accessor :armor3_id
    attr_accessor :armor4_id
    attr_accessor :two_swords_style
    attr_accessor :fix_equipment
    attr_accessor :auto_battle
    attr_accessor :super_guard
    attr_accessor :pharmacology
    attr_accessor :critical_bonus
  end
end
module RPG
  class Enemy
    def initialize
      @id = 0
      @name = ""
      @battler_name = ""
      @battler_hue = 0
      @maxhp = 10
      @maxmp = 10
      @atk = 10
      @def = 10
      @spi = 10
      @agi = 10
      @hit = 95
      @eva = 5
      @exp = 0
      @gold = 0
      @drop_item1 = RPG::Enemy::DropItem.new
      @drop_item2 = RPG::Enemy::DropItem.new
      @levitate = false
      @has_critical = false
      @element_ranks = Table.new(1)
      @state_ranks = Table.new(1)
      @actions = [RPG::Enemy::Action.new]
      @note = ""
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :maxhp
    attr_accessor :maxmp
    attr_accessor :atk
    attr_accessor :def
    attr_accessor :spi
    attr_accessor :agi
    attr_accessor :hit
    attr_accessor :eva
    attr_accessor :exp
    attr_accessor :gold
    attr_accessor :drop_item1
    attr_accessor :drop_item2
    attr_accessor :levitate
    attr_accessor :has_critical
    attr_accessor :element_ranks
    attr_accessor :state_ranks
    attr_accessor :actions
    attr_accessor :note
  end
end
module RPG
  class Enemy
    class Action
      def initialize
        @kind = 0
        @basic = 0
        @skill_id = 1
        @condition_type = 0
        @condition_param1 = 0
        @condition_param2 = 0
        @rating = 5
      end
      def skill?
        return @kind == 1
      end
      attr_accessor :kind
      attr_accessor :basic
      attr_accessor :skill_id
      attr_accessor :condition_type
      attr_accessor :condition_param1
      attr_accessor :condition_param2
      attr_accessor :rating
    end
  end
end
module RPG
  class Enemy
    class DropItem
      def initialize
        @kind = 0
        @item_id = 1
        @weapon_id = 1
        @armor_id = 1
        @denominator = 1
      end
      attr_accessor :kind
      attr_accessor :item_id
      attr_accessor :weapon_id
      attr_accessor :armor_id
      attr_accessor :denominator
    end
  end
end
module RPG
  class Class
    def initialize
      @id = 0
      @name = ""
      @position = 0
      @weapon_set = []
      @armor_set = []
      @element_ranks = Table.new(1)
      @state_ranks = Table.new(1)
      @learnings = []
      @skill_name_valid = false
      @skill_name = ""
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :position
    attr_accessor :weapon_set
    attr_accessor :armor_set
    attr_accessor :element_ranks
    attr_accessor :state_ranks
    attr_accessor :learnings
    attr_accessor :skill_name_valid
    attr_accessor :skill_name
  end
end
module RPG
  class Class
    class Learning
      def initialize
        @level = 1
        @skill_id = 1
      end
      attr_accessor :level
      attr_accessor :skill_id
    end
  end
end
module RPG
  class State
    def initialize
      @id = 0
      @name = ""
      @icon_index = 0
      @restriction = 0
      @priority = 5
      @atk_rate = 100
      @def_rate = 100
      @spi_rate = 100
      @agi_rate = 100
      @nonresistance = false
      @offset_by_opposite = false
      @slip_damage = false
      @reduce_hit_ratio = false
      @battle_only = true
      @release_by_damage = false
      @hold_turn = 0
      @auto_release_prob = 0
      @message1 = ""
      @message2 = ""
      @message3 = ""
      @message4 = ""
      @element_set = []
      @state_set = []
      @note = ""
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_index
    attr_accessor :restriction
    attr_accessor :priority
    attr_accessor :atk_rate
    attr_accessor :def_rate
    attr_accessor :spi_rate
    attr_accessor :agi_rate
    attr_accessor :nonresistance
    attr_accessor :offset_by_opposite
    attr_accessor :slip_damage
    attr_accessor :reduce_hit_ratio
    attr_accessor :battle_only
    attr_accessor :release_by_damage
    attr_accessor :hold_turn
    attr_accessor :auto_release_prob
    attr_accessor :message1
    attr_accessor :message2
    attr_accessor :message3
    attr_accessor :message4
    attr_accessor :element_set
    attr_accessor :state_set
    attr_accessor :note
  end
end
module RPG
  class EventCommand
    def initialize(code = 0, indent = 0, parameters = [])
      @code = code
      @indent = indent
      @parameters = parameters
    end
    attr_accessor :code
    attr_accessor :indent
    attr_accessor :parameters
  end
end
module RPG
  class CommonEvent
    def initialize
      @id = 0
      @name = ""
      @trigger = 0
      @switch_id = 1
      @list = [RPG::EventCommand.new]
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :trigger
    attr_accessor :switch_id
    attr_accessor :list
  end
end
module RPG
  class Event
    def initialize(x, y)
      @id = 0
      @name = ""
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
      attr_accessor :condition
      attr_accessor :graphic
      attr_accessor :move_type
      attr_accessor :move_speed
      attr_accessor :move_frequency
      attr_accessor :move_route
      attr_accessor :walk_anime
      attr_accessor :step_anime
      attr_accessor :direction_fix
      attr_accessor :through
      attr_accessor :priority_type
      attr_accessor :trigger
      attr_accessor :list
    end
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
          @self_switch_ch = "A"
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
          @character_name = ""
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
  class Map
    def initialize(width, height)
      @width = width
      @height = height
      @scroll_type = 0
      @autoplay_bgm = false
      @bgm = RPG::AudioFile.new
      @autoplay_bgs = false
      @bgs = RPG::AudioFile.new("", 80)
      @disable_dashing = false
      @encounter_list = []
      @encounter_step = 30
      @parallax_name = ""
      @parallax_loop_x = false
      @parallax_loop_y = false
      @parallax_sx = 0
      @parallax_sy = 0
      @parallax_show = false
      # // NOTE - RGSS3 tilemap needs 4 layers, you'll get weird Shadow errors otherwise
      @data = Table.new(width, height, 4)
      @events = {}
    end
    attr_accessor :width
    attr_accessor :height
    attr_accessor :scroll_type
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
    attr_accessor :data
    attr_accessor :events
  end
end
module RPG
  class MapInfo
    def initialize
      @name = ""
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
  class Troop
    def initialize
      @id = 0
      @name = ""
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
  class Troop
    class Member
      def initialize
        @enemy_id = 1
        @x = 0
        @y = 0
        @hidden = false
        @immortal = false
      end
      attr_accessor :enemy_id
      attr_accessor :x
      attr_accessor :y
      attr_accessor :hidden
      attr_accessor :immortal
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
      attr_accessor :condition
      attr_accessor :span
      attr_accessor :list
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
        attr_accessor :turn_ending
        attr_accessor :turn_valid
        attr_accessor :enemy_valid
        attr_accessor :actor_valid
        attr_accessor :switch_valid
        attr_accessor :turn_a
        attr_accessor :turn_b
        attr_accessor :enemy_index
        attr_accessor :enemy_hp
        attr_accessor :actor_id
        attr_accessor :actor_hp
        attr_accessor :switch_id
      end
    end
  end
end
module RPG
  class System
    def initialize
      @game_title = ""
      @version_id = 0
      @party_members = [1]
      @elements = [nil, ""]
      @switches = [nil, ""]
      @variables = [nil, ""]
      @passages = Table.new(8192)
      @boat = RPG::System::Vehicle.new
      @ship = RPG::System::Vehicle.new
      @airship = RPG::System::Vehicle.new
      @title_bgm = RPG::BGM.new
      @battle_bgm = RPG::BGM.new
      @battle_end_me = RPG::ME.new
      @gameover_me = RPG::ME.new
      @sounds = []
      20.times { @sounds.push(RPG::AudioFile.new) }
      @test_battlers = []
      @test_troop_id = 1
      @start_map_id = 1
      @start_x = 0
      @start_y = 0
      @terms = RPG::System::Terms.new
      @battler_name = ""
      @battler_hue = 0
      @edit_map_id = 1
    end
    attr_accessor :game_title
    attr_accessor :version_id
    attr_accessor :party_members
    attr_accessor :elements
    attr_accessor :switches
    attr_accessor :variables
    attr_accessor :passages
    attr_accessor :boat
    attr_accessor :ship
    attr_accessor :airship
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
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :edit_map_id
  end
end
module RPG
  class System
    class Terms
      def initialize
        @level = ""
        @level_a = ""
        @hp = ""
        @hp_a = ""
        @mp = ""
        @mp_a = ""
        @atk = ""
        @def = ""
        @spi = ""
        @agi = ""
        @weapon = ""
        @armor1 = ""
        @armor2 = ""
        @armor3 = ""
        @armor4 = ""
        @weapon1 = ""
        @weapon2 = ""
        @attack = ""
        @skill = ""
        @guard = ""
        @item = ""
        @equip = ""
        @status = ""
        @save = ""
        @game_end = ""
        @fight = ""
        @escape = ""
        @new_game = ""
        @continue = ""
        @shutdown = ""
        @to_title = ""
        @cancel = ""
        @gold = ""
      end
      attr_accessor :level
      attr_accessor :level_a
      attr_accessor :hp
      attr_accessor :hp_a
      attr_accessor :mp
      attr_accessor :mp_a
      attr_accessor :atk
      attr_accessor :def
      attr_accessor :spi
      attr_accessor :agi
      attr_accessor :weapon
      attr_accessor :armor1
      attr_accessor :armor2
      attr_accessor :armor3
      attr_accessor :armor4
      attr_accessor :weapon1
      attr_accessor :weapon2
      attr_accessor :attack
      attr_accessor :skill
      attr_accessor :guard
      attr_accessor :item
      attr_accessor :equip
      attr_accessor :status
      attr_accessor :save
      attr_accessor :game_end
      attr_accessor :fight
      attr_accessor :escape
      attr_accessor :new_game
      attr_accessor :continue
      attr_accessor :shutdown
      attr_accessor :to_title
      attr_accessor :cancel
      attr_accessor :gold
    end
  end
end
module RPG
  class System
    class TestBattler
      def initialize
        @actor_id = 1
        @level = 1
        @weapon_id = 0
        @armor1_id = 0
        @armor2_id = 0
        @armor3_id = 0
        @armor4_id = 0
      end
      attr_accessor :actor_id
      attr_accessor :level
      attr_accessor :weapon_id
      attr_accessor :armor1_id
      attr_accessor :armor2_id
      attr_accessor :armor3_id
      attr_accessor :armor4_id
    end
  end
end
module RPG
  class System
    class Vehicle
      def initialize
        @character_name = ""
        @character_index = 0
        @bgm = RPG::AudioFile.new
        @start_map_id = 0
        @start_x = 0
        @start_y = 0
      end
      attr_accessor :character_name
      attr_accessor :character_index
      attr_accessor :bgm
      attr_accessor :start_map_id
      attr_accessor :start_x
      attr_accessor :start_y
    end
  end
end
