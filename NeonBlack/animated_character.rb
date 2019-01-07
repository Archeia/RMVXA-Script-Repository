class Animated_Character
  attr_accessor :x
  attr_accessor :y
  attr_accessor :name
  attr_accessor :index
  attr_accessor :face
  attr_accessor :bitmap
  
  def initialize(x, y, name, index, face = 2)
    @x = x
    @y = y
    @name = name
    @index = index
    @face = face
  end
  
  def identical?(x, y, name, index)
    return (@x == x && @y == y && @name == name && @index == index)
  end
  
  def create_bitmap(width, height, map)
    @bitmap = Bitmap.new(width, height)
    @bitmap.blt(0, 0, map, map.rect)
  end
end

class Window_Base < Window
  alias cp_anim_char update unless $@
  def update
    cp_anim_char
    @step = 0 if @step.nil?
    @step += 1; @step %= 40
    update_anim_chars
  end
  
  def update_anim_chars
    @step = 0 if @step.nil?; @old_step = -1 if @old_step.nil?
    return if (@step / 10) == (@old_step / 10)
    @old_step = @step
    @char_list = [] if @char_list.nil?
    return if @char_list.empty?
    fr = (@step / 10) == 3 ? 1 : @step / 10
    @char_list.each_with_index do |char, i|
      draw_an_character(char.name, char.index, char.x, char.y, char.face, fr, i)
    end
  end
  
  def draw_an_character(name, index, x, y, face = 2, frame = 1, array = nil)
    return unless name
    bitmap = Cache.character(name)
    sign = name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = index
    f = (face / 2) - 1
    src_rect = Rect.new((n%4*3+frame)*cw, (n/4*4)*ch + (ch * f), cw, ch)
    clear_rect = Rect.new(x - cw / 2, y - ch, cw, ch)
    bit = create_back_rect(array, clear_rect) if !array.nil?
    contents.clear_rect(clear_rect)
    contents.blt(clear_rect.x, clear_rect.y, bit, bit.rect) unless bit.nil?
    contents.blt(clear_rect.x, clear_rect.y, bitmap, src_rect)
  end
  
  def create_back_rect(index, rect)
    return nil if @char_list[index].nil?
    return @char_list[index].bitmap if @char_list[index].bitmap
    map = Bitmap.new(rect.width, rect.height)
    map.blt(0, 0, contents, rect)
    @char_list[index].create_bitmap(rect.width, rect.height, map)
    return @char_list[index].bitmap
  end
  
  def draw_animated_character(name, index, x, y, facing = 2)
    add_an_character(name, index, x, y, facing)
    update_anim_chars
  end
  
  def add_an_character(name, index, x, y, face)
    same = false
    @char_list = [] if @char_list.nil?
    @char_list.each do |char|
      next unless char.identical?(name, index, x, y)
      char.face = face
      same = true
    end
    @char_list.push(Animated_Character.new(x, y, name, index, face)) unless same
  end
end