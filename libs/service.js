var YAML = require("yamljs")
var fs = require("fs")
var whiskers = require("whiskers")
var child_process = require("child_process");
var Job = require("./job.js");

function Service(server, servicedir) {

  var service = {};
  service.server     = server;
  service.servicedir = servicedir;
  service.definition = require(service.servicedir + "/service2.yaml");
  service.name       = service.definition.name;
  service.jobdir     = service.servicedir + "/jobs";
  service.jobs       = [];
  service.url        = server.r

  // remove old jobs


  service.new_job = function(req, res, next) {
    if (!req.is("application/json")) 
      return next(new Error("Service expect JSON as input."));
    var id = service.jobs.length;
    var ref = service.server.url + "/" + service.name + "/job/" + id;
    service.jobs[id] = Job(id, req.body.name, ref);
    // TODO check if input is complete and correct
    service.jobs[id].input = req.body.input;
    service.jobs[id].ref = ref;
    service.start_job(id);
    res.status(201);
    res.header("Location", service.jobs[id].ref);
    res.send(service.jobs[id]);
    return next();
  }

  service.start_job = function(id) {
    var job = service.jobs[id];

    fs.mkdirSync(service.jobdir + "/" + id);
    // TODO handle errors in mkdir
    var wd = service.jobdir + "/" + id;
    var command = whiskers.render(service.definition.command, {
      "service" : service,
      "job" : service.jobs[id]
    });
    // start job
    service.jobs[id].run();
    var proc = child_process.exec(command, { "cwd" : wd });
    // handle finishing of job
    proc.on("error", function(err) {
      service.jobs[id].status = "error";
    });
    proc.on("close", function(code, signal) {
      if (code == 0) {
        service.jobs[id].finish();
        var result = service.definition.result;
        service.jobs[id].result = {};
        for (r in result) {
          service.jobs[id].result[r] = service.jobs[id].ref + "/" + r;
        }
      } else {
        service.jobs[id].error();
      }
    });
    // logging
    var logfile = fs.createWriteStream(wd + "/log");
    proc.stderr.on("data", function(data) { logfile.write(data); });
    proc.stdout.on("data", function(data) { logfile.write(data); });
    proc.stdout.on("end", function() { logfile.close(); });
  }

  service.get_job = function(req, res, next) {
    var id = +req.params.id;
    res.send(service.jobs[id]);
    return next();
  }


  function get_log(job, result) {
    if (job.status == "created") {
      res.status(204);
      return next(new Error("Job had not yet started."));
    } 
    var status = job.status == "running" ? 204 : 200;
    fs.readFile(service.jobdir + "/" + id + "/log", function(err, data) {
      if (err) return next(err);
      res.header('Content-Type', 'text');
      res.status(status);
      res.end(data);
      return next();
    });
  }

  service.get_result = function(req, res, next) {
    var id = +req.params.id;
    var result = req.params.result;
    var job = service.jobs[id];
    if (job === undefined) {
      res.status(403);
      return next(new Error("Undefined job: '" + id + "'."));
    }; 
    if (result == "log") return get_log(job, result);
    if (job.status != "finished") {
      res.status(204);
      res.end()
      return next();
    }
    var result = service.definition.result[result]
    if (result === undefined) {
      res.status(403);
      return next(new Error("Undefined result: '" + req.params.result + "'."));
    }; 
    fs.readFile(service.jobdir + "/" + id + "/" + result.filename, function(err, data) {
      if (err) return next(err);
      res.header('Content-Type', result.mimetype);
      res.status(200);
      res.end(data);
      return next();
    });
  }

  server.post("/" + service.name, service.new_job);
  //server.get('/LRC', new_job_form);
  server.get("/" + service.name + "/job/:id", service.get_job);
  server.get("/" + service.name + "/job/:id/:result", service.get_result);

  console.log("Created service " + service.name + " on " + server.url + "/" + service.name + ".");

  return service;
}

module.exports = Service;
