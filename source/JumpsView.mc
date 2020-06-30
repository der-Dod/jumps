using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class JumpsView extends Ui.SimpleDataField 
{
	// member variables
	hidden var fitContributor = null;
	hidden var multiplier;
	hidden var field;
	hidden var fieldName;
	hidden var average;
	hidden var caloryGoal;

    // Set the label of the data field here.
    function initialize(app) {
        SimpleDataField.initialize();
        fitContributor = new FitContributor(self);
        
        // load the multiplier constant from app properties and set label
        multiplier = app.getFloat("multiplier_prop");
        field = app.getProp("field_prop");
        fieldName = get_name_for_value(field);
        // label = Ui.loadResource( Rez.Strings.label ).toUpper(); // + ((multiplier != null) ? " x" + multiplier.format("%.2f") : "");
        label = fieldName.toUpper();
        
        // set average length for jpm spj charts
        average = app.getProp("average_prop");        
        
        caloryGoal = app.getProp("calory_goal");
        
    }
	
	// map field value to name
	function get_name_for_value(val) {
		var propName_map = {
			0 => Ui.loadResource(Rez.Strings.field_0),
			1 => Ui.loadResource(Rez.Strings.field_1),
			2 => Ui.loadResource(Rez.Strings.field_2),
			3 => Ui.loadResource(Rez.Strings.field_3)
		};
		return propName_map[val];
	}
	
	function onStart(app, state) {
        fitContributor.onStart(app);
    }

    function onStop(app, state) {
        fitContributor.onStop(app);
    }

    // Return number of steps. 
    function compute(info) {
        return fitContributor.compute(multiplier, field, average, caloryGoal);
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
    
    // update settings during activity
    function onUpdate() {
    	// not possible to udate label outside of initialize :/
    	field = App.getApp().getProp("field_prop").toNumber();
    	fieldName = get_name_for_value(field).toString();
    	// label = fieldName.toUpper();
    	
    	// updating multiplier leads to jump in steps graph -> disabled
    	// multiplier = App.getApp().getFloat("multiplier_prop");
    	
    	average = App.getApp().getProp("average_prop").toNumber();
    	caloryGoal = App.getApp().getProp("calory_goal").toFloat();
    	
    }

}