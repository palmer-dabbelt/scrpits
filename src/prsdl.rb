require 'rubygems'
require 'hpricot'
require 'mechanize'

class String
	def starts_with(other)
		if (self.size < other.size)
			return false
		else
			return self[0 .. other.size - 1] == other
		end
	end
end

SLEEP_TIME = 140
DOWNLOAD_TIME = 20 * 60
USER_AGENT = "Linux Mozilla"

# Attempts to download lots of files
if (ARGV[0] == nil)
	puts "prsdl <download file>"
	exit 1
end

# Each line containts one URL
file = File.new(ARGV[0], "r")
while (form_url = file.gets)
	form_url.strip!
	out = form_url.split("/")[-1].strip
	
	# Skips the files we've already downloaded
	if (File.exists?(out))
		puts "#{out} exists, skipping"
	else
		agent = Mechanize.new
		agent.user_agent_alias = USER_AGENT
		
		# Some information
		puts "Downloading #{out}"
		
		# Gets the page to click
		form_page = nil
		done = false
		while (!done)
			form_page = agent.get(form_url)
			
			action = nil
			form_page.body.split("\n").each{|line|
				if (line.strip.starts_with("<form id=\"ff\""))
					action = line.split("action=\"")[1].split("\"")[0]
				end
			}
			
			if (action != nil)
				# Clicks the button
				free_form = form_page.form_with(:method => 'POST')
				free_form["dl.start"] = "Free"
				wait_page = agent.submit(free_form)
				
				# Waits on the wait page
				action = nil
				wait_page.body.split("\n").each{|line|
					if (line.strip.starts_with("var tt = '<form name=\"dlf\" action=\""))
						action = line.split("action=\"")[1].split("\"")[0]
					end
				}
				
				# Tests if we found a download action
				if (action != nil)
					sleep(SLEEP_TIME)
					
					data = agent.post(action, {"mirror" => action})
					out = File.new(out, "w");
					out.write(data.body)
					out.close
					
					done = true
				end
			end
			
			# Waits for a while between downloads
			puts "\t Done"
			sleep(DOWNLOAD_TIME)
		end
	end
end
