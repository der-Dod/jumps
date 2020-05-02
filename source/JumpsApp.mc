using Toybox.Application as App;

class JumpsApp extends App.AppBase {

	hidden var _JumpsView;

	function initialize() {
        AppBase.initialize();
        _JumpsView = new JumpsView(self);
    }

    // onStart() is called on application start up
    function onStart(state) {
    	_JumpsView.onStart(self, state);
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	_JumpsView.onStop(self, state);
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ _JumpsView ];
    }
    
    // Read in the MULTIPLIER constant from user settings
    function getMultiplier() {
	    var value = getProperty("multiplier_prop");
	    if (value == null || !(value instanceof Float)) {
	        if (value != null) {
	            value = value.toString();
	            value = stringReplace(value, ",", ".");
            	value = value.toFloat();
	        } else {
	            value = 1.0;
	        }
	    }
	    return value;
    }

}