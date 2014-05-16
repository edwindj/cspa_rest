test = true

yaml = require("yamljs")
fs = require("fs")

timestamp = () ->
	d = new Date()
	d.toISOString()

class Service
	constructor: (@server, @name, @version="0.0.1", @path=".") ->
		@counter = @init_counter()
		@jobs = {}
		# create a job directory
	init_counter: () ->
		0 # create more intelligent job counter
	route: (@server) ->
		# add routing stuff to the server
	create_job: (name, input, on_end = null) ->
		@counter += 1
		id = @counter
		job = new Job(id, "/#{name}/job/#{id}", name, @version, input, {}, on_end)
		@jobs[job.id] = job
	
	run_job: (job) ->
		job.status = "running"
		job.started = timestamp()
		dump job

	dump: (job) ->
		json_path = "${@path}/#{job.id}/job.json"
		fs.writeFileSync json_path, JSON.stringify(job)

	POST_job: (req, res, next) ->
		req.param.name
	GET_job: (req, res, next) ->

	GET_job_result: (req, res, next) ->

class Job
	constructor: (@id, @url, @name, @version, @input, @result, @on_end=null) -> 
		@created = timestamp()
		@started = null
		@ended = null
		@status = "created"

exports.Service = Service

if test?
	server = {send: {}}
	svc = new Service(server, "LRC", "0.0.1")
	#console.log svc
	svc.create_job "test", {a:1}
	console.log svc
