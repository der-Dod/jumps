using Toybox.System;

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

// MET calculation
function met(jumps) {
	// from https://captaincalculator.com/health/calorie/calories-burned-jumping-rope-calculator/
	var met = 0.0f;
	if (jumps == null) {
		met = 0.0f;
	}
	if (jumps == 0) {
		met = 0.0f;
	} else if (jumps < 80) {
		met = 8.8f;
	} else if (jumps >= 80 && jumps < 100) {
		// met = 8.8f;
		met = 0.15 * jumps - 3.2;
	} else if (jumps >= 100 && jumps < 120) {
		// met = 11.8f;
		met = 0.025 * jumps + 9.3;
	} else if (jumps >= 120) {
		met = 12.3f;
	}
	return met;	
}

// logging
function println(debug, text) {
	if (debug) {
		System.println(text);
	}
}