#Animated Battlers v1.0
#----------#
#Features: Allows you to mostly uneasily incorporate animated battlers into
#           your game for that cooler and more polished look! You'll be able
#           to decide individual sprite animations and more complicated skill
#           animations.
#
#Usage:    Plug and play, Customize (heavily) as needed.
#        
%Q(        (Great Schlee, there's too much to explain here without taking up
          18 million lines. So here's a quick key guide while you can find
          the full depth guide here: 
          http://daimonioustails.weebly.com/animated-battlers.html )
)
#
#           Notetags (Actors, Enemies, Classes)
#            <???Anim ["filename", animation_sym]>
#
#           Notetags (Skills)
#            <ANIMATION animation_name>
#
#        Adding Animation Files:
#         Images are taken from Graphics/Battler.
#          "imagename" => [columns,rows],
#
#       Adding Animation Frames:
#         ANIMATIONS is where you create frame data.
#          :animation => [ [id,timer] , [id,timer] , ... ],
#
#       Adding Skill Animations:
#         SKILL_ANIMATIONS are the meat and potatoes.
#          :animation => [ [step1] , [step2] , ... ],
#
#        Valid steps:
#       [:moveto,:target,:align,speed]         -move self to target
#       [:jumpto,:target,:align,speed]         -jump self to target (Exp)
#       [:move,:target,x,y,speed]              -move self based on target
#       [:jump,:target,x,y,speed]              -jump self based on target (Exp)
#       [:play,:target,"filename",:step,timer] -play sprite animation for target
#       [:play,:target,:base,nil,timer]        -play sprite animation for target
#       [:anim,:target,anim_id,timer]          -play animation on target
#       [:mirror,:target,boolean]              -mirror sprite
#       [:wait,timer]                          -wait frames
#       [:flash,:target,color,duration]        -flash target or screen
#       [:tint,tone,duration]                  -tint screen
#       [:se,"name",volume,pitch]              -play se
#       [:damage,:target,amount]               -display damage (Basic Damage Popup)
#       [:field,id]                            -change background (Field Effects)
#       [:missile,:target,icon_id,:effect]     -throw something at target
#
#         :target = :self, :target, :target#, :screen(flash)
#         :align = :align, :align_o (opposite side of sprite)
#         speed = # of frames to move from point a to point b
#         :step = ANIMATIONS name
#         timer = wait in frames (nil for completion)
#         :base = Base anim (:Dead,:Idle,:Run,etc.)
#         anim_id = animation id (database)
#         color = Color.new(r,g,b,a) (alpha optional)
#         tone = Tone.new(r,g,b,g)
#         amount = 0-100 (%), or :rest for remaining
#         :effect = nil, :rotate (spins)
#        
#  
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

$imported = {} if $imported.nil?
$imported[:VlueAnimatedBattlers] = true

module Animation
  ANIMATION_FILES = { "elf-f-1" => [3,8], "elf-f-2" => [3,8],
                      "mage-f-1" => [3,8], "mage-f-2" => [3,8],
                      "man5-1" => [3,8], "man5-2" => [3,8],
                      "ninja-m-1" => [3,8], "ninja-m-2" => [3,8], }
                      
  ANIMATIONS = { :baseidle => [ [6,10] , [7,10] , [8,10] ],
                 :baseattack => [ [3,10] , [4,10] , [5,10] ],
                 :basehurt => [ [6,10] , [7,10] , [8,10] ],
                 :basedead => [ [9,1] ],
                 :baserun  => [ [18,10], [19,10], [20,10] ],
                 :basecheer=> [ [0,10], [1,10], [2,10] ],}
  
  SKILL_ANIMATIONS = {
      :baseattack => [ [:moveto,:target,:align],
                     [:play,:self,:Attack,nil,20],
                     [:damage,:target,:rest],
                     [:play,:target,:Hurt,nil,20],
                     [:moveto,:origin], ],
                    
      :fireball => [ [:move,:self,-10,0],
                     [:play,:self,:Attack],
                     [:missile,:target,96,:rotate],
                     [:flash,:target,Color.new(255,0,0),60],
                     [:anim,:target,57,nil],
                     [:damage,:target,:rest],
                     [:play,:target,:Hurt,nil,20],
                     [:moveto,:origin], ],
                     
      :heal =>  [ [:move,:self,-10,0],
                  [:play,:self,:Cheer,nil,10],
                  [:flash,:target,Color.new(255,255,255),60],
                  [:anim,:target,37,nil],
                  [:damage,:target,:rest],
                  [:play,:target,:Cheer,nil,20],
                  [:moveto,:origin], ],
  }
  
  def self.get_anim(file,anim,loop)
    Animation.new(file,anim,loop)
  end
  
  def self.get_steps(sym)
    SKILL_ANIMATIONS[sym]
  end
  
  class Animation
    def initialize(file,anim,loop)
      @bitmap = Cache.battler(file,0)
      @col, @row = ANIMATION_FILES[file][0], ANIMATION_FILES[file][1]
      @width, @height = @bitmap.width/@col, @bitmap.height/@row
      @animation = ANIMATIONS[anim]
      @frames = []
      @animation.each do |array|
        @frames.push(Frame.new(array[0],array[1]))
      end
      @current_frame = 0
      @current_timer = 0
      @frame_timer = 0
      @loop = loop
    end
    def update
      @current_timer += 1
      @frame_timer += 1
      if @frame_timer == frame.length
        @current_frame += 1
        @frame_timer = 0
      end
      @current_frame = 0 if @loop && @current_frame == @frames.size
    end
    def frame
      @frames[@current_frame]
    end
    def image
      return nil unless frame
      tmpbitmap = Bitmap.new(@width,@height)
      xx, yy = frame.id % @col, frame.id / @col
      xx *= @width;yy *= @height
      tmpbitmap.blt(0,0,@bitmap,Rect.new(xx,yy,@width,@height))
      tmpbitmap
    end
    def done
      @current_frame == @frames.size - 1
    end
    
    class Frame
      attr_reader :id
      attr_reader :length
      def initialize(id,len)
        @id = id
        @length = len
      end
    end
    
  end
  
end

class Sprite_Base
  attr_reader :sprite_animation
  alias animation_update update
  def update
    animation_update
    update_sprite_animation
  end
  def play_animation(file,anim_id,loop = false)
    @sprite_animation = Animation.get_anim(file,anim_id,loop)
  end
  def loop_animation(file,anim_id)
    play_animation(file,anim_id,true)
  end
  def update_sprite_animation
    return if @sprite_animation.nil?
    @sprite_animation.update
    self.bitmap = @sprite_animation.image
  end
  def moveto(x,y,speed,jump = false,rotate = false)
    speed = 20 unless speed
    if @battler && @battler.get_anim("Run")
      loop_animation(@battler.get_anim("Run")[0],@battler.get_anim("Run")[1])
    end
    x_speed = (self.x - x).abs / speed.to_f
    y_speed = (self.y - y).abs / speed.to_f
    iter = 0
    height = Math.sqrt((self.x - x).abs ** 2 + (self.y - y).abs ** 2).to_f
    while x != self.x || y != self.y
      if jump
        self.oy += jump_height(iter, height) - jump_height(iter-1, height)
      end
      self.angle += 20 if rotate
      self.x += x > self.x ? x_speed : -x_speed if x != self.x
      self.y += y > self.y ? y_speed : -y_speed if y != self.y
      self.y = y if (self.y - y).abs <= y_speed
      self.x = x if (self.x - x).abs <= x_speed
      SceneManager.scene.update_basic
      iter += 1;break if iter > speed
    end
    if @battler && @battler.get_anim("Idle")
      loop_animation(@battler.get_anim("Idle")[0],@battler.get_anim("Idle")[1])
    end
  end
  def jump_height(count, height)
    (height * height - (count - height).abs ** 2) / 8
  end
end

class Game_Actor
  def get_anim(anim)
    self.class.note =~ /<#{anim}Anim (.+)>/
    return eval($1) if $1
    actor.note =~ /<#{anim}Anim (.+)>/
    $1 ? eval($1) : nil
  end
  def use_sprite?
    true
  end
  def screen_x
    400 + index * 12
  end
  def screen_y
    200 + index * 32
  end
  def screen_z
    100
  end
  alias ani_index index
  def index
    @spindex ? @spindex : ani_index
  end
  def set_spindex(set)
    @spindex = set
  end
end

class Game_Enemy
  def get_anim(anim)
    enemy.note =~ /<#{anim}Anim (.+)>/
    $1 ? eval($1) : nil
  end
   def atk_animation_id1
    1
  end
end

class Spriteset_Battle
  def create_actors
    @actor_sprites = []
    $game_party.battle_members.each do |actor|
      @actor_sprites.push(Sprite_Battler.new(@viewport1, actor))
    end
  end
  def update_actors
    @actor_sprites.each do |sprite|
      sprite.update
    end
  end
  def reset_positions
    battler_sprites.each {|sprite| sprite.init_position}
  end
end

class Sprite_Battler
  alias animbat_init initialize
  def initialize(*args)
    animbat_init(*args)
    init_position
  end
  def update_bitmap
    if bitmap.nil?
      if @battler.get_anim("Idle") && @battler.alive?
        loop_animation(@battler.get_anim("Idle")[0],@battler.get_anim("Idle")[1])
      elsif @battler.get_anim("Dead") && !@battler.alive?
        loop_animation(@battler.get_anim("Dead")[0],@battler.get_anim("Dead")[1])
      else
        new_bitmap = Cache.battler(@battler.battler_name, @battler.battler_hue)
        self.bitmap = new_bitmap
      end
      self.mirror = @battler.is_a?(Game_Enemy) if @battler.get_anim("Idle")
      init_visibility
    end
  end
  def skill_animation(targets)
    @animation_playing = true
    @steps = Animation.get_steps(@battler.current_action.item.animation)
    @step_timer = 0
    @current_step = -1
    @damage_shown = [0]*8
    update_skill_animation(targets)
  end
  def update_skill_animation(targets)
    while @animation_playing
      @current_step += 1
      break if @current_step == @steps.size
      step = @steps[@current_step].clone
      case step[0]
      when :moveto
        process_moveto(targets,step,false)
        
      when :jumpto
        process_moveto(targets,step,true)
        
      when :move
        process_move(targets,step,false)
        
      when :jump
        process_move(targets,step,true)
        
      when :play
        ntarget = self if step[1] == :self
        ntarget = targets[0] if step[1] == :target
        if step[1].to_s =~ /target(.)/
          ntarget = targets[$1.to_i % targets.size]
        end
        play_anim(ntarget,step)
        
      when :anim
        ntarget = @battler if step[1] == :self
        ntarget = targets[0] if step[1] == :target
        if step[1].to_s =~ /target(.)/
          ntarget = targets[$1.to_i % targets.size]
        end
        if step[2]
          animation_id = step[2]
        else
          animation_id = @battler.atk_animation_id1
        end
        if ntarget
          ntarget.animation_id = animation_id
        else
          targets.each {|ntarget| ntarget.animation_id = animation_id }
        end
        if step[3]
          step[3].times {|i| SceneManager.scene.update_basic }
        else
          sprite = SceneManager.scene.get_sprite(ntarget)
          SceneManager.scene.update_basic while sprite.animation? 
        end
      
      when :mirror
        target = self if step[1] == :self
        target = SceneManager.scene.get_sprite(targets[0]) if step[1] == :target
        if step[1].to_s =~ /target(.)/
          ntarget = SceneManager.scene.get_sprite(targets[$1.to_i % targets.size])
        end 
        step[2] = !step[2] if target.battler.is_a?(Game_Enemy) 
        target.mirror = step[2]
      
      when :wait
        step[1].times {|i| SceneManager.scene.update_basic }
        
      when :flash
        if step[1] == :screen
          $game_troop.screen.start_flash(step[2],step[3])
        else
          target = self if step[1] == :self
          target = SceneManager.scene.get_sprite(targets[0]) if step[1] == :target
          if step[1].to_s =~ /target(.)/
            ntarget = SceneManager.scene.get_sprite(targets[$1.to_i % targets.size])
          end 
          target.flash(step[2],step[3])
        end
        
      when :tint
        $game_troop.screen.start_tone_change(step[1],step[2])
        
      when :se
        Audio.se_play("Audio/Se/" + step[1],step[2],step[3])
        
      when :damage
        if $imported[:BasicDamagePopup]
          i = 0
          if step[1] == :all
            targets.each do |target| 
              target.result.ignore = 1
              partial_damage(step[2],target,i)
              i += 1
            end
          else
            ntarget = @battler if step[1] == :self
            ntarget = targets[0] if step[1] == :target
            if step[1].to_s =~ /target(.)/
              ntarget = targets[$1.to_i % targets.size]
            end
            ntarget.result.ignore = 1
            partial_damage(step[2],ntarget,$1.to_i % targets.size)
          end
        end
      
      when :field
        if $imported[:VlueFieldEffects]
          SceneManager.scene.apply_field(step[1])
        end
        
      when :missile
        ntarget = self if step[1] == :self
        ntarget = targets[0] if step[1] == :target
        if step[1].to_s =~ /target(.)/
          ntarget = targets[$1.to_i % targets.size]
        end
        ntarget = SceneManager.scene.get_sprite(ntarget) if ntarget.is_a?(Game_Battler)
        rotate = step[3] == :rotate ? true : false
        @sprite = Sprite_Base.new
        @sprite.x = self.x
        @sprite.y = self.y - self.bitmap.height / 2
        if step[2].is_a?(Integer)
          @sprite.oy += 12
          @sprite.ox += 12
          @sprite.bitmap = Bitmap.new(24,24)
          tmpbmp = Cache.system("Iconset")
          rect = Rect.new(step[2] % 16 * 24, step[2] / 16 * 24, 24, 24)
          @sprite.bitmap.blt(0, 0, tmpbmp, rect)
        end
        yy = ntarget.y - ntarget.bitmap.height / 4
        @sprite.moveto(ntarget.x,yy,30,false,rotate)
        @sprite.bitmap.dispose
        @sprite.dispose
      
      end
    end
    
  end
  def process_move(targets, step, jump)
    ntarget = self if step[1] == :self
    ntarget = targets[0] if step[1] == :target
    if step[1].to_s =~ /target(.)/
      ntarget = targets[$1.to_i % targets.size]
    end
    ntarget = SceneManager.scene.get_sprite(ntarget) if ntarget.is_a?(Game_Battler)
    step[2] *= -1 if self.mirror
    xx = ntarget.x + step[2]
    if xx != 0
      step[2] < 0 ? xx -= ntarget.bitmap.width / 2 : xx += ntarget.bitmap.width / 2
    end
    moveto(xx,ntarget.y + step[3],step[4],jump)
  end
  def process_moveto(targets,step,jump)
    ntarget = @battler if step[1] == :origin
    ntarget = targets[0] if step[1] == :target
    if step[1].to_s =~ /target(.)/
      ntarget = targets[$1.to_i % targets.size]
    end
    if step[2]
      ntarget = SceneManager.scene.get_sprite(ntarget)
      width, height = ntarget.bitmap.width, ntarget.bitmap.height
      x, y = ntarget.x, ntarget.y
      if step[2] == :align
        step[2] = :right if ntarget.x < self.x
        step[2] = :left if ntarget.x > self.x
      elsif step[2] == :align_o
        step[2] = :right if ntarget.x > self.x
        step[2] = :left if ntarget.x < self.x
      end
      x = ntarget.x + width / 2 if step[2] == :right
      x = ntarget.x - width / 2 if step[2] == :left
      y = ntarget.y + height / 2 if step[2] == :below
      y = ntarget.y - height / 2 if step[2] == :above
    elsif ntarget
      x, y = ntarget.screen_x, ntarget.screen_y
    else
      x, y = 0, 0
    end
    moveto(x,y,step[3],jump)
  end
  def partial_damage(per, target, i)
    item = @battler.current_action.item
    ntarget = Marshal.load(Marshal.dump(target))
    ntarget.set_spindex(target.index) if target.is_a?(Game_Actor)
    if per == :rest
      ntarget.result.hp_damage -= @damage_shown[i]
    else
      ntarget.result.hp_damage *= (per.to_f / 100)
      ntarget.result.hp_damage = ntarget.result.hp_damage.to_i
    end
    @damage_shown[i] += ntarget.result.hp_damage
    SceneManager.scene.add_damage_popup(ntarget,item,@battler)
  end
  def play_anim(target,step)
    target = SceneManager.scene.get_sprite(target) if target.is_a?(Game_Battler)
    file = [step[2],step[3]]
    if step[2].is_a?(Symbol)
      file = target.battler.get_anim(step[2].to_s)
    end
    return unless file
    target.play_animation(file[0],file[1],false)
    if step[4].nil?
      SceneManager.scene.update_basic while !target.sprite_animation.done 
    else
      step[4].times { SceneManager.scene.update_basic }
    end
  end
  def update_position
    
  end
  def init_position
    self.x = @battler.screen_x
    self.y = @battler.screen_y
    self.z = @battler.screen_z
  end
  alias animbat_start_effect start_effect
  def start_effect(effect_type)
    if effect_type == :collapse && @battler.get_anim("Dead")
      loop_animation(@battler.get_anim("Dead")[0],@battler.get_anim("Dead")[1])
    else
      animbat_start_effect(effect_type)
    end
  end
end

class Scene_Battle
  alias animated_animation show_animation
  def show_animation(targets, animation_id)
    if !@subject.current_action.item.animation
      return animated_animation(targets,animation_id) 
    else
      get_sprite(@subject).skill_animation(targets)
    end
    @spriteset.reset_positions
  end
  def get_sprite(target)
    @spriteset.battler_sprites.each do |battler|
      return battler if battler.battler == target
    end
  end
  def get_all_but(subj,targ)
    @spriteset.battler_sprites - [subj] - targ
  end
  def update_for_animation
    @spriteset.update
    Graphics.update
  end
  def use_item
    item = @subject.current_action.item
    @log_window.display_use_item(@subject, item)
    @subject.use_item(item)
    refresh_status
    targets = @subject.current_action.make_targets.compact
    targets.each do |target| 
      item.repeats.times do
        (apply_substitute(target, item)).item_prepare(@subject, item)
      end
    end
    show_animation(targets, item.animation_id)
    targets.each {|target| item.repeats.times { invoke_item(target, item) } }
  end
end
  
class RPG::UsableItem
  def animation
    @note =~ /<ANIMATION (.+)>/ ? $1.to_sym : false
  end
end

class Game_Battler
  def item_prepare(user, item)
    @result.clear
    @result.used = item_test(user, item)
    @result.missed = (@result.used && rand >= item_hit(user, item))
    @result.evaded = (!@result.missed && rand < item_eva(user, item))
    if @result.hit?
      unless item.damage.none?
        @result.critical = (rand < item_cri(user, item))
        make_damage_value(user, item)
      end
    end
  end
  def item_apply(user, item)
    if @result.hit?
      execute_damage(user)
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      item_user_effect(user, item)
    end
  end
end

class Game_ActionResult
  attr_accessor :ignore
end