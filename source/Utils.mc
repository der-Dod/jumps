// Generic string replace function
function stringReplace(str, oldString, newString) {
	var result = str;
	
	while (true) {
		var index = result.find(oldString);
		
		if (index != null) {
			var index2 = index+oldString.length();
			result = result.substring(0, index) + newString + result.substring(index2, result.length());
		}
		else
		{
			return result;
		}
	}
	
	return null;
}

// mean of non null values
function mean_not_null(array) {
    var sum = 0;
    var j = 0;
    var ai;
    for (var i = 0; i < array.size(); ++i) {
	    ai = array[i].toFloat();
	    sum += ai;
	    if (ai != 0.toFloat()) {
	        ++j;
	    }
	}
	if (j != 0) {
		var return_val = sum / j;
		return return_val;
	} else {
		return 0;
	}
}
        