

function Job(id, name, ref) {
  var job = {};
  if (id === undefined) throw "Missing id";
  if (name === undefined) throw "Missing name";
  job.id = id;
  job.name = name;
  job.created = (new Date()).toISOString();
  job.status = "created";
  job.ref = ref;
  
  job.run = function() {
    job.status = "running";
    job.started = (new Date()).toISOString();
  }
  job.error = function() {
    job.status = "error";
    job.ended = (new Date()).toISOString();
  }
  job.finish = function(result) {
    job.status = "finished";
    job.ended = (new Date()).toISOString();
  }

  return job;
}

module.exports = Job;

