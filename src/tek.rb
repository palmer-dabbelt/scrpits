require 'date'

class Dir
	def Dir.foreach_r(path, &f)
		Dir.foreach(path){|spath|
			if (spath[0].chr == ".")
				# nothing
			elsif (File.directory?("#{path}/#{spath}"))
				Dir.foreach_r("#{path}/#{spath}"){|sspath|
					f.call("#{sspath}")
				}
			else
				f.call("#{path}/#{spath}")
			end
		}
	end
end

class String
	def ends_with(other)
		if (self.size < other.size)
			return false
		else
			return self[self.size - other.size .. -1] == other
		end
	end
	
	def starts_with(other)
		if (self.size < other.size)
			return false
		else
			return self[0 .. other.size - 1] == other
		end
	end
	
	def chomp_front!(other)
		replace(chomp_front(other))
	end
	
	def chomp_front(other)
		return self.reverse.chomp(other.reverse).reverse
	end
end

class Dep
	def initialize()
		@deps = Array.new
		@cmds = Array.new
	end
	
	def deps()
		return @deps
	end
	
	def cmds()
		return @cmds
	end
end

class DepHash < Hash
	def initialize()
		super()
	end
	
	def [](other)
		if (super(other) == nil)
			self[other] = Dep.new
		end
		
		return super(other)
	end
end

class Makefile
	def initialize()
		@all = Array.new
		@clean = Array.new
		@targets = DepHash.new
	end
	
	def all()
		return @all
	end
	
	def clean()
		return @clean
	end
	
	def [](other)
		return @targets[other]
	end
	
	def write()
		out = File.new("Makefile", "w")
		
		out.puts("# Makefile autogenerated by tek @ #{DateTime.now}")
		out.puts("# Changes will be overwritten")
		out.puts("SHELL=/bin/bash")
		
		out.puts("all: #{all.join(" ")}")
		out.puts("\t")
		out.puts("")
		
		out.puts("clean::")
		@clean.each{|to_clean|
			out.puts("\trm #{to_clean.to_s.inspect} 2> /dev/null || true")
		}
		out.puts("\t#{`which pclean`.strip}")
		out.puts("")
		
		@targets.each_pair{|name, dep|
			out.puts("#{name}: #{dep.deps.join(" ")}")
			
			dep.cmds.each{|cmd|
				out.puts("\t#{cmd}")
			}
			
			out.puts("")
		}
	end
end

# All the different types of files in our system
class LatexPDF
	def LatexPDF.is_item(path)
		return File.exists?("#{path.chomp(".pdf")}.tex")
	end
	
	def LatexPDF.deps(path)
		dir = "."
		if (path.include?("/"))
			dir = path.split("/")[0..-2].join("/")
		end
	
		out = Array.new
		
		out.push("#{path.chomp(".pdf")}.tex")
		
		file = File.new("#{path.chomp(".pdf")}.tex", "r")
		while (read = file.gets)
			if (read.strip.starts_with("\\bibliography{") || read.strip.starts_with("\\makebibliography{"))
				out.push("#{dir}/#{read.split("{")[1].strip.split("}")[0].strip}.bib")
			end
			
			if (read.strip.starts_with("\\input{"))
				out.push("#{dir}/#{read.split("{")[1].strip.split("}")[0].strip}")
			end
			
			if (read.strip.starts_with("\\includegraphics{") || read.strip.starts_with("\\includegraphics["))
				out.push("#{dir}/#{read.split("{")[1].strip.split("}")[0].strip}")
			end
		end
		
		moredeps = Array.new
		out.each{|dep|
			if (dep.ends_with(".stex"))
				if (File.exists?("#{dep.chomp(".stex")}.tex}"))
					LatexPDF.deps("#{dep.chomp(".stex")}.pdf").each{|newdep|
						moredeps.push(newdep)
					}
				end
				
				moredeps.delete("#{dep.chomp(".stex")}.tex")
			end
		}
		
		moredeps.each{|dep|
			if !(out.include?(dep))
				out.push(dep)
			end
		}
		
		return out
	end
	
	def LatexPDF.cmds(path)
		dir = "."
		if (path.include?("/"))
			dir = path.split("/")[0..-2].join("/")
		end
		
		latexcmd = "cd #{dir} ; pdflatex -interaction=batchmode #{path.chomp(".pdf").chomp_front("#{dir}/")}.tex > /dev/null || pdflatex #{path.chomp(".pdf").chomp_front("#{dir}/")}.tex"
		
		out = Array.new
		
		# Checks for a bibtex
		bibtex = false
		file = File.new("#{path.chomp(".pdf")}.tex", "r")
		while (read = file.gets)
			if (read.strip.starts_with("\\bibliography{") || read.strip.starts_with("\\makebibliography{"))
				bibtex = true
			end
		end
		
		out.push(latexcmd)
		
		if (bibtex == true)
			out.push("bibtex #{path.chomp(".pdf")}")
			out.push(latexcmd)
		end
		
		out.push(latexcmd)
		
		if (File.exists?("#{path.chomp(".pdf")}.nb"))
			out.push("pdfcrop #{path.chomp(".pdf")}.pdf #{path.chomp(".pdf")}.pdf_crop")
			out.push("mv #{path.chomp(".pdf")}.pdf_crop #{path.chomp(".pdf")}.pdf")
		end
		
		out.push("rm #{path.chomp(".pdf")}.log 2> /dev/null || true")
		out.push("rm #{path.chomp(".pdf")}.aux 2> /dev/null || true")
		out.push("rm #{path.chomp(".pdf")}.out 2> /dev/null || true")
		out.push("rm #{path.chomp(".pdf")}.toc 2> /dev/null || true")
		out.push("rm #{path.chomp(".pdf")}.bbl 2> /dev/null || true")
		out.push("rm #{path.chomp(".pdf")}.blg 2> /dev/null || true")
		out.push("rm #{path.chomp(".pdf")}.nav 2> /dev/null || true")
		out.push("rm #{path.chomp(".pdf")}.snm 2> /dev/null || true")
		out.push("rm #{path.chomp(".pdf")}.lof 2> /dev/null || true")
		out.push("rm texput.log 2> /dev/null || true")
		
		return out
	end
	
	def LatexPDF.created(path)
		out = Array.new
		
		out.push("#{path.chomp(".pdf")}.pdf")
		out.push("#{path.chomp(".pdf")}.log")
		out.push("#{path.chomp(".pdf")}.aux")
		out.push("#{path.chomp(".pdf")}.out")
		out.push("#{path.chomp(".pdf")}.toc")
		out.push("#{path.chomp(".pdf")}.bbl")
		out.push("#{path.chomp(".pdf")}.blg")
		out.push("#{path.chomp(".pdf")}.nav")
		out.push("#{path.chomp(".pdf")}.snm")
		out.push("#{path.chomp(".pdf")}.lof")
		
		return out
	end
	
	def LatexPDF.more(path)
		dir = "."
		if (path.include?("/"))
			dir = path.split("/")[0..-2].join("/")
		end
		
		out = Array.new
		
		file = File.new("#{path.chomp(".pdf")}.tex", "r")
		
		while (read = file.gets)
			if (read.strip.starts_with("\\bibliography{") || read.strip.starts_with("\\makebibliography{"))
				out.push("#{dir}/#{read.split("{")[1].strip.split("}")[0].strip}.bib")
			end
			
			if (read.strip.starts_with("\\input{"))
				out.push("#{dir}/#{read.split("{")[1].strip.split("}")[0].strip}")
			end
			
			if (read.strip.starts_with("\\includegraphics{") || read.strip.starts_with("\\includegraphics["))
				out.push("#{dir}/#{read.split("{")[1].strip.split("}")[0].strip}")
			end
		end
		
		file.close
		
		return out
	end
end

class GnuPGPDF
	def GnuPGPDF.is_item(path)
		return path.ends_with(".pdf.gpg")
	end
	
	def GnuPGPDF.deps(path)
		out = Array.new
		
		out.push("#{path.chomp(".pdf.gpg")}.pdf")
		
		return out
	end
	
	def GnuPGPDF.cmds(path)
		out = Array.new
		
		out.push("rm #{path.chomp(".pdf.gpg")}.pdf.gpg 2> /dev/null || true")
		out.push("gpg --sign #{path.chomp(".pdf.gpg")}.pdf")
		
		return out
	end
	
	def GnuPGPDF.created(path)
		out = Array.new
		
		out.push("#{path.chomp(".pdf.gpg")}.pdf.gpg")
		
		return out
	end
	
	def GnuPGPDF.more(path)
		out = Array.new
		
		out.push("#{path.chomp(".pdf.gpg")}.pdf")
		
		return out
	end
end

class TexStex
	def TexStex.is_item(path)
		return File.exists?("#{path.chomp(".stex")}.tex")
	end
	
	def TexStex.deps(path)
		out = Array.new
		
		out.push("#{path.chomp(".stex")}.tex")
# 		out.push("#{path.chomp(".stex")}.pdf")
		
		return out
	end
	
	def TexStex.cmds(path)
		out = Array.new
		
		out.push("texstrip #{path.chomp(".stex")}.tex #{path}")
		
		return out
	end
	
	def TexStex.created(path)
		out = Array.new
		
		out.push("#{path.chomp(".stex")}.stex")
		
		return out
	end
	
	def TexStex.more(path)
		out = Array.new
		
		dir = "."
		if (path.include?("/"))
			dir = path.split("/")[0..-2].join("/")
		end
		
		file = File.new("#{path.chomp(".stex")}.tex", "r")
		
		while (read = file.gets)
			if (read.strip.starts_with("\\input{"))
				out.push("#{dir}/#{read.split("{")[1].strip.chomp("}").strip}")
			end
			
			if (read.strip.starts_with("\\includegraphics{") || read.strip.starts_with("\\includegraphics["))
				out.push("#{dir}/#{read.split("{")[1].strip.chomp("}").strip}")
			end
		end
		
		return out
	end
end

class ODSStex
	def ODSStex.is_item(path)
		return File.exists?("#{path.chomp(".stex")}.ods")
	end
	
	def ODSStex.deps(path)
		out = Array.new
		
		out.push("#{path.chomp(".stex")}.ods")
		
		return out
	end
	
	def ODSStex.cmds(path)
		out = Array.new
		
		out.push("ods2stex #{path.chomp(".stex")}.ods #{path}")
		
		return out
	end
	
	def ODSStex.created(path)
		out = Array.new
		
		out.push("#{path.chomp(".stex")}.stex")
		
		return out
	end
	
	def ODSStex.more(path)
		out = Array.new
		
		return out
	end
end

class GNUPlotPDF
	def GNUPlotPDF.is_item(path)
		return File.exists?("#{path.chomp(".pdf")}.gnuplot")
	end
	
	def GNUPlotPDF.deps(path)
		out = Array.new
		
		dir = "."
		if (path.include?("/"))
			dir = path.split("/")[0..-2].join("/")
		end
		
		out.push("#{path.chomp(".pdf")}.gnuplot")
		
		file = File.new("#{path.chomp(".pdf")}.gnuplot", "r")
		while (read = file.gets)
			read.strip!
			
			if (read.starts_with("plot") && read.include?("using"))
				datfile = read.split("using")[0]
				datfile.strip!
				datfile.chomp_front!("plot")
				datfile.strip!
				datfile.chomp_front!("\"")
				datfile.chomp!("\"")
				datfile.strip!
				
				if (dir != ".")
					datfile = "#{dir}/#{datfile}"
				end
				
				out.push(datfile)
			end
		end
		file.close
		
		return out
	end
	
	def GNUPlotPDF.cmds(path)
		dir = "."
		if (path.include?("/"))
			dir = path.split("/")[0..-2].join("/")
		end
		
		out = Array.new
		
		out.push("cd #{dir} ; gnuplot #{path.chomp(".pdf").chomp_front("#{dir}/")}.gnuplot > #{path.chomp(".pdf").chomp_front("#{dir}/")}.ps")
		out.push("ps2pdf #{path.chomp(".pdf")}.ps #{path.chomp(".pdf")}.pdf")
		out.push("rm  #{path.chomp(".pdf")}.ps")
		out.push("pdfcrop #{path.chomp(".pdf")}.pdf #{path.chomp(".pdf")}.pdf_crop")
		out.push("mv #{path.chomp(".pdf")}.pdf_crop #{path.chomp(".pdf")}.pdf")
		
		return out
	end
	
	def GNUPlotPDF.created(path)
		out = Array.new
		
		out.push("#{path.chomp(".pdf")}.ps")
		out.push("#{path.chomp(".pdf")}.pdf")
		out.push("#{path.chomp(".pdf")}.pdf_crop")
		
		return out
	end
	
	def GNUPlotPDF.more(path)
		out = Array.new
		
		GNUPlotPDF.deps(path).each{|dep|
			if (File.exists?("#{dep}.in") && File.exists?("#{dep}.proc"))
				out.push("#{dep}")
			end
		}
		
		return out
	end
end

class GNUPlotDAT
	def GNUPlotDAT.is_item(path)
		return File.exists?("#{path.chomp(".dat")}.dat.in")
	end
	
	def GNUPlotDAT.deps(path)
		out = Array.new
		
		out.push("#{path.chomp(".dat")}.dat.in")
		out.push("#{path.chomp(".dat")}.dat.proc")
		
		return out
	end
	
	def GNUPlotDAT.cmds(path)
		out = Array.new
		
		out.push("cat ./#{path.chomp(".dat")}.dat.in | ./#{path.chomp(".dat")}.dat.proc > ./#{path.chomp(".dat")}.dat")
		
		return out
	end
	
	def GNUPlotDAT.created(path)
		out = Array.new
		
		out.push("#{path.chomp(".dat")}.dat")
		
		return out
	end
	
	def GNUPlotDAT.more(path)
		out = Array.new
		
		return out
	end
end

class SVGImagePDF
	def SVGImagePDF.is_item(path)
		return File.exists?("#{path.chomp(".pdf")}.svg")
	end
	
	def SVGImagePDF.deps(path)
		out = SVGImagePDF.more(path)
		
		out.push("#{path.chomp(".pdf")}.svg")
		
		return out
	end
	
	def SVGImagePDF.cmds(path)
		out = Array.new
		
		out.push("inkscape #{path.chomp(".pdf")}.svg --export-pdf=#{path.chomp(".pdf")}.pdf")
		out.push("pdfcrop #{path.chomp(".pdf")}.pdf")
		out.push("mv #{path.chomp(".pdf")}-crop.pdf #{path.chomp(".pdf")}.pdf")
		
		return out
	end
	
	def SVGImagePDF.created(path)
		out = Array.new
		
		out.push("#{path.chomp(".pdf")}.pdf")
		out.push("#{path.chomp(".pdf")}.eps")
		
		return out
	end
	
	def SVGImagePDF.more(path)
		out = Array.new
		
		return out
	end
end

class PNGImagePDF
	def PNGImagePDF.is_item(path)
		return File.exists?("#{path.chomp(".pdf")}.png")
	end
	
	def PNGImagePDF.deps(path)
		out = SVGImagePDF.more(path)
		
		out.push("#{path.chomp(".pdf")}.png")
		
		return out
	end
	
	def PNGImagePDF.cmds(path)
		out = Array.new
		
		out.push("convert #{path.chomp(".pdf")}.png #{path.chomp(".pdf")}.pdf")
		
		return out
	end
	
	def PNGImagePDF.created(path)
		out = Array.new
		
		out.push("#{path.chomp(".pdf")}.pdf")
		
		return out
	end
	
	def PNGImagePDF.more(path)
		out = Array.new
		
		return out
	end
end

class JPEGImagePDF
	def JPEGImagePDF.is_item(path)
		return File.exists?("#{path.chomp(".pdf")}.jpeg")
	end

	def JPEGImagePDF.deps(path)
		out = SVGImagePDF.more(path)
		
		out.push("#{path.chomp(".pdf")}.jpeg")
		
		return out
	end

	def JPEGImagePDF.cmds(path)
		out = Array.new
		
		out.push("convert #{path.chomp(".pdf")}.jpeg #{path.chomp(".pdf")}.pdf")
		
		return out
	end

	def JPEGImagePDF.created(path)
		out = Array.new
		
		out.push("#{path.chomp(".pdf")}.pdf")
		
		return out
	end

	def JPEGImagePDF.more(path)
		out = Array.new
		
		return out
	end
end

class PDFCropPDF
	def PDFCropPDF.is_item(path)
		return File.exists?("#{path.chomp(".pdf")}.uncrop.pdf")
	end

	def PDFCropPDF.deps(path)
		out = SVGImagePDF.more(path)
		
		out.push("#{path.chomp(".pdf")}.uncrop.pdf")
		
		return out
	end

	def PDFCropPDF.cmds(path)
		out = Array.new
		
		out.push("pdfcrop #{path.chomp(".pdf")}.uncrop.pdf")
		out.push("mv  #{path.chomp(".pdf")}.uncrop-crop.pdf #{path.chomp(".pdf")}.pdf")
		
		return out
	end

	def PDFCropPDF.created(path)
		out = Array.new
		
		out.push("#{path.chomp(".pdf")}.pdf")
		out.push("#{path.chomp(".pdf")}.uncrop-crop.pdf")
		
		return out
	end

	def PDFCropPDF.more(path)
		out = Array.new
		
		return out
	end
end

class POVRayPDF
	def POVRayPDF.is_item(path)
		return File.exists?("#{path.chomp(".pdf")}.pov")
	end

	def POVRayPDF.deps(path)
		out = SVGImagePDF.more(path)
		
		out.push("#{path.chomp(".pdf")}.pov")
		
		return out
	end

	def POVRayPDF.cmds(path)
		out = Array.new
		
		out.push("povray +I #{path.chomp(".pdf")}.pov -geometry 4000x3000 -D +O#{path.chomp(".pdf")}.png")
		out.push("convert #{path.chomp(".pdf")}.png #{path.chomp(".pdf")}.pdf")
		out.push("rm #{path.chomp(".pdf")}.png")
		
		return out
	end

	def POVRayPDF.created(path)
		out = Array.new
		
		out.push("#{path.chomp(".pdf")}.pdf")
		out.push("#{path.chomp(".pdf")}.png")
		
		return out
	end

	def POVRayPDF.more(path)
		out = Array.new
		
		return out
	end
end


# How we can process each type of file
@@processors = Array.new
@@processors.push(LatexPDF)
@@processors.push(TexStex)
@@processors.push(ODSStex)
@@processors.push(GNUPlotPDF)
@@processors.push(GNUPlotDAT)
@@processors.push(SVGImagePDF)
@@processors.push(PNGImagePDF)
@@processors.push(JPEGImagePDF)
@@processors.push(PDFCropPDF)
@@processors.push(POVRayPDF)
@@processors.push(GnuPGPDF)

# All the .tex files in our item
to_process = Array.new
processed = Array.new
@@make_file = Makefile.new

if (ARGV.size == 0)
	Dir.foreach_r("."){|path|
		if (path.ends_with(".tex"))
			to_process.push("#{path.chomp(".tex")}.pdf".chomp_front("./"))
		end
	}
else
	ARGV.each{|path|
		if (path.ends_with(".tex"))
			to_process.push("#{path.chomp(".tex")}.pdf")
		else
			to_process.push("#{path}")
		end
	}
end

# The Makefile's "all" is all the PDFs, that's what we care about
to_process.each{|pdf_file|
	@@make_file.all.push(pdf_file)
}

# Processes our entire stack
while (to_process.size > 0)
	# One single item which we need to parse
	target = to_process.pop
	
	# Picks a processor
	processor = nil
	@@processors.each{|to_check|
		if (to_check.is_item(target))
			processor = to_check
		end
	}
	
	# Makes sure there's not a nil class
	if (processor == nil)
		puts "No processor found for #{target.inspect}"
		exit 1
	end
	
	# Uses the processor
	processor.deps(target).each{|item|
		@@make_file[target].deps.push(item)
	}
	
	processor.cmds(target).each{|item|
		@@make_file[target].cmds.push(item)
	}
	
	processor.created(target).each{|item|
		@@make_file.clean.push(item)
		processed.push(item)
	}
	
	processor.more(target).each{|item|
		if !(to_process.include?(item) || processed.include?(item))
			to_process.push(item)
		end
	}
end

@@make_file.write
