##-----------------------------------------------------------------------------
#  Project Destroyer v1.0
#  Created by Neon Black
#  v1.0 - 8.27.15 - Main script completed
#  For both commercial and non-commercial use as long as credit is given to
#  Neon Black and any additional authors.  Licensed under Creative Commons
#  CC BY 4.0 - http://creativecommons.org/licenses/by/4.0/
##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------
#  This script deletes everything it can in your project folder without
#  warning.  This script is provided as is!  I take NO responsibility for
#  projects lost by using this script since that is EXACTLY what it is meant
#  to do.  USE AT YOUR OWN RISK!!!
##-----------------------------------------------------------------------------


module ProjectDeath
  def self.delete_directory(dir)
    Dir::foreach(dir) do |file|
      begin
        next if ['.','..','Game.exe'].include?(file)
        if File::directory?("#{dir}/#{file}")
          delete_directory("#{dir}/#{file}")
          Dir::rmdir("#{dir}/#{file}")
        else
          File::delete("#{dir}/#{file}")
        end
      rescue
        next
      end
    end
  end
  
  def self.delete_all
    delete_directory(Dir::pwd)
    exit
  end
end

ProjectDeath.delete_all