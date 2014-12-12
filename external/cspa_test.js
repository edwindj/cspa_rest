
function test(div, context, test) {
  var panel = $("<div>").addClass("panel panel-default").appendTo(div);
  $("<div>").addClass("panel-heading").text(context).appendTo(panel);
  var messages = $("<div>").addClass("panel-body").appendTo(panel);

  function message_handler(error, message) {
    if (error) messages.parent().addClass("panel-danger").removeClass("panel-default");
    $("<p>").html(message)
      .addClass(error ? "alert alert-danger" : "alert alert-success")
      .appendTo(messages);
  }

  test(message_handler);
}

// Based on code from:
// http://stackoverflow.com/questions/7837456/comparing-two-arrays-in-javascript
var equal = function() {

  function array_equal(a, b) {
    if (a.length != b.length) return false;
    for (var i = 0, l=a.length; i < l; i++) {
      if (!equal(a[i], b[i])) return false;
    }       
    return true;
  }

  function object_equal(a, b) {
    //For the first loop, we only check for types
    for (propName in a) {
      //Check for inherited methods and properties - like .equals itself
      //https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/hasOwnProperty
      //Return false if the return value is different
      if (a.hasOwnProperty(propName) != b.hasOwnProperty(propName)) {
        return false;
      //Check instance type: Different types => not equal
      } else if (typeof a[propName] != typeof b[propName]) {
        return false;
      }
    }
    //Now a deeper check using other objects property names
    for(propName in b) {
      //We must check instances anyway, there may be a property that only exists in b
      if (a.hasOwnProperty(propName) != b.hasOwnProperty(propName)) {
        return false;
      } else if (typeof a[propName] != typeof b[propName]) {
        return false;
      }
      //If the property is inherited, do not check any more (it must be equa if both objects inherit it)
      if(!a.hasOwnProperty(propName)) continue;
      //Now the detail check and recursion
      if (!equal(a[propName], b[propName])) return false;
    }
    //If everything passed, let's say YES
    return true;
  }

  function equal(a, b) {
    if (a instanceof Array && b instanceof Array) {
      if (!array_equal(a, b)) return false;
    } else if (a instanceof Object && b instanceof Object) {
      if (!object_equal(a, b)) return false;
    } else if(a != b) {
      return false;
    }
    return true;
  }

  return equal;
}();


function compare_files(url1, url2, callback, getcall) {
  // determine how to load the files
  var json = /[.]json$/.test(url1);
  var csv = /[.]csv$/.test(url1);
  if (!getcall) getcall = json ? d3.json : d3.csv
  if (!getcall) {
    callback(true, "Unsupported file type: '" + url1 + "'.");
    return;
  }
  // load files and compare
  getcall(url1, function(error1, data1) {
    if (error1) {
      callback(true, "Error when loading '" + url1 + "': '" + error1 + "'.");
      return;
    }
    getcall(url2, function(error2, data2) {
      if (error2) {
        callback(true, "Error when loading '" + url2 + "': '" + error2 + "'.");
        return;
      }
      var res = equal(data1, data2);
      if (!res) {
        callback(true, "Files are not equal: <a href='"+url1+"'>" + url1 + "</a>"+
          "' vs <a href='"+url2+"'>'" + url2 + "'</a>.");
      } else {
        callback(false, "Files are equal: '" + url1 + "' vs '" + url2 + "'.");
      }
    });
  });
}

function compare_jobs(job, reference_job, callback, sub) {
  var fail = false;
  var pre = sub ? sub + "." : "";
  for (prop in reference_job) {
    // Check if property is present in job
    if (reference_job.hasOwnProperty(prop) && !job.hasOwnProperty(prop)) {
      callback(true, "Property '" + sub + prop + "' missing.");
      fail = true;
    } else {
      if (reference_job[prop] instanceof Object) {
        if (job[prop] instanceof Object) {
          compare_jobs(job[prop], reference_job[prop], callback, prop);
        } else {
          callback(true, "Property '" + sub + prop + "' is not an object.");
          fail = true;
        }
      } else if (reference_job[prop] !== "") {
        // assume reference_job[prop] and job[prop] are url's; download both 
        // files and check if they are the same
        compare_files(reference_job[prop], job[prop], callback);
      }
    }
  }
  if (fail) {
    callback(true, "Properties of job do not match those of the reference job.");
  } else if (!sub) {
    callback(false, "Properties of job match those of the reference job.");
  }
}



function expect_equal() {

  function on_error(error, message) {
    console.log(message);
  }


  function test(job, ref) {
    job.post(function(error, result_job) {
      if (error || job.status === "error") {
        on_error(true, "Job failed.");
        return;
      }
      on_error(false, "Job finished successfully.");
      d3.json(ref, function(error, reference_job) {
        if (error) {
          on_error(true, "Failed to load reference job: '" + ref + "'.");
          return;
        }
        compare_jobs(result_job, reference_job, on_error);
      });
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

function expect_error() {

  function on_error(error, message) {
    console.log(message);
  }

  function test(job) {
    job.post(function(error, result_job) {
      if (error) {
        on_error(true, "Failed to start job.");
        return;
      }
      if (result_job.status == "error") {
        on_error(false, "Finished with error (as expected).");
      } else {
        on_error(true, "Job did not finish with an error.");
      }
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

