##----------------------------------------------------------------------------##
## Random Enemy Troops v1.0
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.0 - 3.13.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["CP_RANDOM_TROOP"] = 1.0                                            ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script works by adding comments to troops as tags.  These comments
## allow for existing members of the troop to be replaced with other enemies in
## the same location.  This has three tags that can be added to any page in
## under any conditions.
##
## <random troop>  -or-  <randomize troop>
##  - Scrambles enemies in the current troop.  Every enemy has the same chance
##    to be selected.
## troop range[1 8]  -or-  troop range[1-8]  -etc-
##  - Sets the number of enemies that can appear in the troop.  Enemies appear
##    in positions randomly.  The range can be any positive values between 0 and
##    the number of members in the current troop.
## enemy[5]  -or-  enemy[5, 20]
##  - Adds a random enemy to the random enemies list.  If you use this tag, none
##    of the default enemies in the troop will appear unless you use a tag with
##    their ID.  The first number is the enemy's ID in the database.  The second
##    number is the chance to appear in the group.  This can be any number at
##    all.  Note that higher numbers have a higher chance of appearing.
##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------

class Game_Troop < Game_Unit
  ## Alias the clear method to clear out the custom troop data.
  alias :cp_troop_clear :clear
  def clear
    cp_troop_clear
    @data_troop = nil
  end
  
  ## Alias the troop method to allow a new troop to be created.
  alias :cp_troop_troop :troop
  def troop
    return @data_troop if @data_troop
    @data_troop = cp_troop_troop.dup
    @data_troop.scramble
    return @data_troop
  end
end

class RPG::Troop
  ## 4 part method that scrambles troop data.
  def scramble
    enemies = []
    range = [members.size, members.size]
    range_changed = false
    randomize = false
    pages.each do |page|
      page.list.each do |line|
        next unless [108, 408].include?(line.code)
        case line.parameters[0]
        when /<random(ize)? troop>/i
          randomize = true
          range_changed = true
        when /troop range\[(\d+)[- ]*(\d+)\]/i
          range = [[$1.to_i, members.size].min, [$2.to_i, members.size].min]
          range_changed = true
        when /enemy\[(\d+)[, ]*(\d*)\]/i
          enemies.push([$1.to_i, [$2.to_i, 1].max])
        end
      end
    end
    return if enemies.empty? && !range_changed
    if enemies.empty? && randomize
      members.each do |mem|
        ar = [mem.enemy_id, 10]
        next if enemies.include?(ar)
        enemies.push(ar)
      end
    end
    unless enemies.empty?
      max_weight = enemies.inject(0) { |o,e| o += e[1] }
      members.each do |mem|
        i = max_weight - rand(max_weight)
        enemies.each do |a|
          i -= a[1]
          next unless i <= 0
          mem.enemy_id = a[0]
          break
        end
      end
    end
    if range[0] == range[1]
      pops = members.size - range[0]
    else
      pops = (rand(range[1] - range[0] + 1))
    end
    pops.times do
      members.delete_at(rand(members.size))
    end
  end
end
 
 
###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###