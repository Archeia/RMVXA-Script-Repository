#
# EDOS/src/levias/struct/stage.rb
#   by IceDragon
#   dc 30/03/2013
#   dm 30/03/2013
module Levias
  class Stage

    attr_accessor :name
    attr_accessor :areas

    def initialize
      @name = ""
      @areas = []
    end

  end
end
