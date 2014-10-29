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

