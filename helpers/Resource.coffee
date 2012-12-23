###
Resource Helper 0.1
===================

Maps resources within the resource folder to URL paths and returns JSON data 
from mongodb. Uses singular/plural pattern.
	
	# Get all posts offset by 20 and limit by 40 (maximum limit is 50)
	# Both offset and limit is optional
    "domain.com/resource/posts/20/40"
    
    # Get one post (currently only accepts ObjectID)
	"domain.com/resource/post/50d783d498270b387643e44d"

Example file in resources/post.json

    {		
	    "private" : false,
	    "database" : "blog",
	    "server" : "127.0.0.1",
	    "port" : 27017,
	    "collection" : "posts",
	    "methods" : "GET"	
    }

__NOTE__ This helper is currently a bit 'hacky' and needs to be improved upon.
###
fs = require 'fs'
inflection = require 'inflection'
mongo = require 'mongodb'
class Resource	

	constructor: (@resources, @resourcePaths) ->
		@resources = {}
		@resourcePaths = {}
		@__readResourcesSync './resources'

	__readResourcesSync: (path) ->
		###
		Checks the given path for JSON resources and adds it to 
		this.resources and this.resourcePaths to the instance of the object.

		__Arguments__

		    "path" relative to project root 	

		__Usage__

		    @__readResourcesSync './resources'

		###			
		available = fs.readdirSync path
		for resource in available						
			resourceNoExtension = resource.substr(0, resource.lastIndexOf("."));
			@resources[resourceNoExtension] = JSON.parse fs.readFileSync "#{path}/#{resource}", 'utf-8'
			@resourcePaths[resourceNoExtension] = path + '/' + resource			
	
	route: (urlPath, fn) ->	
		###
		This is the "magic" method of the resource helper. This matches the URL path
		to a resource if it exists, looks it up in mongo and then returns it within the callback
		in the data variable

		__Arguments__

		    "urlPath" current request urlpath
			(fn(err,data)) callback function
		
		__Usage__

		    Resources.route req.url, (err, data) ->

		###			
		# If id is a function it's safe to say no ID was passed		
		throw "No callback argument" if typeof fn isnt typeof Function
		urlArray = urlPath.split('/')
		resource = urlArray[2]

		if typeof resource is 'undefined'
			fn 'Resource can not be undefined'
		else
			resources = @resources
			if @resources[resource]
				r = @resources[resource]
				# We want to get one document of the resource
				resourceId = urlArray[3]
				if !resourceId
					fn "Must specify an ID when getting a single resource."
				else 
					# Get stuff from mongo					
					@__getOne r.server, r.database, r.port, r.collection, resourceId, (err, data) ->
						if err
							fn err, null
						else if data
							fn null, data
						else 
							fn null, null
			else if @resources[inflection.singularize(resource)]
				r = @resources[inflection.singularize(resource)]
				# We want to get a collection
				# Might make this assignments much sexier, sorry ;)				
				offset = parseInt(urlArray[3])
				offset = 0 if isNaN(offset)				
				limit  = parseInt(urlArray[4])				
				limit  = 0 if isNaN(limit) or limit > 50

				@__getMany r.server, r.database, r.port, r.collection, offset, limit, (err, data) ->
					if err
						fn err, null
					else if data
						fn null, data
					else 
						fn null, null				
			else 
				fn 'Resource does not exist', null

	__getOne: (server, database, port, collection, id, fn) ->	
		###
		Retrieve one document from MongoDB by ObjectID

		__Arguments__

		    "server" mongo host ip
		    "database" mongo database name
		    .port. mongo host port
		    "collection" mongo collection
		    "id" object id as string  
			(fn(err, data)) callback function

		__Usage__

		    @__getOne "127.0.0.1", "blog", 27017, "posts", "50d783d498270b387643e44d", (err, data) ->

		###				
		mongo.Db.connect "mongodb://#{server}:#{port}/#{database}", (err, db) ->			
			try 
				fn(err, null) if err
				collection = db.collection collection
				objid = mongo.BSONPure.ObjectID.createFromHexString id
				collection.findOne {_id : objid }, (err, data) ->				
					if err
						fn err, null
					else 
						fn null, data
			catch error
				fn "Could not find post with id #{id}", null
		
	__getMany: (server, database, port, collection, offset, limit, fn) ->
		###
		Retrieve many documents from MongoDB

		__Arguments__

		    "server" mongo host ip
		    "database" mongo database name
		    .port. mongo host port
		    "collection" mongo collection
		    .offset. offset for query
		    .limit. limit result set
			(fn(err, data)) callback function

		__Usage__

		    @__getMany "127.0.0.1", "blog", 27017, "posts", 0, 25, (err, data) ->

		###			
		mongo.Db.connect "mongodb://#{server}:#{port}/#{database}", (err, db) ->			
			try 									
				fn(err, null) if err
				collection = db.collection collection					
				collection.find({}).skip(offset).limit(limit).toArray (err, data) ->						
					if err 
						fn err, null
					else 
						fn null, data

			catch error
				fn "Could not find posts", null		
		
module.exports = new Resource