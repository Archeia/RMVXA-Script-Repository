#
# src/hazel/panel.rb
# vr 0.1.0
class Hazel::Panel < Hazel::ComponentBase

  attr_reader :widgets

  def initialize(x, y, w, h)
    super(x, y, w, h)
    @widgets = {}
    @properties.merge!(
      use_header: false,
      header_height: 12
    )
  end

  def refresh_widgets
    @widgets.each_key do |k|
      set_widget(k)
    end

    return self
  end

  def set_widget(widget)
    @widgets[widget] = [widget.x, widget.y]
    pos_widget(widget)
    return self
  end

  def remove_widget(widget)
    @widgets.delete(widget)
    return self
  end

  def pos_widget(widget)
    x, y = @widgets[widget]
    widget.x, widget.y = (@last_x || 0) + x, (@last_y || 0) + y
  end

  def update
    super
    update_position
    update_widgets
  end

  def update_widgets
    unless onyx? # Onyx will update the widgets
      for widget in @widgets
        widget.update
      end
    end
  end

  def onyx?
    return true
  end

  def update_position
    if @last_x != self.x || @last_y != self.y
      @last_x = self.x
      @last_y = self.y

      @widgets.each_key do |w|
        pos_widget(w)
      end
    end
  end

  def refresh_position
    @last_x, @last_y = nil, nil
  end

end