`timescale 1ns / 1ps
// welcome_screen.v - Module to display the welcome screen before the beginning of the game
//Project 4
//
// Copyright Srivatsa Yogendra, 2016
// 
// Created By:		Srivatsa Yogendra and Bhaskar Venkataramaiah
// Last Modified:	25-May-2016 (AC & SY)
//
// Revision History:
// -----------------
// May-2016		BV & SY		Created this module for //the ECE 540 Project 4
//
// Description:
// ------------
// Before the beginning of the game, there is a welcome screen displayed that shows the game cover and the modes to select.
// It offers the mode for the user to select between 2 player game and a single player game.
//////////////////////////////////////////////////////////////////////////////////////////////////////////


module welcome_screen_module(
    input clk,							// The system clock
    output reg background_signal,		// Back ground signal
    input [9:0] pixel_row,				// video logic row address
    input [9:0] pixel_column,			// video logic col address
    output [11:0] data_value_back		// 12 bit address to display the welcome screen `
    );
    
    reg [29:0] counter = 0;				// Counter is set to zero
    wire [17:0] addr;					// Address variable
    wire [7:0] data;					// Data is displayed
    
    always @ (posedge clk) begin
            
            counter <= counter + 1;		// Counter is reset
            
            if (counter < 30'd500000000)
                background_signal <= 1'b1;	// A time counter for 5 seconds is set and this is counter to check
            
            else if (counter >= 30'd500000000)begin
                background_signal <= 0;
                counter <= 30'd500000000;	// A time counter for 5 seconds is set and this is counter to check
            
                end
           
           
            end
            
     assign addr = {pixel_row[8:0],pixel_column[8:0]};	// Address is concatenated with row and column value
     assign data_value_back = data;						// Data Value is assigned here
     
     welcome_screen ws									// Block ROM instantatiation of the welcome screen which is generated using the Vivado IP generator
              (
                .clka(clk),
                .addra(addr),
                .douta(data)
              );
    
    
    
    
endmodule
