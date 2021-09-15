#
# EDOS/src/hazel/hazel.rb
#  by IceDragon
#  dm 03/04/2013
# vr 0.1.1
module Hazel

  class HazelError < Exception
  end

end

# mixin
require_relative 'mixin/mouse_event.rb'

# struct
require_relative 'struct/bound_surface.rb'

#
require_relative 'event_handle.rb'

# data
require_relative 'component_base.rb'
  require_relative 'widget_base.rb'
    require_relative 'widget.rb'
      require_relative 'widget/button.rb'
        require_relative 'widget/radiobutton.rb'
        require_relative 'widget/checkbox.rb'
  require_relative 'panel.rb'
require_relative 'collection_base.rb'
  require_relative 'collection.rb'
    require_relative 'collection/button.rb'
      require_relative 'collection/radio.rb'

# GUI
require_relative 'onyx/onyx.rb'

# Default stuff
require_relative 'default.rb'

# register
require_relative 'onyx_register.rb'

# Mouse Event List
#   mouse_over
#   mouse_hover
#   mouse_not_over
#   mouse_left_click
#   mouse_right_click
#   mouse_middle_click
#   mouse_start_over
#   mouse_start_hover
#   mouse_stop_over
#   mouse_stop_hover
#
# Properties
#   @hover_frame_count (read-only)
#   @hover_frame_cap
#

# Button Event List
#   toggle

__END__
  Hazel is a widget library designed for RGSS3 under ruby.

  Hazel's RadioButton requires a Collection::Radio in order to operate.
  First create a Collection::Radio and then add_obj(your_radio_button)
  The collection will assign a @radio_id and set its @collection