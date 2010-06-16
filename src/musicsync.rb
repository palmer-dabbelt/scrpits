# encoding: utf-8
SOURCE_DIR="/home/palmer/.playlist/"
DEST_DIR="/mnt/rem/phone/music/"

EXTENSION = "mp3"
QUALITY = "128"

class String
	def ends_with(other)
		if (self.size < other.size)
			return false
		else
			return self[self.size - other.size .. -1] == other[0 .. -1]
		end
	end
	
	def gsub_s!(from, to)
		while (include?(from))
			gsub!(from, to)
		end
	end
	
	def gsub_s(from, to)
		out = "#{to_s}"
		
		while (out.include?(from))
			out.gsub!(from, to)
		end
		
		return out
	end
	
	def make_safe()
		out = "#{to_s}"
		
		out.gsub_s!(" ", "_")
		out.gsub_s!("-", "_")
		out.gsub_s!("\341", "a")
		out.gsub_s!("á", "a")
		out.gsub_s!("\351", "e")
		out.gsub_s!("é", "e")
		out.gsub_s!("\355", "i")
		out.gsub_s!("í", "i")
		out.gsub_s!("\363", "o")
		out.gsub_s!("ó", "o")
		out.gsub_s!("ú", "u")
		out.gsub_s!("\303\261", "n")
		out.gsub_s!("\361", "n")
		out.gsub_s!("ñ", "n")
		
		return out
	end
	
	def collapse!()
		out = Array.new
		
		split("/").each{|item|
			if (item == "..")
				out.pop
			else
				out.push(item)
			end
		}
		
		replace(out.join("/"))
	end
end

class MusicFile
	attr_accessor :path
	attr_accessor :artist
	attr_accessor :album
	attr_accessor :track_number
	attr_accessor :title
	attr_accessor :album_art
	
	def initialize()
		@path = ""
		@artist = ""
		@album = ""
		@track_number = 0
		@title = ""
	end
	
	def initialize(path)
		@path = path
		
		exifhash = Hash.new
		`exiftool "#{path}"`.split("\n").each{|line|
			key = line.split(":")[0].strip
			val = line.split(":")[1..-1].join(":").strip
			
			exifhash[key] = val
		}
		
		@artist = exifhash["Artist"].strip
		@album = exifhash["Album"].strip
		@track_number = exifhash["Track"].to_i
		@title = exifhash["Title"].strip
		
		@album_art = nil
		if (File.exists?("#{path.split("/")[0..-2].join("/")}/cover.jpeg"))
			@album_art = "#{path.split("/")[0..-2].join("/")}/cover.jpeg"
		elsif (File.exists?("#{path.split("/")[0..-2].join("/")}/cover.png"))
			`convert "#{"#{path.split("/")[0..-2].join("/")}/cover.png"}" "#{"#{path.split("/")[0..-2].join("/")}/cover.jpeg"}"`
			@album_art = "#{path.split("/")[0..-2].join("/")}/cover.jpeg"
		end
		
		if (@album_art != nil) && (File.size(@album_art) > 128*1024)
			`convert -geometry 300x300 "#{path.split("/")[0..-2].join("/")}/cover.png" "#{path.split("/")[0..-2].join("/")}/cover.jpeg"`
		end
	end
	
	def output_path()
		tag = "#{@artist.make_safe}-#{@album.make_safe}-#{@track_number.to_s.make_safe}-#{@title.to_s.make_safe}".gsub_s("//", "/")
		hash = `echo "#{tag}" | md5sum`.split(" ")[0]
		
		return "#{DEST_DIR}/#{hash}.#{EXTENSION}".gsub_s("//", "/")
	end
	
	def encode_to_output()
		tmp_file = "#{`mktemp`.strip}.wav"
		`mplayer "#{@path}" -ao pcm:file=#{tmp_file} 2> /dev/null`
		if (@album_art == nil)
			`lame #{tmp_file} "#{output_path}" -b #{QUALITY} --tt "#{@title}" --tl "#{@album}" --ta "#{@artist}" --tn "#{@track_number.to_s}" 2> /dev/null`
		else
			`lame #{tmp_file} "#{output_path}" -b #{QUALITY} --tt "#{@title}" --tl "#{@album}" --ta "#{@artist}" --tn "#{@track_number.to_s}" --ti "#{@album_art.to_s}" 2> /dev/null`
		end
		`rm #{tmp_file}`
	end
end

@@output_files = Array.new
Dir.foreach(DEST_DIR){|file|
	if (file[0].chr != ".")
		@@output_files.push("#{DEST_DIR}/#{file}".gsub_s("//", "/"))
	end
}

@@input_files = Array.new
@@input_playlist = nil
Dir.foreach(SOURCE_DIR){|file|
	if (file.ends_with(".m3u"))
		cur = "#{SOURCE_DIR}/#{file}".gsub_s("//", "/")
		
		if (@@input_playlist == nil)
			@@input_playlist = cur
		end
		
		if (File.mtime(@@input_playlist) < File.mtime(cur))
			@@input_playlist = cur
		end
	end
}

puts "Reading Playlist: '#{@@input_playlist}'"
@@input_playlist = File.new(@@input_playlist, "r")
while (read = @@input_playlist.gets)
	if (read.strip == "")
	elsif (read[0].chr == "#")
	else
		path = "#{SOURCE_DIR}/#{read}".strip
		path.gsub_s!("//", "/")
		path.collapse!
		
		musicfile = MusicFile.new(path)
		
		if (@@output_files.include?(musicfile.output_path))
			@@output_files.delete(musicfile.output_path)
		else
			puts "Encoding '#{musicfile.output_path}'"
			musicfile.encode_to_output()
		end
	end
end
@@input_playlist.close

puts @@output_files.join("\n")