=begin
Animated Battlers Script
by Fomar0153
Version 1.2
----------------------
Notes
----------------------
Includes Side View Battlers
Compatable with my Customisable ATB/Stamina Based Battle System Script
Make sure this goes above my Customisable ATB/Stamina Based Battle System Script
----------------------
Instructions
----------------------
Edit variables in Animated_Battlers to suit your needs.
You will need to import battlers for the party to use
they should be named like this:
name_battler
e.g.
Ralph_battler
or you can name them through note tagging
----------------------
Change Log
----------------------
1.0 -> 1.1 Added Notetag support for default battlers
           <battler name> and you can edit it through the
           game e.g. $game_actors[1].battler_name = "Fomar0153"
           Added support for individual battler setup
           Added support for different length animations
           Added support for individual skill and item animations
           Added notetag support to further define when skills are
           close and long range. <close> <range>
1.1 -> 1.2 Fixed a bug were pose overrode setpose animation lengths
           Fixed screen_x related bug that sometimes caused positioning errors.
----------------------
Known bugs
----------------------
None
=end

module Animated_Battlers
  
  # Setup Generics
  # RPG VXA Caps at 60 FPS at best
  FRAMES_PER_SECOND = 4
  # How long it takes for someone to move into position
  MOVEMENT_SECONDS = 1
  # HP level before whoozy pose (percentage)
  LOW_HEALTH_POSE = 50
  
  # Set up Actor Positions
  X_START = 400
  X_OFFSET = 0
  Y_START = 0
  Y_OFFSET = 60
  
  
  BATTLERS = {}
  BATTLERS['DEFAULT'] = {}
  # How many frames there are in an animation
  # Note FRAMES must be set to the maximum
  BATTLERS['DEFAULT']['FRAMES'] = 4
  BATTLERS['DEFAULT']['VFRAMES'] = 14
  # Setup default battlers' standard rows
  BATTLERS['DEFAULT']['POSE_IDLE']     = 0
  BATTLERS['DEFAULT'][0]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_DEFEND']   = 1
  BATTLERS['DEFAULT'][1]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_WHOOZY']   = 2
  BATTLERS['DEFAULT'][2]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_STRUCK']   = 3
  BATTLERS['DEFAULT'][3]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_ATTACK']   = 4
  BATTLERS['DEFAULT'][4]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_ITEM']     = []
  BATTLERS['DEFAULT']['POSE_ITEM'][0]  = 5
  BATTLERS['DEFAULT'][5]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_SKILL']    = []
  BATTLERS['DEFAULT']['POSE_SKILL'][0] = 6
  BATTLERS['DEFAULT'][6]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_MAGIC']    = 7
  BATTLERS['DEFAULT'][7]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_ADVANCE']  = 8
  BATTLERS['DEFAULT'][8]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_RETREAT']  = 9
  BATTLERS['DEFAULT'][9]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_VICTORY']  = 10
  BATTLERS['DEFAULT'][10]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_ENTER']    = 11
  BATTLERS['DEFAULT'][11]               = BATTLERS['DEFAULT']['FRAMES']
  BATTLERS['DEFAULT']['POSE_DEAD']     = 12
  BATTLERS['DEFAULT'][12]               = BATTLERS['DEFAULT']['FRAMES']
  # When doing the victory pose loop back to frame
  # 0 for the first frame
  # (FRAMES - 1) to not loop
  BATTLERS['DEFAULT']['VICTORY_LOOP']  = 1
  
  # I reccomend adding your non-conformist battlers here
  # copy the big block above starting from:
  # BATTLERS['DEFAULT'] = {}
  # all the way to BATTLERS['DEFAULT']['VICTORY_LOOP']  = 1
  # and then change DEFAULT to the name of the battler.
  
  
  
  def self.get_pose(battler_name, pose, id = nil)
    if BATTLERS[battler_name] == nil
      b = BATTLERS['DEFAULT']
    else
      b = BATTLERS[battler_name]
    end
    if pose == "POSE_ITEM" or pose == "POSE_SKILL"
      if id.nil? or b[pose][id].nil?
        return b[pose][0]
      else
        return b[pose][id]
      end
    elsif !b[pose].nil?
      return b[pose]
    else
      return b['POSE_IDLE']
    end
  end
  
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● New attr_accessor
  #--------------------------------------------------------------------------
  attr_accessor :battler_name
  #--------------------------------------------------------------------------
  # ● Aliases setup
  #--------------------------------------------------------------------------
  alias ab_setup setup
  def setup(actor_id)
    ab_setup(actor_id)
    if actor.note =~ /<battler (.*)>/i
      @battler_name = $1
    else
      @battler_name = actor.name + "_battler"
    end
  end
  #--------------------------------------------------------------------------
  # ● Rewrites use_sprite?
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  #--------------------------------------------------------------------------
  # ● New Method screen_x
  #--------------------------------------------------------------------------
  def screen_x
    return Animated_Battlers::X_START + self.index * Animated_Battlers::X_OFFSET
  end
  #--------------------------------------------------------------------------
  # ● New Method screen_y
  #--------------------------------------------------------------------------
  def screen_y
    return Animated_Battlers::Y_START + self.index * Animated_Battlers::Y_OFFSET
  end
  #--------------------------------------------------------------------------
  # ● New Method screen_z
  #--------------------------------------------------------------------------
  def screen_z
    return 100
  end
end

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● Rewrites create_actors
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = $game_party.battle_members.reverse.collect do |actor|
      Sprite_Battler.new(@viewport1, actor)
    end
  end
end

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ● Aliases initialize
  #--------------------------------------------------------------------------
  alias ab_initialize initialize
  def initialize(viewport, battler = nil)
    ab_initialize(viewport, battler)
    @frame = 0
    @mframe = 0
    @pose = 0
    @set_pose = Animated_Battlers.get_pose(@battler.battler_name,"POSE_ENTER")
  end
  #--------------------------------------------------------------------------
  # ● Rewrote update_src_rect
  #--------------------------------------------------------------------------
  def update_src_rect
    sx = (@frame / (60 / Animated_Battlers::FRAMES_PER_SECOND)) * @cw
    if @set_pose >= 0
      sy = @set_pose * bitmap.height / (Animated_Battlers.get_pose(@battler.battler_name, "VFRAMES"))
    else
      sy = @pose * bitmap.height / (Animated_Battlers.get_pose(@battler.battler_name, "VFRAMES"))
    end
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  #--------------------------------------------------------------------------
  # ● Destroyed update_collapse
  #--------------------------------------------------------------------------
  def update_collapse
    return
  end
  #--------------------------------------------------------------------------
  # ● Aliases start_effect
  #--------------------------------------------------------------------------
  alias ab_start_effect start_effect
  def start_effect(effect_type)
    return if effect_type = :collapse
    ab_start_effect
  end
  #--------------------------------------------------------------------------
  # ● Rewrote update_position
  #--------------------------------------------------------------------------
  def update_position
    if @battler.actor?
      self.x = @battler.screen_x
      self.ox = 0
      self.y = @battler.screen_y + bitmap.height
      if @battler.moving > 0
        self.x += (@mframe * (@battler.target_x - @battler.target_width - self.x) / (60 * Animated_Battlers::MOVEMENT_SECONDS))
        self.y += @mframe * (@battler.target_y - self.y + (bitmap.height * (Animated_Battlers.get_pose(@battler.battler_name, "VFRAMES") - 1)/Animated_Battlers.get_pose(@battler.battler_name, "VFRAMES"))) / (60 * Animated_Battlers::MOVEMENT_SECONDS)
      end
    else
      self.x = @battler.screen_x
      self.y = @battler.screen_y + (bitmap.height * (Animated_Battlers.get_pose(@battler.battler_name, "VFRAMES") - 1)) / Animated_Battlers.get_pose(@battler.battler_name, "VFRAMES")
      if @battler.moving > 0
        self.x += (@mframe * (@battler.target_x - self.x + @battler.bitmap_width / Animated_Battlers.get_pose(@battler.battler_name, "FRAMES")) / (60 * Animated_Battlers::MOVEMENT_SECONDS))
        self.y += @mframe * (@battler.target_y + @battler.target_height - @battler.screen_y) / (60 * Animated_Battlers::MOVEMENT_SECONDS)
      end
    end
    self.z = @battler.screen_z
  end
  #--------------------------------------------------------------------------
  # ● New Method update_pose
  #--------------------------------------------------------------------------
  def update_pose
    if @battler.set_pose >= 0
      @set_pose = @battler.set_pose
      @frame = 0
      @battler.set_pose = -1
    end
    return if @set_pose > 0 or @battler.moving > 0
    if @battler.dead?
      @pose = Animated_Battlers.get_pose(@battler.battler_name, "POSE_DEAD")
      return
    end
    if $game_troop.all_dead?
      @pose = Animated_Battlers.get_pose(@battler.battler_name, "POSE_VICTORY")
      return
    end
    if battler.guard?
      @pose = Animated_Battlers.get_pose(@battler.battler_name, "POSE_DEFEND")
      return
    end
    if battler.hp <= (battler.mhp * Animated_Battlers::LOW_HEALTH_POSE / 100)
      @pose = Animated_Battlers.get_pose(@battler.battler_name, "POSE_WHOOZY")
      return
    end
    @pose = Animated_Battlers.get_pose(@battler.battler_name, "POSE_IDLE")
  end
  #--------------------------------------------------------------------------
  # ● Rewrote update
  #--------------------------------------------------------------------------
  def update
    super
    @frame += 1
    if @battler.moving == 1 and @mframe == 0
      @set_pose = Animated_Battlers.get_pose(@battler.battler_name, "POSE_ADVANCE")
    end
    if @battler.moving == 3 and @mframe == (60 * Animated_Battlers::MOVEMENT_SECONDS)
      @set_pose = Animated_Battlers.get_pose(@battler.battler_name, "POSE_RETREAT")
    end
    @mframe += 1 if @set_pose == Animated_Battlers.get_pose(@battler.battler_name, "POSE_ADVANCE")
    @mframe -= 1 if @set_pose == Animated_Battlers.get_pose(@battler.battler_name, "POSE_RETREAT")
    if (@mframe == 0 or @mframe == (60 * Animated_Battlers::MOVEMENT_SECONDS)) and @battler.moving?
      @set_pose = -1
      @battler.moving = (@battler.moving + 1) % 4
    end
    if @frame >= (Animated_Battlers.get_pose(@battler.battler_name, @set_pose) * (60 / Animated_Battlers::FRAMES_PER_SECOND)) and @set_pose > 0
      if @pose == Animated_Battlers.get_pose(@battler.battler_name, "POSE_VICTORY")
        @frame = (Animated_Battlers.get_pose(@battler.battler_name, "VICTORY_LOOP") * (60 / Animated_Battlers::FRAMES_PER_SECOND))
      else
        @frame = 0
      end
      @set_pose = -1 unless (@set_pose == Animated_Battlers.get_pose(@battler.battler_name, "POSE_ADVANCE") or @set_pose == Animated_Battlers.get_pose(@battler.battler_name, "POSE_RETREAT"))
    end 
    if @frame >= (Animated_Battlers.get_pose(@battler.battler_name, @pose) * (60 / Animated_Battlers::FRAMES_PER_SECOND))
      if @pose == Animated_Battlers.get_pose(@battler.battler_name, "POSE_VICTORY")
        @frame = (Animated_Battlers.get_pose(@battler.battler_name, "VICTORY_LOOP") * (60 / Animated_Battlers::FRAMES_PER_SECOND))
      else
        @frame = 0
      end
      @set_pose = -1 unless (@set_pose == Animated_Battlers.get_pose(@battler.battler_name, "POSE_ADVANCE") or @set_pose == Animated_Battlers.get_pose(@battler.battler_name, "POSE_RETREAT"))
    end
    last_pose = @pose
    update_pose
    if last_pose != @pose
      @frame = 0
    end
    if @battler
      @use_sprite = @battler.use_sprite?
      if @use_sprite
        update_bitmap
        update_origin
        update_position
        update_src_rect
      end
      setup_new_effect
      setup_new_animation
      update_effect
    else
      self.bitmap = nil
      @effect_type = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● New Method moving?
  #--------------------------------------------------------------------------
  def moving?
    return !(@mframe == 0 or @mframe == 60 * Animated_Battlers::MOVEMENT_SECONDS)
  end
  #--------------------------------------------------------------------------
  # ● Rewrote update_bitmap
  #--------------------------------------------------------------------------
  def update_bitmap
    new_bitmap = Cache.battler(@battler.battler_name, @battler.battler_hue)
    if bitmap != new_bitmap
      self.bitmap = new_bitmap
      @cw = bitmap.width / Animated_Battlers.get_pose(@battler.battler_name, "FRAMES")
      @ch = bitmap.height / Animated_Battlers.get_pose(@battler.battler_name, "VFRAMES")
      init_visibility
      @battler.bitmap_height = bitmap.height
      @battler.bitmap_width = bitmap.width
    end
  end
  #--------------------------------------------------------------------------
  # ● Rewrote effect?
  #--------------------------------------------------------------------------
  def effect?
    return (@effect_type != nil or moving?)
  end
end

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● New attr_accessors
  #--------------------------------------------------------------------------
  attr_accessor :target_x
  attr_accessor :target_y
  attr_accessor :target_width
  attr_accessor :target_height
  attr_accessor :moving
  attr_accessor :set_pose
  attr_accessor :bitmap_height
  attr_accessor :bitmap_width
  #--------------------------------------------------------------------------
  # ● Aliases initialize
  #--------------------------------------------------------------------------
  alias ab_initialize initialize
  def initialize
    ab_initialize
    @target_x = 0
    @target_y = 0
    @target_width = 0
    @target_height = 0
    @moving = 0
    @set_pose = -1
    @bitmap_height = 0
    @bitmap_width = 0
  end
  #--------------------------------------------------------------------------
  # ● New Method move_to
  #--------------------------------------------------------------------------
  def move_to(target)
    @target_x = target.screen_x
    @target_y = target.screen_y
    @target_width = target.bitmap_width / Animated_Battlers.get_pose(target.battler_name, "FRAMES")
    @target_height = target.bitmap_height / Animated_Battlers.get_pose(target.battler_name, "VFRAMES")
    @moving = 1
  end
  #--------------------------------------------------------------------------
  # ● New Method moving?
  #--------------------------------------------------------------------------
  def moving?
    return (@moving == 1 or @moving == 3)
  end
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● Rewrote use_item
  #--------------------------------------------------------------------------
  def use_item
    item = @subject.current_action.item
    @log_window.display_use_item(@subject, item)
    @subject.use_item(item)
    refresh_status
    targets = @subject.current_action.make_targets.compact
    targets.each {|target| item.repeats.times { invoke_item(target, item) } }
  end
  #--------------------------------------------------------------------------
  # ● Rewrote invoke_item
  #--------------------------------------------------------------------------
  def invoke_item(target, item)
    if rand < target.item_cnt(@subject, item)
      invoke_counter_attack(target, item)
    elsif rand < target.item_mrf(@subject, item)
      invoke_magic_reflection(target, item)
    else
      if item.is_a?(RPG::Item)
        @subject.set_pose = Animated_Battlers.get_pose(@subject.battler_name, "POSE_ITEM", item.id)
        show_animation([target], item.animation_id)
        apply_item_effects(apply_substitute(target, item), item)
      elsif item.is_a?(RPG::Skill)
        if item.id == @subject.attack_skill_id
          @subject.move_to(target)
          update_for_wait while @subject.moving?
          @subject.set_pose = Animated_Battlers.get_pose(@subject.battler_name, "POSE_ATTACK")
          target.set_pose = Animated_Battlers.get_pose(target.battler_name, "POSE_STRUCK")
          show_animation([target], item.animation_id)
          apply_item_effects(apply_substitute(target, item), item)
          @subject.moving = 3
          update_for_wait while @subject.moving?
        elsif item.id == @subject.guard_skill_id
          show_animation([target], item.animation_id)
          apply_item_effects(apply_substitute(target, item), item)
        elsif (item.magical? or item.note.include?("<range>")) and not item.note.include?("<close>")
          @subject.set_pose = Animated_Battlers.get_pose(@subject.battler_name, "POSE_MAGIC",item.id)
          target.set_pose = Animated_Battlers.get_pose(target.battler_name, "POSE_STRUCK") if item.for_opponent?
          show_animation([target], item.animation_id)
          apply_item_effects(apply_substitute(target, item), item)
        else
          if item.for_opponent?
            @subject.move_to(target)
            update_for_wait while @subject.moving?
            @subject.set_pose = Animated_Battlers.get_pose(@subject.battler_name, "POSE_SKILL", item.id)
            target.set_pose = Animated_Battlers.get_pose(target.battler_name, "POSE_STRUCK")
            show_animation([target], item.animation_id)
            apply_item_effects(apply_substitute(target, item), item)
            @subject.moving = 3
            update_for_wait while @subject.moving?
          else
            @subject.set_pose = Animated_Battlers.get_pose(@subject.battler_name, "POSE_SKILL", item.id)
            show_animation([target], item.animation_id)
            apply_item_effects(apply_substitute(target, item), item)
          end
        end
      end
    end
    @subject.last_target_index = target.index
  end
end