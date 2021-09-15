module REI
  module Version
    MAJOR, MINOR, TEENY, PATCH = 0, 9, 1, nil
    STRING = [MAJOR, MINOR, TEENY, PATCH].compact.join('.').freeze
  end
  VERSION = Version::STRING
end
