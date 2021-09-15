$simport.r 'iek/rgss3_ext/font', '1.0.0', 'Extends Font Class'

class Font
  alias :org_initialize :initialize
  def initialize(*args)
    org_initialize(*args)
    yield self if block_given?
  end

  ##
  # save { |font| do_stuff }
  #   Caches the Font's state and restores the Font state on block exit
  # @return [self]
  def save
    cached = to_h
    yield self
    set(cached)
    self
  end

  ##
  # set(hash)
  # @param [Hash<Symbol, Object>] hash
  # @return [self]
  def set(hash)
    self.name      = hash.fetch(:name)      { name }.dup
    self.size      = hash.fetch(:size)      { size }
    self.color     = hash.fetch(:color)     { color }.dup
    self.bold      = hash.fetch(:bold)      { bold }
    self.italic    = hash.fetch(:italic)    { italic }
    self.out_color = hash.fetch(:out_color) { out_color }.dup
    self.outline   = hash.fetch(:outline)   { outline }
    self.shadow    = hash.fetch(:shadow)    { shadow }
    self
  end

  ##
  # import(other)
  # @param [Font] other
  # @return [self]
  def import(other)
    self.name      = other.name.dup
    self.size      = other.size
    self.color     = other.color.dup
    self.bold      = other.bold
    self.italic    = other.italic
    self.out_color = other.out_color.dup
    self.outline   = other.outline
    self.shadow    = other.shadow
    self
  end

  ##
  # to_h
  # @return [Hash<Symbol, Object>]
  def to_h
    {
      name: name,
      size: size,
      color: color,
      bold: bold,
      italic: italic,
      out_color: out_color,
      outline: outline,
      shadow: shadow,
    }
  end
end
