fs = require("fs")
path = require("path")
mkdirp = require("mkdirp")
whiskers = require("whiskers")
restify = require("restify")
child_process = require("child_process")
yaml = require("yamljs")


timestamp = () ->
	d = new Date()
	d.toISOString()

class Service
	constructor: (definition) ->
		# TODO check existence of definition
		@svc = require definition
		@name = @svc.name
		
		@basepath = path.dirname definition
		@job_path =  "#{@basepath}/job"

		@svc.version ?= "0.0.0"
		
		@counter = @init_counter()
		@jobs = {}
		@def = JSON.stringify @svc
	
	add_to: (@server) ->

		server.post("/#{@name}", @POST_job);
		server.post("/#{@name}/job", @POST_job);
		server.get("/#{@name}/job", @GET_jobs);
		server.get("/#{@name}/job/:id", @GET_job);
		s = "/#{@name}/job/[^/]+/result/.*"

		server.get(RegExp("/#{@name}/example/?.*"), restify.serveStatic
			directory: ".",
			"default": "#{@name}/example/job.json"
		)
		console.log "Added service: #{@name}"
		console.log path.resolve "."

	create_job: (name, input, on_end = null) ->
		console.log @server.address()
		@url = "#{@server.url}/#{@name}"
		@counter += 1
		id = @counter
		job = new Job(id, "#{@url}/job/#{id}", name, @svc.version, input, {}, on_end)
		@jobs[job.id] = job

		# create a context in which the template of the definition can be evaluated
		ctxt = {}
		ctxt[key] = value for key, value of @svc
		ctxt.job = job
		ctxt.service = @
		# and fill the template with the context
		svc = JSON.parse whiskers.render @def, ctxt

		for key, value of svc.result
			job.result[key] = value.url
		job.command = svc.command

		mkdirp.sync "#{@job_path}/#{job.id}/input"
		mkdirp.sync "#{@job_path}/#{job.id}/result"
		job.save @job_path
		job
	
	run_job: (job) ->
		job.status = "running"
		job.started = timestamp()
		console.log "job_path = #{@job_path}"
		job.save @job_path
		#options = {cwd: "#{@job_path}/#{job.id}/result"}
		options = {cwd: "#{@basepath}"}
		cmd = child_process.exec job.command, options, (error, stdout, stderr) ->
			if error
				console.log error
		cmd.on "exit", (code) =>
			job.status = if code then "error" else "finished"
			job.ended = timestamp()
			console.log "exit code: #{code}"
			job.save @job_path
	init_counter: () ->
		0 # TODO improve this

	POST_job: (req, res, next) =>
		if req.is("json")
			job = req.body
			# TODO check input structure
			console.log job
			job = @create_job(job.name, job.input, job.on_end)
			#console.log job
			res.header("Location", job.url)
			res.send(201, job);
			@run_job job
		next()

	GET_job:  (req, res, next) =>
		id = req.params.id
		job = @jobs[id]
		if not job
			res.status 404
			return next(false)
		#console.log job
		res.send(200, job)
		#next()

	GET_jobs:  (req, res, next) =>
		console.log @jobs
		res.send(@jobs)
		next()

	GET_job_result:  (req, res, next) ->

class Job
	constructor: (@id, @url, @name, @version, @input, @result, @on_end=null) -> 
		@created = timestamp()
		@started = null
		@ended = null
		@status = "created"
	save: (job_path) -> 
		json_path = "#{job_path}/#{@id}/job.json"
		console.log "Writing job.json -> #{json_path}"
		fs.writeFileSync json_path, JSON.stringify(@, null, 2)

exports.Service = Service

if test?
	svc = new Service("../LRC/service.yaml")
	
	server = restify.createServer()
	server.pre(restify.pre.userAgentConnection())
	server.use(restify.bodyParser())
	
	svc.add_to server
	svc.create_job "bla", {data:"d", rules: "r"}
	svc.create_job "bla2", {data:"d", rules: "r"}
	#console.log svc