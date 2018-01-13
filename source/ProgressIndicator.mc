using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.System as Sys;
using Toybox.Application as App;

class ProgressIndicator extends Ui.Drawable {

	enum {
		Steps, 
		Movement
	}
	var infoType;

	hidden var mColor, mMaxWidth;

	var myWidth = 20;
	
	function initialize(params) {
		// You should always call the parent's initializer and
		// in this case you should pass the params along as size
		// and location values may be defined.
		Drawable.initialize(params);

		mMaxWidth = params.get(:maxWidth);
		infoType = params.get(:infoType);

		updateColor();    
	}

	// Lifecycle

	function onUpdate(dc) {
		updateComponent(dc);
	}

	function draw(dc) {
		updateComponent(dc);
	}

	// Update the color used by component	
	function updateColor() {
		if (infoType == Steps) { 
			var color = App.getApp().getProperty("LineColor");
			mColor = checkColor(color, Gfx.COLOR_ORANGE);
		} else {
			mColor = Gfx.COLOR_RED;
		}
	}

	// Update UI
	private function updateComponent(dc) {
		if (Sys.getDeviceSettings().activityTrackingOn == true) {
			// Info
			var y = infoType == Steps ? 120 : 117; // beneath date: 157, above time: 44, twins: 117
			var activityInfo = ActivityMonitor.getInfo();
			if (activityInfo != null) {
				var fraction = 0;
				if (infoType == Steps) {
					fraction = findStepsFraction(activityInfo);
				} else {
					fraction = findMovementFraction(activityInfo);
				}
				dc.setColor(mColor, mColor);
				dc.fillRectangle(32, y, fraction * 150, 2);
				dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);
				dc.fillRectangle(32 + fraction * 150, y, (1 - fraction) * 150, 2);
			}
		} else {
			dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);
			dc.fillRectangle(32, y, 150, 2);
		}
	}

	// Get the color
	private function checkColor(c, defcolor) {
		return c == null ? defcolor : c;
	}  

	// Calculate fraction for steps
	private function findStepsFraction(activityInfo) {
		var steps = activityInfo.steps;
		if (steps == null) { 
			steps = 0;
		}

		var stepGoal = activityInfo.stepGoal;
		if (stepGoal == null) {
			stepGoal = 1;
		}

		steps = steps.toFloat();
		stepGoal = stepGoal.toFloat();
		var fraction = steps/stepGoal;
		if (fraction >= 1.0) {
			fraction = 1.0;
		}

		return fraction;
	}

	// Calculate fraction for movement
	private function findMovementFraction(activityInfo) {
		var currMoveLevel = activityInfo.moveBarLevel;
		var maxMoveLevel = ActivityMonitor.MOVE_BAR_LEVEL_MAX;
		return currMoveLevel / maxMoveLevel;
	}
}