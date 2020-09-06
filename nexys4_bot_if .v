// nexys4_bot_if.v - for ECE 540 Project 4
//
// 
// Created By:		Chris Dean	
// Last Modified:	June 2016
//
//
// Description:
// ------------
// This module connects our project's picoblaze I/O ports to the correct interfaces
// of our other modules. The picoblaze reads inputs from the encoders and sends control
// signals to the display board to move the pieces.
// 
///////////////////////////////////////////////////////////////////////////

module nexys4_if (
	// Interface to top module
	input 				clk,			// input
	input 				reset,			// input
	input		[2:0] 	random,         // Input from random number generator for one-player control

	// Interface to PicoBlaze (kcpsm6.v)
	input 		[7:0] 	port_id,		// Port ID used by interface for routing to/from PB
	input 		[7:0] 	out_port,		// Data output from PB
	output reg	[7:0] 	in_port, 		// Data input to PB
	input 				k_write_strobe,	// Indicates a write command with immediate value
	input 				write_strobe,	// Indicates a write command
	input 				read_strobe,	// Indicates a read command
	output reg			interrupt,		// output to trigger interrupt in PicoBlaze
	input 				interrupt_ack,	// Acknowledging interrupt from PicoBlaze

	// Interface to Encoders
	input 		[4:0]	enc1, enc2,

	// Interface to board display subsystem
	output 	reg [7:0]	LOCX_CURSOR,	// Location registers for placing the cursor			
	output 	reg [7:0] 	LOCY_CURSOR,
	output 	reg [15:0] 	LED,            // Controls LEDs on Nexys4 board
	output 	reg [7:0]   locX_state,     // Location registers for placing game pieces
    output 	reg [7:0]   locY_state,
    output 	reg [7:0]   update_state,   // Control signals for writing to the board subsystem
    output 	reg         wea_state_ram,
                        Player_2_v,
                        Player_1_v,
                        
    // Interface to 7-Segment Display (sevensegment.v)
	output 	reg [4:0] 	d0,             // output [4:0] One for each digit
	output 	reg [4:0] 	d1,
	output 	reg [4:0] 	d2,
	output 	reg [4:0] 	d3,
	output 	reg [4:0] 	d4,
	output 	reg [4:0] 	d5,
	output 	reg [4:0] 	d6,
	output 	reg [4:0] 	d7,
	output 	reg [7:0] 	dp				// output [7:0] Decimal points				

);

// Read registers
always @(posedge clk) begin
	case(port_id)
		8'h00 		: 	in_port <= {3'b000, enc1};      // Read player 1's input
		8'h01	 	: 	in_port <= {3'b000, enc2};      // Read player 2's input
		8'h20 		: 	in_port <= {3'b000, random};    // 1-player move randomizer
		default : in_port <= 8'bXXXXXXXX ;
	endcase
end

// Write registers
always @(posedge clk) begin
	if(write_strobe == 1'b1) begin
		case(port_id) // Output registers
		
		    // Drive LED's
			8'h07 		: LED[15:8]	    <= out_port;
			8'h08 		: LED[7:0]	    <= out_port;  
			
			// Control signals to board display system
			8'h05 		: LOCX_CURSOR   <= out_port;
			8'h06 		: LOCY_CURSOR   <= out_port;
            8'h16       : Player_1_v    <= out_port[0];
            8'h17       : Player_2_v    <= out_port[0];
			8'h09       : locX_state    <= out_port;
            8'h0A       : locY_state    <= out_port;
            8'h0B       : update_state  <= out_port;
            8'h0C       : wea_state_ram <= out_port[0];
            
            // Drive the seven segment display
		    8'h0D 		: d0		    <= out_port[4:0];
            8'h0E       : d1            <= out_port[4:0];
            8'h0F       : d2            <= out_port[4:0];
            8'h10       : d3            <= out_port[4:0];
	        8'h11 		: d4		    <= out_port[4:0];
            8'h12		: d5            <= out_port[4:0];
            8'h13 		: d6            <= out_port[4:0];
            8'h14 		: d7            <= out_port[4:0];
            8'h15 		: dp            <= out_port[7:0];
			default:		 ;
		endcase	
	end
end

endmodule