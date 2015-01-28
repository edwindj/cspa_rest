

function Job(name, url) {
  var job = {};

  var input_ = {};

  job.name = function(n) {
    if (arguments.length == 1) {
      name = n;
      return this;
    } else {
      return name;
    }
  };

  job.url = function(u) {
    if (arguments.length == 1) {
      url = u;
      return this;
    } else {
      return url;
    }
  };

  function correct_local_href(href){
    if (href[0] == '/'){
       href = "http://localhost:8080" + href
    }
    return href
  }

  job.input = function(name, input, schema) {
    if (arguments.length === 1) {
      return input_[name];
    } else if (arguments.length === 2) {
      input_[name] = correct_local_href(input);
      return this;
    } else if (arguments.length === 3) {
      input_[name] = {"data" : correct_local_href(input), "schema" : correct_local_href(schema)};
      return this;
    } else {
      return input_;
    }
  };

  function wait_till_job_finished(url, callback) {
    d3.json(url)
      .header("Accept", "application/json")
      .get(function(error, job) {
        var finished = error || !(job.status === "running" || job.status === "created");
        if (finished) {
          callback(error, job);
        } else {
          setTimeout(function() { wait_till_job_finished(url, callback);}, 1000);
        }
      });
  }


  job.post = function(callback) {
    var jb = {
      "name" : name,
      "input" : input_
    }
    d3.json(url).header("Content-Type", "application/json")
      .post(JSON.stringify(jb), function(error, data) {
        if (error) callback(error); 
        wait_till_job_finished(data.url, callback);
      });
    return this;
    
  };

  return job;
}
