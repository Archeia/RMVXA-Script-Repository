$simport.r 'iek/riviera/scene/menu_base', '1.0.0', 'Patch for Menu Headers' do |h|
  h.depend 'iek/rgss3_ext/bitmap', '>= 1.0.0'
  h.depend 'iek/rgss3_ext/font', '>= 1.0.0'
  h.depend 'iek/text', '>= 1.0.0'
end

class Scene_MenuBase
  def start
    super
    create_background
    create_header

    create_content_rect

    @actor = $game_party.menu_actor
  end

  def header_config
    @header_config ||= {
      font: Font.new.tap do |font|
        font.color = Color.new 255, 255, 255, 255
        font.size = 64
      end,
      size: 64,
      background_color: Color.new(0, 0, 0, 198),
      baseline_size: 10
    }
  end

  def header_string
    'Menu Base'
  end

  def create_header
    config = header_config
    w, h = Graphics.width, config[:size]
    @header_sprite = Sprite.new
    @header_sprite.bitmap = Bitmap.new(w, h).tap do |bmp|
      bmp.fill config[:background_color]
      bmp.font.import(config[:font])
      bmp.fill_rect 0, h - config[:baseline_size] - 1, w, config[:baseline_size], bmp.font.color
      bmp.draw_text 4, 0, w, h, header_string, Text::Align::LEFT
    end
  end

  def create_help_window
    @help_window = Window_Help.new
    @help_window.viewport = @viewport

    @help_window.hide
  end

  def create_content_rect
    h = Graphics.height - @header_sprite.height
    @content_rect = Rect.new 0, @header_sprite.y2, Graphics.width, h
  end
end
