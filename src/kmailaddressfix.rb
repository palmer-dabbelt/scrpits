VCARD_DIRS = ["/home/palmer/.pim/contact/family/", "/home/palmer/.pim/contact/uiuc/",  "/home/palmer/.pim/contact/whs/"]

class String
	def starts_with(other)
		if (self.size < other.size)
			return false
		else
			return self[0 .. (other.size - 1)] == other[0 .. (other.size - 1)]
		end
	end
	
	def ends_with(other)
		return self.reverse.starts_with(other.reverse)
	end
	
	def chomp_front!(other)
		replace(chomp_front(other))
	end
	
	def chomp_front(other)
		return self.reverse.chomp(other.reverse).reverse
	end
	
	def path_clean!()
		out = Array.new
		
		self.split("/").each{|item|
			if (item == "..")
				out.pop
			else
				out.push(item)
			end
		}
		
		out = out.join("/")
		
		while (out.include?("//"))
			out.gsub!("//", "/")
		end
		
		replace(out)
	end
end

# Holds a map of email to name
@@addresses = Hash.new

# Reads the address book
VCARD_DIRS.each{|dir|
	Dir.foreach(dir){|filename|
		if (filename[0].chr != ".")
			file = File.new("#{dir}/#{filename}", "r")
			
			name = nil
			emails = Array.new
			
			while (read = file.gets)
				if (read.starts_with("FN:"))
					name = read.chomp_front("FN:").strip
				end
				
				if (read.starts_with("EMAIL:"))
					emails.push(read.chomp_front("EMAIL:").strip)
				end
				
				if (read.starts_with("EMAIL;TYPE=PREF:"))
					emails.push(read.chomp_front("EMAIL;TYPE=PREF:").strip)
				end
			end
			
			if (name != nil)
				emails.each{|email|
					@@addresses[email.downcase] = name
				}
			end
			
			file.close
		end
	}
}

# Reads the email
@@address = false
while (read = gets)
	if (!read.starts_with(" "))
		@@address = false
	end
	
	if (read.downcase.starts_with("from: ") || read.downcase.starts_with("to: ") || read.downcase.starts_with("cc: ") || read.downcase.starts_with("bcc:" ))
		@@address = true
	end
	
	if (@@address == true)
		email = read.downcase
		email.strip!
		email.chomp_front!("from: ")
		email.chomp_front!("to: ")
		email.chomp_front!("cc: ")
		email.chomp_front!("bcc: ")
		email.strip!
		email.chomp!(",")
		email.strip!
		
		if (email.include?("<"))
			email = email.split("<")[1]
			email.chomp!(">")
		end
		
		email.downcase!
		
		if (@@addresses[email] == nil)
			puts read.chomp
		else
			out = nil
			
			if (read.starts_with(" "))
				out = " "
			else
				out = "#{read.split(":")[0]}: "
			end
			
			puts "#{out}\"#{@@addresses[email]}\" <#{email}>"
		end
	else
		puts read.chomp
	end
end