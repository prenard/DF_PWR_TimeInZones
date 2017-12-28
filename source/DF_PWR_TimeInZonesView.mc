using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class DF_PWR_TimeInZonesView extends Ui.DataField
{
	var Device_Type;
	
	var App_Title;
	
	var Max_Zones_Number = 9;
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

	
    function initialize(Args)
    {
        DataField.initialize();

	    Device_Type = Ui.loadResource(Rez.Strings.Device);

		var Z_H = new [Max_Zones_Number+1];

		Z_H[1] 			= Args[0];
		Z_H[2] 			= Args[1];
		Z_H[3] 			= Args[2];
		Z_H[4] 			= Args[3];
		Z_H[5] 			= Args[4];
		Z_H[6] 			= Args[5];
		Z_H[7] 			= Args[6];
		Z_H[8]			= Args[7];
		Display_Timer	= Args[8];
        App_Title		= Args[9];
		Avg_Duration	= Args[10];

        //App_Title = "PWR Zones";
		//App_Version ="1.00";

		//Display_Timer = D_T;

	
		//Z_H[1] = Z1_H;
		//Z_H[2] = Z2_H;
		//Z_H[3] = Z3_H;
		//Z_H[4] = Z4_H;
		//Z_H[5] = Z5_H;
		//Z_H[6] = Z6_H;
		//Z_H[7] = Z7_H;
		//Z_H[8] = Z8_H;
						
		var Last_Zone = false;
		
		for (var i = 1; i < Max_Zones_Number ; ++i)
       	{
			//System.println("Looking for Zone " + i + " Zones_Number = " + Zones_Number);

			if (i == 1)
			{
				Zone_L[Zones_Number] = 0;
			}
			else
			{
				Zone_L[Zones_Number] = Zone_H[Zones_Number-1] + 1;
			}


			if ((Z_H[i] == 0) and !(Last_Zone))
			{
				Zone_H[Zones_Number] = Max_Power;
				Last_Zone = true;
				Zones_Number++;
			}

			if (Z_H[i] > 0)
			{
				Zone_H[Zones_Number] = Z_H[i]; 
				Zones_Number++;
			}

			if ((i == (Max_Zones_Number - 1)) and (Z_H[i] > 0))
			{
				Zone_L[Zones_Number] = Zone_H[Zones_Number-1] + 1;
				Zone_H[Zones_Number] = Max_Power;
				Last_Zone = true;
       		}
		}
		

		Loop_Index = 0;
		for (var i = 0; i <= Zones_Number ; ++i)
       	{
			Zone_Time[i] = 0;
			var j = i+1;
			//System.println("Zone " + j + " : " + Zone_L[i] + " - " + Zone_H[i]);
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
    	System.println("DC Height  = " + dc.getHeight());
      	System.println("DC Width  = " + dc.getWidth());

    	View.setLayout(Rez.Layouts.MainLayout(dc));

    	DF_Title = View.findDrawableById("DF_Title");
    	Power_Label = View.findDrawableById("Power_Label");
    	Power_Value = View.findDrawableById("Power_Value");
    	Power_Unit = View.findDrawableById("Power_Unit");
    	Power_Zone = View.findDrawableById("Power_Zone");
    	Z_Label = View.findDrawableById("Z_Label");
    	Z_Value = View.findDrawableById("Z_Value");
    	Z_Range = View.findDrawableById("Z_Range");
     
		//System.println(App_Title);
   	    DF_Title.setText("PWR Zones");

   	    var Label;
   	    Label = "- AVG " + Avg_Duration + "s";
   	    Power_Label.setText(Label);
   	    
   	    Power_Unit.setText("W");

		// Set fields FONTs

       //if (Device_Type.equals("edge_520") or Device_Type.equals("edge_1000"))
       if (Device_Type.equals("edge_520") or Device_Type.equals("edge_820"))
       {
			CustomFont_Value_Medium_1 = Ui.loadResource(Rez.Fonts.Font_Value_Medium_1);
			CustomFont_Value_Medium_2 = Ui.loadResource(Rez.Fonts.Font_Value_Medium_2);
			CustomFont_Value_Large_1 = Ui.loadResource(Rez.Fonts.Font_Value_Large_1);

			Power_Value.setFont(CustomFont_Value_Large_1);
			Power_Zone.setFont(CustomFont_Value_Medium_1);
			Z_Value.setFont(CustomFont_Value_Medium_2);
			Z_Range.setFont(CustomFont_Value_Medium_1);
			Z_Label.setFont(CustomFont_Value_Medium_1);
       }

        return true;
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and save it locally in this method.
    function compute(info)
    {
        //System.println("Power = " + info.currentPower);
        if( (info.currentPower != null))
        {
			for (var i = 0; i < Zones_Number ; ++i)
    	   	{
    	   		if ((Zone_L[i] <= info.currentPower) and (info.currentPower <= Zone_H[i]))
    	   		{
    	   			Zone_Time[i]++;
    	   			//System.println("Zone " + i + " = " + Zone_Time[i]);
    	   		}
        	}
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

        
        if (getBackgroundColor() == Gfx.COLOR_BLACK)
        {
            DF_Title.setColor(Gfx.COLOR_WHITE);
            Power_Label.setColor(Gfx.COLOR_WHITE);
            Power_Value.setColor(Gfx.COLOR_WHITE);
            Power_Unit.setColor(Gfx.COLOR_WHITE);
            Power_Zone.setColor(Gfx.COLOR_WHITE);
            Z_Label.setColor(Gfx.COLOR_WHITE);
            Z_Value.setColor(Gfx.COLOR_WHITE);
            Z_Range.setColor(Gfx.COLOR_WHITE);
        }
        else
        {
            DF_Title.setColor(Gfx.COLOR_BLACK);
            Power_Label.setColor(Gfx.COLOR_BLACK);
            Power_Value.setColor(Gfx.COLOR_BLACK);
            Power_Unit.setColor(Gfx.COLOR_BLACK);
            Power_Zone.setColor(Gfx.COLOR_BLACK);
            Z_Label.setColor(Gfx.COLOR_BLACK);
            Z_Value.setColor(Gfx.COLOR_BLACK);
            Z_Range.setColor(Gfx.COLOR_BLACK);
        }

		//Avg_Power = 1888;
		//Avg_Power_Zone = 2;
		
		Power_Value.setText(Avg_Power.toString());
		Power_Zone.setText(Avg_Power_Zone.toString());
		

		Loop_Index = (Loop_Index + 1) % Loop_Size;
		var Zone_to_Display = Loop_Value[Loop_Index];
		var Zone_to_Display_Plus_One = Zone_to_Display + 1;

		//System.println("Zone to Display : " + Zone_to_Display);
		
		Z_Label.setText(Zone_to_Display_Plus_One.toString());

		var Value_to_Display = TimeFormat(Zone_Time[Zone_to_Display]);
        //System.println(Value_to_Display);
        
		Z_Value.setText(Value_to_Display);

		var Range_to_Display = Zone_L[Zone_to_Display].toString() + " - " + Zone_H[Zone_to_Display].toString();
		Z_Range.setText(Range_to_Display);
		
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
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

}