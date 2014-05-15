test = true

yaml = require("yamljs")

class Service
	constructor: (@server, @name, @version) ->
		@counter = @init_counter()
		# create a job directory
	init_counter: () ->
		0 # create more intelligent job counter
	readDefinition:() ->
		# use yaml to read a service definition
	route: () ->
		# add routing stuff to the server
	createJob: (name, input, on_end) ->


exports.Service = Service

if test?
	server = {send: {}}
	console.log new Service(server, "LRC", "0.0.1")
