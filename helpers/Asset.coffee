###
Asset Helper 0.1
================
__Example usage__

    require('./helpers/Asset.coffee').make(require './config/assets.coffee')
    
These methods are used to concatinate and minify all your assets.
###
fs       = require 'fs'
mkdirp   = require 'mkdirp'
path     = require 'path'
stylus 	 = require 'stylus'
cleanCSS = require 'clean-css'
uglify   = require 'uglify-js'
CoffeeScript = require 'coffee-script'

class AssetHelper	
	__checkStructure: (structure) ->					
		###
		Checks if the given paths exists, will create the directories recursively if non existant. 

		    [structure] an array of paths relative to project root

		    @checkStructure ['/public/assets/css/', '/public/assets/img/', '/public/assets/js/']

		###	 	
		structure = ['/public/assets/css/', '/public/assets/img/', '/public/assets/js/'] if ! structure 			
		for dir in structure 			
			dir = path.join __dirname, '../', dir # Resolve the parent path
			exists = fs.existsSync dir			
			if ! exists 				
				mkdirp.sync dir

	__write: (file, contents) ->
		###
		Write contents to file, this will DELETE the file if it already exists, use with __caution__
		    
		    "file" full path to file to write contents to
		    "contents" content to write

		    @write '/public/assets/css/minified.css', "body{background:'red'}"

		###		
		exists = fs.existsSync file					  	
		fs.unlinkSync file if exists
		fs.writeFileSync file, contents			
	__concatAndStringify: (files) ->
		###
		Returns a string of all the files concatinated together
		    
		    [files] array of paths to concatinate relative to project root		    

		    @write '/public/assets/css/minified.css', "body{background:'red'}"

		###			
		stringified = ''
		for file in files
			stringified += fs.readFileSync file, 'utf-8'
			stringified += "\n\n" # Add some spaces when concatinating files
		return stringified

	make: (array, fn) ->
		###
		Main use of the asset helper. This takes an array of objects and then concatinates the files into the outputfile
		will minify after concatination if action array contains 'minify'

		__Example object__

		    'files' : ['./site/lib/css/base.css', './site/lib/css/skeleton.css', './site/lib/css/layout.css'],
		    'actions' : ['minify'],			
		    'type' : 'css',		
		    'to' : 'public/assets/css/',					
		    'outputFile' : 'skeleton.css'			
		
		__Arguments__

		    [array] of objects
			(fn) callback

		__Usage__

		    AssetHelper.make [objects], -> () 		    	

		###			
		@__checkStructure()
		for object in array
			switch object.type 
				when "css"
					files = object.files					
					css = @__concatAndStringify(files);		
					css = cleanCSS.process(css) if object.actions.indexOf('minify') > -1			
					@__write object.to + object.outputFile, css
				when "javascript"					
					files = object.files
					i = 0
					coffeeFiles = []
					while i < files.length						
						extension = files[i].split('.').pop();
						# If it's a coffeescript file, replace it with a js extension and compile coffee to the js
						if extension == 'coffee'								
							coffeeFiles.push files[i]
							newfile = files[i].substr(0, files[i].lastIndexOf(".")) + ".js";
							coffee = fs.readFileSync files[i], 'utf-8'							
							jscript = CoffeeScript.compile coffee							
							@__write(newfile, jscript)							
							files[i] = newfile
						i++
					js = @__concatAndStringify(files);										
					@__write object.to + object.outputFile, js					
					# @todo do this using the uglifiers api instead so we dont have to write the file twicej 
					if object.actions.indexOf('minify') > -1 
						output = uglify.minify object.to + object.outputFile					
						@__write object.to + object.outputFile, output.code	
					# @todo Clean up the lib dir from javascript files compiled from coffee											
				when "stylus"										
					files = object.files
					output = '';		
					stylusString = @__concatAndStringify(files);
					stylus.render stylusString,
					  filename: object.outputFile
					, (err, css) ->
					  throw err if err
					  css = cleanCSS.process(css) if object.actions.indexOf('minify') > -1 					  	
					  output += css
					@__write object.to + object.outputFile, output	  					  

		if (typeof fn == typeof(Function)) 
			fn()

module.exports = new AssetHelper