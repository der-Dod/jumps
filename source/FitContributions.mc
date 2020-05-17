using Toybox.WatchUi as Ui;
using Toybox.FitContributor as Fit;
using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.Attention;

// constants
const STEPS_SESSION_CHART_ID = 0;
const STEPS_SESSION_FIELD_ID = 1;
const STEPS_LAP_FIELD_ID = 2;
const JPM_SESSION_CHART_ID = 3;
const SPJ_SESSION_CHART_ID = 4;
const JD_SESSION_FIELD_ID = 5;

const MET_FACTOR = 8.130; // =100/12.3 (Jump Effect from 0 to 100, 12.3 is MET max)
const MET_20_120 = 147.6; // 20min à 120jpm = sum(MET)=12.3*20*60=14760; + factor 10

// only for test in CIQ Simulator
const DEBUG = false;

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
	
	hidden var mStepsPerMinute = 0;
	hidden var mSecondsPerStep = 0;
	hidden var mJpmSessionChart = null;
	hidden var mSpjSessionChart = null;
	
	hidden var arrayJumps = null;
	hidden var arrayIndex = 0;
	
	hidden var mJumpDensityField = null;
	hidden var secondsElapsed = 0;
	// hidden var secondsJumped = 0;
	// hidden var jumpDensity = 0;
	hidden var mMetTotal = 0.0f;
	hidden var mMetAvg = 0.0f;
	hidden var mJumpingEffect = 0.0f;
	hidden var mGoalReached = 0;
	hidden var mCals;
	
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
        mJumpDensityField = dataField.createField(
            Ui.loadResource( Rez.Strings.jd_label ),
            JD_SESSION_FIELD_ID,
            Fit.DATA_TYPE_FLOAT,
            {:mesgType=>Fit.MESG_TYPE_SESSION, :units=>Ui.loadResource( Rez.Strings.jd_units )}
        );
        
        mStepsSessionField.setData(0);
        mStepsLapField.setData(0);
        mJumpDensityField.setData(0);

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
	
	function compute(mMultiplier, mField, mAverage, mCaloryGoal, mGoal) {
	    // initialize average length
	    if (arrayJumps == null) {
	        arrayJumps = new [mAverage];
	    }
	    // reset array if setting changed
	    if (mAverage != arrayJumps.size()) {
	    	arrayJumps = new [mAverage];
	    	arrayIndex = 0;
	    }
	    
	    var valueToReturn = null;
	    
		if (mTimerRunning) {
			secondsElapsed += 1;
		
	    	// read current step count
	    	var info = ActivityMonitor.getInfo();
	    		    	
	    	var deltaSteps = 0;
	    	var deltaStepsCorrected = 0;
	    	
	    	// compute and refresh current step counts (for entire session and individual laps)
	    	if (info != null && info.steps != null) {
	    		if (mStepsGlobal != null) {
			        if (info.steps < mStepsGlobal) { // probably step counter has been reset (e.g., midnight)
			        	deltaSteps = info.steps;
			        } 
			        else {
			        	deltaSteps = info.steps - mStepsGlobal;
			        }
			        deltaStepsCorrected = deltaSteps * mMultiplier;
			        mStepsSession += deltaSteps;
			        mStepsLap += deltaSteps;
			        // println(DEBUG, mStepsSession+", "+deltaSteps+", "+deltaStepsCorrected+", "+mStepsSessionCorrected);
		        }
		        
		        mStepsGlobal = info.steps;
		    }
		    
		    /*
		    // record total seconds jumped
		    if (deltaSteps > 0) {
		    		secondsJumped += 1;
		    }
		    if (secondsElapsed != 0) {
		    	jumpDensity = 100 * secondsJumped.toFloat() / secondsElapsed.toFloat();
		    } else {
		    	jumpDensity = 0;
		    }
		    */
		    
		    mStepsSessionCorrected = (mStepsSession * mMultiplier).toNumber();
		    mStepsLapCorrected = (mStepsLap * mMultiplier).toNumber();
		    // println(DEBUG, mStepsSession+", "+mStepsSessionCorrected);
		    
		    // running average assuming 1Hz data recording
		    // populate array if null
		    if  (arrayJumps[arrayIndex] == null) {
		    	for (var i = arrayIndex; i < arrayJumps.size(); ++i) {
		    		arrayJumps[i] = deltaStepsCorrected;
		    	}
		    } else {
		    	// ignore "jumps" in steps recording (8.3 jps is the WR for most jumps in 30s)
		        if (deltaStepsCorrected < 8) {
		    		arrayJumps[arrayIndex] = deltaStepsCorrected;
		    	} else {
		    		arrayJumps[arrayIndex] = 0;
		    	}
		    }
		    
		    var avgJumpsUser = 0;
		    // if curent value is 0, then user stopped to jump
		    if (deltaStepsCorrected != 0) {
		    	// non null average for spj to avoid peaks at beginning
		    	avgJumpsUser = mean_not_null(arrayJumps).toFloat();
			}
		    
		    mStepsPerMinute = (avgJumpsUser * 60).toNumber();
		    if (avgJumpsUser != 0) {
		    	mSecondsPerStep = (1 / (avgJumpsUser)).toFloat();
		    } else {
		    	mSecondsPerStep = 0.toFloat();
		    }
		    // println(DEBUG, arrayIndex+", "+mMultiplier+", "+mField+", "+mAverage+", j="+mStepsSessionCorrected+", jpm="+mStepsPerMinute+", spj="+mSecondsPerStep);
		    // println(DEBUG, arrayJumps);
		    
		    // Jumping Effect
		    mMetTotal += met(mStepsPerMinute);
		    mMetAvg = mMetTotal / secondsElapsed;
		    if (secondsElapsed != 0) {
		    	mMetAvg = mMetTotal / secondsElapsed * MET_FACTOR;
		    } else {
		    	mMetAvg = 0.0f;
		    }
		    mJumpingEffect = mMetTotal / MET_20_120;
		    // println(DEBUG, "Jpm="+mStepsPerMinute+", MET="+mMetAvg);
		    
		    // jumps goal
		    var mTypeIs = null;
		    var mTypeUnits = null;
		    if (mGoal == 0) {
		    	mTypeIs = mStepsSessionCorrected;
		    	mTypeUnits = " "+Ui.loadResource( Rez.Strings.goal_0 );
		    // calory goal
		    } else if (mGoal == 1) {
		    	mTypeIs = Activity.getActivityInfo().calories;
		    	mTypeUnits = "kcal";
		    	// mTypeUnits = Ui.loadResource( Rez.Strings.goal_1 );
		    }
		    
		    mCals = Activity.getActivityInfo().calories;
		    if (mGoalReached < 5) { // vibrate 5s
		    	if (mTypeIs == null) {
		    		mTypeIs = 0;
		    	}
		    	if (mCaloryGoal != 0 && mTypeIs >= mCaloryGoal) {
		    		valueToReturn = mCaloryGoal.format("%.0f")+mTypeUnits+" "+Ui.loadResource( Rez.Strings.goal_reached )+"!";
		    		mGoalReached += 1;
		    		// backlight on & off
					if (Attention has :backlight && mGoalReached == 1) {
			    		Attention.backlight(true);
					}
					if (Attention has :backlight && mGoalReached == 5) {
			    		Attention.backlight(false);
					}
					if (Attention has :vibrate) {
						var vibeData =
			    		[
			        	new Attention.VibeProfile(100, 500), // On for one seconds
			    		];
						Attention.vibrate(vibeData);
					}
		    	}
		    }
		    		    
		    // set next index of average array
		    arrayIndex = (arrayIndex + 1) % arrayJumps.size();
		    
		    // update lap/session FIT Contributions
		    mStepsSessionChart.setData(mStepsSessionCorrected);
		    mStepsSessionField.setData(mStepsSessionCorrected);
		    mStepsLapField.setData(mStepsLapCorrected);
		    mJpmSessionChart.setData(mStepsPerMinute);
		    mSpjSessionChart.setData(mSecondsPerStep);
		    mJumpDensityField.setData(mJumpingEffect);

			// debug log
			println(DEBUG, secondsElapsed+"s, Jpm="+mStepsPerMinute+", METt="+mMetTotal.format("%.0f")+", JE="+mJumpingEffect.format("%.1f")+", "+mCals+"/"+mCaloryGoal+"kcal");
		    
	    }
	    
	    // return value defined in settings
	    if (valueToReturn == null) {
		    //Total = default
		    if (mField == 0) {
		    	valueToReturn = mStepsSessionCorrected;
		    // Jumps per Minute
		    } else if (mField == 1) {
		        valueToReturn = mStepsPerMinute;
		    // Seconds per Jump
		    } else if (mField == 2) {
		        valueToReturn = mSecondsPerStep.format("%.2f");
		    // Jumping Effect
		    } else if (mField == 3) {
		        valueToReturn = mJumpingEffect.format("%.1f");
		    } else {
		    	valueToReturn = mStepsSessionCorrected;
		    }
	    }
		
		return valueToReturn;

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
