# Converts an Openoffice Spreadsheet to PRN format
#	Palmer Dabbelt <palmem@comcast.net>

TO_FILTER = {"%" => "\\%"}
TO_MATHMODE = ["\\delta", "\\rho", "\\frac{", "\\Delta"]
PRECISION = 5

def abs(num)
	if (num < 0)
		return -1 * num
	else
		return num
	end
end

if (ARGV[0] == nil)
	puts "ods2prn <input file> [output file]"
	puts "\tConverts an Openoffice Spreadsheet into a text file"
	exit 1
end

require 'rubygems'

require 'roo'
# all deps are (these were installed as gems)
#	hpricot
#	google-spreadsheet-ruby
#	spreadsheet
#	nokogiri
#	rubyzip
#	builder
#	roo
#	oauth

oo = Openoffice.new(ARGV[0])

output = nil
if (ARGV[1] == nil)
	output = File.new("/dev/stdout", "w")
else
	output = File.new(ARGV[1], "w")
end

number_of_rows = oo.last_column - oo.first_column + 1
output.puts("\\begin{tabular}{#{1.upto(number_of_rows).to_a.map{|i| "l"}.join("")}}")

(oo.first_row).upto(oo.last_row){|row_num|
	(oo.first_column).upto(oo.last_column){|col_num|
		val = oo.cell(row_num, col_num)
		
		if (val.class == Float)
			exponent = 0
			
			if (val != 0.0)
				while  (abs(val) < 1)
					val = val * 10
					exponent = exponent - 1
				end
				
				while (abs(val) >= 10)
					val = val / 10
					exponent = exponent + 1
				end
			end
			
			val = "$#{val.to_s[0..PRECISION-1]}"
			
			if (exponent != 0)
				val = "#{val} \\times 10^{#{exponent}}"
			end
			
			val = "#{val}$"
		end
		
		if (val == nil)
			val = ""
		end
		
		mathy = false
		TO_MATHMODE.each{|mathmode|
			if (val.include?(mathmode))
				mathy = true
			end
		}
		if (mathy == true)
			if !(val.include?("$"))
				val = "$#{val}$"
			end
		end
		
		TO_FILTER.each_pair{|from, to|
			val = val.split(from).join(to)
		}
		
		output.write(val)
		if (col_num != oo.last_column)
			output.write(" & ")
		end
	}
	
	output.puts(" \\\\")
}

output.puts("\\end{tabular}")
