#!/usr/bin/ruby

# coding: utf-8

#requires EXIFTOOL

$LOAD_PATH.push("/home/palmer/prog/ruby_util/")

STRING_UTF8_MAPPING = {"\303\203\302\241" => "\341", "\302\277"=>"\277", "\303\241"=>"\341", "\303\255"=>"\355", "\303\263"=>"\363", "\303\251"=>"\351", "\303\203\305\241"=>"\303\232", "\303\203\302\261"=>"\361", "\303\203\302\263"=>"\363"}
CLEAN_UTF8_MAPPING = {"\363"=>"o", "\277"=>"?", "\351"=>"e", "\341"=>"a", "\355"=>"i", "\303\261"=>"n", "\361"=>"n", "\303\232"=>"U", "¡"=>"!", "¿"=>"?"}

class String
	def utf8()
		out = to_s
	
		STRING_UTF8_MAPPING.each_pair{|from, to|
			while (out.include?(from))
				out.gsub!(from, to)
			end
		}
		
		return out
	end
	
	def utf8!()
		STRING_UTF8_MAPPING.each_pair{|from, to|
			while (include?(from))
				gsub!(from, to)
			end
		}
	end
	
	def utf8_clean()
		out = utf8
	
		CLEAN_UTF8_MAPPING.each_pair{|from, to|
			while (out.include?(from))
				out.gsub!(from, to)
			end
		}
		
		return out
	end
	
	def utf8_clean!()
		utf8!
	
		CLEAN_UTF8_MAPPING.each_pair{|from, to|
			while (include?(from))
				gsub!(from, to)
			end
		}
	end
end

class String
	def gsub_all(from, to)
		out = "#{to_s}"
		 
		while (out.include?(from))
			out.gsub!(from, to)
		end
		
		return out
	end
	
	def gsub_all!(from, to)
		replace(to_s.gsub_all(from, to))
	end
end

class PaddedNum
	attr_accessor :value
	attr_accessor :padding
	attr_accessor :length
	attr_accessor :direction
	
	def initialize(val, padding=" ", length=0, direction=:right)
		@value = val
		@padding = padding
		@length = length
		@direction = direction
	end
	
	def to_s(padding=@padding, length=@length)
		out = value.to_s
		
		while (out.length < @length)
			if (@direction == :left)
				out = "#{padding}#{out}"
			elsif (@direction == :right)
				out = "#{out}#{padding}"
			end
		end
		
		return out
	end
	
	def copy()
		return PaddedNum.new(@value, @padding, @length, @direction)
	end
end 

class OS
	def OS.home_dir()
		return `echo $HOME`.chomp
	end
end

ACCENT_MAP = {"�" => "a", "�" => "e", "�" => "i", "�" => "o", "�" => "u", "ú" => "u"}
BAD_LIST = ["&", "^", "\"", "'"]
BAD_LIST_SINGLE = ["/"]
GOOD = "_"

class OS
	def OS.path_fix(str)
		out = "#{str}"
		
		out.gsub!("~", OS.home_dir)
		out.gsub_all!("//", "/")
		
		out = out.inspect[1..-2]
		
		return out
	end
	
	def OS.path_sanatize(str)
		out = "#{str}"
		
		ACCENT_MAP.each_pair{|from, to|
			out.gsub_all!(from, to)
		}
		
		BAD_LIST.each{|bad|
			out.gsub_all!(bad, GOOD)
		}
		
		return out
	end
	
	def OS.single_sanatize(str)
		out = OS.path_sanatize(str)
		
		BAD_LIST_SINGLE.each{|bad|
			out.gsub_all!(bad, GOOD)
		}
		
		return out
	end
end


FORMAT_KEYS = ["artist", "album", "tracknumber", "title", "extension"]

FORMAT = "/home/palmer/music/%artist/%album/%tracknumber-%title.%extension"
TRACKNUMBER_PADDING = 2
EXTENSIONS = ["flac", "ogg", "mp3", "m4a"]

COVER_EXT = ["jpg", "jpeg", "png"]
COVER_FORMAT = "/home/palmer/music/%artist/%album/"
COVER_NAME = "cover.png"
DIR_NAME = ".directory"

class Dir
	def Dir.foreach_nodot(dir, &f)
		Dir.foreach(dir){|file|
			if ([".", ".."].include?(file))
				#does nothing
			else
				f.call(file)
			end
		}
	end
end

def read_info_hash(filename)
	out = Hash.new
	
	`exiftool "#{filename}"`.split("\n").each{|line|
		key = line.split(":")[0].split(" ").join("").downcase.strip
		val = line.split(":")[1..-1].join(":").utf8.strip
		
		out[key] = val
	}
	
	return out
end

music_files = Array.new
cover = nil
Dir.foreach_nodot("./"){|file|
	ext = file.split(".")[-1]

	if (EXTENSIONS.include?(ext))
		music_files.push(file)
	elsif (COVER_EXT.include?(ext))
		cover = file
	end
}

artist = nil
album = nil
music_files.each{|musicfile|
	info = read_info_hash(musicfile)
	
	extension = OS.single_sanatize musicfile.split(".")[-1] 
	artist = OS.single_sanatize info["artist"]
	album = OS.single_sanatize info["album"]
	title = OS.single_sanatize info["title"]
	
	tracknumber = info["tracknumber"]
	if (tracknumber == nil)
		tracknumber = info["track"]
	end
	
	tracknumber = tracknumber.split(" of ")[0].to_i
	tracknumber = PaddedNum.new(tracknumber)
	tracknumber.padding = "0"
	tracknumber.length = TRACKNUMBER_PADDING
	tracknumber.direction = :left
	
	outpath = "#{FORMAT}"
	
	FORMAT_KEYS.each{|key| eval("outpath.gsub_all!(\"%#{key}\", #{key.to_s}.to_s)")}
	
	`mkdir -p "#{outpath.utf8_clean.split("/")[0..-2].join("/")}"`
	puts "Copying Music: #{outpath.utf8_clean}"
	`cp "#{musicfile}" "#{outpath.utf8_clean}"`
}

#copies the cover
if (cover != nil)
	outpath = "#{COVER_FORMAT}"
	
	outpath.gsub_all!("%artist", artist)
	outpath.gsub_all!("%album", album)
	
	`mkdir -p "#{outpath.utf8_clean}"`
	puts "Making Cover: #{outpath.utf8_clean}/#{COVER_NAME}"
	`convert "#{cover}" "#{outpath.utf8_clean}/#{COVER_NAME}"`
	
	dirfile = File.new("#{outpath.utf8_clean}/#{DIR_NAME}", "w")
	dirfile.puts("[Desktop Entry]")
	dirfile.puts("Icon=./#{COVER_NAME}")
	dirfile.close
end
	
