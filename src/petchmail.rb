require 'net/pop'
require 'net/imap'

CONFIG_FILE = "#{`echo $HOME`.strip}/.petchmailrc.rb"

if !(File.exists?(CONFIG_FILE))
	puts "Create a #{CONFIG_FILE}"
	exit 1
end

require "#{CONFIG_FILE}"

# Connects to the IMAP server
@@imap = Net::IMAP.new(IMAP[0], IMAP[1])
@@imap.authenticate('LOGIN', IMAP[2], IMAP[3])

# Fetches each POP mail
POPS.each{|server|
	Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE)
	Net::POP3.start(server[0], server[1], server[2], server[3]){|index|
		index.each_mail{|mail|
			@@imap.append(IMAP_INBOX, mail.pop)
			mail.delete
		}
	 }
}
