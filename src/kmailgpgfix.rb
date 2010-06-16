MAX_COMBINATIONS = 10000

class Array
	def combination_all(&f)
		count = 0
		
		f.call(Array.new)
		
		1.upto(self.size){|n|
			self.combination(n){|c|
				count = count + 1
				if (count > MAX_COMBINATIONS)
					return
				end
				
				f.call(c)
			}
		}
	end
end

@orig = Array.new
while (read = gets)
	@orig.push(read.chomp)
end

tmpfile = `mktemp`.chomp
`chmod oug-rwx "#{tmpfile}"`
`chmod u+rw "#{tmpfile}"`

@possible_bleads = Array.new
@valid_lines = Array.new
enabled = false
signature = false
@orig.each_index{|index|
	if (@orig[index].strip == "-----BEGIN PGP SIGNED MESSAGE-----")
		enabled = true
	end
	
	if (@orig[index].strip == "-----BEGIN PGP SIGNATURE-----")
		signature = true
		enabled = false
	end
	
# 	puts "#{index} |#{@orig[index].size}|: #{@orig[index]}"
	
	if (enabled && (@orig[index+1] != nil))
		line = @orig[index]
		word = @orig[index+1].split(" ")[0]
		
		if (line == nil)
			line = ""
		end
		
		if (word == nil)
			word = ""
		end
		
		if ((line.length + word.length + 1) >= 60)
			@possible_bleads.push(index)
		end
	end
	
	if (enabled || signature)
		@valid_lines.push(index)
	end
	
	if (@orig[index].strip == "-----END PGP SIGNATURE-----")
		signature = false
		enabled = false
	end
}

@possible_bleads.combination_all{|all_bleads|
	# dumps to the temporary file
	testfile = File.open(tmpfile, "w")
	@orig.each_index{|index|
		if (@valid_lines.include?(index))
			if (all_bleads.include?(index-1))
				#skips this one
			elsif (all_bleads.include?(index))
				out = "#{@orig[index]}"
				index = index + 1
				
				while (all_bleads.include?(index - 1))
					out = "#{out} #{@orig[index]}"
					index = index + 1
				end
				
				testfile.puts(out)
			else
				testfile.puts(@orig[index])
			end
		end
	}
	testfile.close
	
	# attempts to verify
	gpgout = `gpg --verify "#{tmpfile}" 2>/dev/null ; echo $?`.strip
	if (gpgout == "0")
		puts "#{all_bleads.inspect}: #{gpgout}"
		File.delete(tmpfile)
		
		@orig.each_index{|index|
			if (all_bleads.include?(index-1))
				#skips this one
			elsif (all_bleads.include?(index))
				out = "#{@orig[index]}"
				index = index + 1
				
				while (all_bleads.include?(index - 1))
					out = "#{out} #{@orig[index]}"
					index = index + 1
				end
				
				puts(out)
			else
				puts(@orig[index])
			end
		}
		
		exit 0
	end
}

File.delete(tmpfile)

@orig.each_index{|index| puts @orig[index]}
