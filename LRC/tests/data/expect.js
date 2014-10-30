
function expect_equal() {

  function cmp_files(a, b, callback) {
    var json = /[.]json$/.test(a);
    var csv = /[.]csv$/.test(a);
    if (csv || json) {
      var call = json ? d3.json : d3.csv;
      queue().defer(call, a).defer(call, b)
        .await(function(error, data1, data2) {
          if (error) callback(true, "Failed to load files for comparison: '" + error + "'.");
          var res = equal(data1, data2);
          if (!res) {
            callback(true, "Files are not equal: '" + a + "' vs '" + b + "'.");
          } else {
            callback(false, "Files are equal: '" + a + "' vs '" + b + "'.");
          }
        });
    } else {
      callback(true, "Unsupported type: '" + a + "'.");
    }
  }

  function cmp_jobs(job, ref, callback, sub) {
    var fail = false;
    var pre = sub ? sub + "." : "";
    for (prop in ref) {
      // Check if property is present in job
      if (ref.hasOwnProperty(prop) && !job.hasOwnProperty(prop)) {
        callback(true, "Property '" + sub + prop + "' missing.");
        fail = true;
      } else {
        if (ref[prop] instanceof Object) {
          if (job[prop] instanceof Object) {
            cmp_jobs(job[prop], ref[prop], callback, prop);
          } else {
            callback(true, "Property '" + sub + prop + "' is not an object.");
            fail = true;
          }
        } else if (ref[prop] !== "") {
          // assume ref[prop] and job[prop] are url's; download both 
          // files and check if they are the same
          cmp_files(ref[prop], job[prop], callback);
        }
      }
    }
    if (fail) {
      callback(true, "Properties of job do not match those of the the reference job.");
    } else if (!sub) {
      callback(false, "Properties of job match those of the the reference job.");
    }
  }


  function on_error(error, message) {
    console.log(message);
  }


  function test(job, ref) {
    queue()
      .defer(job.post)
      .defer(d3.json, ref)
      .await(function(error, res, ref) {
        console.log(res);
        console.log(ref);
        cmp_jobs(res, ref, on_error);
      });
  }

  test.on_error = function(handler) {
    if (arguments.length === 0) {
      return on_error;
    } else {
      on_error = handler;
      return this;
    }
  };
 
  return test;
}
