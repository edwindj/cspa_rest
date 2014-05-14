var restify = require('restify');


var jobs = [];

function start_job(id) {
  jobs[id].status = "running";
  setTimeout(function() {
    jobs[id].status = "finished";
  }, 10000);
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

function get_job(req, res, next) {
  res.send(jobs[+req.params.id]);
}


var server = restify.createServer();
server.pre(restify.pre.userAgentConnection());
server.use(restify.bodyParser());
server.post('/service', new_job);
server.get('/service/jobs/:id', get_job);

server.listen(8080, function() {
  console.log('%s listening at %s', server.name, server.url);
});

