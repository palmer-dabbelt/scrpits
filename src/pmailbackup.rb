require 'net/imap'
require 'date'

CONFIG_FILE = "#{`echo $HOME`.strip}/.pmailbackuprc.rb"

if !(File.exists?(CONFIG_FILE))
	puts "Create a #{CONFIG_FILE}"
	exit 1
end

require "#{CONFIG_FILE}"

class String
	def starts_with(str)
		if (str.size == 1)
			return self[0].chr == str
		else
			return (self[0..str.size-1] == str)
		end
	end
	
	def chomp_front(str)
		return self.reverse.chomp(str.reverse).reverse
	end
end

# This is today
today = DateTime.now

# Connects to the IMAP server
@@imap = Net::IMAP.new(IMAP[0], IMAP[1])
@@imap.authenticate('LOGIN', IMAP[2], IMAP[3])

# Selects the trash folder
@@imap.select(IMAP_TRASH)

@@imap.search("1:*").each{|uid|
	begin
		envelope = @@imap.fetch(uid, ["ENVELOPE"])[0].attr["ENVELOPE"]
		
		if (envelope != nil) && (envelope.date != nil)
			date = DateTime.parse(envelope.date)
			
			if (date != nil)
				if ((today - date) > KEEP_DAYS)
					# Ensures that we're moving into a valid folder
					folder = "#{IMAP_ARCHIVE}.#{date.year}.#{date.month}"
					if !(@@imap.list(IMAP_ARCHIVE, "#{date.year}.#{date.month}"))
						@@imap.create(folder)
					end
					
					# Move the message
					@@imap.copy(uid, folder)
					@@imap.store(uid, "+FLAGS", [:Deleted])
					@@imap.expunge
				end
			end
		end
	rescue
	end
}
