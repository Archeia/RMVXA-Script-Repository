#
# EDOS/lib/hazel/version.rb
#
module Hazel
  module Version
    MAJOR = 2
    MINOR = 1
    TEENY = 0
    PATCH = nil
    STRING = [MAJOR, MINOR, TEENY, PATCH].compact.join('.').freeze
  end
  VERSION = Version::STRING
end
