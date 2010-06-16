#!/usr/bin/ruby

DIRFILE_PATH = ".directory"
EXTENSIONS = ["jpg", "jpeg", "png"]
FORCED_EXTENSION = "png"
COVER_NAME = "cover"

@coverpath = nil
Dir.foreach(`pwd`.chomp){|file|
	start = file.split(".")[0]
	if (start != nil)
		start = start.split("_")[0]
		
		if (start != nil)
			if (start.strip == COVER_NAME)
				@coverpath = file
			end
			
			if (EXTENSIONS.include?(file.split(".")[-1]))
				if (@coverpath == nil)
					@coverpath = file
				end
			end
		end
	end
}

extension = @coverpath.split(".")[-1]
@oldpath = nil
if (extension != FORCED_EXTENSION)
	newpath = "#{@coverpath.split(".")[0..-2].join(".")}.#{FORCED_EXTENSION}"
	
	if (newpath != @coverpath)
		`convert "#{@coverpath}" "#{newpath}"`
	end
	
	`rm "#{@coverpath}"`
	@oldpath = @coverpath
	@coverpath = newpath
end

if (@coverpath.split(".")[0..-2].join(".") != COVER_NAME)
	`mv "#{@coverpath}" "#{COVER_NAME}.#{FORCED_EXTENSION}"`
	@coverpath = "#{COVER_NAME}.#{FORCED_EXTENSION}"
end

if (@coverpath != nil)
	@file = nil
	
	if (File.exists?(DIRFILE_PATH))
		@file = File.new(DIRFILE_PATH, "a")
	else
		@file = File.new(DIRFILE_PATH, "w")
		@file.puts("[Desktop Entry]")
	end
	
	puts "Setting coverpath to #{@coverpath}"
	if (@oldpath != nil)
		puts "\tConverted from #{@oldpath}"
	end
	
	@file.puts("Icon=./#{@coverpath}")
	
	@file.close
else
	puts "No cover found, they start with \"cover\""
	puts "Valid Extensions:"
	EXTENSIONS.each{|ext| puts "\t#{ext}"}
end