`timescale 1ns / 1ps

// control_pmod.v - module for processing PmodENC signals
//
// 
// Created By:		Chris Dean
// Last Modified:	May-2016
//
// Revision History:
// -----------------
// May-2016		CD		Modified this module for the ECE 540 Project 4
//
// Description:
// ------------
// Module for converting input from the Pmod Rotary Encoder to a 3-bit count. Turning the knob
// left decrements the counter output and turning it right increments it. If the switch is in
// the 'up' position, it will increment/decrement at twice the rate, and the counter is reset
// when the button is pressed.


module control_Pmod(
    input rotary_event,
    input rotary_left,
    input pmod_sw,
    input pmod_btns,
    output reg [2:0] left_pos,
    input clk
    );
    
    always @ (posedge clk)
    begin
		// updating the counters based on buttons
        case ({pmod_btns,rotary_event,pmod_sw,rotary_left})
            4'b1000: left_pos <= left_pos;
            4'b1001: left_pos <= left_pos;
            4'b1010: left_pos <= left_pos;
            4'b1011: left_pos <= left_pos;
            4'b0110: left_pos <= left_pos + 2 ;
            4'b0111: left_pos <= left_pos - 2 ;
            4'b0100: left_pos <= left_pos + 1 ;
            4'b0101: left_pos <= left_pos - 1 ;
            4'b0000: left_pos <= left_pos;
            default: left_pos <= left_pos;
        endcase
    end
endmodule
