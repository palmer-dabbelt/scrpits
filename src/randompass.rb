#!/usr/bin/env ruby

class Integer
	def letter()
		if (to_i < 10)
# 			return ("0".getbyte(0) + to_i).chr
			return ("0"[0] + to_i).chr
		elsif (to_i < 36)
# 			return ("a".getbyte(0) + to_i-10).chr
			return ("a"[0] + to_i-10).chr
		elsif (to_i < 62)
# 			return ("A".getbyte(0) + to_i-36).chr
			return ("A"[0] + to_i-36).chr
		else
			return nil
		end
	end
end


entropy = "1234567890123456"
entropy = entropy.split("").map{(rand * 62).to_i}.map{|i| i.letter}.join("")
puts entropy
