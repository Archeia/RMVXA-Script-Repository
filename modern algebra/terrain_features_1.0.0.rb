#==============================================================================
#    Terrain Features
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 3 February 2013
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    By default, the terrain tags in RMVX Ace are almost useless. This script
#   makes it so that you can give terrains a number of features, such as:
#   changing the rate of encounters; changing the chance for preemptive and 
#   surprise attacks; changing the battleback; changing movement speed;
#   setting a footstep sound; and more. Read the Editable Region at line 100
#   for a full list.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials. If you are using my Boat/Ship Passability for Events 
#   script, then this script should be BELOW that one in the Script Editor.
#``````````````````````````````````````````````````````````````````````````````
#  Terrain Features:
#
#    When it comes to the actual terrain features themselves, they are setup 
#   in the Editable Region at line 100. Please review them there to get an idea
#   of what each does and how to set them up. In brief, however, the features
#   are:
#
#        :battleback_1            :battleback_2           :encounter_rate
#        :preemptive_rate         :surprise_rate          :disable_dash
#        :walk_speed              :boat_speed             :ship_speed
#        :airship_speed           :boat_passable          :ship_passable 
#        :airship_land_ok         :walk_se                :boat_se
#        :ship_se                 :airship_se             :se_random_pitch
#                                 :common_event_id
#``````````````````````````````````````````````````````````````````````````````
#  Substitute Terrains:
#
#    Naturally, you setup terrain tags on your tileset directly, just as you do 
#   ordinarily, and you access them through the Get Location Data event command
#   on the third page, just as you do ordinarily. Similarly, you are still
#   limited to 8 terrain tags per tilemap.
#
#    The only thing this script adds on that front is the ability to substitute
#   some terrain tags for different tilemaps. Say, for instance, you have 
#   configured your world map and, in the course of doing so, you have used all 
#   8 terrain tags. Now, you are making a cave map and you want to use new 
#   terrain types. In that case, you can put the following code into the 
#   notebox of the tilemap:
#
#      \sub_terrain[id_1 = new_id_1; id_2 = new_id_2; ... id_n = new_id_n]
#
#   where id_n and new_id_n are both integers. new_id_n will be substituted 
#   wherever you set id_n. What this means in practice is that you can 
#   reservice some of your other terrain tags in a new tilemap. Wherever you
#   set id_n as the terrain tag, it will instead be received as new_id_n.
#
#  EXAMPLE:
#
#      \sub_terrain[1 = 8; 2 = 9]
#
#    In this tilemap, wherever you tag the terrain as 1, it will instead be 8, 
#   and wherever you tag the terrain as 2, it will instead be 9. Thus, even 
#   though 1 and 2 are being used, say for water tiles, you can give to
#   terrains 8 and 9 a number of different attributes, and the tiles tagged as
#   1 or 2 in this tilemap will instead have the attributes of terrains 8 or 9.
#==============================================================================

$imported = {} unless $imported
$imported[:"MA_TerrainFeatures 1.0.x"] = true

#==============================================================================
# *** Terrain Features
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This is the configuration module for all terrain features
#==============================================================================

module MA_TerrainFeatures
  #==========================================================================
  # ** Data_TerrainFeature
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  A Struct that holds all relevant attributes of a terrain type
  #==========================================================================
  
  Data_Terrain = Struct.new(:battleback_1, :battleback_2, :encounter_rate, 
    :preemptive_rate, :surprise_rate, :disable_dash, :walk_speed, :boat_speed, 
    :ship_speed, :airship_speed, :boat_passable, :ship_passable, 
    :airship_land_ok, :walk_se, :boat_se, :ship_se, :airship_se, 
    :se_random_pitch, :common_event_id)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Terrain Data
  #    Initializes a Data_Terrain object for the specified terrain_id
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.terrain_data(terrain_id)
    t = Data_Terrain.new
    t.members.each { |feature| t[feature] = default_value_for(feature) }
    se = RPG::SE
    case terrain_id
    #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    #  BEGIN Editable Region
    #````````````````````````````````````````````````````````````````````````
    #  This is where you set the terrain features. The when x line identifies 
    # which terrain tag's features you are editing. Each possible feature is 
    # detailed below, and the number given next to it is its default value. If
    # you do not include that line in the setting, that is the value it will 
    # have.
    #
    #  when 0 # Terrain Tag: 0
    #    t.encounter_rate = 100
    #        This value is the percentage by which walking on this terrain
    #        increases your encounter gauge. Note that bush terrains already
    #        get a 200% boost in encounters, and this is multiplied to that.
    #    t.preemptive_rate = 100
    #        This value is the percentage by which walking on this terrain
    #        increases the chance the party will get a preemptive strike.
    #    t.surprise_rate = 100
    #        This value is the percentage by which walking on this terrain
    #        increases the chance the party will be ambushed.
    #    t.battleback_1 = nil
    #        This value overrides the default battleback 1 when on this 
    #        terrain. It should be a string, set to the filename of the graphic
    #        you want to use. If nil, the normal battleback 1 is used.
    #    t.battleback_2 = nil
    #        Same as t.battleback_1, but for battleback 2.
    #    t.disable_dash = false
    #        If set to true, dash will be disabled on this terrain.
    #    t.walk_speed = 0
    #        This value is added to the walk speed of any character walking on
    #        the tile. So, if this is -1, the player will be slowed down by one
    #        setting when walking on this terrain.
    #    t.boat_speed = 0
    #        Same as t.walk_speed, but it applies to boats.
    #    t.ship_speed = 0
    #        Same as t.walk_speed, but it applies to ships.
    #    t.airship_speed = 0
    #        Same as t.walk_speed, but it applies to airships.
    #    t.boat_passable = nil
    #        If set to true or false, this overrides ordinary passability 
    #        settings and will make the tile passable if in a boat. If nil,
    #        then the terrain has no effect on boat passability.
    #    t.ship_passable = nil
    #        Same as t.boat_passable, but it applies to ships.
    #    t.airship_land_ok = nil
    #        Same as t.boat_passable, but it applies to whether the airship can
    #        land, not to passability.
    #    t.walk_se = nil
    #        The sound effect played when the player walks on this terrain. It 
    #        is set as:
    #          t.walk_se = se.new("Filename", 80, 100)
    #        Replace 80 with the desired volume and 100 with desired pitch. 
    #        When nil, no SE is played.
    #    t.boat_se = nil
    #        Same as t.walk_se, but applies when crossing terrain in boat
    #    t.ship_se = nil
    #        Same as t.walk_se, but applies when crossing terrain in ship
    #    t.airship_se = nil
    #        Same as t.walk_se, but applies when crossing terrain in airship
    #    t.se_random_pitch = nil
    #        This value lets you set a range to randomize the pitch of the se
    #        played when crossing the terrain. It is set as:
    #          t.se_random_pitch = 70..125
    #        Replace 70 with the lowest pitch you want and replace 125 with the
    #        highest pitch in the range. If nil, the pitch will not be 
    #        randomized
    #    t.common_event_id = 0
    #        This is the ID of a common event that is called every time the 
    #        player accesses this terrain. Any common event called in this
    #        way should never require more than 1 frame to execute fully.
    #````````````````````````````````````````````````````````````````````````
    #  EXAMPLE 1:
    #
    #  when 4 # Terrain Tag: 4
    #    t.encounter_rate = 150
    #    t.surprise_rate = 200
    #    t.battleback_1 = "DirtField"
    #    t.battleback_2 = "Forest2"
    #    t.disable_dash = true
    #    t.walk_speed = -1
    #    t.airship_land_ok = false
    #
    #  Whenever the player was walking on terrain tagged as 4:
    #    Enemy encounters would occur one and a half times more frequently
    #    Enemies are twice as likely to get a surprise attack
    #    The battlefield will be "DirtField" & "Forest2"
    #    The player would be unable to dash
    #    The player's movement speed would be reduced by 1
    #    Airships cannot land on this terrain.
    #````````````````````````````````````````````````````````````````````````
    #    EXAMPLE 2: 
    #
    #  when 7 # Terrain Tag: 7
    #    t.encounter_rate = 0
    #    t.walk_se = se.new("Knock", 60)
    #    t.se_random_pitch = 80..120
    #
    #  Whenever the player was walking on terrain tagged as 7:
    #    There would not be any enemy encounters
    #    Each step, the "Knock" SE plays at 60 volume and a pitch between 80-120
    #````````````````````````````````````````````````````````````````````````
    #  If you need more than terrain tags 0-7, just add a new when line for 
    # each new ID and configure it as you do the rest.
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    when 0 # Terrain Tag: 0 - Regular
    when 1 # Terrain Tag: 1 - 
    when 2 # Terrain Tag: 2 - 
    when 3 # Terrain Tag: 3 - 
    when 4 # Terrain Tag: 4 - 
    when 5 # Terrain Tag: 5 - 
    when 6 # Terrain Tag: 6 - 
    when 7 # Terrain Tag: 7 - 
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #  END Editable Region 
    #////////////////////////////////////////////////////////////////////////
    end
    t
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Default values for features
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.default_value_for(feature)
    # Default Values
    case feature
    when :encounter_rate then 100
    when :preemptive_rate then 100
    when :surprise_rate then 100
    when :disable_dash then false
    when :walk_speed then 0
    when :boat_speed then 0
    when :ship_speed then 0
    when :airship_speed then 0
    when :common_event_id then 0
    else nil # Everything else
    end
  end
  
  #============================================================================
  # *** Array_DataTerrains
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  This mixes in to the $data_ma_terrains array
  #============================================================================

  module Array_DataTerrains
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Get Terrain (lazy instantiation)
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def [](terrain_id)
      result = super(terrain_id)
      if !result
        result = MA_TerrainFeatures.terrain_data(terrain_id)
        self[terrain_id] = result
      end
      result
    end
  end
end

#==============================================================================
# *** DataManager
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - self.load_database
#==============================================================================

class << DataManager
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Load Normal/Battle Test Database
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  [:load_normal_database, :load_battle_test_database].each { |method|
    alias_method(:"matf_#{method}_9xa4", method)
    define_method(method) do |*args|
      send(:"matf_#{method}_9xa4", *args)
      $data_ma_terrains = [].extend(MA_TerrainFeatures::Array_DataTerrains)
    end
  }
end

#==============================================================================
# ** Game_Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - setup; terrain_tag; disable_dash?; boat_passable?; 
#      ship_passable?; airship_land_ok?
#    new method - matf_create_substitute_terrains; matf_airship_passable?
#==============================================================================

class Game_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias matf_setp_4oz6 setup
  def setup(*args)
    matf_setp_4oz6(*args) # Call original method
    matf_create_substitute_terrains
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Substitute Terrains
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def matf_create_substitute_terrains
    @matf_sub_terrains = [0, 1, 2, 3, 4, 5, 6, 7]
    subs = tileset.note.scan(/\\SUB_TERRAINS?\[(.*?)\]/im).flatten.join(';')
    subs.scan(/(\d+)[\s=>,]+(\d+)/).each { |a,b| @matf_sub_terrains[a.to_i] = b.to_i }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Terrain Tag
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias matf_terrtag_5io7 terrain_tag
  def terrain_tag(*args)
    @matf_sub_terrains[matf_terrtag_5io7(*args)] # Call original method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Check if Dashing
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias matf_disabldsh_8hb5 disable_dash?
  def disable_dash?(*args)
    matf_disabldsh_8hb5(*args) || $data_ma_terrains[$game_player.terrain_tag].disable_dash
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Determine if Passable by Boat/Ship or Airship Can Land
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  [:boat_passable, :ship_passable, :airship_land_ok].each { |method|
    alias_method(:"matf_check#{method}_3um9", :"#{method}?")
    define_method(:"#{method}?") do |x, y, *args|
      pass = $data_ma_terrains[terrain_tag(x, y)][method]
      pass == !!pass ? pass : send(:"matf_check#{method}_3um9", x, y, *args)
    end
  }
end

#==============================================================================
# ** Game_CharacterBase
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - real_move_speed
#    new method - terrain_speed_modifier
#==============================================================================

class Game_CharacterBase
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Move Speed 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias matf_realmvspeed_4wm3 real_move_speed
  def real_move_speed(*args)
    spd = matf_realmvspeed_4wm3(*args) + terrain_speed_modifier
    spd > 0 ? spd : 1
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Terrain Speed Modifier
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def terrain_speed_modifier
    $data_ma_terrains[terrain_tag].walk_speed
  end
end

if $imported[:MA_BoatShipPassability] # Compatibility with Boat/Ship Passability
  #============================================================================
  # ** Game_Event
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    overwritten supermethod - terrain_speed_modifier
  #============================================================================

  class Game_Event
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Terrain Speed Modifier
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def terrain_speed_modifier
      case @mabspe_passability
      when :boat then $data_ma_terrains[terrain_tag].boat_speed       # Boat
      when :ship then $data_ma_terrains[terrain_tag].ship_speed       # Ship
      else super                                                      # Walk
      end
    end
  end
end

#==============================================================================
# ** Game_Player
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - encounter_progress_value; increase_steps
#    overwritten supermethod - terrain_speed_modifier
#==============================================================================

class Game_Player
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Encounter Progress Value
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias matf_encountprgrssval_5rz3 encounter_progress_value
  def encounter_progress_value(*args)
    value = matf_encountprgrssval_5rz3(*args) # Call Original Method
    value * ($data_ma_terrains[$game_player.terrain_tag].encounter_rate / 100.0)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Increase Steps
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias matf_incstps_1ok6 increase_steps
  def increase_steps(*args)
    matf_incstps_1ok6(*args) # Call Original Method
    terrain = $data_ma_terrains[terrain_tag]
    $game_temp.reserve_common_event(terrain.common_event_id) if terrain.common_event_id > 0
    matf_play_move_se
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Play Move SE
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def matf_play_move_se
    terrain = $data_ma_terrains[terrain_tag]
    # Select SE depending on vehicle
    se = case @vehicle_type
    when :boat, :ship, :airship, :walk then terrain[:"#{@vehicle_type}_se"]
    else nil # Don't do it as above just in case new vehicle types
    end
    # Play SE if it exists
    if se
      rand_p = terrain.se_random_pitch
      se.pitch = (rand_p.first + rand(rand_p.last - rand_p.first)) if rand_p
      se.play
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Terrain Speed Modifier
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def terrain_speed_modifier
    case @vehicle_type
    when :boat then $data_ma_terrains[terrain_tag].boat_speed       # Boat
    when :ship then $data_ma_terrains[terrain_tag].ship_speed       # Ship
    when :airship then $data_ma_terrains[terrain_tag].airship_speed # Airship
    else super                                                      # Walk
    end
  end
end

#==============================================================================
# ** Game_Party
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - rate_preemptive; rate_surprise
#==============================================================================

class Game_Party
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Calculate Probability of Preemptive Attack
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias matf_ratepreempt_3jn6 rate_preemptive
  def rate_preemptive(*args)
    terrain_per = $data_ma_terrains[$game_player.terrain_tag].preemptive_rate
    matf_ratepreempt_3jn6(*args) * (terrain_per / 100.0)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Calculate Probability of Surprise
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias matf_ratsurprise_5kv2 rate_surprise
  def rate_surprise(*args)
    terrain_per = $data_ma_terrains[$game_player.terrain_tag].surprise_rate
    matf_ratsurprise_5kv2(*args) * (terrain_per / 100.0)
  end
end

#==============================================================================
# ** Spriteset_Battle
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - battleback1_name; battleback2_name
#==============================================================================

class Spriteset_Battle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Filename of Battle Background (Floor)
  #    Whether on overworld or not, check if terrain has an overriding 
  #    battleback and use if it does. Ignore during Battle Test
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias matf_bb1nm_2ob6 battleback1_name
  def battleback1_name(*args)
    bb1 = $BTEST ? nil : $data_ma_terrains[$game_player.terrain_tag].battleback_1
    bb1 ? bb1 : matf_bb1nm_2ob6(*args) # Call Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Filename of Battle Background (Wall)
  #    Whether on overworld or not, check if terrain has an overriding 
  #    battleback and use if it does. Ignore during Battle Test
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias matf_bback2name_5vx4 battleback2_name
  def battleback2_name(*args)
    bb2 = $BTEST ? nil : $data_ma_terrains[$game_player.terrain_tag].battleback_2
    bb2 ? bb2 : matf_bback2name_5vx4(*args) # Call Original Method
  end
end