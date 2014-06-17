var YAML = require("yamljs");
var fs = require("fs");
var whiskers = require("whiskers");
var child_process = require("child_process");
var rimraf = require("rimraf");
var mkdirp = require("mkdirp");
var restify = require("restify");

var Job = require("./job.js");

function Service(server, servicedir, vpath) {  
  var service = {};
  service.server     = server;
  service.servicedir = servicedir;
  service.definition = require(service.servicedir + "/service.yaml");
  service.name       = (vpath || "") + service.definition.name;
  service.jobdir     = service.servicedir + "/jobs";
  service.jobs       = [];

  // remove old jobs
  rimraf(service.jobdir, function(error) {
    if (error) {
      throw "Failed to clean working directory '" + service.jobdir + "'.";
    }
    mkdirp(service.jobdir
       , function(error) {
      if (error) 
        throw "Failed to create working directory '" + service.jobdir + "'.";
    });
  });
  


  service.new_job = function(req, res, next) {
    if (!req.is("application/json")) 
      return next(new Error("Service expect JSON as input."));
    var id = service.jobs.length;
    var url = service.server.url + "/" + service.name + "/job/" + id;
    var job = service.jobs[id] = Job(id, req.body.name, url, service.jobdir + "/" + id);
    // TODO check if input is complete and correct
    job.input = req.body.input;
    job.url = url;
    service.start_job(job);
    res.header("Location", job.url);
    res.send(201, job);
    return next();
  }

  service.start_job = function(job) {
    var wd = service.jobdir + "/" + job.id + "/result";
    mkdirp.sync(wd);
    var command = whiskers.render(service.definition.command, {
      "service" : service,
      "job" : job
    });
    // start job
    job.run();
    var proc = child_process.exec(command, { "cwd" : wd });
    // handle finishing of job
    proc.on("error", function(err) {
      job.error();
    });
    proc.on("close", function(code, signal) {
      if (code == 0) {
        var result = service.definition.result;
        job.result = {};
        for (r in result) {
          job.result[r] = job.url + "/result/" + r;
        }
        job.finish();
      } else {
        job.error();
      }
      job.log = job.url + "/log";
    });
    // logging
    var logfile = fs.createWriteStream(wd + "/../log");
    proc.stderr.on("data", function(data) { logfile.write(data); });
    proc.stdout.on("data", function(data) { logfile.write(data); });
    proc.stdout.on("end", function() { logfile.close(); });
  }

  service.list_jobs = function(req, res, next) {
    if (req.accepts("text/html")) {
      fs.readFile(service.servicedir + "/html/jobs.html", function(err, template) {
        if (err) return next(err);
        res.header('Content-Type', 'text/html');
        res.status(200);
        var html = whiskers.render(template, {
          "service" : service,
          "jobs" : service.jobs
        });
        res.end(html);
        return next();
      });
    } else {
      res.send(service.jobs);
      return next();
    }
  }

  service.get_job = function(req, res, next) {
    // Retrieve the job from the job list
    var id = +req.params.id;
    var job = service.jobs[id];
    if (job === undefined){
      return next(new restify.ResourceNotFoundError("Unknown job"));
    }
    // When the client accepts html return a web page describing the job; otherwise
    // return the json object of the job. In this way webbrowsers (which accept both
    // html and json) will receive the html. The disadvantage is that clients wishing
    // to have json have to explicitly request json. 
    if (req.accepts("text/html")) {
      fs.readFile(service.servicedir + "/html/job.html", function(err, template) {
        if (err) return next(err);
        res.header('Content-Type', 'text/html');
        res.status(200);
        var html = whiskers.render(template, {
          "service" : service,
          "job" : job
        });
        res.end(html);
        return next();
      });
    } else {
      res.send(service.jobs[id]);
      return next();
    }
  }


  service.get_log = function(req, res, next) {
    var id = +req.params.id;
    var job = service.jobs[id];
    
    if (job === undefined) {
      res.status(403);
      return next(new Error("Undefined job: '" + id + "'."));
    }; 
  
    if (job.status == "created") {
      res.status(204);
      return next(new Error("Job had not yet started."));
    } 
    
    var status = job.status == "running" ? 204 : 200;
    fs.readFile(service.jobdir + "/" + job.id + "/log", function(err, data) {
      if (err) return next(err);
      res.header('Content-Type', 'text');
      res.status(status);
      res.end(data);
      return next();
    });
  }

  service.get_example_data = function(req, res, next) {
    var file = service.servicedir + "/example/input/" + req.params.file;
    // check if file exists
    fs.readFile(file, function(err, data) {
      if (err) return next(err);
      res.status(200);
      res.end(data);
      return next();
    });
  }

  service.get_result = function(req, res, next){
    var id = req.params[0];
    var path = req.params[1];

    var job = service.jobs[id];
    if (job === undefined) {
      res.status(403);
      return next(new Error("Undefined job: '" + id + "'."));
    }; 

    if (job.status != "finished") {
      res.status(204);
      res.end()
      return next();
    }

    var result = service.definition.result;
    var parts = path.split("/");
    for (var p in parts){
      if (result  !== undefined){ 
        result = result[parts[p]];
      }
    }
    
    if (result === undefined || result.filename === undefined) {
      res.status(403);
      return next(new Error("Undefined result: '" + path + "'."));
    }; 
    
    fs.readFile(service.jobdir + "/" + job.id + "/result/" + result.filename, function(err, data) {
      if (err) return next(err);
      res.header('Content-Type', result.mimetype);
      res.status(200);
      res.end(data);
      return next();
    });
  }

  server.post("" + service.name, service.new_job);
  server.get("" + service.name + "/job", service.list_jobs);
  server.get("/" + service.name + "/job/:id", service.get_job);
  server.get(RegExp("/" +  service.name + "/job/([^/]+)/result/(.*)"), service.get_result);
  // this next line catches the log statement
  server.get("/" + service.name + "/job/:id/log", service.get_log);
  server.get("/" + service.name + "/example/input/:file", service.get_example_data);
  

  console.log("Created service " + service.name + " on " + server.url + "/" + service.name + ".");

  return service;
}

module.exports = Service;
