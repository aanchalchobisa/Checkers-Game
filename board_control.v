// board_control.v - Top level module for the board display used in the ECE 540 Project 4
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
// Top level module for board display for ECE 540 Project 4. It takes the input from the nexys4fpga.v, 
// it reads the vid row and column address and passes it to update or fetch the state. It also fetches the 
// board display value for the corresponding pixel
//////////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module board_control(
    input 		  clk, 				// The system clock
				  reset,			// The system reset
    input	[9:0] vid_row,			// The row location of the VGA display
    input 	[9:0] vid_col,			// The col location of the VGA display
    output 	[7:0] icon_state,		// Output the icon state
    output 	[2:0] world_pixel,		// Output the board display value
    output 	[7:0] LocX_reg,			// X-coordinate of Icon's location        
                  LocY_reg,   	    // Y-coordinate of Icon's location        
         
    input 	[7:0] locX_state,		// X-coordinate to update the Icon state location        
	input 	[7:0] locY_state,		// Y-coordinate to update the Icon state location        
	input 	[7:0] update_state,		// The state update value
	input         wea_state_ram		// The write enable signal for ram
    );
    

        
	wire 	[7:0] pixel_row,        // video logic row address
			      pixel_col;        // video logic column address

    
    assign pixel_col = vid_col >> 2;	// Shifting video col to scale to 512 x 512 display
    assign pixel_row = vid_row >> 2;	// Shifting video row to scale to 512 x 512 display
 
	board board1(
						.clk(clk),
						.vid_row (pixel_row),        // video logic row addres          
						.vid_col (pixel_col),        // video logic column address             
						.board_design (world_pixel)  // map value for location [row_addr, col_addr]
						
						); 

    control_value_sent c1 ( 
						.clk(clk),
						.LocX(LocX_reg),             // X-coordinate of Icon's location        
						.LocY(LocY_reg),             // Y-coordinate of Icon's location
						.pixel_row(pixel_row), 		 // video logic row addres
						.pixel_col(pixel_col),		 // video logic column address             
						.IconVal(icon_state),		 // state of the icon 

						.locX_state(locX_state),	 // X-coordinate to update the Icon state location        
						.locY_state(locY_state),	 // Y-coordinate to update the Icon state location        
						.update_state(update_state), // The state update value
						.wea_state_ram(wea_state_ram)// The write enable signal for ram
						);                           
    
endmodule
