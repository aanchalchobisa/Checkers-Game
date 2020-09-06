`timescale 1ns / 1ps
// coloriser.v - Module to pass RGB values in the ECE 540 Project 4
//
// Copyright Srivatsa Yogendra, 2016
// 
// Created By:		Bhaskar Venkataramaiah and Srivatsa Yogendra
// Last Modified:	25-May-2016 (BV & SY)
//
// Revision History:
// -----------------
// May-2016		BV & SY		Created this module for the ECE 540 Project 4
//
// Description:
// ------------
// Module to pass the RGB values for the display. It checks to display the welcome screen, the victory screen, 
// the icon or the board at each pixel based on the control signals. These inputs are generated from various modules 
// and values to display are passed using the coloriser module.
//////////////////////////////////////////////////////////////////////////////////////////////////////////


module colorizer(
    input 			  video_on,				// video on signal to indicate the display pixel locations are in the display range.
    input 		[2:0] world_pixel,			// MAP pixel encoded value	
    input 		[7:0] icon,					// Signal containing the RGB values for the icon screen
    input 		[2:0] cursor,				// Encoded value for the cursor display
    input 			  background_signal,	// Control signal to display the Welcome screen
    input 		[7:0] data_value_back,		// Signal containing the RGB values for the Welcome screen
    input 			  dis_victory_screen,	// Control signal to display the victory screen
    input 		[7:0] data_out_v_s, 		// Signal containing the RGB values for the victory screen
    input 			  clk,					// VGA_clk is 25MHz
    output reg [11:0] RGB					// the signal to drive the output vga signals
    );
    
    
	always@ (posedge clk) begin
		if (video_on == 1'b0)
				RGB <= 12'd0;											// if video signal is low, drive value for 0

		else if (background_signal == 1)begin							// If the welcome screen signal is high, display the welcome screen
				RGB[3:0] <=(data_value_back[1:0]<<2);
				RGB[7:4] <=(data_value_back[4:2]<<1);
				RGB[11:8] <=(data_value_back[7:5]<<1);
				end

		else if (dis_victory_screen == 1)begin							// If the victory screen signal is high, display the victory screen
				RGB[3:0] <=(data_out_v_s[1:0]<<2);
				RGB[7:4] <=(data_out_v_s[4:2]<<1);
				RGB[11:8] <=(data_out_v_s[7:5]<<1);
				end
		else begin
			if ((icon == 0) && (cursor == 0)) begin						// Else display the board, if cursor and icon signals are low
				if 		(world_pixel == 3'h2) 	RGB <= 12'hED8;
				else if (world_pixel == 3'b001) RGB <= 12'h841;
				else if (world_pixel == 3'h3) 	RGB <= 12'hACE;
			end
			else if (cursor == 0) begin									// if cursor is low, display the icon
				if 		(icon == 8'hFF) 		RGB <= 12'hED8;
				else begin
					RGB[3:0] <=(icon[1:0]<<2);							
					RGB[7:4] <=(icon[4:2]<<1);
					RGB[11:8] <=(icon[7:5]<<1);
					end
			end

			else if (cursor == 1) RGB <= 12'hF00; 						// if cursor is high display the cursor

		end
	end    
endmodule
