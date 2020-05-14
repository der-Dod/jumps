using Toybox.Application as App;
using Toybox.System;

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

    // return value from user settings without checking
    function getProp(prop) {
	    return getProperty(prop);
    }
    
    // not possible to update label outside of initialize :/
    // update displayed field from user settings
    function onSettingsChanged() {
    	_JumpsView.requestUpdate();
		_JumpsView.onUpdate();
    }

	/*
	// Play a predefined tone
	function goal_reached() {
		if (Attention has :playTone) {
			Attention.playTone(Attention.TONE_SUCCESS);
		}
		if (Attention has :backlight) {
    		Attention.backlight(true);
		}
		if (Attention has :vibrate) {
			var vibeData =
    		[
        	new Attention.VibeProfile(50, 2000), // On for two seconds
        	new Attention.VibeProfile(0, 2000),  // Off for two seconds
        	new Attention.VibeProfile(50, 2000), // On for two seconds
        	new Attention.VibeProfile(0, 2000),  // Off for two seconds
        	new Attention.VibeProfile(50, 2000)  // on for two seconds
    		];
			Attention.vibrate(vibeData);
		}
	}
	*/
}