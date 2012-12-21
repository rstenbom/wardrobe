assets = [
	# skeleton.css		
		'files' : ['./site/lib/css/base.css', './site/lib/css/skeleton.css', './site/lib/css/layout.css'],
		'actions' : ['minify'],			
		'type' : 'css',		
		'to' : 'public/assets/css/',					
		'outputFile' : 'skeleton.css'
	,	
	# minified.css			
		'files' : ['./site/lib/styl/layout.styl', './site/lib/styl/style.styl'],
		'actions' : ['minify'],			
		'type' : 'stylus',		
		'to' : 'public/assets/css/',					
		'outputFile' : 'minified.css'
	,
	# libs.js				
		'files' : ['./site/lib/jslibs/underscore.js', './site/lib/jslibs/backbone.js'],
		'actions' : ['minify'],			
		'type' : 'javascript',		
		'to' : 'public/assets/js/',					
		'outputFile' : 'libs.js'
	,
	# app.js	
		'files' : ['./site/lib/coffee/app.coffee'],
		'actions' : ['minify'],			
		'type' : 'javascript',		
		'to' : 'public/assets/js/',					
		'outputFile' : 'app.js'	
]

module.exports = assets