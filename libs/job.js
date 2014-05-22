var fs = require("fs")

function Job(id, name, ref, jobdir) {
  var job = {};
  if (id === undefined) throw "Missing id";
  if (name === undefined) throw "Missing name";
  job.id = id;
  job.name = name;
  job.created = (new Date()).toISOString();
  job.status = "created";
  job.ref = ref;

  // create job directory
  fs.mkdirSync(jobdir);
  // TODO handle errors in mkdir

  // internal data
  job.internal = {};
  job.internal.dir = jobdir;

  job.store = function() {
    if (job.internal.dir) {
      var file = job.internal.dir + "/job.json"
      fs.writeFileSync(file, JSON.stringify(job));
    }
  }
  
  job.run = function() {
    job.status = "running";
    job.started = (new Date()).toISOString();
    job.store();
  }
  job.error = function() {
    job.status = "error";
    job.ended = (new Date()).toISOString();
    job.store();
  }
  job.finish = function(result) {
    job.status = "finished";
    job.ended = (new Date()).toISOString();
    job.store();
  }

  job.store();
  return job;
}

module.exports = Job;

