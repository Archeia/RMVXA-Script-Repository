#
# hazel/component_base.rb
# vr 0.10

#
# Hazel Base Component class, superclass of all Hazel Components
#
class Hazel::ComponentBase

  include MACL::Mixin::Surface2Bang

  # Surface
  attr_reader :surface, :properties
  attr_accessor :z # Surface doesn't have a z property
  attr_accessor :label, :icon

  def initialize(x, y, w, h)
    @surface = Hazel::BoundSurface.new(x, y, x + w, y + h) # used to store the widgets size
    @surface.freeform = false # no freeforming!
    @z = 0
    @label = "" # custom label for this widget, used by buttons for text
    @icon = nil

    @disposed = false
    @properties = {}
  end

  def detection_surface
    if @detection_surface
      if !MACL::Surface::Tool.match?(@surface, @detection_surface)
        refresh_detection_surface
      end
    else
      refresh_detection_surface
    end
    @detection_surface
  end

  def refresh_detection_surface
    @detection_surface = MACL::Surface.new(@surface)
    @detection_surface.contract!(anchor: 5, amount: 1)
  end

  # exposure of Surface properties for convienience
  [:x, :y, :x2, :y2, :width, :height].each do |sym|
    module_eval(%Q(
      def #{sym}
        return @surface.#{sym}
      end

      def #{sym}=(n)
        @surface.#{sym} = n
      end
    ))
  end

  def pos_in_area?(x, y)
    surf = detection_surface
    return x.between?(surf.x, surf.x2) && y.between?(surf.y, surf.y2)
  end

  # other
  def dispose
    @disposed = true
  end

  def disposed?
    return !!@disposed
  end

  def update
    #
  end

end