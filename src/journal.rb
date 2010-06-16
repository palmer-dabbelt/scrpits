JOURNAL_PATH = "/home/palmer/.pim/journal/"
IDENTITY = "Palmer Dabbelt"
EDIT = lambda{|path| `kwrite "#{path}"`}
CLEAN = lambda{|path| ["#{path}~", "#{path}"]}
ENCRYPT = lambda{|in_paths, out_path| `cat #{in_paths.map{|s| s.inspect}.join(" ")} | gpg -ser "#{IDENTITY}" > #{out_path}`}
DECRYPT = lambda{|path| `cat "#{path}" | gpg`}

class String
	def chomp_front!(str)
		replace(chomp_front(str))
	end
	
	def chomp_front(str)
		return self.reverse.chomp(str.reverse).reverse
	end
end

# All the operations our program can preform
def op_create(args)
	if (args.size != 0)
		puts "create doesn't take any additional arguments"
		exit 1
	end
	
	# Makes sure we're not overwriting an entry
	journal_date = `date +%Y-%m-%d-%H-%M-%S`.strip
	journal_path = "#{JOURNAL_PATH}/#{journal_date}.gpg"
	if (File.exists?(journal_path))
		puts "The journal file '#{journal_path}' exists"
		puts "Someone might be trying to mess with you"
		exit 1
	end
	
	# Allows the user to edit the file
	tmp_path = `mktemp`.strip
	EDIT.call(tmp_path)
	tmp_file = File.new(tmp_path, "a")
	tmp_file.puts("")
	tmp_file.close
	
	date_path = `mktemp`.strip
	date_file = File.new(date_path, "w")
	date_file.puts("# journal: edited on #{journal_date}")
	date_file.puts("")
	date_file.close
	
	# Encrypts the file
	ENCRYPT.call([date_path, tmp_path], journal_path)
	
	# Cleans up after
	CLEAN.call(tmp_path).each{|path|
		if (File.exists?(path))
			File.delete(path)
		end
	}
	
	CLEAN.call(date_path).each{|path|
		if (File.exists?(path))
			File.delete(path)
		end
	}
end

def op_list(args)
	search_path = args.join("-")
	
	files = `ls "#{JOURNAL_PATH}/#{search_path}"*.gpg`.split("\n")

	files.sort!

	files.each{|file|
		puts file.chomp_front(JOURNAL_PATH).chomp_front("/").chomp(".gpg")
	}
end

def op_show(args)
	files = Array.new
	
	# Works like cat, puts all the files next to each other
	args.each{|file|
		full_path = "#{JOURNAL_PATH}/#{file}.gpg"
		
		if !(File.exists?(full_path))
			puts "File not found: '#{full_path}'"
			exit 1
		end
		
		files.push(full_path)
	}
	
	# Decrypts and shows each file
	files.each{|full_path|
		decrypted = DECRYPT.call(full_path)
		puts decrypted
	}
end


# This is the table of operations our journal can preform
@op_table = Hash.new
@op_table["create"] = lambda{|args| op_create(args)}
@op_table["list"] = lambda{|args| op_list(args)}
@op_table["show"] = lambda{|args| op_show(args)}

# And these are the aliases
@op_table["c"] = @op_table["create"]
@op_table["l"] = @op_table["list"]
@op_table["s"] = @op_table["show"]

# Now parses the argument
if (@op_table[ARGV[0]] == nil)
	puts "journal: The encrypted journal manager"
	puts "\t'#{ARGV[0]}': command not found"
	puts ""
	puts "create: Creates a new journal entry"
	puts "list [year] [month] [day] [hour] [minute] [second]: Lists all the entries (possible to filter)"
	puts "show <year-month-day-hour-minute-second> ...: Works like cat"
	puts ""
	puts "Note that 'create' uses a temporary file, in /tmp"
	exit 1
end

# Passes it on to someone else
@op_table[ARGV[0]].call(ARGV[1..-1])
