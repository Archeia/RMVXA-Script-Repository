=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
#==============================================================================
# EST - RING SYSTEM
#==============================================================================
# Author  : Estriole
# Version : 1.3
#==============================================================================

  #==============================================================================
  # Boneless R.I.B.S. [Ring Only] VX
  #==============================================================================
  # Author  : OriginalWij
  # Version : 1.0
  #==============================================================================

    #========================================================================#
    # Draw Line VX                                                           #
    #========================================================================#
    # Author  : modern algebra                                               #
    # Version : 1.0                                                          #
    #========================================================================#    
      
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2014.06.12     >     Initial Release
 v1.1 2014.06.12     >     fix the logic for [good_count, crit_count] setting.
                           compatibility patch to THEO battle system
 v1.2 2014.06.13        MAJOR UPDATE
                     >     change how the ring drawn so you can use the transparent 
                           color for wedge without seeing behind the ring.
                     >     add configuration for ring z value
                     >     dispose the ring image correctly instead hiding it only
                     >     Bugfix enemy cannot damage the actor
                     >     change setting symbol :barspeed to :bar_speed so it match :add_wedge,etc
                     >     compatibility with Theo SBS
                           split the "ring setting grab" and "ring call". then save it
                           so we can use it in the middle of attack (if using Theo SBS)
                     >     remove the <anim_first> notetags for now. (might add it later)
                     >     add ring setting replace and ring setting mod feature
                           actor / class / equipment / states can affect ring settings
                           replace can only used once (priority: states > equip > class > actor)
                           while mod stacks.
                     >     add $imported["EST - RING SYSTEM"] variable for other scripter to
                           make compatibility patch.
                     >     change the Graphic.update and Input.update to update_basic.
                           so the scene not freeze. more compatible with victor animated battle
                           and Theo SBS now.
 v1.3 2014.06.14     >     add $game_system.ring_active to check the ring currently running or not.
                     >     add method to reset ring miss/crit/null evade.

                           
 ■ License        ╒═════════════════════════════════════════════════════════╛
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE).
 
 This script written based (also take some code) from Boneless RIBS (Ring Only) VX
 script written by OriginalWij (which have some draw line code from modern algebra)
 so you need to credit both (OriginalWij and modern algebra) too if you want to use
 this script
 
 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
    This script create ring system where you need to hit the ring in the right 
 spot to achieve certain result you configured. you can use this system for 
 eventing OR for battle.
 
 This script written by request of Lionheart_84 from www.rpgmakervxace.net

 ■ Requirement     ╒═════════════════════════════════════════════════════════╛
   Just RPG MAKER VX ACE program :D 

 ■ Compatibility     ╒═════════════════════════════════════════════════════════╛
 battle system that i already tested:
 > Default Battle System
 > Yanfly Ace Battle Engine
 > MOGHUNTER battle system
 > Victor Animated battle system
 > Theo Sideview Battle System (ring repeat feature not compatible but INSTEAD 
                                you can change the whole skill sequence based 
                                on ring result !!)
                                 
 tell me if there's other battle system compatible or not so i can add it to
 this list. :D.
   
 ■ How to Use     ╒═════════════════════════════════════════════════════════╛   
 ================================================================================
  Event Script Commands:
 ================================================================================
  Place any of the following script commands in an event 'script' box:
  [Event Commands : Page 3 : Bottom-Right-Most Button]
 ================================================================================
 1)  To call the ring on the map:

       do_ring(x, y, wedge, degrees, times)
       
    x : X coordinate of the Ring (upper left corner)
    y : Y coordinate of the Ring (upper left corner)
    wedge : wedge-set (wedge size & placement array) [start1, stop1, start2, stop2, ...]
    degrees : degrees to start the ring bar at (default = 0)
    times : how many rotation before the ring end (default = 3)

  NOTE: The only real limit on the number of start/stop pairings in the wedge
       is how many you can fit in 360°. [practical limit = 10]

  THE RESULT WILL BE SAVED IN VARIABLES YOU DEFINE IN THE MODULE BELOW !!!!!
  so you can use that for eventing in conditional branch easily.

  RING_HIT_COUNT_VAR => variable you set here will save any hit (good or crit)
  GOOD_COUNT_VAR => variable you set here will save the GOOD hit
  CRIT_COUNT_VAR => variable you set here will save the CRIT hit
  SCORE_COUNT_VAR => variable you set here will save the score (good hit = 1, crit hit = 2)
       
  NOTE2: GOOD hit mean you hit it in normal zone. CRIT hit mean you hit it in
         stike zone.
         
  THE RESULT ALSO SAVED IN $game_system 
  (for example if you want to use it in Theo SBS :if sequence)
  $game_system.ring_hit_count   => store value of any hit (good or crit)
  $game_system.good_count       => store value of good hit 
  $game_system.crit_count       => store value of crit hit 
  $game_system.score_count      => store the score (good hit = 1, crit hit = 2)
         
 2)  To change the bar speed:
       $game_system.bar_speed = new_bar_speed
       
 3)  To disable strike zones (for next ring call only) (as used in Shops)
       $game_system.no_strike = true
       
 4)  To modify the size of strike size
       $game_system.strike_size = value
     the strike size here mean percentage from the wedge size that count as crit/strike
       
 ================================================================================
  SKILL / ITEM Notetags:
 ================================================================================

 1)  To make skill / item use ring system add this notetags:

    <use_ring>

 2)  You can customize each skill/item RING by adding this notetags:
    <ring_setting>
    :x => a,
    :y => b,
    :wedge => c,
    :bar_speed => d,
    :strike=> e,
    :no_strike => f,
    </ring_setting>
    
    a: coordinate x of the ring (number)
    b: coordinate y of the ring (number)
    c: array that will determine the wedge. format:
       [start1, stop1, start2, stop2, ...]
       for example: [10,50,70,120]
       first wedge will be between 10 - 50 degree
       second wedge will be between 70 - 120 degree
    d: rotation speed of the bar
    e: percentage of the strike zone based on wedge zone (1-99) (number)
    f: true -> the ring will have no strike zone
       false -> the ring will have strike zone (default: false)
    
    [everything optional]
       
    example notetags:
    <ring_setting>
    :x=> 10,
    :y=> 10,
    :wedge=>[10,80, 120,170],
    :bar_speed=>4,
    :strike=> 10,
    </ring_setting>
    
    will put the ring at coordinate x:10 y:10. also have two wedge [10,80] and [120,170]
    and have the rotation speed of 4. also the strike zone will be 10% of wedge zone.

  WARNING : DO NOT FORGET THE COMA AFTER EACH SETTING ENTRY!!!
  
 3)  You can have the skill MISS when the number of good/crit hit below certain value:
    IGNORE skill setting in database that make you ALWAYS HIT
    
    <ring_miss: x>
    
    x: number of hits MINIMUM so the skill WON'T miss
    
    example notetags:
    <ring_miss: 1>   => you have to hit at least 1 good OR crit hit.

 4)  You can have the skill 100% CRIT when the number of CRIT hit the 
    same or above certain value
    
    <ring_crit: x>
    
    x: number of CRIT hits REQUIRED so the skill 100% CRITICAL.
    
    example notetags:
    <ring_crit: 2>   => you have to hit at least 2 CRIT hit to 100% critical.
    
 5)  You can have the skill/item NULLIFY TARGET EVADE (mean the skill will ignore evade)
    when the number of good OR crit hit same or above certain value
    NOTE: you can still miss if your hit rate suck. but the enemy cannot evade.
    if you want certain hit just set the skill to always hit in database.
    don't worry. ring_miss notetags ignore that. so you can still miss.
    
    <ring_null_evade: x>
    
    x: number of good OR crit hit required to NULLIFY TARGET EVADE
    
    example notetags:
    <ring_null_evade: 3> => you have to hit at least 3 (either good/crit) times

 6)  You can have the skill/item NULLIFY TARGET EVADE (mean the skill will ignore evade)
    when the number of CRIT hit (ONLY) same or above certain value
    NOTE: you can still miss if your hit rate suck. but the enemy cannot evade.
    if you want certain hit just set the skill to always hit in database.
    don't worry. ring_miss notetags ignore that. so you can still miss.
    
    <ring_crit_null_evade: x>
    
    x: number of good OR crit hit required to NULLIFY TARGET EVADE
    
    example notetags:
    <ring_crit_null_evade: 1> => you have to hit at least 1 CRIT

 7)  You can modify how many times the skill REPEATS (like in database repeat times).
    when you met certain requirement:
      
    <ring_repeats>
    key => value,
    </ring_repeats>

    key => you have two format that you can use:
           array system -> [good_hit, crit_hit] ex: [1,1]
           score system -> good hit = 1, crit hit = 2 ex: 3
           
           array system setting have HIGHER priority than score system.
           so if the both condition met it will use array system setting.
           
    value => number of hits
    
    example notetags:
    <ring_repeats>
    [1,0] => 2,
    [1,1] => 3,
    [0,2] => 10,
    3 => 20,
    </ring_repeats>
    
    means:
    1 good hit only => 2 hits
    1 good hit + 1 crit hit => 3 hits
    2 crit hits => 10 hits 
    3 score => 20 hits
    
    (assuming you have 3 set of wedge)
    as you can see... there's many way of achieving 3 score.
    example: 1 good + 1 crit OR 3 good  
    so in case above. you will only get 20 repeats ONLY if you get 3 good.
    since you have another setting for 1 good + 1 crit using array system.
    it will prioritize it.
  
  WARNING : DO NOT FORGET THE COMA AFTER EACH SETTING ENTRY!!!
  NOTE : putting 0 or negative value will make the skill weird. 
  just use ring_miss feature instead.
  NOTE2 : this can BYPASS the database limit of 9 hits
  
 8) You can modify the damage formula for the skills based on the ring result.

 > first add this inside the DAMAGE FORMULA of the SKILL / ITEM:
  (the capital word means you need to replace it with your own)
  (the other text stay at it is. don't change it at all)
  
  a.ring(a,b,DEFAULT_FORMULA)

  DEFAULT_FORMULA => formula that will be use by the enemy or when there's 
                     no setting for the ring result.
                     
  example: a.ring(a,b,a.atk * 4 - b.def * 2)
                     
 > then add this notetags in the skill/item notes
    <ring_result>
    key => formulainstring,
    </ring_result>
    key => you have two format that you can use:
           array system -> [good_hit, crit_hit] ex: [1,1]
           score system -> good hit = 1, crit hit = 2 ex: 3
           
           array system setting have HIGHER priority than score system.
           so if the both condition met it will use array system setting.
           
    formulainstring => your formula as string (inside "")
    there's shortcut letter that you can use for the formula:
    a = skill/item user
    b = skill/item target
    v = $game_variables
    s = $game_switches
    pt = $game_party
    l = $game_party.leader   
    f = default formula you enter inside DAMAGE FORMULA as explained above
    id = current_action.item.id
    sk = current skill/item (RPG::Skill or RPG::Item object)

    example notetags:
    <ring_result>
    [0,0] => "f/2",
    [1,0] => "f",
    [0,1] => "f + 1000",
    [1,1] => "f*2 + 1000",
    3 => "1000000",
    </ring_result>    
    
    means:
    when miss entirely => default formula / 2
    1 good hit only => default formula
    1 crit hit only => default formula + 1000 damage
    1 good hit + 1 crit hit => default formula x 2 + 1000 damage
    3 score => 1000000 damage
    
    (assuming you have 3 set of wedge)
    as you can see... there's many way of achieving 3 score.
    example: 1 good + 1 crit OR 3 good  
    so in case above. you will only get 1000000 damage ONLY if you get 3 good.
    since you have another setting for 1 good + 1 crit using array system.
    it will prioritize it.
  
  WARNING : DO NOT FORGET THE COMA AFTER EACH SETTING ENTRY!!!
    
 ================================================================================
    v 1.2 MAJOR UPDATE
    
    Ring Setting Replace and Ring Setting Mod feature
    
 ===============================================================================   
    WARNING: this feature is a harder to use. need a little bit scripting 
    understanding like knowledge about HASH format.
    this feature also consume quite space on the NOTETAGS. :D. sorry.
 ===============================================================================
 
    you can add notetags in: actor, class, equipment, state and it can affect
    the ring.
    
  1) Ring replace feature. this will REPLACE the ring setting in the skill notetags.
  ONLY one change can be done (unfortunately). if multiple changes done. it will use this concept:
  
  state > equipment > class > actor
  
  the latest state would take more priority than the earlier state
  the lower equipment would take more priority than the upper equipment
  
  put this notetags:
  
  <ring_setting_replace>
  key => hash,
  </ring_setting_replace>
   
  key: [:skill]  -> means this affect ALL skills
       [:item]   -> means this affect ALL items
       [:skill,id] -> change id to any number and it only affect skill with that id
       [:item,id] -> change id to any number and it only affect skill with that id
  hash: this hash format like the ring_setting notetags above:
        {
        :x => a,
        :y => b,
        :wedge => c,
        :bar_speed => d,
        :strike=> e,
        :no_strike => f,
        },
    a: coordinate x of the ring (number)
    b: coordinate y of the ring (number)
    c: array that will determine the wedge. format:
       [start1, stop1, start2, stop2, ...]
       for example: [10,50,70,120]
       first wedge will be between 10 - 50 degree
       second wedge will be between 70 - 120 degree
    d: rotation speed of the bar
    e: percentage of the strike zone based on wedge zone (1-99) (number)
    f: true -> the ring will have no strike zone
       false -> the ring will have strike zone (default: false)
   
  example usage:    
  <ring_setting_replace>
  [:skill] => {
  :x => 10,
  :y => 10,
  :wedge => [10,50,70,120,150,200],
  :bar_speed => 4,
  },
  </ring_setting_replace>
  will replace ALL skill ring setting to this settings:
  x = 10, y = 10, wedge = [10,50,70,120,150,200] and bar speed of 4
  
  another example:
  <ring_setting_replace>
  [:skill,1] => {
  :x => 10,
  :y => 10,
  :wedge => [10,50,70,120,150,200],
  :bar_speed => 4,
  },
  [:skill,2] => {
  :x => 10,
  :y => 10,
  :wedge => [10,50,70,120,150,200],
  :bar_speed => 4,
  },
  </ring_setting_replace>
  the same as above but it will ONLY change ring setting for SKILL 1 and SKILL 2
  (you can have different changes for the skill 1 and 2 if you want)
  
  WARNING: DO NOT FORGET THE COMA. you need to understand how hash works !!
  
  IDEA OF IMPLEMENTATION:
  > you can put the ring setting replace notetags for each actor.
  and each actor will have DIFFERENT RINGS.
  > put it in class... it's the same as above actually... not new idea...
  > put it in equipment -> equip this and your skill will become 
                           super large wedges style ring.
  
  2) Ring Setting Mod feature. we can have equipment that alter the way
  the ring setting works. THIS FEATURE STACKS. so you can have multiple mods
  and it added up together (except no_strike setting. it will take the latest entry).
  
  RING SETTING MOD takes effect AFTER RING SETTING REPLACE. 
  so you can combine BOTH feature !!!!!
  
  to use this feature... add this note to actor / class / equip / state notetags:
  <ring_setting_mod>
  key => hash,
  </ring_setting_mod>

  key: [:skill]  -> means this affect ALL skills
       [:item]   -> means this affect ALL items
       [:skill,id] -> change id to any number and it only affect skill with that id
       [:item,id] -> change id to any number and it only affect skill with that id
  hash: this hash format like the ring_setting notetags above:
        {
        :x => a,
        :y => b,
        :add_wedge => c,
        :add_wedge => d,
        :bar_speed => e,
        :strike=> f,
        :no_strike => g,
        },
    a: coordinate x OFFSET can be plus or minus number
    b: coordinate y OFFSET can be plus or minus number
    c: wedge set that to be add to the array (must be array of two. ex: [100, 130]
       the first member must be smaller than second member. also you cannot
       have one member already included in wedge set while the other not.
       it can break the wedge. (wedge set must be set of two)
    d: wedge set that to be removed to the array (any number here will remove from wedge set array)
       be careful! it can break the wedge entirely. if used incorrectly.
    e: rotation speed of the bar OFFSET. can be plus or minus number
    f: percentage of the strike zone OFFSET. can be plus or minus number
    g: true -> the ring will have no strike zone
       false -> the ring will have strike zone (default: false)
  
  example usage:
  since this mod the ring (not replacing it). you can only have 1 or 2 entry.
  not like the replace feature above that require you to complete the setting.
  
  <ring_setting_mod>
  [:skill] =>{
  :bar_speed => -100,
  },
  </ring_setting_mod> 
  it will slow all skills bar speed by 100 points.
  
  another example:
  <ring_setting_mod>
  [:skill,1] =>{
  :bar_speed => -100,
  :x => 15,
  :y => -15,
  :add_wedge => [10,30],
  },
  </ring_setting_mod> 
  it will modify skill 1 only. reducing bar speed by 100 point
  mod the x coordinate +15 point. mod the y coordinate -15 point.
  add a new wedge set [10,30]  
  
  IDEA FOR IMPLEMENTATION:
  you can create accessory that slow down the bar speed.
  you can create cursed equipment that make bar speed faster and make the wedge smaller.
  
  WARNING: DO NOT FORGET THE COMA. you need to understand how hash works !!  
  
  WARNING: this two feature can be confusing to configure. you need to really
  keep track record on how each character rings look like.
  
 ===============================================================================
 for scripters: to check the ring currently active or not:
 $game_system.ring_active
 it will return true when the ring still there.
  
 ■ Future Plan     ╒═════════════════════════════════════════════════════════╛   
 > scene for modifying rings freely using soul fragment
 (requested by lionheart). but this take least priority because it will be hard
 
=end

$imported = {} if $imported.nil?
$imported["EST - RING SYSTEM"] = true

module ESTRIOLE
  module OW_RIBS
  
  # RING
  # Ring skin image filename [default = 'Default_Ring']
  RING_SKIN = 'Default_Ring'
  # Ring size (ring-skin width & height} [default = 192]
  RING_SIZE = 192
  # Strike 'wedge' size (as a percent [%] of the main 'wedge') [default = 20]
  STRIKE_SIZE = 20
  RING_Z = 1000
  
  # POSITION BAR
  # Bar rotation speed (in degrees, higher number = faster) [default = 2]
  BAR_SPEED = 2
  # Bar size (also 'wedge' radius) [default = 72]
  BAR_SIZE = 72
    
  # COLOR
  # Bar color [default = Color.new(0, 0, 255)]
  BAR_COLOR = Color.new(0, 120, 255)  
  # 'Wedge' color [default = Color.new(255, 0, 0, 200)]
  WEDGE_COLOR = Color.new(255, 0, 0,200)
  # 'Wedge' color (when strike activated) [default = Color.new(0, 255, 255, 200)]
  STRIKE_COLOR = Color.new(0, 255, 255, 200)
  # Strike 'wedge' color [default = Color.new(255, 128, 0, 200)]
  STRIKE = Color.new(255, 128, 0,200)
  # Strike 'wedge' active color [default = Color.new(255, 255, 0, 200)]
  STRIKE_ACTIVE = Color.new(255, 255, 0,200)
  # Activated 'wedge' color [default = Color.new(0, 255, 0, 200)]
  ACTIVE = Color.new(0, 255, 0,200)

  # SOUNDS
  
  # Sound to play on a CORRECT button press [default = 'Audio/SE/Chime2']
  BUTTON_SOUND = 'Audio/SE/Chime2'
  # Sound to play on a CORRECT bonus button press [default = 'Audio/SE/Flash2']
  STRIKE_SOUND = 'Audio/SE/Flash2'
  # Sound to play on an INCORRECT button press [default = 'Audio/SE/Buzzer1']
  BUZZER_SOUND = 'Audio/SE/Buzzer1'
  
  # VARIABLES (For Saving the ring result) Mainly for eventing
  # Variable to store how many hit (crit or not)
  RING_HIT_COUNT_VAR = 97
  # Variable to store how many good hit only (not crit)
  GOOD_COUNT_VAR = 98
  # Variable to store how many crit hit only
  CRIT_COUNT_VAR = 99
  # Variable to store the ring score (good hit = 1 point, crit = 2 point)
  SCORE_COUNT_VAR = 100
  
  # MISCELLANEOUS
  
  # Button to press to activate a wedge [default = Input::C]
  BUTTON = Input::C
  
  # SHARED METHOD
    def reset_ring
      $game_system.score_count = nil
      $game_system.good_count  = nil 
      $game_system.crit_count = nil
      $game_system.ring_hit_count   = nil
      $game_system.current_action = nil
      $game_system.bar_speed = nil
      $game_system.no_strike = nil
      $game_system.strike_size = nil
      $game_system.ring_setting = nil

      $game_system.ring_miss = nil
      $game_system.ring_crit = nil
      $game_system.ring_null_evade = nil
      $game_system.ring_repeats     = nil
    end
    def reset_ring_effect
      $game_system.ring_miss = nil
      $game_system.ring_crit = nil
      $game_system.ring_null_evade = nil
      $game_system.ring_repeats     = nil
    end

  end
end

#===============================================================================
# Bitmap
#===============================================================================

class Bitmap
  #----------------------------------------------------------------------------
  # Draw Line (modified version of Draw Line by modern algebra)
  #----------------------------------------------------------------------------
  def draw_line(x1, y1, x2, y2, color = Color.new(255, 255, 255), width = 1)
    cx = x2 - x1
    cy = y2 - y1
    if cx.abs > cy.abs
      return if cx == 0
      if x2 < x1
        temp = x2
        x2 = x1
        x1 = temp
        temp = y2
        y2 = y1
        y1 = temp
      end
      for i in 0..cx.abs
        y = y1 + cy * i / cx
        set_pixel(x1 + i, y, color)
        if width > 1
          for j in 2..width
            if (j & 1) == 0
              set_pixel(x1 + i, y - j / 2, color)
            else
              set_pixel(x1 + i, y + j / 2, color)
            end
          end
        end
      end
    else
      return if cy == 0
      if y2 < y1
        temp = x2
        x2 = x1
        x1 = temp
        temp = y2
        y2 = y1
        y1 = temp
      end
      for i in 0..cy.abs
        x = x1 + cx * i / cy
        set_pixel(x, y1 + i, color)
        if width != 1
          for j in 2..width
            if j & 1
              set_pixel(x - j / 2, y1 + i, color)
            else
              set_pixel(x + j / 2, y1 + i, color)
            end
          end
        end
      end
    end
  end
end

#==============================================================================
# Game_System
#==============================================================================


#==============================================================================
# Ring_Window (New)
#==============================================================================

class Ring_Window < Window_Base
  #--------------------------------------------------------------------------
  # Include
  #--------------------------------------------------------------------------
  include ESTRIOLE::OW_RIBS
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, radius)
    super(x, y, (radius * 2) + 38, (radius * 2) + 38)
    @radius = BAR_SIZE
    @center = radius
    self.opacity = 0
    self.contents.clear
    self.z = RING_Z
    @ring_bg = Sprite.new
    @ring_bg.bitmap = Cache.system(RING_SKIN)
    @ring_bg.x = x + standard_padding
    @ring_bg.y = y + standard_padding
    @ring_bg.z = RING_Z - 1
    #self.contents = Cache.system(RING_SKIN)
  end
  def dispose
    super
    @ring_bg.bitmap.dispose
    @ring_bg.dispose
    @ring_bg = nil
  end
  #--------------------------------------------------------------------------
  # Draw Wedge
  #--------------------------------------------------------------------------
  def draw_wedge(start, finish, color = WEDGE_COLOR)
    strike = 0
    if start > finish
      for d in start..360
        x = @center + @radius * Math.cos(d * Math::PI / 180)
        y = @center + @radius * Math.sin(d * Math::PI / 180)
        self.contents.draw_line(@center, @center, x, y, color, 3)
      end
      strike += (360 - start)
      start = 0
    end
    for d in start..finish
      x = @center + @radius * Math.cos(d * Math::PI / 180)
      y = @center + @radius * Math.sin(d * Math::PI / 180)
      self.contents.draw_line(@center, @center, x, y, color, 3)
    end
    strike += (finish - start)
    start = finish - strike * $game_system.strike_size / 100
    start.round
    color = STRIKE if color == WEDGE_COLOR
    color = STRIKE_ACTIVE if color == STRIKE_COLOR
    return if $game_system.no_strike
    for d in start..finish
      x = @center + @radius * Math.cos(d * Math::PI / 180)
      y = @center + @radius * Math.sin(d * Math::PI / 180)
      self.contents.draw_line(@center, @center, x, y, color, 3)
    end
  end
end

#==============================================================================
# Bar_Window (New)
#==============================================================================

class Bar_Window < Window_Base
  #--------------------------------------------------------------------------
  # Include
  #--------------------------------------------------------------------------
  include ESTRIOLE::OW_RIBS
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, radius, start)
    super(x, y, (radius * 2) + 38, (radius * 2) + 38)
    self.z = RING_Z
    @radius = radius
    @center = radius
    @last_degrees = start
    self.opacity = 0
    self.contents.clear
    draw_bar(start)
  end
  #--------------------------------------------------------------------------
  # Draw Bar
  #--------------------------------------------------------------------------
  def draw_bar(degrees = 0)
    color = BAR_COLOR
    erase = Color.new(0, 0, 0, 0)
    x = @center + @radius * Math.cos((@last_degrees) * Math::PI / 180)
    y = @center + @radius * Math.sin((@last_degrees) * Math::PI / 180)
    self.contents.draw_line(@center, @center, x, y, erase, 3)
    x = @center + @radius * Math.cos(degrees * Math::PI / 180)
    y = @center + @radius * Math.sin(degrees * Math::PI / 180)
    self.contents.draw_line(@center, @center, x, y, color, 3)
    @last_degrees = degrees
  end
end

#==============================================================================
# Scene_Base
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # Include (New)
  #--------------------------------------------------------------------------
  include ESTRIOLE::OW_RIBS
  def do_ring_auto
      x = $game_system.ring_setting[:x]
      y = $game_system.ring_setting[:y]
      wedge = $game_system.ring_setting[:wedge]
      times = $game_system.ring_setting[:times]
      degrees = $game_system.ring_setting[:degrees]
      SceneManager.scene.do_ring(x,y,wedge,degrees,times)
  end
  def evaluate_ring_auto(item = $game_system.current_action)
      reset_ring_effect
      $game_system.ring_miss = true if item.ring_miss && item.ring_miss > $game_system.ring_hit_count
      $game_system.ring_null_evade = true if item.ring_null_evade && item.ring_null_evade <= $game_system.ring_hit_count
      $game_system.ring_null_evade = true if item.ring_crit_null_evade && item.ring_crit_null_evade <= $game_system.crit_count
      $game_system.ring_crit = true if item.ring_crit && item.ring_crit <= $game_system.crit_count
      $game_system.ring_repeats = item.ring_repeats[$game_system.score_count] rescue nil
      chk = item.ring_repeats[[$game_system.good_count,$game_system.crit_count]] rescue nil
      $game_system.ring_repeats = chk if chk
  end
  #--------------------------------------------------------------------------
  # Do Ring (New)
  #--------------------------------------------------------------------------
  def do_ring(x = 0, y = 0, wedge = [10,30], degrees = 0 , times = 3)
    $game_system.ring_active = true
    times -= 1 if times.is_a?(Numeric)
    count = press_count = wedge_count = good_count = bonus_count = 0
    bx = x + ((RING_SIZE / 2) - BAR_SIZE)
    by = y + ((RING_SIZE / 2) - BAR_SIZE)
    @ring_window = Ring_Window.new(x, y, RING_SIZE / 2)
    @bar_window = Bar_Window.new(bx, by, BAR_SIZE, degrees)
    wedge_count = wedge.size / 2
    size = wedge_count - 1
    pressed = []
    for i in 0..size
      @ring_window.draw_wedge(wedge[i * 2], wedge[i * 2 + 1])
      pressed.push(false)
    end
    for i in 1..30
      update_basic
    end
    speed = $game_system.bar_speed
    loop do
      degrees += speed
      degrees -= 360 if degrees >= 360
      count += speed
      break if count > 360
      @bar_window.draw_bar(degrees)
      update_basic
      old_count = press_count
      if Input.trigger?(BUTTON)
        for i in 0..size
          if wedge[i * 2] > wedge[i * 2 + 1]
            w2 = wedge[i * 2 + 1] + (360 - wedge[i * 2])
            w1 = wedge[i * 2 + 1] - w2 * $game_systems.strike_size / 100
            w2 = wedge[i * 2 + 1]
            if w1 < 0
              w1 = 360 + w1
              if (w1..360) === degrees or (0..w2) === degrees
                color = STRIKE_COLOR
              else
                color = ACTIVE
              end
            else
              color = (w1..w2) === degrees ? STRIKE_COLOR : ACTIVE
            end
            color = ACTIVE if $game_system.no_strike
            if ((wedge[i * 2]..360) === degrees or
                (0..wedge[i * 2 + 1]) === degrees) and !pressed[i]
              p_calc = color == STRIKE_COLOR ? bonus_count : good_count
              pitch = 100 + p_calc * 10
              sound = color == STRIKE_COLOR ? STRIKE_SOUND : BUTTON_SOUND
              Audio.se_play(sound, 100, pitch)
              @ring_window.draw_wedge(wedge[i * 2], wedge[i * 2 + 1], color)
              pressed[i] = true
              good_count += 1
              press_count += 1
              bonus_count += 1 if color == STRIKE_COLOR
            end
          else
            if (wedge[i * 2]..wedge[i * 2 + 1]) === degrees and !pressed[i]
              w2 = wedge[i * 2 + 1]
              w1 = w2 - (w2 - wedge[i * 2]) * $game_system.strike_size / 100
              color = (w1..w2) === degrees ? STRIKE_COLOR : ACTIVE
              color = ACTIVE if $game_system.no_strike
              p_calc = color == STRIKE_COLOR ? bonus_count : good_count
              pitch = 100 + p_calc * 10
              sound = color == STRIKE_COLOR ? STRIKE_SOUND : BUTTON_SOUND
              Audio.se_play(sound, 100, pitch)
              @ring_window.draw_wedge(wedge[i * 2], wedge[i * 2 + 1], color)
              pressed[i] = true
              good_count += 1
              press_count += 1
              bonus_count += 1 if color == STRIKE_COLOR
            end
          end
        end
        if old_count == press_count
          Audio.se_play(BUZZER_SOUND, 100, 100)
          press_count += 1
        end
      end
      if count == 360 && times != 0
        count = 0
        times -= 1 if times.is_a?(Numeric)
      end
      break if count == 360 or press_count == wedge_count
    end
    if press_count == wedge_count
      for i in 1..30
        Graphics.update
      end
    end
    $game_variables[SCORE_COUNT_VAR] = $game_system.score_count = good_count + bonus_count
    $game_variables[RING_HIT_COUNT_VAR] = $game_system.ring_hit_count = good_count
    $game_variables[GOOD_COUNT_VAR] = $game_system.good_count = good_count - bonus_count
    $game_variables[CRIT_COUNT_VAR] = $game_system.crit_count = bonus_count
    
    $game_system.no_strike = false
    @bar_window.dispose if @bar_window
    @ring_window.dispose if @ring_window
    @bar_window = nil
    @ring_window = nil
    $game_system.ring_active = false
    return [good_count, bonus_count]
  end
end

class Game_Battler < Game_BattlerBase
  include ESTRIOLE::OW_RIBS
  
  def ring(a ,b , formula = 0)
   return formula if !self.is_a?(Game_Actor)
   return formula if self.confusion?
   v = $game_variables
   s = $game_switches
   pt = $game_party
   l = $game_party.leader   
   f = formula
   sk = $game_system.current_action
   id = $game_system.current_action.id
   return formula if sk.ring_result == {}   
   chk = eval(sk.ring_result[$game_system.score_count]) rescue nil
   chk = eval(sk.ring_result[[$game_system.good_count,$game_system.crit_count]]) rescue nil if !chk
   return chk if chk
   return formula
  end

  def ring_objects
    return [] if self.is_a?(Game_Enemy)
    actr = [self.actor] rescue []
    cls = [self.class] rescue []
    eqps = equips rescue []
    sts = states rescue []
    objects = actr + cls + eqps + sts
  end
  
  def grab_ring_setting_replace(type = :skill, id = 1)
    note_replace = ""
    ring_objects.reverse.each do |obj|
      if obj && obj.ring_setting_replace[[type]]
      note_replace += "<ring_setting>\r\n"
        obj.ring_setting_replace[[type]].each do |key,value|
        note_replace += ":#{key} => #{value},\r\n"
        end
      note_replace += "</ring_setting>\r\n"
      end
      if obj && obj.ring_setting_replace[[type,id]]
      note_replace += "<ring_setting>\r\n"
        obj.ring_setting_replace[[type,id]].each do |key,value|
        note_replace += ":#{key} => #{value},\r\n"
        end
      note_replace += "</ring_setting>\r\n"
      end
    end
    return note_replace
  end #end def
  
  def grab_ring_setting_mod(type = :skill, id = 1)
    ring_mod = {
    :x=> 0,
    :y=> 0,
    :add_wedge=> [],
    :rem_wedge=> [],
    :bar_speed=> 0,
    :strike=> 0,
    :no_strike => nil,
    }
    ring_objects.reverse.each do |obj|
      if obj && obj.ring_setting_mod[[type]]
        obj.ring_setting_mod[[type]].each do |key,value|
          ring_mod[key.to_sym] += value if key.to_sym != :no_strike
          ring_mod[key.to_sym] = value if key.to_sym == :no_strike
        end
      end
      if obj && obj.ring_setting_mod[[type,id]]
        obj.ring_setting_mod[[type,id]].each do |key,value|
          ring_mod[key.to_sym] += value if key.to_sym != :no_strike
          ring_mod[key.to_sym] = value if key.to_sym == :no_strike
        end
      end      
    end
    return ring_mod
  end
  
end
 

class Scene_Battle < Scene_Base
  
  include ESTRIOLE::OW_RIBS
    
  alias est_ring_use_item use_item
  def use_item
    $game_system.current_action = item = @subject.current_action.item.dup
    type = item.is_a?(RPG::Skill) ? :skill : :item
    item.note = @subject.grab_ring_setting_replace(type,item.id) + item.note
    
    if !@subject.is_a?(Game_Enemy) && !@subject.confusion?
      $game_system.ring_setting = {}
      $game_system.ring_setting[:x] = item.ring_setting[:x] == nil ? 0 : item.ring_setting[:x] rescue 0
      $game_system.ring_setting[:y] = item.ring_setting[:y] == nil ? 0 : item.ring_setting[:y] rescue 0
      $game_system.ring_setting[:strike] = $game_system.strike_size = item.ring_setting[:strike] == nil ? STRIKE_SIZE : item.ring_setting[:strike] rescue STRIKE_SIZE
      $game_system.ring_setting[:no_strike] = $game_system.no_strike = item.ring_setting[:no_strike] rescue nil
      $game_system.ring_setting[:wedge] = item.ring_setting[:wedge] == nil ? [10,60] : item.ring_setting[:wedge] rescue [10,20]
      $game_system.ring_setting[:times] = item.ring_setting[:times] == nil ? 3 : item.ring_setting[:times] rescue 3
      $game_system.ring_setting[:degrees] = item.ring_setting[:degrees] == nil ? 0 : item.ring_setting[:degrees] rescue 0
      $game_system.ring_setting[:bar_speed] = $game_system.bar_speed = item.ring_setting[:bar_speed] == nil ? BAR_SPEED : item.ring_setting[:bar_speed] rescue 2
       @subject.grab_ring_setting_mod(type, item.id).each do |key,value|
         case key.to_sym
         when :strike
           $game_system.strike_size = $game_system.ring_setting[:strike] += value
         when :no_strike
           $game_system.no_strike = $game_system.ring_setting[:no_strike] = value if value
         when :add_wedge
           $game_system.ring_setting[:wedge] += value
         when :rem_wedge
           $game_system.ring_setting[:wedge] -= value
         when :bar_speed  
           $game_system.bar_speed = $game_system.ring_setting[:bar_speed] += value         
         else
         $game_system.ring_setting[key.to_sym] += value
         end
       end
       #prevent the ring speed below 0
      $game_system.ring_setting[:bar_speed] = $game_system.bar_speed = [$game_system.bar_speed,1].max
    end
    
    if item.use_ring && !@subject.is_a?(Game_Enemy) && !@subject.confusion?      
      SceneManager.scene.do_ring_auto
      SceneManager.scene.evaluate_ring_auto
    end
    
    est_ring_use_item
    
    return if $imported[:ve_animated_battle]
    reset_ring
  end
  
  if $imported[:ve_animated_battle]
    alias ring_victor_patch_call_effect call_effect
    def call_effect
      ring_victor_patch_call_effect
      reset_ring
    end
  end
  
end

class RPG::UsableItem < RPG::BaseItem
  def repeats
    return $game_system.ring_repeats if $game_system.ring_repeats
    return @repeats
  end
end

class RPG::BaseItem
  def use_ring
    return false if !note[/<use_ring>/im]
    return true if note[/<use_ring>/im]    
  end
  def ring_miss
    return false if !note[/<ring_miss:([^>]*)>/im]
    a = note[/<ring_miss:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a[0].to_i
  end
  def ring_crit
    return false if !note[/<ring_crit:([^>]*)>/im]
    a = note[/<ring_crit:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a[0].to_i
  end
  def ring_null_evade
    return false if !note[/<ring_null_evade:([^>]*)>/im]
    a = note[/<ring_null_evade:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a[0].to_i
  end
  def ring_crit_null_evade
    return false if !note[/<ring_crit_null_evade:([^>]*)>/im]
    a = note[/<ring_crit_null_evade:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a[0].to_i
  end
  def ring_setting
    return {} if !note[/<ring_setting?>(?:[^<]|<[^\/])*<\/ring_setting?>/i]
    a = note[/<ring_setting?>(?:[^<]|<[^\/])*<\/ring_setting?>/i].scan(/(?:!<ring_setting?>|(.*)\r)/)
    a.delete_at(0)    
    a = a.join("\r\n")
    return noteargs = eval("{#{a}}") rescue {}
  end  
  def ring_setting_replace
    return {} if !note[/<ring_setting_replace?>(?:[^<]|<[^\/])*<\/ring_setting_replace?>/i]
    a = note[/<ring_setting_replace?>(?:[^<]|<[^\/])*<\/ring_setting_replace?>/i].scan(/(?:!<ring_setting_replace?>|(.*)\r)/)
    a.delete_at(0)    
    a = a.join("\r\n")
    return noteargs = eval("{#{a}}") rescue {}
  end  
  def ring_setting_mod
    return {} if !note[/<ring_setting_mod?>(?:[^<]|<[^\/])*<\/ring_setting_mod?>/i]
    a = note[/<ring_setting_mod?>(?:[^<]|<[^\/])*<\/ring_setting_mod?>/i].scan(/(?:!<ring_setting_mod?>|(.*)\r)/)
    a.delete_at(0)    
    a = a.join("\r\n")
    return noteargs = eval("{#{a}}") rescue {}
  end  
  def ring_result
    return {} if !note[/<ring_result?>(?:[^<]|<[^\/])*<\/ring_result?>/i]
    a = note[/<ring_result?>(?:[^<]|<[^\/])*<\/ring_result?>/i].scan(/(?:!<ring_result?>|(.*)\r)/)
    a.delete_at(0)    
    a = a.join("\r\n")
    return noteargs = eval("{#{a}}") rescue {}
  end  
  def ring_repeats
    return {} if !note[/<ring_repeats?>(?:[^<]|<[^\/])*<\/ring_repeats?>/i]
    a = note[/<ring_repeats?>(?:[^<]|<[^\/])*<\/ring_repeats?>/i].scan(/(?:!<ring_repeats?>|(.*)\r)/)
    a.delete_at(0)    
    a = a.join("\r\n")
    return noteargs = eval("{#{a}}") rescue {}
  end  
end


class Game_ActionResult
  def missed
    return $game_system.ring_miss if $game_system.ring_miss
    return @missed
  end
  def critical
    return $game_system.ring_crit if $game_system.ring_crit
    return @critical
  end
  def evaded
    return !$game_system.ring_null_evade if $game_system.ring_null_evade
    return @evaded
  end
  def missed=(val)
    @missed = val
    @missed = $game_system.ring_miss if $game_system.ring_miss
    return @missed
  end
  def critical=(val)
    @critical = val
    @critical = $game_system.ring_crit if $game_system.ring_crit
    return @critical
  end
  def evaded=(val)
    @evaded = val
    @evaded = !$game_system.ring_null_evade if $game_system.ring_null_evade
    return @evaded
  end
end

class Game_System
  #--------------------------------------------------------------------------
  # Include (New)
  #--------------------------------------------------------------------------
  include ESTRIOLE::OW_RIBS
  #--------------------------------------------------------------------------
  # Public Instance Variables (New)
  #--------------------------------------------------------------------------
  attr_accessor :score_count
  attr_accessor :good_count  
  attr_accessor :crit_count
  attr_accessor :ring_hit_count  
  attr_accessor :current_action
  attr_accessor :bar_speed
  attr_accessor :no_strike
  attr_accessor :strike_size
  attr_accessor :ring_setting
  attr_accessor :ring_active

  attr_accessor :ring_miss
  attr_accessor :ring_crit
  attr_accessor :ring_null_evade
  attr_accessor :ring_repeats
  #--------------------------------------------------------------------------
  # Initialize (Mod)
  #--------------------------------------------------------------------------
  alias ow_ribs_gs_initialize initialize unless $@
  def initialize
    ow_ribs_gs_initialize
    @score_count = 0
    @good_count = 0
    @crit_count = 0
    @ring_hit_count = 0
    @bar_speed = BAR_SPEED
    @no_strike = false
    @ring_active = false
    @strike_size = STRIKE_SIZE
  end
  def strike_size
    return STRIKE_SIZE if !@strike_size
    @strike_size
  end
end

class Game_Interpreter
  def do_ring(x = 0, y = 0, wedge = [10,30], degrees = 0 , times = 3)
    SceneManager.scene.do_ring(x, y, wedge, degrees, times)
  end
end