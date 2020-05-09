using Toybox.WatchUi as Ui;
using Toybox.FitContributor as Fit;
using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.System;
using Toybox.Time;
using Toybox.Math;

// constants
const STEPS_SESSION_CHART_ID = 0;
const STEPS_SESSION_FIELD_ID = 1;
const STEPS_LAP_FIELD_ID = 2;
const JPM_SESSION_CHART_ID = 3;
const SPJ_SESSION_CHART_ID = 4;

class FitContributor
{
	// member variables
	hidden var mStepsSessionChart = null;
	hidden var mStepsSessionField = null;
    hidden var mStepsLapField = null;
	hidden var mTimerRunning = false;
	
	hidden var mStepsGlobal = null;
	hidden var mStepsSession = 0;
	hidden var mStepsLap = 0;
	hidden var mStepsSessionCorrected = 0;
	hidden var mStepsLapCorrected = 0;
	
	hidden var mPreviousSteps;
	hidden var mPreviousTime;
	hidden var mStepsPerMinute = 0;
	hidden var mSecondsPerStep = 0;
	hidden var mJpmSessionChart = null;
	hidden var mSpjSessionChart = null;
	
	hidden var arrayJumps = null;
	hidden var arrayIndex = 0;
	
	function set_avg_length(average) {
		arrayJumps = new [average];
	}

	function initialize(dataField) {
		mStepsSessionChart = dataField.createField(
            Ui.loadResource( Rez.Strings.label ),
            STEPS_SESSION_CHART_ID,
            Fit.DATA_TYPE_UINT32,
            {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>Ui.loadResource( Rez.Strings.units )}
        );
        mStepsSessionField = dataField.createField(
            Ui.loadResource( Rez.Strings.label ),
            STEPS_SESSION_FIELD_ID,
            Fit.DATA_TYPE_UINT32,
            {:mesgType=>Fit.MESG_TYPE_SESSION, :units=>Ui.loadResource( Rez.Strings.units )}
        );
        mStepsLapField = dataField.createField(
            Ui.loadResource( Rez.Strings.label ),
            STEPS_LAP_FIELD_ID,
            Fit.DATA_TYPE_UINT32,
            {:mesgType=>Fit.MESG_TYPE_LAP, :units=>Ui.loadResource( Rez.Strings.units )}
        );
        mJpmSessionChart = dataField.createField(
            Ui.loadResource( Rez.Strings.jpm_label ),
            JPM_SESSION_CHART_ID,
            Fit.DATA_TYPE_UINT32,
            {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>Ui.loadResource( Rez.Strings.jpm_units )}
        );
        mSpjSessionChart = dataField.createField(
            Ui.loadResource( Rez.Strings.spj_label ),
            SPJ_SESSION_CHART_ID,
            Fit.DATA_TYPE_FLOAT,
            {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>Ui.loadResource( Rez.Strings.spj_units )}
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
        
    }

    function onStop(app) {
    	// store current values of steps on stop for later usage (e.g., resume later)
        app.setProperty(STEPS_SESSION_FIELD_ID, mStepsSession);
        app.setProperty(STEPS_LAP_FIELD_ID, mStepsLap);
    }
	
	function compute(mMultiplier, mField, mAverage) {
	    // initialize average length
	    if (arrayJumps == null) {
	        arrayJumps = new [mAverage];
	    }
	    // reset array if setting changed
	    if (mAverage != arrayJumps.size()) {
	    	arrayJumps = new [mAverage];
	    	arrayIndex = 0;
	    }
	    
		if (mTimerRunning) {
	    	// read current step count
	    	var info = ActivityMonitor.getInfo();
	    	
	    	// only for test in CIQ Simulator b/c simulate data does not have steps
	    	// info.steps = Math.round(Activity.getActivityInfo().elapsedDistance.toFloat());
	    	/* if (mStepsGlobal != null) {
	    		info.steps = mStepsGlobal + arrayIndex;
	    	} else {
	    		info.steps = arrayIndex;
	    	} */
	    	// info.steps = Math.round((Math.sin(Math.rand())*3).abs());
	    	// System.println("random="+info.steps);
	    	
	    	var deltaSteps = 0;
	    	var deltaTime = 1;
	    	var mMomentTime = new Time.Moment(Time.now().value());
	    	
	    	// compute and refresh current step counts (for entire session and individual laps)
	    	if (info != null && info.steps != null) {
	    		if (mStepsGlobal != null) {
			        if (info.steps < mStepsGlobal) { // probably step counter has been reset (e.g., midnight)
			        	deltaSteps = info.steps;
			        } 
			        else {
			        	deltaSteps = info.steps - mStepsGlobal;
			        }
			    	mStepsSession += (deltaSteps * mMultiplier);
			    	mStepsLap += (deltaSteps * mMultiplier);
			    	deltaTime = mMomentTime.value() - mPreviousTime;
			    	
		        }
		        
		        mStepsGlobal = info.steps;
		        mPreviousTime = mMomentTime.value();
		    }
		    
		    mStepsSessionCorrected = mStepsSession.toNumber();
		    mStepsLapCorrected = mStepsLap.toNumber();
		    // System.println(deltaSteps+" / "+deltaTime+" * 60 * "+mMultiplier);
		    
		    /*
		    // current value can only be a multiple of 60, needs average over last n seconds
		    mStepsPerMinute = (deltaSteps / deltaTime * 60 * mMultiplier).toNumber();
		    if (deltaSteps != 0) {
		    	mSecondsPerStep = (deltaTime / (deltaSteps * mMultiplier)).toFloat();
		    } else {
		    	mSecondsPerStep = 0.toFloat();
		    }
		    // System.println("VAL: jumps="+mStepsSessionCorrected+", jpm="+mStepsPerMinute+", spj="+mSecondsPerStep);
		    */
		    
		    // running average assuming 1Hz data recording
		    // populate array if null
		    if  (arrayJumps[arrayIndex] == null) {
		    	for (var i = arrayIndex; i < arrayJumps.size(); ++i) {
		    		arrayJumps[i] = deltaSteps;
		    	}
		    } else {
		    	arrayJumps[arrayIndex] = deltaSteps;
		    }
		    
		    var avgJumpsMath = Math.mean(arrayJumps).toFloat();
		    var avgJumpsUser = mean_not_null(arrayJumps).toFloat();
		    // System.println("means: math="+Math.mean(arrayJumps)+", user="+avgJumps);
		    // System.println("average="+avgJumps);
		    mStepsPerMinute = (avgJumpsMath * 60 * mMultiplier).toNumber();
		    if (avgJumpsUser != 0) {
		    	mSecondsPerStep = (1 / (avgJumpsUser * mMultiplier)).toFloat();
		    } else {
		    	mSecondsPerStep = 0.toFloat();
		    }
		    // System.println(arrayIndex+", "+mMultiplier+", "+mField+", "+mAverage+", j="+mStepsSessionCorrected+", jpm="+mStepsPerMinute+", spj="+mSecondsPerStep);
		    // System.println(arrayJumps);
		    
		    arrayIndex = (arrayIndex + 1) % arrayJumps.size();
		    mPreviousTime = mMomentTime.value();
		    mPreviousSteps = info.steps;
		    
		    // update lap/session FIT Contributions
		    mStepsSessionChart.setData(mStepsSessionCorrected);
		    mStepsSessionField.setData(mStepsSessionCorrected);
		    mStepsLapField.setData(mStepsLapCorrected);
		    mJpmSessionChart.setData(mStepsPerMinute);
		    mSpjSessionChart.setData(mSecondsPerStep);
		    
	    }
	    
	    // return value defined in settings
	    var valueToReturn;
	    //Total = default
	    if (mField == 0) {
	    	valueToReturn = mStepsSessionCorrected;
	    // Jumps per Minute
	    } else if (mField == 1) {
	        valueToReturn = mStepsPerMinute;
	    // Seconds per Jump
	    } else if (mField == 2) {
	        valueToReturn = mSecondsPerStep.format("%.2f");
	    } else {
	    	valueToReturn = mStepsSessionCorrected;
	    }
		return valueToReturn;
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