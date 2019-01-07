##################################################
#                                                #
#             CONFIGURATION                      #
#                                                #
##################################################


mykey = "7uLEgQijsUAk7rVb4umBPP8DER3Cpyd9PuSFulhf1PgiN3pW4uvC8bR4P2ujsNb"


# how many times you want the script scramble your key.

scramble_times = 10


# RECRYPT previously "written" files (assuming thief manage to write your
# scripts to file successfully) #turn this on if you need extra security...
auto_guard_write = false

# if you set auto_guard_write = true. make sure you place &cypher_key
# ABOVE all other custom scripts that write to file (default scripts don't write so don't worry)
# to make it sure... place script control and cypher_key below default scripts but 
# ABOVE all custom scripts... it's safer that way...

##################################################
#                                                #
#         DO NOT TOUCH BELOW THIS                #
#                                                #
##################################################

mykey = mykey.split(//) if mykey.is_a?(String)
scramble_times.times do
mykey = prepare_scramble_key(mykey)
end
recrypt_script(mykey)
mykey = nil

tempscript = []
for i in 0 ... $RGSS_SCRIPTS.size
tempscript[i] = []
tempscript[i][1] = $RGSS_SCRIPTS[i][1]
tempscript[i][2] = $RGSS_SCRIPTS[i][2]
tempscript[i][3] = $RGSS_SCRIPTS[i][3]
$RGSS_SCRIPTS[i][1] = ""
$RGSS_SCRIPTS[i][2] = ""
$RGSS_SCRIPTS[i][3] = ""
$RGSS_SCRIPTS[i] = []
end
$RGSS_SCRIPTS = tempscript
tempscript = nil

module SceneManager
  class << self 
    alias est_wipe_run_safety_net run
  end
  def self.run
    $RGSS_SCRIPTS = []
    begin
    ESTRIOLE.send(:remove_const, :SCRIPT_CONTROL)
    Object.send(:remove_const, :Cipher)
    Object.send(:remove_method, :prepare_scramble_key)
    Object.send(:remove_method, :add_entropy)
    Object.send(:remove_method, :convert_scripts_to_rvdata)
    Object.send(:remove_method, :decrypt_rvdata_to_scripts)
    Object.send(:remove_method, :recrypt_script)
    rescue
    p 'Safenet Guarding...'
    end
    est_wipe_run_safety_net
  end
end

if auto_guard_write

ZCRYPTLEVEL = [
"C'mon... use your brain it's still 6 security layer to go :P",
"Nice... You got until this part... only a little more to go (5 layer)",
"You know what... you're sure hardworker. only 4 Left",
"Please stop from stealing my script will ya... 3 steps more and you've sinned...",
"hope you never break my last 2 layer security here...",
"arrghh.... only 1 more security left >.<. you're good.",
"Can't believe you manage to open it... PM me please so i can improve this... press alt+F4 to retrieve your script",
"Still not decrypted yet LOL... you failed... you're over more than 1 steps. think where you've gone wrong",
]

ZCRYPT_MODE = ["start","level 1","level 2","reverse","level 3","double","shuffle","Finalize"]

key = "this is the third protection to make sure you don't steal my scripts..."
cipher = Cipher.new(key) if key

ObjectSpace.each_object(File).dup.each do |f|
next if f.path == "Data/EST_CS2_SCRIPTS.rvdata2"
  text = ""
  ZCRYPT_MODE.each do |m|
    case m;
    when "reverse"; text += ZCRYPTLEVEL.reverse.join("\n")
    when "shuffle"; text += ZCRYPTLEVEL.shuffle.join("\n")    
    when "double"; ZCRYPTLEVEL+= ZCRYPTLEVEL; text += ZCRYPTLEVEL.shuffle.join("\n")    
    else; text += ZCRYPTLEVEL.join(m)
    end
  end
  text = cipher.encrypt text
  destroy = File.new(f.path,"w") rescue nil
  next unless destroy
  destroy.write(text)
  destroy.close
end

end