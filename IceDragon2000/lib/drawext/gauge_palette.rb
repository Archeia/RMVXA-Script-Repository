#
# EDOS/lib/drawext/gauge_palette.rb
#   by IceDragon
module DrawExt
  def self.init_gauge_palettes
    @gauge_palettes = {}
    dir = File.join(File.dirname(__FILE__), 'gauge_palette')
    load File.join(dir, 'default.rb')
    load File.join(dir, 'rgby.rb')
    load File.join(dir, 'gem.rb')
    load File.join(dir, 'keyboard.rb')
    load File.join(dir, 'elements.rb')
    load File.join(dir, 'attributes.rb')
    load File.join(dir, 'pokemon-4c.rb')
    #@gauge_palettes.each { |k, pal| pal.freeze_entries }
  end

  def self.new_gauge_palette(name)
    pal = DrawExtPalette.new
    pal.name = name
    @gauge_palettes[name] = pal
  end

  def self.new_gauge_palette_from(name, from_name)
    new_gauge_palette(name).import(gauge_palettes[from_name])
  end

  class << self
    attr_reader :gauge_palettes
  end
end
