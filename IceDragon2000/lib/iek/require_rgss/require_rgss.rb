# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# IEK (https://github.com/IceDragon200/IEK)
# Require RGSS
#   by IceDragon (https://github.com/IceDragon200)
#   version 1.0.0
# Description
#   --
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
def top_binding
  self.send(:binding)
end

module RequireRGSS
  def self.load(name, options = {})
    if data = $RGSS_SCRIPTS[name]
      $rrgss_options = options
      result = eval(data[2], top_binding, name, 1)
      $rrgss_options = nil
      result
    else
      raise LoadError, "RGSS_SCRIPT #{name} does not exists"
    end
  end
end

module Kernel
  def vaxle_require(name, options = {})
    RequireRGSS.load(name, options)
  end

  alias :require_rgss :vaxle_require
end
