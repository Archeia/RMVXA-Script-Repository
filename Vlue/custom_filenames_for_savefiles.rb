#Custom SaveFile Names
#----------#
#Features: Allows you to set custom save file names that noone will ever see.
#    There are some practical uses! I just don't have any yet.
#
#Usage: Plug and play and customize
#   Things to note... delete/move save files before packing game
#   else those files will go with it! Sillyness.
# 
#Customization: Set below, in comments.
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

module DataManager
=begin Customization:
  SAVEFILENAME is the details before the number and extension
  SAVEFILEEXTENSION is the extension of the file, defail is Rvdata2
=end
  SAVEFILENAME   = "SAVE"
  SAVEFILEEXTENSION = "Rvdata2"
  def self.save_file_exists?
    !Dir.glob(SAVEFILENAME + "*" + SAVEFILEEXTENSION).empty?
  end
  def self.make_filename(index)
    sprintf(SAVEFILENAME + "%02d." + SAVEFILEEXTENSION, index + 1)
  end
end