$simport.r 'iek/better_data', '1.0.0', 'exposes more functionality for DataManager'

module DataManager
  def self.use_normal_database_for_battle?
    false
  end

  def self.game_data_extname
    '.rvdata2'
  end

  def self.savefile_data_extname
    '.rvdata2'
  end

  def self.load_game_data(basename)
    load_data("Data/#{basename}#{game_data_extname}")
  end

  def self.pre_load_database(dbname)
    #
  end

  def self.post_load_database(dbname)
    #
  end

  def self.pre_create_game_objects
    #
  end

  def self.post_create_game_objects
    #
  end

  def self.load_user_normal_database
    #
  end

  def self.load_user_battle_database
    #
  end

  def self.load_normal_database
    pre_load_database(:normal)
    $data_actors        = load_game_data('Actors')
    $data_classes       = load_game_data('Classes')
    $data_skills        = load_game_data('Skills')
    $data_items         = load_game_data('Items')
    $data_weapons       = load_game_data('Weapons')
    $data_armors        = load_game_data('Armors')
    $data_enemies       = load_game_data('Enemies')
    $data_troops        = load_game_data('Troops')
    $data_states        = load_game_data('States')
    $data_animations    = load_game_data('Animations')
    $data_tilesets      = load_game_data('Tilesets')
    $data_common_events = load_game_data('CommonEvents')
    $data_system        = load_game_data('System')
    $data_mapinfos      = load_game_data('MapInfos')
    load_user_normal_database
    post_load_database(:normal)
  end

  def self.load_battle_test_database
    return load_normal_database if use_normal_database_for_battle?
    pre_load_database(:battle)
    $data_actors        = load_game_data('BT_Actors')
    $data_classes       = load_game_data('BT_Classes')
    $data_skills        = load_game_data('BT_Skills')
    $data_items         = load_game_data('BT_Items')
    $data_weapons       = load_game_data('BT_Weapons')
    $data_armors        = load_game_data('BT_Armors')
    $data_enemies       = load_game_data('BT_Enemies')
    $data_troops        = load_game_data('BT_Troops')
    $data_states        = load_game_data('BT_States')
    $data_animations    = load_game_data('BT_Animations')
    $data_tilesets      = load_game_data('BT_Tilesets')
    $data_common_events = load_game_data('BT_CommonEvents')
    $data_system        = load_game_data('BT_System')
    load_user_battle_database
    post_load_database(:battle)
  end

  def self.create_user_game_objects
  end

  def self.create_regular_game_objects
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_timer         = Game_Timer.new
    $game_message       = Game_Message.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
  end

  def self.create_game_objects
    pre_create_game_objects
    create_regular_game_objects
    create_user_game_objects
    post_create_game_objects
  end

  def self.save_file_basename
    'Save'
  end

  def self.save_file_exists?
    !Dir.glob("#{save_file_basename}*#{savefile_data_extname}").empty?
  end

  def self.make_filename(index)
    sprintf("#{save_file_basename}%02d#{savefile_data_extname}", index + 1)
  end
end
