#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# Auto Serialize/Deserialize
# Author: Kread-EX
# Version 1.0
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

=begin
INTRODUCTION
This little tool allows to automatically serialize files of the desired extensions located in the project folder.
In addition, modifications of the load/require methods are provided in order to:

    * Build those files into the RGSS interpreter (for script files).
    * Convert them into an array of lines (for text files).

Note that this only works in debug mode.

INSTRUCTIONS
Very easy to use. Place the script on the top of the editor (below the F12 fix or Pause script if you are using them).
Then configure which extensions you want to serialize.
You'll just have to call the appropriate methods for any particular later use.
=end

EXTENSIONS = ['.rb', '.txt']

if $DEBUG
  dirname = File.expand_path('./Game.exe')
  dirname.slice!('Game.exe')
  Dir.entries(dirname).each {|filename|
    next if ['.', '..'].include?(filename)
    if EXTENSIONS.include?(File.extname(filename))
      File.open(filename, 'rb') {|file| save_data(file.readlines.join, 'Data/' + filename)}
    end
  }
end

module Kernel
  class << self
    alias_method :kread_special_require, :require
    #--------------------------------------------------------------------------
    # * Require
    #--------------------------------------------------------------------------
    def require(filename)
      path = "Data/#{filename}"
      file = self.load_data(path)
      File.open('temp.rb', 'wb') {|newf| newf.write(file)}
      file = nil
      kread_special_require(File.expand_path('./temp.rb'))
      File.delete('temp.rb')
    end
    alias_method :kread_special_load, :load
    #--------------------------------------------------------------------------
    # * Load
    #--------------------------------------------------------------------------
    def load(filename)
      path = "Data/#{filename}"
      file = self.load_data(path)
      File.open('temp.rb', 'wb') {|newf| newf.write(file)}
      file = nil
      kread_special_load(File.expand_path('./temp.rb'))
      File.delete('temp.rb')
    end
    #--------------------------------------------------------------------------
    # * Load text files
    #--------------------------------------------------------------------------
    def load_text_file
      path = "Data/#{filename}"
      file = self.load_data(path)
      File.open('temp.txt', 'wb') {|newf| newf.write(file)}
      file = nil
      text_file = File.open('temp.txt', 'rb')
      array = text_file.readlines
      text_file.close
      File.delete('temp.txt')
      return array
    end
  end
end