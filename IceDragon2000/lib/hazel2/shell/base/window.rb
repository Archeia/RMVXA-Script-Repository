# Shell::Window
# // 02/06/2012
# // 02/06/2012
require_relative 'base'
module Hazel
  class Shell::Window < Shell::Base

    include Mixin::CallbackHook
    include Shell::Addons::OwnViewport
    include Shell::Addons::Contents

    def initialize(x, y=nil, width=nil, height=nil)
      super(x, y, width, height)
    end

  end
end