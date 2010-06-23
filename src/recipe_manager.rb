RECIPE_DIR = "/home/palmer/.recipes"
INDEX_FILE = "#{RECIPE_DIR}/index.xml"
HTML_DIR = "/home/palmer/public_html/recipes"
RM_VERSION = 1

require 'rubygems'

gem 'libxml-ruby', '>= 0.8.3'
require 'xml'

class Ingredient
end

class Step
end

class Image
end

class Recipe
	attr_accessor :name
	attr_accessor :ingredients
	attr_accessor :steps
	attr_accessor :servings
	attr_accessor :images
	
	def initialize()
		@name = nil
		@ingredients = Array.new
		@steps = Array.new
		@servings = nil
		@images = Array.new
	end
	
	def Recipe.from_node(node)
		
	end
	
	def to_node()
		node = XML::Node.new("recipe")
		
		node["name"] = @name.to_s
		node["servings"] = @servings.to_s
		
		steps = XML::Node.new("steps")
		@steps.each{|step|
			steps << step.to_nodes
		}
		node << steps
		
		images = XML::Node.new("images")
		@images.each{|image|
			images << image.to_node
		}
		node << images
		
		ingredients = XML::Node.new("ingredients")
		@ingredients.each{|ingredient|
			images << ingredient.to_node
		}
		node << ingredients
	end
end

# The different modes of using the program
@@modes = Hash.new
@@modes["help"] = lambda{|options| MODE_help(options)}
@@modes["create"] = lambda{|options| MODE_create(options)}

# Provides help
def MODE_help(options)
	puts @@modes.keys.join(" ")
end

# Allows you to create a new recipe
def MODE_create(options)
	if (options.size != 1)
		puts "Call create with the recipe name"
		exit 1
	end
	
	# The recipe name is the only argument
	recipe_name = options[0].to_s
	if (@@recipes[recipe_name] != nil)
		puts "Recipe already exists"
		exit 1
	end
	
	recipe = Recipe.new
	recipe.name = recipe_name
	
	@@recipes[recipe_name] = recipe
end

# Makes sure the recipe directory exists
if !(File.directory?(RECIPE_DIR))
	FileUtils::mkdir(RECIPE_DIR)
	doc = XML::Document.new
	
	doc.root = XML::Node.new("recipe_manager")
	doc.root["version"] = RM_VERSION.to_s
	
	doc.root << XML::Node.new("recipes")
	
	doc.save(INDEX_FILE, :indent=>true)
end

# Creates a new list of recipes
parser = XML::Parser.file(INDEX_FILE)
@@recipes = Hash.new

# Calls the correct mode
if (@@modes[ARGV[0]] == nil)
	puts "No mode, dumping you to help"
	@@modes["help"].call(Array.new)
	puts @@modes.inspect
else
	@@modes[ARGV[0]].call(ARGV[1..-1])
end

# Writes it out
doc = XML::Document.new
	
doc.root = XML::Node.new("recipe_manager")
doc.root["version"] = RM_VERSION.to_s

recipes = XML::Node.new("recipes")
@@recipes.each_pair{|name, recipe|
	recipes << recipe.to_node
}
doc.root << recipes

doc.save(INDEX_FILE)

