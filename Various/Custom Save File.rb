#==================#
# Custom Save File #
#==================#===========================#
# This script allows you to easily change your #
# save file name and extension                 #
#                                              #
# Instructions:                                #
#  add it in script database and change        #
#  here extension and filename                 #
#==============================================#
 
module DataManager
#================#
# Customization: #
#================#==================================================#
# SAVEFILENAME is the details before the number and extension       #
# SAVEFILEEXTENSION is the extension of the file, defail is Rvdata2 #
#===================================================================#
  SAVEFILENAME   = "SAVE"
  SAVEFILEEXTENSION = "Rvdata2"
  def self.save_file_exists?
    !Dir.glob(SAVEFILENAME + "*" + SAVEFILEEXTENSION).empty?
  end
  def self.make_filename(index)
    sprintf(SAVEFILENAME + "%02d." + SAVEFILEEXTENSION, index + 1)
  end
end