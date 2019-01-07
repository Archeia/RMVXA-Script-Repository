class Game_Interpreter
  def get_picture_name(name, emotion)
    a = Dir.entries("Graphics/Pictures").select {|i| i =~ /%\[(\d+),?\s*?(\d*?)\]#{name}-#{emotion}/}
    return !a.empty? ? a[0] : nil
  end
end