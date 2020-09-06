`timescale 1ns / 1ps
// board.v - module for the board display used in the ECE 540 Project 4
//
// Copyright Srivatsa Yogendra, 2016
// 
// Created By:		Aanchal Chobisa and Srivatsa Yogendra
// Last Modified:	25-May-2016 (AC & SY)
//
// Revision History:
// -----------------
// May-2016		AC & SY		Created this module for the ECE 540 Project 4
//
// Description:
// ------------
// Module for board display for ECE 540 Project 4. It takes the input from the board_control.v, 
// it reads the vid row and column address and passes the board display value for the corresponding pixel. 
// A block ROM is instantiated which consists of the values of the board.
//////////////////////////////////////////////////////////////////////////////////////////////////////////


module board(
    input 			clk,			// system clock
    input 	[7:0]	vid_row,        // video logic row addres          
					vid_col,        // video logic column address
                  
    output  [2:0] 	board_design	// Pixel value for the board display
    );
    
   
   reg 		[13:0] 	vid_addr;		// The address to extract the pixel location from the Block ROM
   
   BOARD_MAP bac(
				   .clka(clk),			// system clock
				   .addra(vid_addr),	// The address to extract the pixel location from the Block ROM
				   .douta(board_design)	// The value for the pixel location
				 );
   
   
   always @ (posedge clk)
   begin
        
        vid_addr <= {vid_row[6:0],vid_col[6:0]}-1;	// The Block ROM address to extract the pixel location 
   end 
       
endmodule

