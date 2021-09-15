$simport.r 'iei/arts', '0.1.0', 'IEI Arts System'

class IEI::Art < RPG::BaseItem
  def all_tags
    super + ['art']
  end
end

module IEI
  module ArtsSystem
    module Mixin
    end

    Art = IEI::Art # // Don't tamper with this >_____>

    @arts = []     # // Don't touch this either >_____>

    Feature = RPG::BaseItem::Feature # // >_>... You know the drill

    # // And this +____+
    def self.arts
      @arts
    end

    def self.new_art(id)
      art = IEI::Art.new
      art.id = id
      @arts[id] = art
    end

    def self.seed_database
      # // How to create a new art? Look below
      # // Does nothing . x .
      art = new_art(0)
      art.icon.index = 0
      art.name = '----------'
      art.description = 'Does Absolutely Nothing'
      art.features.push(Feature.new(0, 0, 0.0))
      # // And finally you can start making your own arts here
      # // If your having difficulty with the Features try getting the Features4Dummies XD
      # // >_> Now if your smart you'll figure out a way to manage your 'arts'
    end

    def self.create_database
      @arts = []
      seed_database
      @arts
    end
  end
end

DataManager.add_callback(:load_user_database) do
  $data_arts = IEI::ArtsSystem.create_database
end

module IEI::ArtsSystem::Mixin::Battler
  def pre_init_iei
    super
    @arts = [] # // Error Prevention ? D: : =3=
  end

  def init_iei
    super
    init_arts
    flush_arts
  end

  def post_init_iei
    super
    # // Something else .x .
  end

  # //
  def init_arts # // . x . You add custom things here
    @arts = []
  end

  def all_arts # // .x. Returns all present arts on this character
    init_arts unless @arts
    @arts.map{|i|$data_arts[i]}
  end

  def arts # // .x. You can filter certain arts here
    all_arts
  end

  def arts_features # // . x . If you need all the features it adds
    arts.inject([]){|r,obj|r+obj.features}
  end

  def feature_objects
    super + arts
  end

  # // Usage Stuff
  def remove_art art_id
    @arts.delete art_id
  end

  def set_art art_id,index
    @arts[index] = art_id
  end

  def set_art_wf art_id,index  # // Set Art, With Flush . x .
    set_art art_id,index
    flush_arts
  end

  def swap_art_order index1, index2
    @arts[index1], @arts[index2] = @arts[index2], @arts[index1]
  end

  def change_equip_art art_id,index
    set_art art_id,index  if allowed_art? art_id
  end

  def equip_art art,index
    change_equip_art(art ? art.id : 0, index)
  end

  def equip_arts *arts
    (0...arts_equip_size).each do |i|
      equip_art(arts.shift, i) if @arts[i].nil? || @arts[i].zero?
    end
  end

  def unequip_arts
    (0...arts_equip_size).each do |i| change_equip_art(0, i) end
  end

  def has_art? id
    @arts.include? id
  end

  # //
  def flush_arts
    @arts.select!{|a|allowed_art?(a)}
    @arts.pad!(arts_equip_size,0)
  end

  # // Settings
  def allowed_art? id
    true
  end

  def arts_equip_size # // Try to keep it reasonable >_>
    3
  end

  def arts_point_limit # // NYI (Not yet Implemented)
    50
  end
end

module IEI::ArtsSystem::Mixin::Party
  def pre_init_iei
    super
    @arts = {}
  end

  def init_iei
    super
  end

  def post_init_iei
    super
  end

  def gain_art(art_id, n)
    return unless $data_arts[art_id]
    @arts[art_id] ||= 0
    @arts[art_id] = (@arts[art_id] + n).max(0)
    @arts.delete(art_id) if @arts[art_id] == 0
  end

  def lose_art art_id,n
    gain_art art_id,-n
  end

  def art_number art_id
    @arts[art_id] || 0
  end

  def arts
    @arts.keys.sort.select{|k|art_number(k)>0}.map{|k|$data_arts[k]}
  end

  def has_art? art_id
    return art_number art_id  > 0
  end
end
