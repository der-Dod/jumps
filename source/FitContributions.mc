using Toybox.WatchUi as Ui;
using Toybox.FitContributor as Fit;
using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.AntPlus;

// constants
const STEPS_SESSION_FIELD_ID = 0;
const STEPS_LAP_FIELD_ID = 1;
const VERT_OSC_FIELD_ID = 2;

class FitContributor
{
	// member variables
	hidden var mMultiplier = 1.0;
	
	hidden var mStepsSessionField = null;
	hidden var mStepsLapField = null;
	hidden var mTimerRunning = false;
	
	hidden var mStepsGlobal = null;
	hidden var mStepsSession = 0;
	hidden var mStepsLap = 0;
	hidden var mStepsSessionCorrected = 0;
	hidden var mStepsLapCorrected = 0;


	function initialize(dataField) {
		mStepsSessionField = dataField.createField(
            Ui.loadResource( Rez.Strings.label ),
            STEPS_SESSION_FIELD_ID,
            Fit.DATA_TYPE_UINT32,
            {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>Ui.loadResource( Rez.Strings.units )}
        );
        mStepsLapField = dataField.createField(
            Ui.loadResource( Rez.Strings.label ),
            STEPS_LAP_FIELD_ID,
            Fit.DATA_TYPE_UINT32,
            {:mesgType=>Fit.MESG_TYPE_LAP, :units=>Ui.loadResource( Rez.Strings.units )}
        );
        
        mStepsSessionField.setData(0);
        mStepsLapField.setData(0);

	}
	
	function onStart(app) {
		var info = Activity.getActivityInfo();
		
		// if the activity has restarted after "resume later", load previously stored steps values
		if (info != null && info.elapsedTime > 0) {
	        mStepsSession = app.getProperty(STEPS_SESSION_FIELD_ID);
	        mStepsLap = app.getProperty(STEPS_LAP_FIELD_ID);
	        if (mStepsSession == null) {
	            mStepsSession = 0;
	        }
	        if (mStepsLap == null) {
	            mStepsLap = 0;
	        }
        }
        
        // load the multiplier constant from app properties
        var multiplier = app.getMultiplier();
        if (multiplier != null) {
        	mMultiplier = multiplier;
        }
    }

    function onStop(app) {
    	// store current values of steps on stop for later usage (e.g., resume later)
        app.setProperty(STEPS_SESSION_FIELD_ID, mStepsSession);
        app.setProperty(STEPS_LAP_FIELD_ID, mStepsLap);
    }
	
	function compute() {
		if (mTimerRunning) {
	    	// read current step count
	    	var info = ActivityMonitor.getInfo();
	    	
	    	// compute and refresh current step counts (for entire session and individual laps)
	    	if (info != null && info.steps != null) {
	    		if (mStepsGlobal != null) {
			        if (info.steps < mStepsGlobal) { // probably step counter has been reset (e.g., midnight)
			        	mStepsSession += info.steps;
			        	mStepsLap += info.steps;
			        } 
			        else {
			        	mStepsSession += info.steps - mStepsGlobal;
			        	mStepsLap += info.steps - mStepsGlobal;
			        }
		        }
		        
		        mStepsGlobal = info.steps;
		    }
		    
		    mStepsSessionCorrected = (mStepsSession * mMultiplier).toNumber();
		    mStepsLapCorrected = (mStepsLap * mMultiplier).toNumber();
		    
		    // update lap/session FIT Contributions
		    mStepsSessionField.setData(mStepsSessionCorrected);
		    mStepsLapField.setData(mStepsLapCorrected);
	    }
	
		return mStepsSessionCorrected;
	}
        
    // start/resume
    function onActivityStart() {
    	mTimerRunning = true;
    }
    
    // stop/pause
    function onActivityStop() {
    	mTimerRunning = false;
    	mStepsGlobal = null;
    }
    
    function onTimerLap() {
    	mStepsLap = 0;
    }
    
    function onTimerReset() {
    	mStepsSession = 0;
    	mStepsLap = 0;
    }
}