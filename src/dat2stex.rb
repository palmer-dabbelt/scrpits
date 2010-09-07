in_file = File.open(ARGV[0], "r")
out_file = File.open(ARGV[1],"w")

while (read = in_file.gets)
	out_file.puts("#{read.strip.split("\t").map{|s| "$#{s}$"}.join("&")}\\\\")
end