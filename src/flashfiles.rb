#!/usr/bin/env ruby

proc = nil
fd = nil
name = nil

`lsof -Fpfn -- /tmp/`.split("\n").each{|line|
	line.strip!

	if (line[0].chr == "p")
		proc = line[1..-1]
	elsif (line[0].chr == "f")
		fd = line[1..-1]
	elsif (line[0..10] == "n/tmp/Flash")
		puts "/proc/#{proc}/fd/#{fd}"
		proc = nil
		fd = nil
	end
}
