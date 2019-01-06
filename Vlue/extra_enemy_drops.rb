#Extra Enemy Drops v1.0
#----------#
#Features: Let's you set, via notes, more than just three item drops 
#           from an enemy. Yay!
#
#Usage:    Plug and play, customize as needed
#        
#         Enemy Notetags:
#          <DROP type id rate>
#           type is 1 for item, 2 for weapon, 3 for armor
#           id is the id of the item
#           rate is the 1/rate of the item, 20 would be 1/20 chance
#
#          A weapon of id 3 that drops 1 out of 5 times would be:
#           <DROP 2 3 5>
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#- Free to use in any project with credit given, donations always welcome!

#Maximum number of items that can drop from one enemy in a battle
MAX_ENEMY_DROPS = 3

class RPG::Enemy
  def add_drop(type,id,rate)
    @drop_items.push(RPG::Enemy::DropItem.new)
    @drop_items[-1].kind = type
    @drop_items[-1].data_id = id
    @drop_items[-1].denominator = rate
  end
  def add_drops
    snote = self.note.clone
    while snote.include?("<DROP ")
      snote =~ /<DROP (\d+) (\d+) (\d+)>/
      add_drop($1.to_i,$2.to_i,$3.to_i)
      snote[snote.index("<DROP")] = "N"
    end
  end
end

module DataManager
  def self.load_database
    if $BTEST
      load_battle_test_database
    else
      load_normal_database
      check_player_location
    end
    add_enemy_drops
  end
  def self.add_enemy_drops
    $data_enemies.each do |enemy|
      next if enemy.nil?
      enemy.add_drops
    end
  end
end

class Game_Enemy
  def make_drop_items
    iter = 0
    enemy.drop_items.inject([]) do |r, di|
      if di.kind > 0 && rand * di.denominator < drop_item_rate && iter < MAX_ENEMY_DROPS
        iter += 1
        r.push(item_object(di.kind, di.data_id))
      else
        r
      end
    end
  end
end