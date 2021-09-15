$simport.r 'iek/better_data/callbacks', '1.0.0', 'Utilizes iek callbacks for better_data' do |h|
  h.depend 'iek/better_data', '>= 1.0.0'
  h.depend! 'iek/callbacks', '>= 1.0.0'
end

module DataManager
  include Mixin::Callback

  def self.pre_load_database(dbname)
    try_callback(:pre_load_database, dbname)
  end

  def self.post_load_database(dbname)
    try_callback(:post_load_database, dbname)
  end

  def self.pre_create_game_objects
    try_callback(:pre_create_game_objects)
  end

  def self.post_create_game_objects
    try_callback(:post_create_game_objects)
  end
end
