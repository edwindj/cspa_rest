var PORT = 8080;
var JOBDIR = __dirname + "/jobs";

var restify = require('restify');
var child_process = require("child_process");
var fs = require("fs");


var jobs = [];



function finish_job(id, code) {
  if (code != 0) {
    jobs[id].status = "error";
  } else {
    jobs[id].status = "finished";
  }
}

function start_job(id) {
  fs.mkdirSync(JOBDIR + "/" + id);
  // TODO check result of mkdir
  jobs[id].status = "running";
  var proc = child_process.spawn("R", ["--vanilla", "-f", __dirname + "/code/test.R", 
      "--args", __dirname + "/code/test.csv", "out.csv"], {
    "cwd" : JOBDIR + "/" + id
  });
  proc.on("close", function(code) { finish_job(id, code); });
}

function new_job(req, res, next) {
  if (req.is("application/json")) {
    id = jobs.length;
    jobs[id] = req.body;
    jobs[id].ref = server.url + "/service/jobs/" + id;
    jobs[id].status = "scheduled";
    start_job(id);
    res.status(201);
    res.header("Location", jobs[id].ref);
    res.send(jobs[id]);
  } else {
    next(new Error("Invalid data format."));
  }
}

function new_job_form(req, res, next) {
  fs.readFile("html/new_job.html", function (err, data) {
    if (err) {
      next(err);
      return;
    }
    res.header('Content-Type', 'text/html');
    res.status(200);
    res.end(data);
    next();
  });
}


function get_job(req, res, next) {
  res.send(jobs[+req.params.id]);
}

function get_job_result(req, res, next) {
  var id = req.params.id;
  if (req.params.result == "result") {
    fs.readFile(JOBDIR + "/" + id + "/out.csv", function (err, data) {
      if (err) {
        next(err);
        return;
      }
      res.header('Content-Type', 'text/csv');
      res.status(200);
      res.end(data);
      next();
    });
  }
}

var server = restify.createServer();
server.pre(restify.pre.userAgentConnection());
server.use(restify.bodyParser());
server.post('/service', new_job);
server.get('/service', new_job_form);
server.get('/service/jobs/:id', get_job);
server.get('/service/jobs/:id/:result', get_job_result);

server.listen(PORT, function() {
  console.log('%s listening at %s', server.name, server.url);
});

