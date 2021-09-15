#
# EDOS/lib/shell/addons.rb
# vr 2.0.0
module Hazel
  class Shell
    module Addons

      VERSION = "2.0.0".freeze

    end
  end
end

require_relative 'addons/base'

require_relative 'addons/registry'
require_relative 'addons/callback_host'

require_relative 'addons/own_viewport'
require_relative 'addons/background'

require_relative 'addons/content'
require_relative 'addons/handler_base'
require_relative 'addons/selectable_base'
require_relative 'addons/cursor_base'