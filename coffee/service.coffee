test = true

fs = require("fs")
mkdirp = require("mkdirp")
restify = require("restify")

timestamp = () ->
	d = new Date()
	d.toISOString()

class Service
	constructor: (@name, @version="0.0.1", @wd=".") ->
		@counter = @init_counter()
		@jobs = {}
		# create a job directory

	add_to: (@server) ->
		
		server.post("/#{@name}", @POST_job);
		server.post("/#{@name}/job", @POST_job);
		server.get('/#{@name}/job/:id', @GET_job);

	create_job: (name, input, on_end = null) ->
		@counter += 1
		id = @counter
		job = new Job(id, "/#{name}/job/#{id}", name, @version, input, {}, on_end)
		@jobs[job.id] = job
		wd = @wd
		mkdirp.sync "#{wd}/job/#{job.id}"
		job.save @wd
	
	run_job: (job) ->
		job.status = "running"
		job.started = timestamp()
		job.save @wd
	
	init_counter: () ->
		0 # TODO improve this

	POST_job: (req, res, next) ->
		if req.is("json")
			job = req.body
			# TODO check input structure
			job = create_job(job.name, job.input, job.on_end)
			res.status(201)
			res.header("Location", job.url)
			res.send(job);
		next()

	GET_job:  (req, res, next) ->
		id = req.param.id
		job = @jobs[id]
		res.status(200);
		res.send(job)
		next()

	GET_job_result:  (req, res, next) ->

class Job
	constructor: (@id, @url, @name, @version, @input, @result, @on_end=null) -> 
		@created = timestamp()
		@started = null
		@ended = null
		@status = "created"
	save: (basepath) -> 
		json_path = "#{basepath}/job/#{@id}/job.json"
		fs.writeFileSync json_path, JSON.stringify(@)

exports.Service = Service

if test?
	server = restify.createServer();
	server.pre(restify.pre.userAgentConnection());
	server.use(restify.bodyParser());
	svc = new Service("LRC", "0.0.1")
	svc.add_to server
	server.listen(8080, () ->
		console.log "listening"
	)
