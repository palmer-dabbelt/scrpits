require 'socket'
require 'thread'

PORT = 8080
HOSTNAME = "dabbelt.zapto.org"

# Prints the IP address
ip = `/sbin/ifconfig | grep "inet addr" | grep "Bcast" | head -1`.strip.split(":")[1].split(" ")[0]
puts "IP Address: #{ip}"

# Tells everybody we're listening
puts "Listening on #{PORT}"

# Prits out the URC
puts "Direct your browser to 'http://#{ip}:#{PORT}'"

# Accepts a single connection
socket = TCPServer.new(PORT)
client = socket.accept

# Checks that we have a get request
request = client.gets
if (request.split(" ")[0].downcase != "get")
	client.close
	socket.close
	exit 1
end

puts "\tClient connected"

# Opens the file for reading
file = File.new(ARGV[0], "r")
filename_short = ARGV[0].split("/")[-1]

# Sends a message that suggests that we get another file
client.puts("HTTP/1.0 302 Found")
client.puts("Location: /#{filename_short}")
client.puts("Content-type: text/html")
client.puts("")
client.puts("                <html>
                   <head><title>302 Found</title></head>
                   <body>302 Found <a href=\"#{filename_short}\">here</a>.</body>
                </html>")
client.close

# Checks again that we have a get request
client = socket.accept
request = client.gets
if (request.split(" ")[0].downcase != "get")
	client.close
	socket.close
	exit 1
end

# Passes the client the proper headers
client.puts("HTTP/1.1 200 OK")
client.puts("Content-Length: #{File.stat(ARGV[0]).size}")
client.puts("")

# Copies out the whole file
while (line = file.gets)
	client.puts(line)
end

# We're done with the connection
client.close
socket.close
