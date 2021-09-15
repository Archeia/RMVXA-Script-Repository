#
# hazel/widgetbase.rb
# vr 0.11

#
# Hazel Base Widget class, superclass of all Hazel Widgets
#
class Hazel::WidgetBase < Hazel::ComponentBase

  def initialize(x, y, w, h)
    super(x, y, w, h)
    @event = {} # event flag, used for sprites and other elements
  end

  attr_reader :event

end