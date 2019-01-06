#Basic Real Time (System Time)
#----------#
#Features: Provides a series of functions and escape characters to incorporate
#   system time into games.
#
#Usage:   Within Script and Conditional Branches:
#   RTime::fulltime    - returns date, year, and time in one string
#   RTime::time(m, f)  - returns time, m flag is for 24 hour time
# f flag is to include seconds
#   RTime::year    - returns the current year
#   RTime::month(n, a) - returns the current month
#   n flag true, shows month name over number
#   a flag toggles abbreviation i.e "Jan"
#   RTime::day(n, a)   - returns the day of the month
#   n flag true, shows day of the week
#   a flag toggles abbreviation i.e "Fri"
#   RTime::dayweek - returns the day as an integer (Sunday = 0 ..)
#   RTime::hour(m) - returns the current hour, m flag for 24 hour
#   RTime::minute  - returns the current minute
#   RTime::second  - returns the current second
#
#  Within message boxes:
#   \RT[FT]    - replaced by full time
#   \RT[Tm]    - replaced by system time(24 hour)
#   \RT[T] - replaced by system time(am/pm)
#   \RT[Y] - replaced by current year
#   \RT[N] - replaced by current month, integer
#   \RT[n] - replaced by current month, name
#   \RT[D] - replaced by current day of the month
#   \RT[d] - replaced by current day of the week
#   \RT[H] - replaced by current hour(am/pm)
#   \RT[h] - replaced by current hour(24 hour)
#   \RT[m] - replaced by current minute
#   \RT[s] - replaced by current second
#
#Examples: "Why \N[1], it's currently the year \RT[Y]!"
#   RTime::dayweek == 5 /* Within conditional branch, returns true if it's Friday */
#   Rtime::time(true, false)
#
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

module RTime
  #Functions, explained above#
  def self.fulltime
    return Time.now.strftime("%A, %B %-d, %Y %l:%M")
  end
  def self.time(military = true, full = true)
    return Time.now.strftime("%k:%M:%S") if military and full
    return Time.now.strftime("%k:%M") if military
    return Time.now.strftime("%l:%M:%S %p") if full
    return Time.now.strftime("%l:%M %p")
  end
  def self.year
    return Time.now.year
  end
  def self.month(name = false, abbr = false)
    return Time.now.month if name == false
    if abbr then return Time.now.strftime("%b") else return Time.now.strftime("%B") end
  end
  def self.day(name = false, abbr = false)
    return Time.now.day if name == false
    if abbr then return Time.now.strftime("%a") else return Time.now.strftime("%A") end
  end
  def self.dayweek
    return Time.now.wday
  end
  def self.hour(military = true)
    return Time.now.hour if military
    if Time.now.hour > 12 then return (Time.now.hour - 12) else return Time.now.hour end
  end
  def self.minute
    return Time.now.min
  end
  def self.second
    if Time.now.sec == 60 then return 0 else return Time.now.sec end
  end
end

class Window_Base < Window
  #Alias of convert, to include Rtime escape characters
  alias real_time_convert_escape_characters convert_escape_characters
  def convert_escape_characters(text)
    result = real_time_convert_escape_characters(text)
    result.gsub!(/\eRT\[FT]/) { RTime::fulltime }
    result.gsub!(/\eRT\[Tm]/) { RTime::time(true, false) }
    result.gsub!(/\eRT\[T]/) { RTime::time(false, false) }
    result.gsub!(/\eRT\[Y]/) { RTime::year }
    result.gsub!(/\eRT\[N]/) { RTime::month }
    result.gsub!(/\eRT\[n]/) { RTime::month(true) }
    result.gsub!(/\eRT\[D]/) { RTime::day }
    result.gsub!(/\eRT\[d]/) { RTime::day(true) }
    result.gsub!(/\eRT\[H]/) { RTime::hour(false) }
    result.gsub!(/\eRT\[h]/) { RTime::hour }
    result.gsub!(/\eRT\[m]/) { RTime::minute }
    result.gsub!(/\eRT\[s]/) { RTime::second }
    result
  end
end