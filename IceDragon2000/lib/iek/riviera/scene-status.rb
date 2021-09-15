$simport.r 'iek/riviera/scene/status', '1.0.0', 'Riviera styled Status Menu' do |h|
  h.depend 'iek/riviera/scene/menu_base', '>= 1.0.0'
end

class Scene_Status
  def start
    super
    create_status_window
    create_tail
  end

  def create_status_window
    rect = @content_rect.dup
    rect.width /= 2
    @status_window = Window_Status.new(@actor, rect: rect)
    @status_window.set_handler(:cancel,   method(:return_scene))
    @status_window.set_handler(:pagedown, method(:next_actor))
    @status_window.set_handler(:pageup,   method(:prev_actor))
  end

  def create_tail
    @tail_sprite = Sprite.new
    @tail_sprite.bitmap = Bitmap.new(Graphics.width, 24 * 2)
    @tail_sprite.bitmap.fill(Color.new(0, 0, 0, 198))
    @tail_sprite.y2 = @content_rect.y2
  end

  def header_string
    'Status'
  end
end
