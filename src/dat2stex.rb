class String
	def to_scin()
		if !(self.include?("e"))
			return self
		end
		
		mantissa = self.split("e")[0].to_f
		exponent = self.split("e")[1].to_i
		
		if (exponent == 0)
			return mantissa.to_s
		else
			return "#{mantissa.to_s} \\times 10^{#{exponent.to_s}}"
		end
	end
end

in_file = File.open(ARGV[0], "r")
out_file = File.open(ARGV[1],"w")

while (read = in_file.gets)
	out_file.puts("#{read.strip.split("\t").map{|s| "$#{s.to_scin}$"}.join("&")}\\\\")
end