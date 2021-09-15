#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Register
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Register
# ** Script Type   : Script Manager
# ** Date Created  : 02/19/2011
# ** Date Modified : 05/20/2011
# ** Script Tag    : IEO-000(Register)
# ** Difficulty    : Easy
# ** Version       : 1.0
# ** IEO ID        : 000
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
# You may:
# Edit and Adapt this script as long you credit aforementioned author(s).
#
# You may not:
# Claim this as your own work, or redistribute without the consent of the author.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#-*--------------------------------------------------------------------------*-#
# *Sigh*
# This script isn't very useful, it how ever helps you by producing a list of
# all the ieo scripts you have installed.
# There is also a version warning (mixed versions of scripts)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTRUCTIONS
#-*--------------------------------------------------------------------------*-#
#
# Plug 'n' Play
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Everything.... hopefully
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#-*--------------------------------------------------------------------------*-#
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
#
#-*--------------------------------------------------------------------------*-#
# Below
#   Materials
#   YEM Core Fixes and Upgrades
#
# Above
#   Main
#   All IEO Scripts
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
#
#  Non
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#
#  02/15/2011 - V1.0 Started Script, Finished Script
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Non
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FAQ
#-*--------------------------------------------------------------------------*-#
# Acronyms -
#  BEM - Battle Engine Melody
#  CBS - Custom Battle System
#  DBS - Default Battle System
#  GTBS- Gubid's Tactical Battle System
#  IEO - Icy Engine Omega
#  IEX - Icy Engine Xellion
#  OHM - IEO-005(Ohmerion)
#  SRN - IEX - Siren
#  YGG - IEX - Yggdrasil
#  ATB - Active Turn Battle
#  DTB - Default Turn Battle
#  PTB - Press Turn Battle
#  CTB - Charge Turn Battle
#
# Q. Whats up with the IDs?
# A. Well due to some naming issues, I ended up with 5 scripts in IEX
#    all having similar names, this causes some issues for updating
#    and sorting.
#    I have decided to add some IDS so I can sort and find script with EASE.
#
# Q. Where is the name from?
# A. Roman Alphabet, thanks to PentagonBuddy and Jalen by the way.
#
# Q. Where did you learn scripting?
# A. Yanfly's scripts, read almost everyone of them, so my scripting style
#    kinda looks like his.
#
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
$simport.r 'ieo/register', '1.1.0', 'IEO Core Registration module'
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script ||= {})[[0, "Core"]] = 1.1
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# ** IEO
#==============================================================================#
module IEO
#==============================================================================#
# ** REGISTER
#==============================================================================#
  module REGISTER
    @@installed_scripts = {}
  #--------------------------------------------------------------------------#
  # * new-method :log_all_scripts
  #--------------------------------------------------------------------------#
    def self.log_all_scripts()
      File.open("IEO-ScriptLog.log", "w+") do |file|
        scripts = $ieo_script.keys.compact.sort #{ |a, b| a[0] <=> b[0]}
        scripts.each do |info|
          text = sprintf("Ver#{$ieo_script[info]} %03d-%s\n", info[0], info[1])
          file.write(text)
        end
      end
    end

  #--------------------------------------------------------------------------#
  # * new-method :log_script
  #--------------------------------------------------------------------------#
    def self.log_script(script_id, script_name, script_version)
      scr_oversion = @@installed_scripts[[script_id, script_name]]
      unless scr_oversion.nil?()
        if scr_oversion > script_version
          raise "A newer version of #{script_name} is already installed"
          exit
        elsif scr_oversion < script_version
          raise "An older version of #{script_name} is installed"
          exit
        else
          raise "A duplicate of #{script_name} is installed"
          exit
        end
      else
        @@installed_scripts[[script_id, script_name]] = script_version
      end
    end

  end
#==============================================================================#
# ** CORE
#==============================================================================#
  module CORE
  #--------------------------------------------------------------------------#
  # * new-method :quick_shop
  #--------------------------------------------------------------------------#
    def self.quick_shop
      data = ($data_items + $data_weapons + $data_armors).compact
      $game_temp.shop_goods = data.map do |e|
        case e
        when RPG::Item
          result << [0, e.id]
        when RPG::Weapon
          result << [1, e.id]
        when RPG::Armor
          result << [2, e.id]
        else
          raise
        end
      end

      $game_temp.shop_purchase_only = false
      $scene = Scene_Shop.new
    end
  end
end
#==============================================================================#
IEO::REGISTER.log_script(0, "Register", 1.0)
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
