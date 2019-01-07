###--------------------------------------------------------------------------###
#  CP Pop-ups script                                                           #
#  Version 1.2a                                                                #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neon Black                                                #
#  Modified by:                                                                #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V1.2 - 11.10.2012~11.11.2012                                                #
#   Removed info view                                                          #
#   Added state and buff pop-ups                                               #
#   Lots of large changes                                                      #
#  V1.1 - 8.23.2012                                                            #
#   Slight tweaks for later use                                                #
#  V1.0 - 7.15.2012                                                            #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Game_Battler: initialize, regenerate_hp, regenerate_mp,       #
#                              regenerate_tp                                   #
#                Sprite_Battler: update                                        #
#                Window_BattleLog: display_counter, display_reflection,        #
#                                  display_substitute,                         #
#                                  display_action_results, display_failure,    #
#                                  display_critical, display_miss,             #
#                                  display_evasion, display_hp_damage,         #
#                                  display_mp_damage, display_tp_damage        #
#  Overwrites  - Window_BattleLog: display_added_states,                       #
#                                  display_removed_states,                     #
#                                  display_changed_buffs, display_buffs        #
#  New Objects - Game_Battler: create_pop, do_pop, pop_hp, pop_mp, pop_tp,     #
#                              get_popup, pop_reset                            #
#                Sprite_Battler: setup_new_popup, from_viewport,               #
#                                make_pop_hash, pop_types, create_popup,       #
#                                pos_by_type, update_popup,                    #
#                                check_pops_for_nil, find_pos_arc, find_arc,   #
#                                find_pos_raise, find_pos_slow_raise,          #
#                                find_pos_zoom, lowest_point                   #
#                Window_BattleLog: create_state_pop                            #
#                RPG::State: pop_values, set_pop_values                        #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script adds an extra little window to the battle screen when           #
#  selecting an enemy that displays a guage with the enemey's hp, mp, tp, and  #
#  states.  This also adds pop-ups to the enemies when they take damage,       #
#  reflect or counter an attack, or just any other general information that    #
#  may be easier to read as a pop-up than in the battle log window.  You can   #
#  adjust how many of these look with the info below.                          #
###-----                                                                -----###
#      Tags:                                                                   #
#  Several tags can be used in states to change the pop-up text that appears   #
#  when the state is inflicted or removed.  Simply add the tag to a state's    #
#  notebox.  The tags are as follows.                                          #
#                                                                              #
#    pop add[text] - Displays "text" when the state is added.                  #
#    pop remove[text] - Displays "text" when the state is removed.  Leave      #
#                       blank to disable the state.                            #
#                                                                              #
#    pop add color[x] - Changes the pop-up color when the state is added.      #
#    pop remove color[x] - Changes the color of the pop-up when the state is   #
#                          removed.  If "x" is a number, it chooses the color  #
#                          from the windowskin.  If "x" is a word, it chooses  #
#                          the color from the COLOUR hash in the config        #
#                          section.                                            #
#                                                                              #
#    pop add style[type] - Changes the pop-up style when the state is added.   #
#    pop remove style[type] - Changes the pop-up style when the state is       #
#                             removed.  Can be set to any of the following:    #
#                             bounce, zoom, raise, slow_raise                  #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP         # Do not                                                     #
module BATTLEVIEW #  change these.                                             #
#                                                                              #
###-----                                                                -----###
# These are the settings for the pop-up display.  The height is how high from  #
# the origin a pop-up will fly.  Width is how far across vertically it can go  #
# from the origin in either direction.  These settings effect all pop-up       #
# styles.                                                                      #
HEIGHT = 64 # Default = 64                                                     #
WIDTH = 16 # Default = 16                                                      #
#                                                                              #
# These are the font settings for pop-ups.  These affect many of the settings  #
# of all pop-ups overall.                                                      #
POP_SIZE = 32 # Default = 32                                                   #
POP_BOLD = true # Default = true                                               #
#                                                                              #
# To prevent pop-ups from covering each other up, new pop-ups will be offset   #
# based on the text size and appear above the last one.  This value is the max #
# number of times the pop-ups will offset before returning to the bottom.      #
OFFSETS = 4 # Default = 4                                                      #
#                                                                              #
# This hash contains the text that pops up for different situations.  You can  #
# set each of them to different text to change what they say when they pop-up. #
# This hash MUST include :hp, :mp, and :tp.  In each of the tags you can       #
# include "%s" for the default information for the pop up (such as state names #
# or damage numbers).                                                          #
TEXT ={ # Don't edit this line.                                                #

:hp       => "%s",
:mp       => "%s MP",
:tp       => "%s FP",
:counter  => "Counter",
:reflect  => "Reflect",
:sub      => "Stand-in",
:fail     => "Fail",
:critical => "Critical",
:miss     => "Miss",
:evade    => "Evade",
:hpregen  => "+%s HP",
:mpregen  => "+%s MP",
:tpregen  => "+%s FP",
:hpslip   => "-%s HP",
:mpslip   => "-%s MP",
:tpslip   => "-%s FP",
:addstate => "+%s",
:substate => "-%s",
:buff     => "%s Up",
:debuff   => "%s Down",
:rebuff   => "%s Revert",

} # Don't edit this line.                                                      #
#                                                                              #
# This hash contains the colours used by the pop-ups.  Each must contain both  #
# a main colour and an outline colour.  Also note that this hash MUST contain  #
# :null, :hpdamage, :hpheal, :mpdamage, :mpheal, :tpdamage, and :tpheal.  It   #
# can then use any of the other hash values in the hash above except for :hp,  #
# :mp, or :tp.  If a hash value is not defined, null is used instead.          #
COLOUR ={ # Don't edit this line.                                              #

:null     => [Color.new(255, 255, 255), Color.new(  0,   0,   0)],
:hpdamage => [Color.new(255, 255, 255), Color.new(200,   0,   0)],
:hpheal   => [Color.new(255, 255, 255), Color.new( 25, 155,  25)],
:mpdamage => [Color.new(200, 255, 255), Color.new(200,   0,   0)],
:mpheal   => [Color.new(200, 255, 255), Color.new( 25, 155,  25)],
:tpdamage => [Color.new(120, 255, 120), Color.new(200,   0,   0)],
:tpheal   => [Color.new(120, 255, 120), Color.new( 25, 155,  25)],
:hpslip   => [Color.new(255, 255, 255), Color.new(200,   0,   0)],
:hpregen  => [Color.new(255, 255, 255), Color.new( 25, 155,  25)],
:mpslip   => [Color.new(200, 255, 255), Color.new(200,   0,   0)],
:mpregen  => [Color.new(200, 255, 255), Color.new( 25, 155,  25)],
:tpslip   => [Color.new(120, 255, 120), Color.new(200,   0,   0)],
:tpregen  => [Color.new(120, 255, 120), Color.new( 25, 155,  25)],
#                                                                              #
# The following colors are used by different scripts.  Please check the name   #
# of the script directly above the set of colors.                              #
#   CP Enemy Scan v1.1+                                                        #
:weak_pop   => [Color.new(255, 100,   0), Color.new( 50,   0,   0)],
:strong_pop => [Color.new(100, 100, 225), Color.new(  0,   0,  45)],

} # Don't edit this line.                                                      #
#                                                                              #
# The following hash contains the style of each of the pop-ups.  Any tag from  #
# either of the last two hashes may be used except for :null.  If a tag is not #
# present, the pop-up style will be bounce.  The valid styles are:             #
#  :bounce, :raise, :slow_raise, :zoom                                         #
POP_STYLE ={ # Don't edit this line.                                           #

:counter  => :zoom,
:reflect  => :zoom,
:sub      => :zoom,
:fail     => :slow_raise,
:critical => :raise,
:miss     => :slow_raise,
:evade    => :slow_raise,
:addstate => :raise,
:substate => :slow_raise,
:hpregen  => :slow_raise,
:mpregen  => :slow_raise,
:tpregen  => :slow_raise,
:buff     => :raise,
:debuff   => :raise,
:rebuff   => :slow_raise,
#                                                                              #
# The following styles are used by different scripts.  Please check the name   #
# of the script directly above the set of styles.                              #
#   CP Enemy Scan v1.1+                                                        #
:weak_pop   => :raise,
:strong_pop => :slow_raise,

} # Don't edit this line.                                                      #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


end
end

$imported = {} if $imported.nil?
$imported["CP_BATTLEVIEW"] = 1.2

class Game_Battler < Game_BattlerBase
  attr_accessor :popup  ## Allows use of the popup array.
  
  alias cp_bv_initialize initialize
  def initialize
    cp_bv_initialize
    @popup = []  ## Adds the popup array.
  end
  
  def create_pop(text, colour, type = nil)  ## Create a new popup.
    tmp = [text, colour, type]              ## Colour comes form the hash above.
    @popup = [] if @popup.nil?
    @popup.push(tmp)  ## Push the popup to the array.
  end
  
  def do_pop(key, text = "")
    return unless CP::BATTLEVIEW::TEXT.include?(key)  ## Checks text hash.
    string = CP::BATTLEVIEW::TEXT[key] ## Gets the text from the text hash.
    n1 = string.gsub(/%s/, text.to_s)
    n2 = key  ## Sets the colour hash value.
    pop = CP::BATTLEVIEW::POP_STYLE[key]
    create_pop(n1, n2, pop)  ## Sends it to the popup maker.
  end
    
  def pop_hp(dmg)  ## Similar to the above, but with added steps.
    if dmg < 0  ## Check for healing or damage.
      i = dmg * -1  ## Makes damage negative for healing.
      n2 = :hpheal  ## Gets the heal colour hash value.
      pop = CP::BATTLEVIEW::POP_STYLE[:hpheal]
    else
      i = dmg
      n2 = :hpdamage  ## Gets the damage colour hash value.
      pop = CP::BATTLEVIEW::POP_STYLE[:hpdamage]
    end
    pop = CP::BATTLEVIEW::POP_STYLE[:hp] if pop.nil?
    string = CP::BATTLEVIEW::TEXT[:hp]
    n1 = string.gsub(/%s/, i.to_s)  ## Sets the string for damage.
    create_pop(n1, n2, pop)  ## Sends it to the popup maker.
  end
  
  def pop_mp(dmg)
    if dmg < 0
      i = dmg * -1
      n2 = :mpheal
      pop = CP::BATTLEVIEW::POP_STYLE[:mpheal]
    else
      i = dmg
      n2 = :mpdamage
      pop = CP::BATTLEVIEW::POP_STYLE[:mpdamage]
    end
    pop = CP::BATTLEVIEW::POP_STYLE[:mp] if pop.nil?
    string = CP::BATTLEVIEW::TEXT[:mp]
    n1 = string.gsub(/%s/, i.to_s)
    create_pop(n1, n2, pop)
  end
  
  def pop_tp(dmg)
    if dmg < 0
      i = dmg * -1
      n2 = :tpheal
      pop = CP::BATTLEVIEW::POP_STYLE[:tpheal]
    else
      i = dmg
      n2 = :tpdamage
      pop = CP::BATTLEVIEW::POP_STYLE[:tpdamage]
    end
    pop = CP::BATTLEVIEW::POP_STYLE[:tp] if pop.nil?
    string = CP::BATTLEVIEW::TEXT[:tp]
    n1 = string.gsub(/%s/, i.to_s)
    create_pop(n1, n2, :bounce)
  end
  
  def get_popup  ## Gets a popup and removes the bottom one.
    res = @popup[0]  ## Gets the next popup to display.
    @popup = @popup.last(@popup.size - 1)  ## Removes it from the list.
    return res  ## Returns the popup.
  end
  
  def pop_reset
    @popup = []  ## Removes all popups from the list.
  end
  
  alias cp_pop_slip_hp regenerate_hp
  def regenerate_hp
    cp_pop_slip_hp
    if @result.hp_damage < 0
      do_pop(:hpregen, -@result.hp_damage)
    elsif @result.hp_damage > 0
      do_pop(:hpslip, @result.hp_damage)
    end
  end
  
  alias cp_pop_slip_mp regenerate_mp
  def regenerate_mp
    cp_pop_slip_mp
    if @result.mp_damage < 0
      do_pop(:mpregen, -@result.mp_damage)
    elsif @result.mp_damage > 0
      do_pop(:mpslip, @result.mp_damage)
    end
  end
  
  alias cp_pop_slip_tp regenerate_tp
  def regenerate_tp
    cp_pop_slip_tp
    rate = (max_tp * trg).to_i
    if rate > 0
      do_pop(:tpregen, rate)
    elsif rate < 0
      do_pop(:tpslip, rate)
    end
  end
end

class Sprite_Battler < Sprite_Base
  alias cp_bv_update update
  def update
    cp_bv_update
    if @battler && @battler.use_sprite?
      setup_new_popup  ## Sets up popups if sprites are used.
      update_popup
    end
  end
  
  def setup_new_popup
    unless @battler.popup.empty?  ## Only makes popups for enemies.
      create_popup(@battler.get_popup)  ## Sorry sideview battles.
      update_popup
    end
  end
  
  def from_viewport
    return @viewport4.nil? ? viewport : @viewport4
  end
  
  def make_pop_hash
    if @pop_sprite.nil?  ## Holds sprites in an array.
      @pop_sprite = {}
      pop_types.each {|type| @pop_sprite[type] = [] }
    end
  end
  
  def pop_types
    [:bounce, :raise, :slow_raise, :zoom]
  end
  
  def create_popup(pop)  ## Creates the popup sprite.
    type = pop_types.include?(pop[2]) ? pop[2] : pop_types[0]
    make_pop_hash
    sprite = ::Sprite.new(from_viewport)  ## Makes a new sprite.
    sprite.bitmap = Bitmap.new(240, 64)  ## Makes the sprite bitmap.
    if pop[1].is_a?(Symbol)  ## Pop colour.
      n = CP::BATTLEVIEW::COLOUR.include?(pop[1]) ? pop[1] : :null
      c1 = CP::BATTLEVIEW::COLOUR[n][0]
      c2 = CP::BATTLEVIEW::COLOUR[n][1]
    elsif pop[1].is_a?(Integer)
      n = pop[1]
      c1 = Cache.system("Window").get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
      c2 = Font.default_out_color
    else
      c1 = Font.default_color
      c2 = Font.default_out_color
    end
    sprite.bitmap.font.color.set(c1)  ## Text.
    sprite.bitmap.font.out_color.set(c2)  ## Outline.
    sprite.bitmap.font.bold = CP::BATTLEVIEW::POP_BOLD  ## Makes the text bold.
    sprite.bitmap.font.size = CP::BATTLEVIEW::POP_SIZE  ## Sets the font size.
    numb = sprite.bitmap.text_size(pop[0]).height
    sprite.ox = sprite.bitmap.width / 2  ## Sets the sprite's center.
    sprite.oy = (sprite.bitmap.height + numb) / 2
    sprite.bitmap.draw_text(0, 0, 240, 64, pop[0], 1)  ## Draws the bitmap.
    i = rand(2)  ## Chooses left or right movement for the sprite.
    pl = i == 1 ? rand * 1 : rand * -1  ## Sets max offset.
    frame = 1  ## Frame for the sprite.
    pos =  pos_by_type(frame, pl, type) ## Finds the on screen position.
    sprite.x = pos[0]  ## Moves the sprite.
    sprite.y = pos[1] - (@pop_sprite[type].size % CP::BATTLEVIEW::OFFSETS) * CP::BATTLEVIEW::POP_SIZE
    sprite.zoom_x = pos[2]  ## Zooms the sprite.
    sprite.zoom_y = pos[3]
    sprite.z = z + 350  ## Changes the sprite's Z position.
    first = @pop_sprite[type].last(CP::BATTLEVIEW::OFFSETS).index(nil)
    if first
      if @pop_sprite[type].size < CP::BATTLEVIEW::OFFSETS
        @pop_sprite[type][first] = [sprite, frame, pl, type]
      else
        @pop_sprite[type][CP::BATTLEVIEW::OFFSETS - first] = [sprite, frame, pl, type]
      end
    else
      @pop_sprite[type].push([sprite, frame, pl, type])  ## Adds the sprite to an array.
    end
  end
  
  def pos_by_type(frame, pl, type)
    case type
    when :bounce
      find_pos_arc(frame, pl)
    when :raise
      find_pos_raise(frame, pl)
    when :slow_raise
      find_pos_slow_raise(frame, pl)
    when :zoom
      find_pos_zoom(frame, pl)
    else
      find_pos_arc(frame, pl)
    end
  end
  
  def update_popup
    deltree = {}  ## Sets sprites to delete this turn.
    make_pop_hash
    @pop_sprite.each do |type, array|
      next if array.empty?  ## Return if no sprites.
      array.each_with_index do |sprite, i|
        next unless sprite
        sprite[0].opacity = 255  ## Sets the sprite's opacity.
        sprite[1] += 1  ## Update the sprite's frame.
        if sprite[1] >= 70  ## Prepare to delete.
          deltree[type] = [] if deltree[type].nil?
          deltree[type].push(i)
        end
        if sprite[1] >= 60  ## Begins to fade at frame 60.
          n = 70 - sprite[1]
          n *= 25
          sprite[0].opacity = n
        end
        pos = pos_by_type(sprite[1], sprite[2], sprite[3])  ## Gets the position.
        sprite[0].x = pos[0]  ## Moves the sprite.
        sprite[0].y = pos[1] - (i % CP::BATTLEVIEW::OFFSETS) * CP::BATTLEVIEW::POP_SIZE
        sprite[0].zoom_x = pos[2]  ## Zooms the sprite.
        sprite[0].zoom_y = pos[3]
      end
    end
    deltree.each do |type, array|
      array.each do |dm|
        @pop_sprite[type][dm][0].dispose
        @pop_sprite[type][dm] = nil
      end
      while @pop_sprite[type].size > CP::BATTLEVIEW::OFFSETS
        if check_pops_for_nil(type)
          @pop_sprite[type] = @pop_sprite[type].last(@pop_sprite[type].size - 4)
        else
          break
        end
      end
    end
    @pop_sprite.each do |type, array|
      @pop_sprite[type] = [] if array.compact.empty?
    end
  end
  
  def check_pops_for_nil(type)
    CP::BATTLEVIEW::OFFSETS.times do |i|
      return false unless @pop_sprite[type][i].nil?
    end
    return true
  end
  
  def find_pos_arc(frame, pl)  ## Finds the sprite position.
    rw = CP::BATTLEVIEW::WIDTH * pl  ## Gets the grid to use.
    rh = CP::BATTLEVIEW::HEIGHT
    rx = x  ## Gets the origin X and Y.
    im = lowest_point
    ry = [y - height * 0.3, im].min
    ra = [(frame * 9), 180].min  ## Finds the position on an arc.
    ax, ay = find_arc(rw, rh, ra, frame)
    ix = rx + ax  ## Places the arc on the grid.
    iy = ry - ay
    if frame > 20
      rw2 = rw / 2
      rh2 = rh / 2
      ra2 = [((frame - 20) * 9), 180].min
      ax2, ay2 = find_arc(rw2, rh2, ra2, frame - 20)
      ix += (ax2 - rw2)
      iy -= ay2
    end
    return [ix, iy, 1.0, 1.0]  ## Returns the positions.
  end
  
  def find_arc(rw, rh, ra, frame)  ## Gets X and Y of the arc pos.
    sx = (rw * Math.cos((45 + 0.5 * ra) * Math::PI / 180))
    sy = rh * Math.sin(ra * Math::PI / 180)
    sy = (sy * -1) / 3 if sy < 0
    return [sx, sy]
  end
  
  def find_pos_raise(frame, pl)
    rx = x
    b = [y - height / 2, lowest_point].min
    ry = b - CP::BATTLEVIEW::HEIGHT * (1 - ((70 - frame) ** 12).to_f / (70 ** 12))
    return [rx, ry, 1.0, 1.0]
  end
  
  def find_pos_slow_raise(frame, pl)
    rx = x
    b = [y - height / 2, lowest_point].min
    ry = b - CP::BATTLEVIEW::HEIGHT * (frame.to_f / 70)
    return [rx, ry, 1.0, 1.0]
  end
  
  def find_pos_zoom(frame, pl)
    zoom = 3.0 - [frame.to_f, 10.0].min / 5
    ry = [y - height / 2, lowest_point].min + CP::BATTLEVIEW::POP_SIZE *
         (1 - [frame.to_f, 10.0].min / 10)
    return [x, ry, zoom, zoom]
  end
  
  def lowest_point
    $imported["CP_BATTLEVIEW_2"] ? Graphics.height - 120 : Graphics.height
  end
end

class Window_BattleLog < Window_Selectable
  alias cp_bv_display_counter display_counter
  def display_counter(target, item)  ## Aliased to create a popup.
    target.do_pop(:counter)  ## Sets the popup.
    cp_bv_display_counter(target, item)  ## Displays normally.
  end  ## Identical to the next few.
  
  alias cp_bv_display_reflection display_reflection
  def display_reflection(target, item)
    target.do_pop(:reflect)
    cp_bv_display_reflection(target, item)
  end
  
  alias cp_bv_display_substitute display_substitute
  def display_substitute(substitute, target)
    substitute.do_pop(:sub)
    cp_bv_display_substitute(substitute, target)
  end
  
  alias cp_bv_display_action_results display_action_results
  def display_action_results(target, item)
    cp_bv_display_action_results(target, item)
    if target.result.used  ## Resets popups at the end of the log.
      target.pop_reset
    end
  end
  
  alias cp_bv_display_failure display_failure
  def display_failure(target, item)
    if target.result.hit? && !target.result.success
      target.do_pop(:fail)
      cp_bv_display_failure(target, item)
    end
  end
  
  alias cp_bv_display_critical display_critical
  def display_critical(target, item)
    if target.result.critical
      target.do_pop(:critical)
      cp_bv_display_critical(target, item)
    end
  end
  
  alias cp_bv_display_miss display_miss
  def display_miss(target, item)
    target.do_pop(:miss)
    cp_bv_display_miss(target, item)
  end
  
  alias cp_bv_display_evasion display_evasion
  def display_evasion(target, item)
    target.do_pop(:evade)
    cp_bv_display_evasion(target, item)
  end
  
  alias cp_bv_display_hp_damage display_hp_damage
  def display_hp_damage(target, item)
    return if target.result.hp_damage == 0 && item && !item.damage.to_hp?
    target.pop_hp(target.result.hp_damage)
    cp_bv_display_hp_damage(target, item)
  end
  
  alias cp_bv_display_mp_damage display_mp_damage
  def display_mp_damage(target, item)
    return if target.dead? || target.result.mp_damage == 0
    target.pop_mp(target.result.mp_damage)
    cp_bv_display_mp_damage(target, item)
  end
  
  alias cp_bv_display_tp_damage display_tp_damage
  def display_tp_damage(target, item)
    return if target.dead? || target.result.tp_damage == 0
    target.pop_tp(target.result.tp_damage)
    cp_bv_display_tp_damage(target, item)
  end
  
  def display_added_states(target)
    target.result.added_state_objects.each do |state|
      state_msg = target.actor? ? state.message1 : state.message2
      target.perform_collapse_effect if state.id == target.death_state_id
      if state.pop_values[4]
        create_state_pop(target, state, :addstate)
      else
        target.do_pop(:addstate, state.name) unless state.name.empty?
      end
      next if state_msg.empty?
      replace_text(target.name + state_msg)
      wait
      wait_for_effect
    end
  end
  
  def display_removed_states(target)
    target.result.removed_state_objects.each do |state|
      if state.pop_values[4]
        create_state_pop(target, state, :substate)
      else
        target.do_pop(:substate, state.name) unless state.name.empty?
      end
      next if state.message4.empty?
      replace_text(target.name + state.message4)
      wait
    end
  end
  
  def create_state_pop(target, state, key)
    n1 = key == :addstate ? state.pop_values[0] : state.pop_values[1]
    n2 = state.pop_values[2]; pop = state.pop_values[3]
    return if (n1.nil? && !CP::BATTLEVIEW::TEXT.include?(key)) || state.name.empty?
    n1 = CP::BATTLEVIEW::TEXT[key].gsub(/%s/, state.name.to_s) if n1.nil?
    n2 = key if n2.nil?
    pop = CP::BATTLEVIEW::POP_STYLE[key] if pop.nil?
    target.create_pop(n1, n2, pop)
  end
  
  def display_changed_buffs(target)
    display_buffs(target, target.result.added_buffs, Vocab::BuffAdd, :buff)
    display_buffs(target, target.result.added_debuffs, Vocab::DebuffAdd, :debuff)
    display_buffs(target, target.result.removed_buffs, Vocab::BuffRemove, :rebuff)
  end
  
  def display_buffs(target, buffs, fmt, pop = nil)
    buffs.each do |param_id|
      target.do_pop(pop, Vocab::param(param_id))
      replace_text(sprintf(fmt, target.name, Vocab::param(param_id)))
      wait
    end
  end
end

class RPG::State < RPG::BaseItem
  def pop_values
    set_pop_values if @pop_values.nil?
    return @pop_values
  end
  
  def set_pop_values
    @pop_values = [nil, nil, nil, nil, false]
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when /pop add\[(.*)]/i
        @pop_values[0] = $1.to_s
        @pop_values[4] = true
      when /pop remove\[(.*)]/i
        @pop_values[1] = $1.to_s
        @pop_values[4] = true
      when /pop color\[(\d*)(\w*)\]/i
        n = $1.to_s != "" ? $1.to_i : nil
        s = $2.to_sym
        @pop_values[2] = n.nil? ? s : n
        @pop_values[4] = true
      when /pop style\[(\w+)\]/i
        @pop_values[3] = $1.to_sym
        @pop_values[4] = true
      end
    end
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###