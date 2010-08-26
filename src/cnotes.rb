if (ARGV[0] != "dummy")
	`cnotes dummy 2> /dev/null`
	exit 0
end

class String
	def ends_with(other)
		if (self.size < other.size)
			return false
		else
			return self[self.size - other.size .. -1] == other
		end
	end
end

# Today's date, in short format
date = `date +%Y-%m-%d`.strip
outfile_path = "#{date}.tex"

# Checks that we're not going to overwrite some good notes
if (File.exists?(outfile_path))
	puts "'#{outfile_path}' already exists"
	
	# So edit it, instead
	kwrite_thread = Thread.new{
		`kwrite "#{outfile_path}"`
	}
	
	# And exit
	`this_process_does_not_exist`
	exit
end

# If we need to, create a new notes file
class_name = `pwd`.strip.chomp("/").chomp("/notes").split("/")[-1].strip.downcase
if (`pwd`.strip.split("/")[3].downcase == "research")
	class_name = "research"
end

# Uses the long date format in the notes
date_long = "#{`date +%B`.strip} #{`date +%e`.strip}, #{`date +%Y`.strip}"

# Makes the LaTeX headers
outfile = File.new("#{outfile_path}", "w")

outfile.puts("\\documentclass{school-#{class_name}-notes}")
outfile.puts("\\date{#{date_long}}")
outfile.puts("")
outfile.puts("\\begin{document}")

if (class_name == "ealc250")
	outfile.puts("\\begin{CJK*}{UTF8}{gbsn}")
end

outfile.puts("\\maketitle")
outfile.puts("")
outfile.puts("")
outfile.puts("")

if (class_name == "ealc250")
	outfile.puts("\\end{CJK*}")
end

outfile.puts("\\end{document}")

outfile.close

# Instantly opens up kwrite, in addition, does some stuff in the background
kwrite_thread = Thread.new{
	`kwrite "#{outfile_path}"`
}

# Figures out every notes file
tex_files = Array.new
Dir.foreach("."){|file|
	if (file.ends_with(".tex"))
		tex_files.push(file)
	end
}
tex_files.delete("__all__.tex")
tex_files.sort!

# Figures out the start date and end date
start_date = `cat "#{tex_files[0]}" | grep "\\date{" | head -1`.strip.split("{")[1].chomp("}")
end_date = `cat "#{tex_files[-1]}" | grep "\\date{" | head -1`.strip.split("{")[1].chomp("}")

# Attempts to create a compilation file
comp = File.new("__all__.tex", "w")

comp.puts("\\documentclass{school-#{class_name}-notes}")
comp.puts("\\date{#{start_date} - #{end_date}}")
comp.puts("")

comp.puts("
\\renewcommand{\\topic}[1]
{
	\\section{#1}
}

\\renewcommand{\\subtopic}[1]
{
	\\subsection{#1}
}

\\renewcommand{\\subsubtopic}[1]
{
	\\subsubsection{#1}
}
")
comp.puts("")

comp.puts("\\begin{document}")
comp.puts("\\maketitle")
comp.puts("\\makecontents")
comp.puts("")

# Skips the inimportant things
comp.puts("\\renewcommand{\\maketitle}[1]{}")
comp.puts("\\renewcommand{\\documentclass}[1]{}")
comp.puts("")
comp.puts("")

# Includes all the notes
tex_files.each{|file|
	comp.puts("\\input{#{file.chomp(".tex")}.stex}")
}
comp.puts("")

comp.puts("\\end{document}")

comp.close

# Updates the Configfile and Makefile
`tek`

# We're done
`this_process_does_not_exist`
