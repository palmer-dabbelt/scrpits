BASE="/home/palmer/movies/tv"

class Dir
	def Dir.foreach_r(dir, &f)
		Dir.foreach(dir){|file|
			if (file[0].chr == ".")
			elsif (File.directory?("#{dir}/#{file}"))
				Dir.foreach_r("#{dir}/#{file}"){|subfile|
					f.call(subfile)
				}
			elsif (File.exists?("#{dir}/#{file}"))
				f.call("#{dir}/#{file}")
			end
		}
	end
end

@show = ARGV[0]
if (@show == nil)
	shows = Array.new
	
	Dir.foreach(BASE){|list|
		if (list[0].chr != ".")
			shows.push(list)
		end
	}
	
	shows = shows.sort_by{rand()}
	
	@show = shows[0]
end
@show.strip!

puts "Watching Show: #{@show}"

@episodes = Array.new
Dir.foreach_r("#{BASE}/#{@show}"){|episode|
	@episodes.push(episode)
}

@episodes = @episodes.sort_by{rand()}

@episodes.each{|episode|
	puts episode
	`vplayer "#{episode}" > /dev/null 2> /dev/null`
}