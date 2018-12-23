class Window_Base
  alias :process_normal_character_vxa :process_normal_character
  def process_normal_character(c, pos)
        return unless c >= ' ' #skip drawing if c is not a displayable character
        process_normal_character_vxa(c, pos)
  end
end