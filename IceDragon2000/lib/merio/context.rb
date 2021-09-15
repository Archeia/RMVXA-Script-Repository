#
# EDOS/lib/drawext/merio/context.rb
#   by IceDragon (mistdragon100@gmail.com)
#   dc 23/06/2013
#   dm 23/06/2013
# vr 1.0.0
module DrawExt
  module Merio
    class DrawContext
      ### mixins
      include DrawExt::Merio::Functions

      ### instance_attributes
      attr_writer :default_font_name

      ##
      # initialize(Bitmap bitmap)
      def initialize(bitmap)
        @bitmap = bitmap
        clear_settings
      end

      class << self
        alias :wrap :new
      end
    end

    def self.context_wrap(bmp)
      DrawContext.new(bmp)
    end
  end
end
