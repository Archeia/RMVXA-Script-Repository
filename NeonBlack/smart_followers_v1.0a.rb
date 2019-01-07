##-----------------------------------------------------------------------------
#  Smart(er) Followers v1.0a
#  Created by Neon Black
#  v1.0 - 1.24.14 - Main script completed
#  For both commercial and non-commercial use as long as credit is given to
#  Neon Black and any additional authors.  Licensed under Creative Commons
#  CC BY 4.0 - http://creativecommons.org/licenses/by/4.0/
##-----------------------------------------------------------------------------

module CPSmartFollowers
  ## The minimum delay between each character in the party in frames.
  ## What this means is the followers will appear a few spaces behind each
  ## other rather than being right on each others' backs.
  MoveDelay = 8
end


##-----------------------------------------------------------------------------
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


$imported ||= {}
$imported["CP_SMART_FOLLOWERS"] = 1.0

class Game_Player < Game_Character
  ## Adds the latest player movement to the follower queue.
  def move_straight(d, turn_ok = true)
    forefront = passable?(@x, @y, d)
    super
    return unless forefront
    @followers.move(d, nil, self.direction, :str)
  end
  
  def move_diagonal(horz, vert)
    forefront = diagonal_passable?(@x, @y, horz, vert)
    super
    return unless forefront
    @followers.move(horz, vert, self.direction, :dia)
  end
  
  def jump(x_plus, y_plus)
    super
    @followers.move(x_plus, y_plus, self.direction, :jum)
  end
  
  ## Re-orders the order methods are performed in the update method.  May be
  ## problomatic if another script expects the original ordering.  If there are
  ## issues, try commenting out lines 52 to 63 using CTRL+Q.
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    last_moving = moving?
    ## Original location of "move_by_input".
    super
    update_scroll(last_real_x, last_real_y)
    update_vehicle
    update_nonmoving(last_moving) unless moving?
    move_by_input
    @followers.update
  end
  
  ## Size of the queue for proper following.
  def movement_index
    @followers.follower_queue.size
  end
end

class Game_Followers
  attr_reader :follower_queue
  alias_method "cp_092013_move", "move"
  alias_method "cp_092013_initialize", "initialize"
  alias_method "cp_092213_synchronize", "synchronize"
  
  def initialize(*args)
    cp_092013_initialize(*args)
    @follower_queue = []
  end
  
  def update
    update_movement(gathering?)
    @gathering = false if gathering? && gather?
    each { |follower| follower.update }
  end
  
  ## Long method that checks numerous conditions to ensure that the follower is
  ## allowed to move forward.  Has a forced method to allow followers to
  ## gather.
  def update_movement(force = false)
    @last_follow = nil
    @data.each_with_index do |f,i|
      unless force
        last = @last_follow.nil? ? $game_player : @last_follow
        last = f if last.movement_index <= 1
        @last_follow = f if @last_follow.nil? && @follower_queue[f.movement_index+1].nil?
        @last_follow = f if @last_follow && f.movement_index+1 >= @last_follow.movement_index
        f.increase_displacement_count(last != f && last.moving?)
        if last.moving? || f.movement_index + 1 >= last.movement_index
          @last_follow = f unless f.check_displacement_count
        end ## The lines above are used for follower displacement.
      end
      @last_follow = f if f.moving?
      comm = @follower_queue[f.movement_index]
      @last_follow = f unless comm
      next if @last_follow == f
      f.direction = comm[2]
      case comm[3] ## Perform a specific kind of motion when following.
      when :str
        f.move_straight(comm[0])
      when :dia
        f.move_diagonal(*comm[0..1])
      when :jum
        f.jump(*comm[0..1])
      end
      f.movement_index += 1
      @last_follow = f
    end
    if @data[-1].movement_index > 1
      each { |follower| follower.movement_index -= 1 }
      @follower_queue.shift
    end
  end
  
  ## Ironically, I kept the original methods in for random errors.
  def move(*args)
    if args.empty?
      cp_092013_move()
    else
      @follower_queue.push(args)
    end
  end
  
  def synchronize(*args)
    cp_092213_synchronize(*args)
    clear_queue
  end
  
  def clear_queue
    each do |follower|
      follower.movement_index = 0
      follower.jump_count = 0
    end
    @follower_queue = []
  end
end

class Game_Follower < Game_Character
  attr_accessor :direction, :movement_index
  attr_writer :jump_count
  alias_method "cp_092213_initialize", "initialize"
  
  def initialize(*args)
    cp_092213_initialize(*args)
    @movement_index = 0
    @displ_count = 0
  end
  
  ## Needed @direction_fix to be free from the player.
  def update
    @direction_fix  = true
    @move_speed     = $game_player.real_move_speed
    @transparent    = $game_player.transparent
    @walk_anime     = $game_player.walk_anime
    @step_anime     = $game_player.step_anime
    @opacity        = $game_player.opacity
    @blend_type     = $game_player.blend_type
    super
  end
  
  ## Counts and uncounts displacement for better following.
  def increase_displacement_count(count = false)
    if count
      @displ_count += 1 unless moving? || @displ_count >= CPSmartFollowers::MoveDelay
    else
      @displ_count -= 1 unless @displ_count <= 0
    end
  end
  
  def check_displacement_count
    @displ_count >= CPSmartFollowers::MoveDelay
  end
  
  def no_displacement
    @displ_count == 0
  end
end


##-----------------------------------------------------------------------------
## End of script.
##-----------------------------------------------------------------------------