using Toybox.WatchUi as Ui;

class JumpsView extends Ui.SimpleDataField 
{
	// member variables
	hidden var fitContributor = null;

    // Set the label of the data field here.
    function initialize(app) {
        SimpleDataField.initialize();
        fitContributor = new FitContributor(self);
        
        // load the multiplier constant from app properties and set label
        var multiplier = app.getMultiplier();
        label = Ui.loadResource( Rez.Strings.label ).toUpper(); // + ((multiplier != null) ? " x" + multiplier.format("%.2f") : "");
    }

	function onStart(app, state) {
        fitContributor.onStart(app);
    }

    function onStop(app, state) {
        fitContributor.onStop(app);
    }

    // Return number of steps. 
    function compute(info) {
        return fitContributor.compute();
    }
    
    function onTimerStart() {
    	fitContributor.onActivityStart();
    }
    
    function onTimerStop() {
    	fitContributor.onActivityStop();
    }
    
    function onTimerResume() {
    	fitContributor.onActivityStart();
    }
    
    function onTimerPause() {
    	fitContributor.onActivityStop();
    }
    
    function onTimerLap() {
    	fitContributor.onTimerLap();
    }
	
	function onTimerReset() {
    	fitContributor.onTimerReset();
    }
    
    function onNextMultisportLeg() {
    	fitContributor.onTimerReset();
    }
}