# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# IEK (https://github.com/IceDragon200/IEK)
# Script Dep
#   by IceDragon (https://github.com/IceDragon200)
# Description
#   This is a version manager class, used for registering strings with versions.
#   Its used mostly for registering scripts with their version and
#   checking for their dependencies.
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
class ScriptDep
  VERSION = '1.1.0'

  class Conflict < RuntimeError
    def initialize(id, version = nil)
      if version
        message = "Conflicting (#{id} version: #{version}) is present"
      else
        message = "Conflicting (#{id}) is present"
      end
      super message
    end
  end

  class InvalidDependency < RuntimeError
    def initialize(id, version = nil)
      if version
        message = "Dependency (#{id} version: #{version}) is missing"
      else
        message = "Dependency (#{id}) is missing"
      end
      super message
    end
  end

  class InvalidVersionString < RuntimeError
    def initialize(str)
      super "Invalid version String (#{str})"
    end
  end

  class InvalidDependencyVersion < RuntimeError
  end

  class RegisterError < RuntimeError
  end

  class Version
    # used for checking version dependencies
    VERSION_VALIDATE = /(\d+(?:.\d+)*)/
    VERSION_DEP_REGEX = /(~>|==|>=|<=|!=|>|<|=)\s+(\d+(?:.\d+)*)/

    include Comparable

    attr_reader :str
    protected :str

    def initialize(str)
      unless str =~ VERSION_VALIDATE
        raise InvalidVersionString.new(str)
      end
      @str = str
      refresh
    end

    def <=>(other)
      @str <=> other.str
    end

    def to_s
      @str.dup
    end

    def refresh
      str =~ VERSION_VALIDATE
      @data = $1.split('.')
    end

    def major
      @data[0]
    end

    def minor
      @data[1]
    end

    def teeny
      @data[2]
    end

    def rev
      @data[3]
    end

    def shift
      ver = @data.dup.tap { |a| a.shift }.join('.')
      self.class.new(ver)
    end

    def self.parse_dep_version(str)
      if str =~ VERSION_DEP_REGEX
        return $1, new($2)
      else
        raise InvalidDependencyVersion.new(str)
      end
    end

    def self.create(obj)
      obj && new(obj)
    end

    private :refresh
  end

  class ScriptHeader
    Dependency = Struct.new(:id, :version)

    attr_accessor :dep
    attr_accessor :id
    attr_accessor :name
    attr_accessor :description
    attr_accessor :version
    attr_accessor :dependencies
    attr_accessor :conflicts
    attr_accessor :provisions

    # @param [String] id
    #   @example iek/my_awesome_script
    # @param [String] name
    #   @example My Awesome Script
    # @param [String] description
    #   @example This blows stuff up
    # @param [String] version
    #   @example "0.1.0"
    def initialize(id, name, description, version)
      @id, @name, @description, @version  = id, name, description, version
      @dependencies = []
      @conflicts = []
      @provisions = []
    end

    def depend(id, version = nil)
      @dependencies << Dependency.new(id, version)
    end

    def depend!(id, version = nil)
      depend(id, version)
      @dep.depend!(id, version) if @dep
    end

    def conflict(id, version = nil)
      @conflicts << Dependency.new(id, version)
    end

    def conflict!(id, version = nil)
      conflict(id, version)
      @dep.conflict!(id, version) if @dep
    end

    def provides(id, version = nil)
      conflict! id, version
      @provisions << Dependency.new(id, version)
    end

    def to_s
      if id != name
        "#{id} (#{version}) #{name} - #{description}"
      else
        "#{id} (#{version}) - #{description}"
      end
    end
  end

  def initialize
    @data = {}

    register('__script_dep__', VERSION, 'Script Manager')
  end

  def registered?(id)
    @data.has_key?(id)
  end

  def check_registered(id)
    if head = @data[id]
      raise RegisterError, "#{id} has been registered as #{head}"
    end
  end

  def register(id, version_str, description = '')
    check_registered id

    head = ScriptHeader.new(id, id, description, Version.new(version_str))

    head.dep = self

    yield head if block_given?

    @data[id] = head
    head.provisions.each do |dep|
      check_registered dep.id
      @data[dep.id] = head
    end

    id
  end

  def valid?(id, version_str)
    head = @data[id]
    if head
      if version_str
        # Checks expected version against, given version
        meth, ver = Version.parse_dep_version(version_str)

        expected = ver
        given = head.version

        case meth
        when '~>'
          if expected.major != given.major
            return false
          end
          expected = expected.shift
          given = given.shift
          meth = '>='
        when '='
          meth = '=='
        end
        if given.send(meth, expected)
          return true
        end
      else
        return true
      end
    end
    false
  end

  def conflict!(id, version_str = nil)
    if valid?(id, version_str)
      raise Conflict.new(id, version_str)
    end
    false
  end

  def depend!(id, version_str = nil)
    unless valid?(id, version_str)
      raise InvalidDependency.new(id, version_str)
    end
    false
  end

  def entries
    @data.entries
  end

  def list
    @data.values
  end

  def check!
    @data.each do |key, head|
      head.conflicts.each do |dep|
        conflict!(*dep)
      end

      head.dependencies.each do |dep|
        depend!(*dep)
      end
    end
  end

  alias :r :register
end
