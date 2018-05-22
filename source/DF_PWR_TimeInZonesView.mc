using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class DF_PWR_TimeInZonesView extends Ui.DataField
{
	var Device_Type;
	
	var App_Title;
	
	var Max_Zones_Number = 7;
	var Max_Power = 1999;
	
	var Zones_Number = 0;
	var Zone_L = new [Max_Zones_Number];
	var Zone_H = new [Max_Zones_Number];
	var Zone_Time = new [Max_Zones_Number];

	var Max_Display_Timer = 10;
	var Display_Timer = 0;	

    var Loop_Index;
    var Loop_Size;
	var Loop_Value = new [Max_Display_Timer*Max_Zones_Number];

	var Power_Current = 0;
	var Power_Current_Zone = 0;

	var Avg_Power = 0;
	var Avg_Power_Zone = 0;
	var Avg_Duration = 0;

    var History_Power;
	var Next_Power_Sample_Idx;
	var Sum_Of_Power_Samples;
	var Number_Of_Power_Samples;

	var CustomFont_Value_Medium_1 = null;
	var CustomFont_Value_Medium_2 = null;
	var CustomFont_Value_Large_1 = null;

	// Layout Fields

    var DF_Title;
    var Power_Label;
    var Power_Value;
    var Power_Unit;
    var Power_Zone;
    var Z_Label;
    var Z_Value;
    var Z_Range;

	// Graph Management

	var Display_Graph = false;

	var Graph_Timer = 0;
    var arrayColours = [Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLUE, Gfx.COLOR_GREEN, Gfx.COLOR_YELLOW, Gfx.COLOR_ORANGE, Gfx.COLOR_RED, Gfx.COLOR_DK_RED];


	var arrayPowerSize = 0;
    var arrayPowerValue = new [0];
    var arrayPowerZone = new [0];
    var curPos;
	var avePowerValue = 0;
	var avePowerCount = 0;

	var Powermin = 0;
	var Powermax = 0;

	var DF_Title_x = 0;
	var DF_Title_y = 0;
	var DF_Title_font = Gfx.FONT_XTINY;

	var Power_Value_x = 0;
	var Power_Value_y = 0;
	var Power_Value_font = Gfx.FONT_XTINY;

	var Power_Zone_x = 0;
	var Power_Zone_y = 0;
	var Power_Zone_font = Gfx.FONT_XTINY;

	var Power_Unit_x = 0;
	var Power_Unit_y = 0;
	var Power_Unit_font = Gfx.FONT_XTINY;

	var Z_Label_x = 0;
	var Z_Label_y = 0;
	var Z_Label_font = Gfx.FONT_XTINY;

	var Z_Value_x = 0;
	var Z_Value_y = 0;
	var Z_Value_font = Gfx.FONT_XTINY;

	var Z_Range_x = 0;
	var Z_Range_y = 0;
	var Z_Range_font = Gfx.FONT_XTINY;

	var Graph_Right_x = 0;
	var Graph_Bottom_y = 0;

	
    function initialize(Args)
    {
        DataField.initialize();

	    Device_Type = Ui.loadResource(Rez.Strings.Device);
		//System.println("Device_Type = " + Device_Type);
		
		var Z_H = new [Max_Zones_Number - 1];

		Z_H[0] 			= Args[0];
		Z_H[1] 			= Args[1];
		Z_H[2] 			= Args[2];
		Z_H[3] 			= Args[3];
		Z_H[4] 			= Args[4];
		Z_H[5] 			= Args[5];
		Display_Timer	= Args[6];
        App_Title		= Args[7];
		Avg_Duration	= Args[8];
		Graph_Timer 	= Args[9];
		Display_Graph	= Args[10];

		// Memory limitation on Edge 520 = no graph support
		if (Device_Type.equals("edge_520"))
		{
			Display_Graph = false;
		}

		System.println("Display_Graph = " + Display_Graph);
		
		Zone_L[0] = 0;
		for (var i = 0; i < Z_H.size() ; ++i)
   	   	{
			for (var j = 0; j < Zones_Number ; ++j)
   			{
				System.println("Zone " + j + " : " + Zone_L[j] + " - " + Zone_H[j]);
			}

			if ((Z_H[i] == 0) and (!Last_Zone))
			{
				Zone_H[Zones_Number] = Max_HR;
			}
			else
			{
				Zone_H[Zones_Number] = Z_H[i];
				Zones_Number++;
				Zone_L[Zones_Number] = Zone_H[Zones_Number-1] + 1;
				if (i == (Z_H.size() - 1))
				{
					Zone_H[Zones_Number] = Max_Power;
				}
			}
		}
		
		System.println("Zones_Number = " + Zones_Number);

		Loop_Index = 0;
		for (var i = 0; i <= Zones_Number ; ++i)
       	{
			Zone_Time[i] = 0;
			var j = i + 1;
			System.println("Zone " + j + " : " + Zone_L[i] + " - " + Zone_H[i]);
			for (var k = 0; k < Display_Timer; ++k)
    	   	{
    	   		Loop_Value[Loop_Index] = i;
    	   		Loop_Index++;
			}
		}
		Loop_Size = Loop_Index;
		//System.println("Loop_Size : " + Loop_Size);
		
		//for (var i = 0; i < Loop_Size ; ++i)
       	//{
		//	System.println("Display " + i + " - Zone " + Loop_Value[i]);
		//}

		// Device Management

		switch (Device_Type)
		{
			case "edge_520":

				Graph_Right_x = 195;
				Graph_Bottom_y = 49;

				DF_Title_x = 1;
				DF_Title_y = 0;
				DF_Title_font = Gfx.FONT_XTINY;

				Power_Value_x = 80;
				Power_Value_y = 10;
				Power_Value_font = Gfx.FONT_NUMBER_HOT;

				Power_Zone_x = 85;
				Power_Zone_y = 0;
				Power_Zone_font = Gfx.FONT_SMALL;

				Power_Unit_x = 85;
				Power_Unit_y = 38;
				Power_Unit_font = Gfx.FONT_XTINY;

				Z_Label_x = 95;
				Z_Label_y = 25;
				Z_Label_font = Gfx.FONT_NUMBER_MILD;
				
				Z_Value_x = 197;
				Z_Value_y = 0;
				Z_Value_font = Gfx.FONT_NUMBER_MILD;

				Z_Range_x = 197;
				Z_Range_y = 30;
				Z_Range_font = Gfx.FONT_MEDIUM;

				break;

			case "edge_520_plus":

				Graph_Right_x = 195;
				Graph_Bottom_y = 49;

				DF_Title_x = 1;
				DF_Title_y = 0;
				DF_Title_font = Gfx.FONT_XTINY;

				Power_Value_x = 80;
				Power_Value_y = 10;
				Power_Value_font = Gfx.FONT_NUMBER_HOT;

				Power_Zone_x = 85;
				Power_Zone_y = 0;
				Power_Zone_font = Gfx.FONT_SMALL;

				Power_Unit_x = 85;
				Power_Unit_y = 38;
				Power_Unit_font = Gfx.FONT_XTINY;

				Z_Label_x = 95;
				Z_Label_y = 25;
				Z_Label_font = Gfx.FONT_NUMBER_MILD;
				
				Z_Value_x = 197;
				Z_Value_y = 0;
				Z_Value_font = Gfx.FONT_NUMBER_MILD;

				Z_Range_x = 197;
				Z_Range_y = 30;
				Z_Range_font = Gfx.FONT_MEDIUM;

				break;

			case "edge_820":

				Graph_Right_x = 195;
				Graph_Bottom_y = 49;

				DF_Title_x = 1;
				DF_Title_y = 0;
				DF_Title_font = Gfx.FONT_XTINY;

				Power_Value_x = 80;
				Power_Value_y = 10;
				Power_Value_font = Gfx.FONT_NUMBER_HOT;

				Power_Zone_x = 85;
				Power_Zone_y = 0;
				Power_Zone_font = Gfx.FONT_SMALL;

				Power_Unit_x = 85;
				Power_Unit_y = 38;
				Power_Unit_font = Gfx.FONT_XTINY;

				Z_Label_x = 95;
				Z_Label_y = 25;
				//Z_Label_font = Gfx.FONT_MEDIUM;
				Z_Label_font = Gfx.FONT_NUMBER_MILD;
				
				Z_Value_x = 197;
				Z_Value_y = 0;
				Z_Value_font = Gfx.FONT_NUMBER_MILD;

				Z_Range_x = 197;
				Z_Range_y = 30;
				Z_Range_font = Gfx.FONT_MEDIUM;

				break;

			case "edge_1000":

				Graph_Right_x = 230;
				Graph_Bottom_y = 75;

				DF_Title_x = 1;
				DF_Title_y = 1;
				DF_Title_font = Gfx.FONT_XTINY;

				Power_Value_x = 115;
				Power_Value_y = 20;
				Power_Value_font = Gfx.FONT_NUMBER_THAI_HOT;

				Power_Zone_x = 118;
				Power_Zone_y = 1;
				Power_Zone_font = Gfx.FONT_SMALL;

				Power_Unit_x = 118;
				Power_Unit_y = 62;
				Power_Unit_font = Gfx.FONT_XTINY;

				Z_Label_x = 118;
				Z_Label_y = 20;
				Z_Label_font = Gfx.FONT_NUMBER_MILD;

				Z_Value_x = 238;
				Z_Value_y = 1;
				Z_Value_font = Gfx.FONT_LARGE;

				Z_Range_x = 238;
				Z_Range_y = 45;
				Z_Range_font = Gfx.FONT_LARGE;

				break;

			case "edge_1030":

				Graph_Right_x = 270;
				Graph_Bottom_y = 90;

				DF_Title_x = 1;
				DF_Title_y = 1;
				DF_Title_font = Gfx.FONT_XTINY;

				Power_Value_x = 125;
				Power_Value_y = 20;
				Power_Value_font = Gfx.FONT_NUMBER_THAI_HOT;

				Power_Zone_x = 115;
				Power_Zone_y = 1;
				Power_Zone_font = Gfx.FONT_MEDIUM;

				Power_Unit_x = 95;
				Power_Unit_y = 1;
				Power_Unit_font = Gfx.FONT_XTINY;

				//Z_Label_x = 130;
				//Z_Label_y = 35;
				//Z_Label_font = Gfx.FONT_MEDIUM;
				Z_Label_x = 135;
				Z_Label_y = 40;
				Z_Label_font = Gfx.FONT_LARGE;


				Z_Value_x = 280;
				Z_Value_y = 1;
				Z_Value_font = Gfx.FONT_NUMBER_MEDIUM;

				Z_Range_x = 280;
				Z_Range_y = 50;
				//Z_Range_font = Gfx.FONT_LARGE;
				Z_Range_font = Gfx.FONT_MEDIUM;

				break;

			default:
				break;
		}

		arrayPowerSize = Graph_Right_x - 5;


		System.println("Before Array Allocation - Total Memory = " + System.getSystemStats().totalMemory + " / Used Memory = " + System.getSystemStats().usedMemory);

		// Test to manage Edge 520 memory limitation
		if (Display_Graph)
		{
			for (var i = 0; i < arrayPowerSize; ++i)
			{
				arrayPowerValue.add(["0"]);
				arrayPowerZone.add(["0"]);
				//System.println("During Array Allocation - Total Memory = " + System.getSystemStats().totalMemory + " / Used Memory = " + System.getSystemStats().usedMemory);
			}
		}


		System.println("arrayPowerValue.size()  = " + arrayPowerValue.size());
		System.println("arrayPowerZone.size()  = " + arrayPowerZone.size());
		System.println("Graph Period = " + (arrayPowerSize * Graph_Timer / 60) + " Min");
		
		
        curPos = 0;
        for (var i = 0; i < arrayPowerValue.size(); ++i)
        {
            arrayPowerValue[i] = 0;
            arrayPowerZone[i] = -1;
        }


        History_Power = new[Avg_Duration];
		
		//System.println("AVG duration = " + history_torque.size());
		
		Next_Power_Sample_Idx = 0;
		Sum_Of_Power_Samples = 0;
		Number_Of_Power_Samples = 0;
        
        for (var i = 0; i < History_Power.size(); ++i)
        	{
				History_Power [i] = 0;
			}
    }

    //! Set your layout here. Anytime the size of obscurity of
    //! the draw context is changed this will be called.
    function onLayout(dc)
    {
    	//System.println("DC Height  = " + dc.getHeight());
      	//System.println("DC Width  = " + dc.getWidth());

    	View.setLayout(Rez.Layouts.MainLayout(dc));

/*
       //if (Device_Type.equals("edge_520") or Device_Type.equals("edge_1000"))
       if (Device_Type.equals("edge_520") or Device_Type.equals("edge_820"))
       {
			CustomFont_Value_Medium_1 = Ui.loadResource(Rez.Fonts.Font_Value_Medium_1);
			CustomFont_Value_Medium_2 = Ui.loadResource(Rez.Fonts.Font_Value_Medium_2);
			CustomFont_Value_Large_1 = Ui.loadResource(Rez.Fonts.Font_Value_Large_1);
       }
*/
        return true;
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and save it locally in this method.
    function compute(info)
    {
		var Power_Zone = 0;

		if (info.currentPower != null)
		{
			Power_Current = info.currentPower;
			Power_Current = 800;
			Power_Zone = GetPowerZone(Power_Current);
			Power_Current_Zone = Power_Zone + 1;
			System.println("Power_Zone = " + Power_Zone);
		}

		if (info.currentPower != null && info.elapsedTime != null && info.elapsedTime > 0)
		{

			// Compute time in Zones
			System.println("Power_Zone = " + Power_Zone);
			Zone_Time[Power_Zone]++;

			avePowerValue = avePowerValue + info.currentPower;
			avePowerCount = avePowerCount + 1;
			
			// Test to manage Edge 520 memory limitation
			if(Display_Graph and avePowerCount > Graph_Timer)
			{
				arrayPowerValue[curPos] = (avePowerValue / avePowerCount).toNumber();
				arrayPowerZone[curPos] = GetPowerZone(arrayPowerValue[curPos]);

				System.println("arrayPowerValue[" + curPos + "]: " + arrayPowerValue[curPos]);
				System.println("arrayPowerZone[" + curPos + "]: " + arrayPowerZone[curPos]);


				curPos = curPos + 1;
				if(curPos > arrayPowerValue.size()-1)
				{
					curPos = 0;
				}
				avePowerCount = 0;
				avePowerValue = 0;
			}

			Powermin = Zone_L[0];
			Powermax = Zone_H[Zones_Number - 2];

        	for (var i = 0; i < arrayPowerValue.size(); ++i)
        	{
        		if(arrayPowerZone[i] >=0)
        		{
       				if(arrayPowerValue[i] > Powermax)
       				{
        				Powermax = arrayPowerValue[i];
        			}
        			else
        			if(arrayPowerValue[i] < Powermin)
        			{
        				Powermin = arrayPowerValue[i];
        			}
        		}
        	}        		

			Powermin = Powermin - 0;
			//if(HRmin < Zone_L[1] + 10) { HRmin = Zone_L[1] + 10; }  // set floor just above min HR
			Powermax = Powermax + 5;
			//if(HRmax > Zone_H[4] + 5) { HRmax = Zone_H[4] + 5; }  // clip spikes just above max HR
		
        }

        var power;
        
        if( (info.currentPower != null))
            {

				power = info.currentPower.toFloat();

				// subtract the oldest sample from our moving sum
				Sum_Of_Power_Samples -= History_Power [Next_Power_Sample_Idx];

				// calculate the distance traveled since the last call
				History_Power [Next_Power_Sample_Idx] = power;

				// add the newest sample to our moving sum
				Sum_Of_Power_Samples += History_Power [Next_Power_Sample_Idx];

				// keep track of how many samples we've accrued
				if (Number_Of_Power_Samples < History_Power.size())
				{
					++Number_Of_Power_Samples;
				}

				//value_picked =  (sum_of_samples / number_of_samples).format("%06.2f");
				Avg_Power =  (Sum_Of_Power_Samples / Number_Of_Power_Samples).format("%.0f");

				//System.println("avg = " + value_picked.format("%.2f"));
				
				// advance to the next sample, and wrap around to the beginning
				Next_Power_Sample_Idx = (Next_Power_Sample_Idx + 1) % History_Power.size();

				for (var i = 0; i <= Zones_Number ; ++i)
       			{
       				if( (Zone_L[i] <= Avg_Power.toNumber()) and (Avg_Power.toNumber() <= Zone_H[i]))
       				{
       					Avg_Power_Zone = i + 1;
       				}
       			}

        	}
        
    }

    //! Display the value you computed here. This will be called
    //! once a second when the data field is visible.
    function onUpdate(dc)
    {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

		var FontDisplayColor = Gfx.COLOR_BLACK;
        
        if (getBackgroundColor() == Gfx.COLOR_BLACK)
        {
            FontDisplayColor = Gfx.COLOR_WHITE;
        }
        else
        {
            FontDisplayColor = Gfx.COLOR_BLACK;
        }

		//Avg_Power = 1888;
		//Avg_Power_Zone = 2;
		
		Loop_Index = (Loop_Index + 1) % Loop_Size;
		var Zone_to_Display = Loop_Value[Loop_Index];
		var Zone_to_Display_Plus_One = Zone_to_Display + 1;
		var Value_to_Display = TimeFormat(Zone_Time[Zone_to_Display]);
		var Range_to_Display = Zone_L[Zone_to_Display].toString() + ":" + Zone_H[Zone_to_Display].toString();
		
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

		if (Display_Graph)
		{
	        for (var i = 0; i < arrayPowerValue.size(); ++i)
    	    {
				//System.println("Graph: " + i);
				var ii;
				var scaling;
    	    	ii = curPos-1-i;
	        	if(ii < 0)
    	    	{
        			ii = ii + arrayPowerValue.size();
	        	}
	        	if(arrayPowerZone[ii] >=0)
    	    	{
					scaling = (arrayPowerValue[ii] - Powermin).toFloat() / (Powermax - Powermin).toFloat();
					dc.setColor(arrayColours[arrayPowerZone[ii]], Gfx.COLOR_TRANSPARENT);
        			dc.drawLine(Graph_Right_x - i, Graph_Bottom_y, Graph_Right_x - i, (Graph_Bottom_y - Graph_Bottom_y * scaling).toNumber());
	        	}
    	    }
		}

   	    var DF_Title_Text;
   	    DF_Title_Text = "PWR Zones - " + Avg_Duration + "s";

		textL(dc, DF_Title_x, DF_Title_y, DF_Title_font, FontDisplayColor, DF_Title_Text);
		textR(dc, Power_Value_x, Power_Value_y, Power_Value_font, FontDisplayColor, Avg_Power.toString());
		textL(dc, Power_Zone_x, Power_Zone_y, Power_Zone_font, FontDisplayColor, Avg_Power_Zone.toString());
		textL(dc, Power_Unit_x, Power_Unit_y, Power_Unit_font, FontDisplayColor, "W");
		textL(dc, Z_Label_x, Z_Label_y, Z_Label_font, FontDisplayColor, Zone_to_Display_Plus_One.toString());
		textR(dc, Z_Value_x, Z_Value_y, Z_Value_font, FontDisplayColor, Value_to_Display.toString());
		textR(dc, Z_Range_x, Z_Range_y, Z_Range_font, FontDisplayColor, Range_to_Display.toString());


    }

    function TimeFormat(Seconds)
    {
      var Rest;
               
      var Hour   = (Seconds - Seconds % 3600) / 3600; 
      Rest = Seconds - Hour * 3600;
      var Minute = (Rest - Rest % 60) / 60;
      var Second = Rest - Minute * 60; 

      var Return_Value = Hour.format("%d") + ":" + Minute.format("%02d") + ":" + Second.format("%02d");
      return Return_Value;
    }

	function textR(dc, x, y, font, color, s)
	{
		if (s != null)
		{
			dc.setColor(color, Gfx.COLOR_TRANSPARENT);
			//dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_RIGHT);
		}
	}

	function textL(dc, x, y, font, color, s)
	{
		if (s != null)
		{
			dc.setColor(color, Gfx.COLOR_TRANSPARENT);
			//dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_LEFT);
		}
	}


    function GetPowerZone(pwr)
    {
		System.println("Zones_Number  = " + Zones_Number);
		var Power_Zone = 0;
		for (var i = 0; i <= Zones_Number ; ++i)
    	{
    		if ((Zone_L[i] <= pwr) and (pwr <= Zone_H[i]))
    	   	{
    	   		Power_Zone = i;
    	   		return Power_Zone;
    	   	}
        }
    	return Power_Zone;
	}


}