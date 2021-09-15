#
# EDOS/src/hazel/onyx/onyx.rb
# vr 0.1.1
module Hazel::Onyx

  class OnyxError < Exception
  end

  class OnyxRegistryError < Exception
  end

end

require_relative 'structs.rb'

require_relative 'sprite_component_base.rb'
  require_relative 'sprite_widget_base.rb'
    require_relative 'sprite_button_base.rb'
      require_relative 'sprite_button.rb'
      require_relative 'sprite_checkbox.rb'
      require_relative 'sprite_radiobutton.rb'
  require_relative 'sprite_panel.rb'

require_relative 'spriteset_components.rb'

require_relative 'componentregistry.rb'