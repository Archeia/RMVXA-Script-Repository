# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# IEK (https://github.com/IceDragon200/IEK)
# MicroJSON - Monkey Patch
#   by IceDragon (https://github.com/IceDragon200)
# Description
#   This is the core extension script for MicroJSON
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#//$simport.r("micro_json/monkey", "1.0.0", "Core extension for MicroJSON") do |h|
#//  h.depend("micro_json", ">= 1.0.0")
#//end

JSON = MicroJSON

class Object
  def to_mini_json
    MicroJSON.dump self
  end
  alias :to_json :to_mini_json
end
