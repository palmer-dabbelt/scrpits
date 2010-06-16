time = ARGV[0]
message = ARGV[1]

if (time == nil)
	puts "PTimer <time> [message]"
	exit 1
end

if (time[-1].chr == "s")
	time = time.chomp("s").to_f
elsif (time[-1].chr == "m")
	time = time.chomp("m").to_f * 60
elsif (time[-1].chr == "h")
	time = time.chomp("h").to_f * 60 * 60
end

if (message == nil)
	message = "PTimer"
end

sleep(time.to_i)

`kdialog --msgbox "#{message}"`
