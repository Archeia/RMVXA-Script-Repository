# IEX-ScriptHandler
TAG = /(?:IEX-)(\w+)[ ]*V(\d+)_(\d+)(\w+)?/i
begin
  texts = [] ; scripts = [] ; finalscripts = {}
  Dir.glob("*.txt").each { |tex| texts << tex }
  texts.each { |tx| scripts << tx.to_s if tx.to_s =~ TAG }

  scripts.each do |sc|
    puts "Now Processing #{sc}"
    case sc
    when TAG
      finalscripts[$1.to_s] = [] if finalscripts[$1.to_s].nil?
      finalscripts[$1.to_s].push(sprintf("%d_%d%s", $2.to_i, $3.to_i, $4.to_s))
    end
  end

  puts "\n (O'.')=O Q('.'O) - Validation in Progress"
  finalscripts.keys.sort.each do |key|
    finalscripts[key].sort!
    vv = ""
    finalscripts[key].each { |v| vv += v.to_s + " " }
    last_version = [finalscripts[key][-1]]
    removal = ""
    (finalscripts[key] - last_version).to_a.each { |r| removal +=  r.to_s + " " }
      if finalscripts[key].size > 1
      puts sprintf("\n%s - Versions: %s", key, vv.to_s)
      puts "  Warning, this script has Multi Versions Present"
      puts "  Remove #{removal}"
    else
      puts sprintf("\n%s - Version: %s", key, vv.to_s)
      puts "  This script is up to date"
    end
  end
  gets
end
