infile = File.new(ARGV[0], "r")
outfile = File.new("#{ARGV[0].chomp(".txt")}.stex", "w")

outfile.puts("\\begin{verbatim}")
while (read = infile.gets)
	outfile.write(read)
end
outfile.puts("\\end{verbatim}")

outfile.close
infile.close
