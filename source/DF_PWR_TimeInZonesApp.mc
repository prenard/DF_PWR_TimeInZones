// 
// Prod id = C1EB2C642BF84C2BBF5677E59CF96002
// Dev id  = 5efb299104b34d9ab800284c50ff6334
//
// History:
//
// 2018-02-10: Create Development Branch
//
//      * Add Power Graph
//
// 2017-12-28: Version 1.06
//
//		* CIQ 2.41 to support Edge 1030
//      * 1030 support
//

using Toybox.Application as App;
using Toybox.WatchUi as Ui;

var AppVersion="1.21-01";

class DF_PWR_TimeInZonesApp extends App.AppBase {

	var deviceFamily;
	var Device_Type;

    function initialize()
    {
        AppBase.initialize();
        
        Device_Type = Ui.loadResource(Rez.Strings.Device);
        System.println("Device Type = " + Device_Type);

        deviceFamily = Toybox.WatchUi.loadResource(Rez.Strings.deviceFamily);
        System.println("deviceFamily = " + deviceFamily);

        var DeviceSettings = System.getDeviceSettings();
        System.println("Device - Screen Height = " + DeviceSettings.screenHeight);
        System.println("Device - Screen Width = " + DeviceSettings.screenWidth);
        System.println("Device - Is Touchscreen = " + DeviceSettings.isTouchScreen);
		System.println("Total Memory = " + System.getSystemStats().totalMemory);
        
    }

    // onStart() is called on application start up
    function onStart(state)
    {
    }

    // onStop() is called when your application is exiting
    function onStop(state)
    {
    }

    // Return the initial view of your application here
    function getInitialView()
    {
		System.println("AppVersion = " + AppVersion);
		setProperty("App_Version", AppVersion);

		var Args = new [10];

		Args[0]  = readPropertyKeyInt("Z1_H",160);
		Args[1]  = readPropertyKeyInt("Z2_H",220);
		Args[2]  = readPropertyKeyInt("Z3_H",250);
		Args[3]  = readPropertyKeyInt("Z4_H",270);
		Args[4]  = readPropertyKeyInt("Z5_H",300);
		Args[5]  = readPropertyKeyInt("Z6_H",410);
		Args[6]  = readPropertyKeyInt("Display_Timer",2);
		Args[7]  = readPropertyKeyInt("Avg_Duration",3);
		Args[8]  = readPropertyKeyInt("Graph_Timer",4);
		//Args[9] = getProperty("Display_Graph");
		Args[9] = Application.Properties.getValue("Display_Graph");

        return [ new DF_PWR_TimeInZonesView(Args) ];
    }

	function readPropertyKeyInt(key,thisDefault)
	{
		//var value = getProperty(key);
		var value = Application.Properties.getValue(key);
		
		
        if(value == null || !(value instanceof Number))
        {
        	if(value != null)
        	{
            	value = value.toNumber();
        	}
        	else
        	{
                value = thisDefault;
        	}
		}
		return value;
	}

}