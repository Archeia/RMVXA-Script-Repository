#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Autobackup
#  Author: Kread-EX
#  Version 1.03
#  Release date: 26/12/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#--------------------------------------------------------------------------
#  ▼ UPDATES
#--------------------------------------------------------------------------
# #  03/02/2013. Changed file comparison method.
# #  23/01/2013. Stop trying to compare Audio files.
# #  18/01/2013. Fixed bug with UNIX filenames.
#--------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#--------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgmakerweb.com
#--------------------------------------------------------------------------
#  ▼ INTRODUCTION
#--------------------------------------------------------------------------
# # Makes an automatic backup of data and/or graphic files when you start
# # the game if necessary. Should be removed from the project upon release.
#--------------------------------------------------------------------------

# Folder for your backups. They're ordered by date afterwards.
BACKUP_FOLDER = "Backups"

# Location of your Dropbox folder.
DROPBOX_FOLDER = "Documents/Dropbox"

# Hotkey. If you press this during the game, a unique backup will be sent
# to your Dropbox folder. Does nothing if the folder doesn't exist.
DROPBOX_HOTKEY = :ALT

# Set this to false to only back up the project data.
BACKUP_GRAPHICS = false

# Disable the autobackups by setting this to `true. The Dropbox hotkey will
# still be available however.
DISABLE_AUTOSCRIPT = true

# Actual script start here. Don't edit unless you know what you're doing.

#===========================================================================
# ■ Dir
#===========================================================================

class Dir
  #--------------------------------------------------------------------------
  # ● Create directories recursively
  #--------------------------------------------------------------------------
  def self.mkdir_recursive(path)
    return if File.exists?(path)
    dir, file = File.split(path)
    Dir.mkdir_recursive(dir) unless File.exists?(dir)
    Dir.mkdir(path)
  end
end

unless DISABLE_AUTOSCRIPT
  # Check if backup necessary.
  Dir.mkdir(BACKUP_FOLDER) unless Dir.exist?(BACKUP_FOLDER)
  time = Time.now.strftime("%m-%d-%Y %H-%M")
  current_version = load_data("Data/System.rvdata2").version_id
  do_copy = false
  backup_version = target_path = nil
  backup_size = Dir.entries(BACKUP_FOLDER).size - 2
  if backup_size == 0
    target_path = "#{BACKUP_FOLDER}/0001 (#{time})"
    Dir.mkdir(target_path)
    do_copy = true
  end
  Dir.entries(BACKUP_FOLDER).each do |filename|
    next if ['.', '..'].include?(filename)
    if filename.include?("000#{backup_size}")
      backup_version = load_data(BACKUP_FOLDER + '/' + filename +
      '/Data/System.rvdata2').version_id
      if backup_version != current_version
        target_path = "#{BACKUP_FOLDER}/000#{backup_size + 1} (#{time})"
        Dir.mkdir(target_path)
        do_copy = true
        break
      end
    end
  end
  # Perform backup
  if do_copy
    d = 'Data/'
    Dir.entries(d).each do |filename|
      next if ['.', '..'].include?(filename)
      next if filename.include?('Thumbs.db')
      next if filename.include?('Desktop.ini')
      Dir.mkdir_recursive(File.join(target_path, d))
      IO.copy_stream(d + filename, target_path + '/'+ d + filename)
    end
    if BACKUP_GRAPHICS
      d = 'Graphics/'
      td = nil
      files = File.join("Graphics/*", '*.*')
      Dir.glob(files).each do |filename|
        next if ['.', '..'].include?(filename)
        next if filename.include?('Thumbs.db')
        next if filename.include?('Desktop.ini')
        td = File.dirname(filename)
        Dir.mkdir_recursive(File.join(target_path, td))
        IO.copy_stream(filename, target_path + '/' + filename)
      end
    end
    puts 'Autobackup done!'
  end
end

#===========================================================================
# ■ Scene_Base
#===========================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # ● Frame Update [Basic]
  #--------------------------------------------------------------------------
  alias_method(:krx_autobackup_sb_ub, :update_basic)
  def update_basic
    Thread.new {make_dropbox_backup} if Input.trigger?(DROPBOX_HOTKEY)
    krx_autobackup_sb_ub
  end
  #--------------------------------------------------------------------------
  # ● Creates the actual Dropbox backup
  #--------------------------------------------------------------------------
  def make_dropbox_backup
    title = $data_system.game_title.gsub (/[:"\\\/?|]/) {'_'}
    dfolder = File.join(ENV['HOME'], DROPBOX_FOLDER)
    return unless Dir.exist?(dfolder)
    path = File.join(dfolder, title)
    Dir.mkdir(path) unless Dir.exist?(path)
    allfiles = File.join("**", '*.*')
    dir = nil
    Dir.glob(allfiles).each do |filename|
      next if filename.include?('Thumbs.db')
      next if filename.include?('Desktop.ini')
      dir = File.join(path, File.dirname(filename))
      Dir.mkdir_recursive(dir) unless Dir.exist?(dir)
      if File.exist?(path + '/' + filename)
        puts "File already exists: #{filename}"
        next if filename.include?('Audio')
        if File.mtime(path + '/' + filename) < File.mtime(filename)
          puts "File overwritten: #{filename}"
          IO.copy_stream(filename, path + '/' + filename)
        end
      else
        puts "File copied: #{filename}"
        IO.copy_stream(filename, path + '/' + filename)
      end
    end
    puts 'Hotkey Backup complete!'
  end
end