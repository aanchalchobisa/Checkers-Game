`timescale 1ns / 1ps
// cursor.v - Module to pass RGB values in the ECE 540 
//Project 4
//
// Copyright Srivatsa Yogendra, 2016
// 
// Created By:		Aanchal Chobisa and Srivatsa Yogendra
// Last Modified:	25-May-2016 (AC & SY)
//
// Revision History:
// -----------------
// May-2016		BV & SY		Created this module for //the ECE 540 Project 4
//
// Description:
// ------------
// Module to pass the address values for the display of cursor //icon. The cursor icon is a 56 * 56 image stored in block ROM //generate using Vivado IP generator. The cursor is used to //point the pieces of player when it is the player's turn.
//Here in this piece of code, the pixel column and row is //checked with the locX and LocY to decide the address to be //sent to the colorizer module.
//////////////////////////////////////////////////////////////////////////////////////////////////////////

module cursor_mod(
    input [9:0] vid_row,	// The row location of the VGA display 
    input [9:0] vid_col,	// The col location of the VGA display
    input [7:0] locX,locY,	// X-coordinate to update the Icon state location, Y-coordinate to update the Icon state location
	input clk,				// The system clock
   
    output reg [2:0] cursor // The cursor variable to display the cursor Icon
    
    );
    
    reg [11:0] addr;		// Internal Variable to send as address to the colorizer module
    
    wire [7:0] pixel_col, pixel_row;	// Variable to store video logic row and column address
    wire  [2:0] cursor_d;				// The cursor variable to display the cursor Icon
    
   assign pixel_col = vid_col >> 2;		// video logic column address
   assign pixel_row = vid_row >> 2;		// video logic row address
   
   
   always@ (posedge clk) begin
            
            
         if ((pixel_col == locX) && (pixel_row == locY)) begin
            
            addr <= 0;									// Intial condition to send the address to the colorizer module
         end
		 
         else cursor <= 0;								// Cursor value is sent as zero
          
         if ((pixel_col> locX) && (pixel_col < locX+15) ) begin		// Checking for the boundary for each square box of 56 * 56 Icon and incrementing the address
            if ((pixel_row>locY) && (pixel_row < locY+15))begin		// Each box is iterated through to form an imaginary box before sending the cursor as output.
                    
                        addr <= addr + 1;							// Incrementing the address
						cursor <= cursor_d;							// Sending the cursor value
                     end

               end
                   
          else cursor <= 0;											// Till the imaginary box is formed new cursor value is not sent
                      
                   
        end
       
      
      cursor_data_rom cursor1 (										// Instantiating the Cursor module generated through IP Vivado Generator for the BLOCK ROM 
          .clka(clk),
          .addra(addr),
          .douta(cursor_d)
        );
      
      
endmodule
