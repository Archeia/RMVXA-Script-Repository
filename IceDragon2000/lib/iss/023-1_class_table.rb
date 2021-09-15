#encoding:UTF-8
# ISS023 - Class Table 1.0
#==============================================================================#
# ** ISS - Class Table
#==============================================================================#
# ** Date Created  : 08/30/2011
# ** Date Modified : 09/10/2011
# ** Created By    : IceDragon
# ** For Game      : S.A.R.A
# ** ID            : 023
# ** Version       : 1.0
# ** Requires      : ISS000 - Core(2.3 or above)
#                    ISS022 - System Table(1.0 or above)
#                    IST - MoreRubyStuff(1.9 or above)
#==============================================================================#
($imported ||= {})["ISS-ClassTable"] = true
#==============================================================================#
# ** ISS::ClassTable // Setup
#==============================================================================#
module ISS
  install_script(23, :class)
  class ClassTable < ::ISS::SystemTable

    module Blocks ; end

    include Blocks

    def self.xy_from_index(index, width)
      return index % width, index / width
    end

    def self.index_from_xy(x, y, width)
      return x+(y*width)
    end

    def self.create_block_range(x, y, size)
      result = []
      for i in 0..size
        result << [x+i, y+i]
        result << [x+i, y-i]
        result << [x-i, y+i]
        result << [x-i, y-i]
      end
      return result.uniq
    end

    # // ClassBlock(class_id)
    # // StatBlock(stat, value)
    # // SkillBlock(skill_id)
    # // PassiveBlock(passive_id)

    def self.randomize_class_table(table)
      classes = []
      16.times { |i| classes << [ClassBlock, i] }
      classes.shift
      stats = [
        [StatBlock, [:maxhp, [1, rand(20)].max]],
        [StatBlock, [:maxhp, 10]],
        [StatBlock, [:maxhp, 25]],
        [StatBlock, [:maxhp, 50]],
        [StatBlock, [:maxhp, 100]],

        [StatBlock, [:maxmp, [1, rand(20)].max]],
        [StatBlock, [:maxmp, 5]],
        [StatBlock, [:maxmp, 10]],
        [StatBlock, [:maxmp, 25]],
        [StatBlock, [:maxmp, 50]]
      ]
      [:atk, :def, :spi, :agi].each { |s|
        stats += [
          [StatBlock, [s, 1]],
          [StatBlock, [s, 2]],
          [StatBlock, [s, 3]],
          [StatBlock, [s, 5]],
          [StatBlock, [s, 10]],
          [StatBlock, [s, 15]],
        ]
      }
      psvs_skls = [
        [PassiveBlock, [21]],
        [PassiveBlock, [22]],
        [PassiveBlock, [23]],
        [PassiveBlock, [24]],
        [PassiveBlock, [25]],
        [PassiveBlock, [26]],
        [PassiveBlock, [27]],
        [SkillBlock  , [46]],
        [SkillBlock  , [47]],
        [SkillBlock  , [48]],
        [SkillBlock  , [49]],
        [SkillBlock  , [50]],
        [SkillBlock  , [51]],
        [SkillBlock  , [52]],
      ]
      blockbases = (classes+stats+psvs_skls).randomize
      for i in 0...table.size
        st = blockbases.shift
        table[i].base = st[0]
        table[i].parameters = st[1]
      end
      return table
    end

    ACTOR_TABLES = {}
    ACTOR_TABLES[0] = {
      :width  => 9,
      :height => 7,
    }
    ACTOR_TABLES[0][:table] = []
    val = [0]#, 1, 2, 3, 8, 9, 10, 11]
    (ACTOR_TABLES[0][:width]*ACTOR_TABLES[0][:height]).times { |i|
      ACTOR_TABLES[0][:table][i] = [val[rand(val.size)],[nil, nil]]
    }
    def self.get_actor_table(actor)
      tb = ACTOR_TABLES[actor.id].nil?() ? ACTOR_TABLES[0] : ACTOR_TABLES[actor.id]
      tb.table = randomize_class_table(tb.table)
      return tb
    end

    ClassTableRaw  = Struct.new(:width, :height, :table)
    BlockConstruct = Struct.new(:block_id, :base, :parameters)

    ACTOR_TABLES.keys.each { |key|
      tb = ACTOR_TABLES[key]
      ACTOR_TABLES[key] = ClassTableRaw.new(tb[:width], tb[:height], tb[:table])
      for i in 0...ACTOR_TABLES[key].table.size
        tx = ACTOR_TABLES[key].table[i]
        ACTOR_TABLES[key].table[i][1] ||= []
        ACTOR_TABLES[key].table[i] = BlockConstruct.new(tx[0], tx[1][0], tx[1][1])
      end
    }

  end
end

#==============================================================================#
# ** ISS::ClassTable
#==============================================================================#
class ISS::ClassTable < ::ISS::SystemTable

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(parent)
    @parent = parent
    t = self.class.get_actor_table(parent)
    super(t.width, t.height)
    self.set_from(t.table) { |e, i|
      blk = e.base.new(*e.parameters)
      blk.x = i % t.width
      blk.y = i / t.width
      blk.z = 2
      blk.set_indexes(e.block_id, e.block_id+4)
      blk
    }
  end

  #--------------------------------------------------------------------------#
  # * super-method :can_mark?
  #--------------------------------------------------------------------------#
  def can_mark?(x, y)
    return false unless super(x, y)
    sor = []
    sor << get_cell(x+1, y ) if inRange?( x+1, y)
    sor << get_cell(x-1, y ) if inRange?( x-1, y)
    sor << get_cell(x, y+1 ) if inRange?( x, y+1)
    sor << get_cell(x, y-1 ) if inRange?( x, y-1)
    return false unless sor.any?() { |scell| scell.marked }
    return true
  end

end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor

  attr_accessor :class_table
  attr_reader :table_points

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iss023_gma_setup :setup unless $@
  def setup(*args, &block)
    iss023_gma_setup(*args, &block)
    @class_table = ::ISS::ClassTable.new(self)
    @table_points = 1
    @unlocked_classes = []
  end

  #--------------------------------------------------------------------------#
  # * new-method :table_points=
  #--------------------------------------------------------------------------#
  def table_points=(value)
    @table_points = [value, 0].max
  end

  #--------------------------------------------------------------------------#
  # * alias-method :level_up
  #--------------------------------------------------------------------------#
  alias :iss023_gma_level_up :level_up unless $@
  def level_up(*args, &block)
    iss023_gma_level_up(*args, &block)
    self.table_points += 1
  end

  #--------------------------------------------------------------------------#
  # * new-method :unlock_class
  #--------------------------------------------------------------------------#
  def unlock_class(class_id)
    @unlocked_classes << class_id unless @unlocked_classes.include?(class_id)
  end

end

#==============================================================================#
# ** Window_ClassTablePoints
#==============================================================================#
class Window_ClassTablePoints < ::Window_Base

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(actor)
    super(0, 0, 198, 56)
    @actor = actor
    refresh()
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh
  #--------------------------------------------------------------------------#
  def refresh()
    self.contents.clear()
    pnts = @actor.table_points
    self.contents.font.color = system_color
    self.contents.draw_text(0, 0, self.contents.width, WLH, "Remaining Points:")
    self.contents.font.color = normal_color
    self.contents.draw_text(0, 0, self.contents.width, WLH, pnts, 2)
    @last_points = pnts
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update
  #--------------------------------------------------------------------------#
  def update()
    refresh() if @last_points != @actor.table_points
  end

end

#==============================================================================#
# ** Scene_ClassTable
#==============================================================================#
class Scene_ClassTable < ::Scene_SystemTable

  include ::ISS::ClassTable::Blocks

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(actor, called=:map, return_index=0)
    # ---------------------------------------------------- #
    @actor = nil
    @act_index = 0
    @index_call = false
    # ---------------------------------------------------- #
    if actor.kind_of?(Game_Battler)
      @actor = actor
    elsif actor != nil
      @actor = $game_party.members[actor]
      @act_index = actor
      @index_call = true
    end
    super(called, return_index)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :set_blocks
  #--------------------------------------------------------------------------#
  def set_blocks()
    @blocks = @actor.class_table
  end

  #--------------------------------------------------------------------------#
  # * super-method :start
  #--------------------------------------------------------------------------#
  def start()
    super()
    @highlight_blocks = []
    @highlight_cursors = []
    4.times { |i|
      @highlight_cursors[i] = ISS::SystemTable::Cursor.new() ; @highlight_cursors[i].z = 2
      @highlight_cursors[i].unbound() ; @highlight_cursors[i].fade_rate = 70.0
      @highlight_blocks[i] = ISS::SystemTable::Sprite_CursorRect.new(@highlight_cursors[i], nil)
      @highlight_blocks[i].tone.set(0, 98, 255)
      @highlight_blocks[i].blend_type = 1
    }
    @blocks.elements.each { |b|
      if b.is_a?(ClassBlock) && b.class_id == @actor.class_id
        mark_cell(b.x, b.y)
        @cursor.moveto(b.x, b.y)
      end unless b.marked
    }
    update_cursor_tone()
    @points_window = Window_ClassTablePoints.new(@actor)
    @points_window.y = Graphics.height - @points_window.height
  end

  #--------------------------------------------------------------------------#
  # * super-method :terminate
  #--------------------------------------------------------------------------#
  def terminate()
    @highlight_blocks.each { |b| b.dispose() }
    @points_window.dispose() unless @points_window.nil?() ; @points_window = nil
    @highlight_blocks.clear() ; @highlight_blocks = nil
    super()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update()
    super()
    @points_window.update()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_cursor_tone
  #--------------------------------------------------------------------------#
  def update_cursor_tone()
    if can_mark?(@cursor.tx, @cursor.ty)
      @cursor_sprite.tone.set(0, 0, 0, 0)
    else
      @cursor_sprite.tone.set(-52, -92, 198, 0)
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_mark_input
  #--------------------------------------------------------------------------#
  def update_mark_input()
    if Input.trigger?(Input::Z)
      @blocks.elements.randomize.each { |b|
        if can_mark?(b.x, b.y)
          Sound.play_recovery()
          @cursor.moveto(b.x, b.y) ; break
        end
      }
    end
    if Input.trigger?(Input::C)
      if can_mark?(@cursor.tx, @cursor.ty)
        Sound.play_decision()
        mark_cell(@cursor.tx, @cursor.ty)
        @actor.table_points -= 1
      else
        @highlight_cursors.randomize.each { |c|
          if can_mark?(c.x.to_i, c.y.to_i)
            Sound.play_cursor()
            @cursor.moveto(c.x.to_i, c.y.to_i) ; return
          end
        }
        Sound.play_buzzer()
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * super-method :object_updates
  #--------------------------------------------------------------------------#
  def object_updates()
    super()
    @highlight_cursors[0].moveto(@cursor.x+1, @cursor.y)
    @highlight_cursors[1].moveto(@cursor.x-1, @cursor.y)
    @highlight_cursors[2].moveto(@cursor.x, @cursor.y+1)
    @highlight_cursors[3].moveto(@cursor.x, @cursor.y-1)
    @highlight_cursors.each { |c|
      c.update()
      c.visible = can_mark?(c.x.to_i, c.y.to_i)
      c.adjust_wh(@adjust_zoom, @adjust_zoom) }
  end

  #--------------------------------------------------------------------------#
  # * super-method :sprite_updates
  #--------------------------------------------------------------------------#
  def sprite_updates()
    super()
    update_cursor_tone()
    @highlight_blocks.each { |c| c.update() }
  end

  #--------------------------------------------------------------------------#
  # * new-method :can_mark?
  #--------------------------------------------------------------------------#
  def can_mark?(x, y)
    return false unless @actor.table_points > 0
    super(x, y)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :mark_cell
  #--------------------------------------------------------------------------#
  def mark_cell(x, y)
    cell = @blocks.get_cell(x, y)
    unless cell.marked
      cell.mark()
      cell.runEffect(@actor)
      puts cell.effect_to_s
      cell.animation_id = 20
      wait_for_animation()
      @block_sprites.draw_cell(cell)
    end
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
