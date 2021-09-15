module REI
  module Version
    MAJOR = 1
    MINOR = 9
    TEENY = 1
    PATCH = nil
    STRING = [MAJOR, MINOR, TEENY, PATCH].compact.join('.').freeze
  end
  VERSION = Version::STRING
end
