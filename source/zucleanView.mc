using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Greg;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.UserProfile as Up;
//using Toybox.ActivityMonitor as Am;

class zucleanView extends Ui.WatchFace {

	//hidden var settingsChanged = true;
	
	// Icons
	var alarmIcon;
	var bluetoothIcon;
	var messagesIcon;
	var sleepIcon;
	
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        alarmIcon = Ui.loadResource(Rez.Drawables.id_alarm);
        bluetoothIcon = Ui.loadResource(Rez.Drawables.id_bluetooth);
        messagesIcon = Ui.loadResource(Rez.Drawables.id_messages);
        sleepIcon = Ui.loadResource(Rez.Drawables.id_sleep);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    		//checkSettings(dc);
    		
    		// Get and update progress indicator
    		var progress = View.findDrawableById("progressIndicator");
		progress.updateColor();
    		var movement = View.findDrawableById("movementIndicator");
		movement.updateColor();
    
        // Get and show the current time
        var clockTime = Sys.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var view = View.findDrawableById("TimeLabel");
        view.setText(timeString);
        
        // Date
        var nowInfo = Greg.info(Time.now(), Time.FORMAT_MEDIUM);
		var dateLabel = View.findDrawableById("DateLabel");
		var nowString = Lang.format("$1$ $2$ $3$", [nowInfo.day, nowInfo.month, nowInfo.day_of_week]);
		dateLabel.setText(nowString);
		
		// Battery
		var batteryLevel = Sys.getSystemStats();
		var batLabel = View.findDrawableById("BatteryLabel");
		var warningLabel = View.findDrawableById("WarningLabel");
		if (batteryLevel.battery < 10.0) {
			batLabel.setColor(Gfx.COLOR_RED);
			warningLabel.setText("battery low");
		}
		else {
			batLabel.setColor(Gfx.COLOR_WHITE);
			warningLabel.setText("");
		}
		var batteryString = Lang.format("$1$%",[batteryLevel.battery.format("%01d")]);
		batLabel.setText(batteryString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        // Draw icons
        var settings = Sys.getDeviceSettings();
      	if (settings.phoneConnected != null && settings.phoneConnected == true ){
      		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
	        	dc.drawBitmap(160, 5, bluetoothIcon);
      	}
      	if (settings.alarmCount != null && settings.alarmCount > 0 ){
      		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
	        	dc.drawBitmap(36, 5, alarmIcon);
      	}
  	    if (settings.notificationCount != null && settings.notificationCount > 0 ){
      		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
	        	dc.drawBitmap(145, 5, messagesIcon);
      	}

		// Old-style way to find if sleeping
	    var profile = Up.getProfile();
	    var sleepTime = profile.sleepTime.value();
	    var wakeTime = profile.wakeTime.value();
		var nowTime = (clockTime.hour * 60 + clockTime.min) * 60 + clockTime.sec;
		
	    var isSleeping = false;
	    if (sleepTime != null && wakeTime != null ) {
	     	if (sleepTime < wakeTime) {
				 isSleeping = nowTime > sleepTime && nowTime < wakeTime;			     		  
	     	} else if (sleepTime > wakeTime) {
 	     		isSleeping = nowTime > sleepTime || nowTime < wakeTime;
 	     	}
	    }
      	//if (Am.getInfo().isSleepMode == true) {
      	if (isSleeping == true) {
      		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
	        	dc.drawBitmap(51, 5, sleepIcon);
		}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

	// Private
	/*
	private function checkSettings(dc) {
    		if (!settingsChanged) {
			return;
		}
		
		settingsChanged = false;
    }
    */
}
