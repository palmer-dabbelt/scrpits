require 'rubygems'
require 'mechanize'

def download_fileserve(url, output)
	agent = Mechanize.new
	agent.follow_meta_refresh = true

	page = agent.get(url)
	
	puts page.inspect
end

download_fileserve('http://www.fileserve.com/file/qHYAx3b', "simpsons-04x11.avi")