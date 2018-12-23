#==============================================================================
#    State Icon Scroll
#    Version: 1.0c
#    Author: modern algebra (rmrk.net)
#    Date: January 20, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script allows you to set it so that if an actor is afflicted with
#   many states and buffs, it will scroll through them instead of only showing
#   the first four.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor, above Main and 
#   below Materials.
#
#    This script is plug & play and will show up in any window, but if you so 
#   desire, you can set the speed, pause time, and which windows this feature
#   will be available. See the Editable Region beginning at line 29 for more 
#   details.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_StateIconScroll] = true

MASIS_SCROLL_SETTINGS = {
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #  Editable Region
  #````````````````````````````````````````````````````````````````````````````
  #  For all of the following options, you may only alter the part that comes 
  # after the colon. Each line except the last should end in a comma.
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  scroll_speed:  This value controls how many pixels the states will scroll 
  # every frame. If between 0 and 24, then it will scroll smoothly. If set to 
  # 0, it will be in flash mode, meaning it will show as many states as it can,
  # then get rid of them immediately and show the next states, and so on. If 
  # set to a value greater than 23, then it must be a multiple of 24, and it
  # will flash by as many icons as you specify.
  scroll_speed:    2,
  #  pause_time:  This value determines how much time to wait once it reaches
  # the next icon. There are 60 frames in one second.
  pause_time:      60,
  #  windows_enabled:  This array allows you to specify which windows it will
  # work in. :Window_Base means it will show up in every window, but you could,
  # for instance, replace it with something like this:
  #    [:Window_BattleStatus, :Window_Status]
  #  Then the states would only scroll in the Status and Battle Scenes, and not
  # in the Main Menu or any other scene. It is recommended that you just keep 
  # it as [:Window_Base]
  windows_enabled: [:Window_Base]
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  END Editable Region
  #////////////////////////////////////////////////////////////////////////////
}

if MASIS_SCROLL_SETTINGS[:scroll_speed] > 24
  MASIS_SCROLL_SETTINGS[:scroll_speed] /= 24
  MASIS_SCROLL_SETTINGS[:scroll_speed] *= 24
end

#==============================================================================
#    Sprite_IconScroll
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This sprite shows the icons of all states and buffs and scrolls through them
#==============================================================================

class Sprite_IconScroll < Sprite_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(viewport, x, y, width, icons = [], icon_hues = [])
    super(viewport)
    @last_paused_ox = 0
    @scroll_pause_time = MASIS_SCROLL_SETTINGS[:pause_time]
    reset(x, y, width, icons, icon_hues)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update
    super
    # If paused, wait until time finishes
    if @scroll_pause_time >= 0
      update_pause
    else
      update_scroll
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Pause
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_pause
    @scroll_pause_time -= 1
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Scroll
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_scroll
    # If flashing through all icons
    if MASIS_SCROLL_SETTINGS[:scroll_speed] == 0
      self.src_rect.x += self.src_rect.width # Go to the next set of icons
      @scroll_pause_time = MASIS_SCROLL_SETTINGS[:pause_time] # Reset pause
      self.src_rect.x = 0 if self.src_rect.x >= bitmap.width
    elsif MASIS_SCROLL_SETTINGS[:scroll_speed] <= 24
      self.src_rect.x += MASIS_SCROLL_SETTINGS[:scroll_speed]
      if self.src_rect.x >= @last_paused_ox + 24 # Make sure stops on an icon
        # If at the point where repeating original icons, reset src_rect.x
        self.src_rect.x = (@last_paused_ox + 24) % @restart_x
        @last_paused_ox = self.src_rect.x
        @scroll_pause_time = MASIS_SCROLL_SETTINGS[:pause_time] # Reset pause
      end
    else
      self.src_rect.x += MASIS_SCROLL_SETTINGS[:scroll_speed]
      @scroll_pause_time = MASIS_SCROLL_SETTINGS[:pause_time] # Reset pause
      self.src_rect.x %= @restart_x
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Dispose
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def dispose
    bitmap.dispose if bitmap
    super
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Reset
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def reset(x, y, width, icons = [], icon_hues = [])
    self.x = x
    self.y = y
    @restart_x = icons.size*24
    src_x = src_rect.x if src_rect
    # Only create the icons buffer if not on Flash All mode.
    w = MASIS_SCROLL_SETTINGS[:scroll_speed] == 0 ? 0 : width
    bitmap.dispose if bitmap
    self.bitmap = Bitmap.new(@restart_x + w, 24)
    # Remember point at which to reset the src_rect
    src_rect.set(src_x ? src_x % @restart_x : 0, 0, width, 24)
    draw_bitmap(icons, icon_hues)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Bitmap
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_bitmap(icons, icon_hues = [])
    # Unless it is simply flashing through each row
    if MASIS_SCROLL_SETTINGS[:scroll_speed] != 0
      # Create a buffer so that it can smoothly scroll
      icons += icons[0, viewport.rect.width / 24]
      icon_hues += icon_hues[0, viewport.rect.width / 24] unless icon_hues.empty?
    end
    # Draw all icons
    icons.each_with_index {|n, i| 
      if icon_hues.size > 0 # Icon Hue Compatibility
        draw_icon_with_hue(n, icon_hues.shift, i*24, 0)
      else
        draw_icon(n, i*24, 0) 
      end
    }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Icon (copied from the default Window_Base method)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_icon(icon_index, x, y)
    iconset = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap.blt(x, y, iconset, rect, 255)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Icon With Hue (Icon Hue Compatibility)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_icon_with_hue(icon_index, icon_hue, x, y)
    iconset = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    # Draw Icon onto small and independent bitmap
    icon_bmp = Bitmap.new(24, 24) 
    icon_bmp.blt(0, 0, iconset, rect)
    icon_bmp.hue_change(icon_hue) # Change hue of icon
    rect.x, rect.y = 0, 0
    bitmap.blt(x, y, icon_bmp, rect, 255)
    icon_bmp.dispose # Dispose Icon Bitmap
  end
end

#==============================================================================
# ** Window_Base
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - initialize; draw_actor_icons; update; dispose
#    new method - dispose_icon_scroll_sprites; update_icon_scroll_sprites
#==============================================================================

class Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias masis_iniz_4hb5 initialize
  def initialize(*args, &block)
    # If an enabled window
    if MASIS_SCROLL_SETTINGS[:windows_enabled].any? {|win_sym| self.is_a?(Kernel.const_get(win_sym)) }
      @iconscroll_sprites = {}            # Initialize Sprite Hash
      @iconscroll_viewport = Viewport.new # Initialize Viewport
    end
    masis_iniz_4hb5(*args, &block) # Run Original Method
    update_icon_scroll_viewport if @iconscroll_viewport
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Actor Icons
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias masis_drwactoric_4jv3 draw_actor_icons
  def draw_actor_icons(actor, x, y, width = 96, *args)
    icons = (actor.state_icons + actor.buff_icons)
    if @iconscroll_sprites
      @iconscroll_sprites.each_pair {|key, val| 
        dispose_icon_scroll_sprites(key) if val.x == x && val.y == y }
    end
    # If icons exceed the space given and this window enables state scroll
    if (width / 24) < icons.size && @iconscroll_sprites
      w = (width / 24) * 24
      icon_hues = []
      if $imported[:MAIcon_Hue] # Icon Hue Compatibility
        for state in actor.states
          icon_hues.push(state.icon_hue) if state.icon_index != 0
        end
      end
      if @iconscroll_sprites[actor.object_id]
        @iconscroll_sprites[actor.object_id].reset(x, y, w, icons, icon_hues)
      else
        dispose_icon_scroll_sprites(actor.object_id) if @iconscroll_sprites[actor.object_id]
        @iconscroll_sprites[actor.object_id] = Sprite_IconScroll.new(@iconscroll_viewport, x, y, w, icons, icon_hues)
      end
    else # Otherwise, resort to default method
      dispose_icon_scroll_sprites(actor.object_id) if @iconscroll_sprites[actor.object_id]
      masis_drwactoric_4jv3(actor, x, y, width, *args) # Run Original Method
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias masis_update_3ed4 update
  def update(*args, &block)
    update_icon_scroll_sprites if @iconscroll_sprites
    update_icon_scroll_viewport if @iconscroll_viewport
    masis_update_3ed4(*args, &block) # Run Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Icon Scroll Sprites
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_icon_scroll_sprites
    return unless @iconscroll_sprites
    @iconscroll_sprites.values.each {|sprite| 
      sprite.update # Update each sprite
      # Match the opacity of the rest of the contents
      sprite.visible = self.visible
      sprite.opacity = self.contents_opacity 
    }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Icon Scroll Viewport
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_icon_scroll_viewport
    return unless @iconscroll_viewport
    # Update Viewport stats to match the contents.
    if viewport
      # Real position of the window
      vrect = viewport.rect
      x = vrect.x - viewport.ox + self.x + padding
      y = vrect.y - viewport.oy + self.y + padding
      w = [width - 2*padding, (vrect.x + vrect.width) - x].min
      h = [height - 2*padding, (vrect.y + vrect.height) - y].min
      @iconscroll_viewport.z = viewport.z + 1
      @iconscroll_viewport.visible = viewport.visible && self.open? && self.visible
    else
      x, y, w, h = self.x + padding, self.y + padding, width - 2*padding, height - 2*padding
      @iconscroll_viewport.z = self.z + 1
      @iconscroll_viewport.visible = self.open? && self.visible
    end
    @iconscroll_viewport.rect.set(x, y, w, h)
    @iconscroll_viewport.ox = self.ox
    @iconscroll_viewport.oy = self.oy
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Dispose Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias masis_disps_1qn6 dispose
  def dispose(*args, &block)
    # Dispose all scroll sprites
    dispose_icon_scroll_sprites(nil) if @iconscroll_sprites 
    @iconscroll_viewport.dispose if @iconscroll_viewport # Dispose the viewport
    masis_disps_1qn6(*args, &block) # Run Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Dispose Icon Scroll Sprite
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def dispose_icon_scroll_sprites(actor_id = nil)
    return unless @iconscroll_sprites
    if !actor_id # If nil, delete all Icon Scroll Sprites
      @iconscroll_sprites.keys.each {|a_id| dispose_icon_scroll_sprites(a_id) }
    elsif @iconscroll_sprites[actor_id] # If a sprite exists for that object
      # Delete the individual's sprite and remove it from the hash
      @iconscroll_sprites[actor_id].dispose 
      @iconscroll_sprites.delete(actor_id)
    end
  end
end