FROM=ARGV[0]
TO=ARGV[1]
FILES=ARGV[2..-1]

files = Array.new
FILES.each{|file|
    if (File.exists?(file))
        files.push(file)
    end
}

puts `rename "#{FROM}" "#{TO}" #{files.map{|s| s.inspect}.join(" ")}`

