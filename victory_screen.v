`timescale 1ns / 1ps
// victory_screen.v - Module to pass RGB values in the ECE 540 
//Project 4
//
// Copyright Srivatsa Yogendra, 2016
// 
// Created By:		Aanchal Chobisa and Bhaskar Venkataramaiah
// Last Modified:	25-May-2016 (AC & SY)
//
// Revision History:
// -----------------
// May-2016		BV & AC		Created this module for //the ECE 540 Project 4
//
// Description:
// ------------
// The logic to decide the winner of the game. As the game ends, when all the pawns of any player has been
//captured by the opponent player, we keep a count of the pawns of both of the payer and compare them to 0. 
//Whenever the count comes down to 0 for any player, the game ends declaring the winner.
//////////////////////////////////////////////////////////////////////////////////////////////////////////


module victory_screen(
    input clk,						// The system clock
    input Player_1_v,				// Check if it is player 1
    input Player_2_v,				// Check if it is player 1
    input [9:0] pixel_row,			// video logic row address
    input [9:0] pixel_column,		// video logic column address
    output [7:0] data_out_v_s,		// To decide which player won the game
    output dis_victory_screen		// Victory Screen
    );
    
    wire [17:0] addr;				// Address from the Block ROM
    wire [7:0] data1,data2;
     wire     [7:0]         vid_row,        // video logic row address
                            vid_col;        // video logic column address
           
       
       assign vid_col = pixel_column >> 2;	// Scaling the vid_col to fit in the 512 * 512 image
       assign vid_row = pixel_row >> 2;		// Scaling the vid_row to fit in the 512 * 512 image
    
    assign dis_victory_screen = Player_1_v | Player_2_v;	// If any of the player is decided as winner, it will be received here
    assign addr = {vid_row[6:0],vid_col[6:0]};				// Address is concatenated
    assign data_out_v_s = Player_1_v ? data1 : (Player_2_v ? data2 : 0 ); // Depending upon the winner, the relevant image was displayed as player 1 and player 2
    
    victory_screen_p1 vs					// Player 1 winning image is stored in block ROM, it is instantiated here in the victory screen 
                  (
                    .clka(clk),
                    .addra(addr),
                    .douta(data1)
                  );
                  
    victory_screen_p2 vs2					// Player 2 winning image is stored in block ROM, it is instantiated here in the victory screen
                                    (
                                      .clka(clk),
                                      .addra(addr),
                                      .douta(data2)
                                    );
    
endmodule