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
		console.log "Added service: #{@name}"
		@create_job("test", {data: "bla", rules: "bla1"})

	create_job: (name, input, on_end = null) ->
		@url ?= "#{@server.url}/#{@name}"
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
		@run_job job
	
	run_job: (job) ->
		job.status = "running"
		job.started = timestamp()
		console.log "job_path = #{@job_path}"
		job.save @job_path
		options = {cwd: "#{@basepath}"}
		cmd = child_process.exec job.command, options, (error, stdout, stderr) ->
			if error
				console.log error
		cmd.on "exit", (code) =>
			job.status = if code then "error" else "finished"
			console.log "exit code: #{code}"
			job.save @job_path
	init_counter: () ->
		0 # TODO improve this

	POST_job: (req, res, next) =>
		if req.is("json")
			job = req.body
			# TODO check input structure
			job = @create_job(job.name, job.input, job.on_end)
			res.status(201)
			res.header("Location", job.url)
			res.send(job);
		next()

	GET_job:  (req, res, next) =>
		id = req.params.id
		job = @jobs[id]
		if not job
			res.status 404
			return next(false)
		console.log job
		#res.status(200) unless job;
		res.send(job)
		next()

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