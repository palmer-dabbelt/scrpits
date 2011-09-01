if (ARGV.size == 0)
    puts "prename: from to files..."
    puts "\tFROM is the pattern in the original filenames"
    puts "\tTO is the pattern that FROM will get changed into by running prename"
    puts "\tFILES is the list of files to rename FROM=>TO on"
    exit 1
end

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

