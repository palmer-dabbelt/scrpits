ARGV.each{|in_file|
	info = Hash.new
	
	`exiftool "#{in_file}"`.split("\n").map{|s| s.strip}.each{|line|
		key = line.split(":")[0].strip
		val = line.split(":")[1..-1].join(":").strip
		
		info[key] = val
	}
	
	temp = `mktemp -d`.strip
	
	`mplayer "#{in_file}" -vo null -vc null -ao pcm:file="#{temp}"/wavefile.wav`
	`lame -b 128 --tt "#{info["Title"]}" --ta "#{info["Artist"]}" --tl "#{info["Album"]}" --ty "#{info["Year"]}" "#{temp}"/wavefile.wav "#{in_file}.mp3"`
	
	`rm -rf "#{temp}"`
}
