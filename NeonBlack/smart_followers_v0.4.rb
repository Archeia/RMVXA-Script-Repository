class Game_Player < Game_Character
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
end

class Game_Followers
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
  
  def update_movement(force = false)
    @last_follow = nil
    @data.each_with_index do |f,i|
      @last_follow = f if f.moving?
      unless force
        @last_follow = f if @last_follow.nil? && @follower_queue[f.movement_index+1].nil?
        @last_follow = f if @last_follow && f.movement_index+1 >= @last_follow.movement_index
      end
      comm = @follower_queue[f.movement_index]
      @last_follow = f unless comm
      next if @last_follow == f
      f.direction = comm[2]
      case comm[3]
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
    if @data[-1].movement_index > 0
      each { |follower| follower.movement_index -= 1 }
      @follower_queue.shift
    end
  end
  
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
  end
  
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
end