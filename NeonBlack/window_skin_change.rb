module CP
New_Skin = "Window"
end

class Window_ChoiceList < Window_Command
  alias cp_init_do_stuff initialize
  def initialize(*args)
    cp_init_do_stuff(*args)
    self.windowskin = Cache.system(CP::New_Skin)
  end
end

class Window_NumberInput < Window_Base
  alias cp_init_do_stuff initialize
  def initialize(*args)
    cp_init_do_stuff(*args)
    self.windowskin = Cache.system(CP::New_Skin)
  end
end

class Window_KeyItem < Window_ItemList
  alias cp_init_do_stuff initialize
  def initialize(*args)
    cp_init_do_stuff(*args)
    self.windowskin = Cache.system(CP::New_Skin)
  end
end

class Window_Message < Window_Base
  alias cp_init_do_stuff initialize
  def initialize(*args)
    cp_init_do_stuff(*args)
    self.windowskin = Cache.system(CP::New_Skin)
  end
end