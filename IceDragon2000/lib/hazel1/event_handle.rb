#
# EDOS/src/hazel/eventhandle.rb
#   by IceDragon
#   dc 03/04/2013
#   dm 20/05/2013
class Hazel::EventHandle

  VERSION = "1.0.1".freeze

  include MACL::Mixin::Callback

  attr_reader :parent

  ##
  # initialize(Object parent)
  def initialize(parent)
    @parent = parent
    init_callbacks
    @callback_settings[:args_prepend] = [@parent]
  end

  alias :clear   :clear_callbacks
  alias :dispose :dispose_callbacks
  alias :add     :add_callback
  alias :remove  :remove_callback
  alias :try     :try_callback
  alias :call    :call_callback
  alias :events  :callbacks

  public :clear, :dispose, :add, :remove, :try, :call, :events

end