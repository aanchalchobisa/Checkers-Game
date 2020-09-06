// nexys4fpga.v - Top level module for Nexys4 for ECE 540 Project 4
// 
// Created By:		Chris Dean
// Last Modified:	9-Jun-2016
//
// Revision History:
// -----------------
// May-2016     CD      Created from our project 2 top module. 
// Jun-2016     CD      Finalized for project completion and submission.
//
// Description:
// ------------
// Top level module for ECE 540 final project. It interfaces the board I/O with
// the devices instantiated here through the nexys4_if module.
//
// Main subsystems include:
//  Hardware interface  - Included button debounce, seven-segment translation, and
//                          rotary encoder modules.
//  Picoblaze and ROMs  - Switch 15 selects which player mode ROM to load upon startup.
//                      - Program ROMs dictate game logic to the board
//  Display             - Includes Icon instances, DTG and Colorizer.
//  Board logic         - Takes commands from PicoBlaze for moving pieces, keeps a 
//                          representation of the board saved, and sends the information 
//                          to the display controller.
//
// External port names match pin names in the nexys4fpga.xdc constraints file
///////////////////////////////////////////////////////////////////////////

module Nexys4fpga (
	input 				clk,                 	// 100MHz clock from on-board oscillator
	input				btnL, btnR,				// pushbutton inputs - left (db_btns[4])and right (db_btns[2])
	input				btnU, btnD,				// pushbutton inputs - up (db_btns[3]) and down (db_btns[1])
	input				btnC,					// pushbutton inputs - center button -> db_btns[5]
	input				btnCpuReset,			// red pushbutton input -> db_btns[0]
	input	[15:0]		sw,						// switch inputs
	
	output	[15:0]		led,  					// LED outputs	
	
	output 	[6:0]		seg,					// Seven segment display cathode pins
	output              dp,
	output	[7:0]		an,						// Seven segment display anode pins	
	
	input	[7:0]		JA, JD,					// JA, JD Header
	
	// Output to VGA port
	output  [3:0]       VGA_R,
	output  [3:0]       VGA_G,
	output  [3:0]       VGA_B,
	output              VGA_HS,
	output              VGA_VS
); 

	// parameter
	parameter SIMULATE = 0;

	// Hardware interface signals
	wire 	[15:0]		db_sw;					// debounced switches
	wire 	[5:0]		db_btns;				// debounced buttons
	
	wire				sysclk;					// 100MHz clock from on-board oscillator	
	wire				sysreset;				// system reset signal - asserted high to force reset
	
	wire 	[4:0]		dig7, dig6,
						dig5, dig4,
						dig3, dig2, 
						dig1, dig0;				// display digits
	wire 	[63:0]		digits_out;				// ASCII digits (Only for Simulation)
	wire 	[7:0]		decpts;					// decimal points
	wire 	[15:0]		chase_segs;				// chase segments from Rojobot (debug)
	
	wire    [7:0]       segs_int;               // 7-seg module the segments and the decimal point
    
    // Encoder signals
    wire                rotary_a,
                        rotary_b,
                        rotary_press,
                        rotary_sw,
                        rotary_event,
                        rotary_left;
    wire                pmod_btns,
                        pmod_sw;
    wire      [2:0]     left_pos, left_pos2;
                        
    // Board control and icon signals
    wire    [7:0]       locX,                       // X-coordinate of icon location        
                        locY,                       // Y-coordinate of icon location
    wire    [7:0]       icon;
    wire                video_on;
    wire                locked;
    wire    [2:0]       board_design;
    wire    [13:0]      pixel_add;
    wire    [7:0]       debug_led;
    wire    [7:0]       icon_state;
    wire    [2:0]       cursor;
    wire    [7:0]       locX_cursor, locY_cursor;   // Cursor location
    wire                wea_state_ram,Player_1_v,Player_2_v, dis_victory_screen;
    wire    [7:0]       data_value_back,data_out_v_s;
    wire                background_signal;
    wire    [7:0]       locX_state;
    wire    [7:0]       locY_state;
    wire    [7:0]       update_state;
                  
    // interface to the video logic
    wire     [9:0]      vid_row,                // video logic row address
                        vid_col,                // video logic column address
                        pixel_row,              // video logic row address
                        pixel_col;              // video logic column address
    wire                dclk;                   //pixel clock: 25MHz
    reg                 clr;                    //asynchronous reset
    wire                hsync;                  //horizontal sync out
    wire                vsync;                  //vertical sync out
    wire      [11:0]    RGB;
                                              
    // Picoblaze
    wire                kcpsm6_reset;
    wire    [11:0] 		address;	            // address line from picoblaze to its instruction rom
    wire    [17:0]      instruction;            // instruction line from rom to picoblaze
    wire                bram_enable;            // enable signal for the ROM
    wire    [7:0]       port_id;                // Port_Id for the device to communicate with the interface
    wire    [7:0]       out_port;               // Picoblaze data port to write the data
    wire    [7:0]       in_port;                // Picoblaze data port to read the data
    wire                write_strobe;           // PicoBlaze communication signal
    wire                k_write_strobe;         // PicoBlaze communication signal
    wire                read_strobe;            // PicoBlaze communication signal
    wire                interrupt;              // Interrupt input to the PicoBlaze
    wire                interrupt_ack;          // Interrupt acknowledge from the PicoBlaze
    wire                kcpsm6_sleep;           // Picoblaze sleep signal
    wire                rdl;                    // Picoblaze reset signal



// ******************************************************************/
// * Wire Assignments                                               */
// ******************************************************************/

    // 3-bit random number generator
    reg	[2:0] 	randomizer;
    always@(posedge clk) begin
	   randomizer <= randomizer +1 ;
	end
	
	// set up the display
	assign	dig3 = {1'b0,left_pos};
	assign	dig2 = {1'b0,left_pos2};
	assign 	dig1 = {1'b0,RGB[3:0]};
	assign	dig0 = {1'b0,4'b0000};
	assign	decpts = 8'b00000000;
	assign  VGA_R = RGB[11:8];
	assign  VGA_G = RGB[7:4];
    assign  VGA_B = RGB[3:0];
    assign  VGA_HS = hsync;
    assign  VGA_VS = vsync;
    
	// Read from Encoder ports
	assign rotary_a = JA[4];
	assign rotary_b = JA[5];
	assign rotary_press = JA[6];
	assign rotary_sw = JA[7];
            
	assign rotary_a2 = JD[4];
	assign rotary_b2 = JD[5];
	assign rotary_press2 = JD[6];
	assign rotary_sw2 = JD[7];
	
	assign 	sysreset = ~db_btns[0]; // btnCpuReset is asserted low
	
	assign dp = segs_int[7];
	assign seg = segs_int[6:0];

// ******************************************************************/
// * Module instantiations                                          */
// ******************************************************************/			

	
	
	
	// Debounce pushbuttons and switches
	debounce
	#(
		.RESET_POLARITY_LOW(1),
		.SIMULATE(SIMULATE)
	)  	DB1
	(
		.clk(sysclk),	
		.pbtn_in({btnC,btnL,btnU,btnR,btnD,btnCpuReset}),
		.switch_in(sw),
		.pbtn_db(db_btns),
		.swtch_db(db_sw)
	);	
	
	// Debounce the encoders
	debounce
	#(
			.RESET_POLARITY_LOW(1),
			.SIMULATE(SIMULATE)
	)      DB2
	(
			.clk(sysclk),    
			.pbtn_in({4'b0, rotary_press2, rotary_press}),		// [5:0] input
			.switch_in({14'h0000, rotary_sw2, rotary_sw}),		// [15:0] intput
			.pbtn_db({4'b0, pmod_btns2, pmod_btns}),			// [5:0] output
			.swtch_db({14'h0000, pmod_sw2, pmod_sw})			// [15:0] output
	);
	
	
	//
	// Rotary Filters and control_Pmod. One instance for each of the two encoders.
    //
    
    // Encoder 1 filter and conversion to position counter
    rotary_filter f1 (
       .rotary_a(rotary_a),             // A input from S3E Rotary Encoder
       .rotary_b(rotary_b),             // B input from S3E Rotary Encoder
       .rotary_event(rotary_event),     // Asserted high when rotary encoder changes position
       .rotary_left(rotary_left),       // Asserted high when rotary direction is to the left
       .clk(sysclk)                     // input clock
    );
    control_Pmod conpm (
        .rotary_event(rotary_event),    // Event signal from the filter
        .rotary_left(rotary_left),      // Direction of turn, from filter
        .pmod_btns(pmod_btns),          // Debounced button
        .pmod_sw(pmod_sw),              // Debounced switch
        .left_pos(left_pos),            // Position output 0-7
        .clk(sysclk)
    );
    
    
    // Encoder 2 filter and conversion to position counter 
	rotary_filter f2 (
		 .rotary_a(rotary_a2),          // A input from S3E Rotary Encoder
		 .rotary_b(rotary_b2),          // B input from S3E Rotary Encoder
		 .rotary_event(rotary_event2),  // Asserted high when rotary encoder changes position
		 .rotary_left(rotary_left2),    // Asserted high when rotary direction is to the left
		 .clk(sysclk)                   // input clock
	);
	control_Pmod conpm2 (
		.rotary_event(rotary_event2),   // Event signal from the filter
		.rotary_left(rotary_left2),     // Direction of turn, from filter
		.pmod_btns(pmod_btns2),         // Debounced button
		.pmod_sw(pmod_sw2),             // Debounced switch
		.left_pos(left_pos2),           // Position output 0-7
		.clk(sysclk)
	);
		
	// 7-segment Controller
	sevensegment
	#(
		.RESET_POLARITY_LOW(0),
		.SIMULATE(SIMULATE)
	) SSB
	(
		// inputs for control signals
		.d0(dig0),
		.d1(dig1),
 		.d2(dig2),
		.d3(dig3),
		.d4(dig4),
		.d5(dig5),
		.d6(dig6),
		.d7(dig7),
		.dp(decpts),
		
		// outputs to seven segment display
		.seg(segs_int),			
		.an(an),
		
		// clock and reset signals (100 MHz clock, active high reset)
		.clk(sysclk),
		.reset(sysreset),
		
		// ouput for simulation only
		.digits_out(digits_out)
	);


    // Clock Generator          
    clk_wiz_0 CLKGEN
    (
        .clk_in1(clk),          // input clock is 100 MHz
        .clk_out1(sysclk),      // sysclk is 100 MHz
        .clk_out2(VGA_clk),     // VGA_clk is 25MHz
        .locked(locked)
    );
          
    // Display Timing Generator for VGA
    dtg  dtg1(
        .clock (VGA_clk),       // 25MHz clock input
        .rst (sysreset),        // system reset
        .horiz_sync (hsync),    // horizontal sync
        .vert_sync (vsync),     // vertical sync
        .video_on (video_on),   // video on signal
        .pixel_row (vid_row),   // row output
        .pixel_column (vid_col) // column output
    );
    
    // Colorizer to turn signal from board subsystem into VGA output signal
    colorizer colorizer1(
        .video_on(video_on),
        .world_pixel(board_design),                 // Board pixel value
        .icon (icon),                               // Icon pixel value
        .cursor(cursor),                            // Cursor pixel value
        .clk (VGA_clk),                             // 25MHz input clock
        .background_signal(background_signal),      // background signal
        .data_value_back(data_value_back),          // data value back
        .dis_victory_screen(dis_victory_screen),    // Victory screen value
        .data_out_v_s(data_out_v_s),                // data out
        .RGB (RGB)                                  // Color value of this pixel
    );
          
    // Pawn/king icon display module
    icon ic(
         .vid_row(vid_row),
         .vid_col(vid_col),
         .locX(locX),
         .locY(locY),
         .icon(icon),
         .icon_state(icon_state),
         .clk(VGA_clk)
      
    );
         
    // Board control logic subsystem
    board_control board_ctrl(
        .clk(sysclk),
        .reset(sysreset),
        .vid_row(vid_row),
        .vid_col(vid_col),
        .icon_state(icon_state),
        .world_pixel(board_design),
        .LocX_reg(locX),                // X-coordinate of location to write       
        .LocY_reg(locY),                // Y-coordinate of rojobot's location
        .locX_state(locX_state),        // Value at this location
        .locY_state(locY_state),        // value at this location
        .update_state(update_state),    // Toggle to update
        .wea_state_ram(wea_state_ram)
        
    );
        
    // PicoBlaze and instruction ROM
     assign kcpsm6_sleep = 1'b0;
     assign kcpsm6_reset = sysreset | rdl;
	kcpsm6 #(
		.interrupt_vector	(12'h3FF),
		.scratch_pad_memory_size(256),
		.hwbuild		(8'h00))
  	processor(
		.address 		(address),
		.instruction 	(instruction),
		.bram_enable 	(bram_enable),
		.port_id 		(port_id),
		.write_strobe 	(write_strobe),
		.k_write_strobe (k_write_strobe),
		.out_port 		(out_port),
		.read_strobe 	(read_strobe),
		.in_port 		(in_port),
		.interrupt 		(interrupt),
		.interrupt_ack 	(interrupt_ack),
		.reset 			(kcpsm6_reset),
		.sleep			(kcpsm6_sleep),
		.clk 			(sysclk)
	); 

    // Signals and assignments to choose which program ROM to connect to PB
    // Switch 15 will route the instruction signals from PB to either the
    // one-player program or two-player program.
    wire    [17:0] instruction1, instruction2;
    wire    rdl1;
    wire    rdl2;
    assign  instruction = db_sw[15] ? instruction2 : instruction1;
    assign  rdl = db_sw[15] ? rdl2 : rdl1;

  	// One-player ROM
	game_logic #(
		.C_FAMILY		   ("7S"),   	//Family 'S6' or 'V6'
		.C_RAM_SIZE_KWORDS	(2),  		//Program size '1', '2' or '4'
		.C_JTAG_LOADER_ENABLE	(1))  	//Include JTAG Loader when set to '1' 
	logic1 (    					    //Name to match your PSM file
 		.rdl 			(rdl1),	        // output "kcpsm6_reset" from Picoblaze instance
		.enable 		(bram_enable),	// input
		.address 		(address),		// 11:0 input
		.instruction 	(instruction1),	// 17:0 output
		.clk 			(sysclk)		// input
	);		

    // Two-player ROM
    game_logic2 #(
        .C_FAMILY          ("7S"),      //Family 'S6' or 'V6'
        .C_RAM_SIZE_KWORDS  (2),        //Program size '1', '2' or '4'
        .C_JTAG_LOADER_ENABLE   (0))    //Include JTAG Loader when set to '1' 
    logic2 (                            //Name to match your PSM file
        .rdl            (rdl2),         // output "kcpsm6_reset" from Picoblaze instance
        .enable         (bram_enable),  // input
        .address        (address),      // 11:0 input
        .instruction    (instruction2), // 17:0 output
        .clk            (sysclk)        // input
    );  


    // Interface module
    nexys4_if inter(
        // Interface to top module
        .clk(sysclk),				// input
        .reset(sysreset),			// input
	    .random(randomizer), 	    // input [2:0]
    
        // Interface to Encoders
        .enc1({rotary_event, pmod_btns, left_pos}), 		// input [2:0]
        .enc2({rotary_event2, pmod_btns2, left_pos2}), 		// input [2:0]
    
        // Interface to PicoBlaze (kcpsm6.v)
        .port_id(port_id),					// input [7:0]
        .out_port(out_port),				// input [7:0]
        .in_port(in_port), 					// output [7:0]
        .k_write_strobe(k_write_strobe),	// input
        .write_strobe(write_strobe),		// input
        .read_strobe(read_strobe),			// input
        .interrupt(interrupt),				// output 
        .interrupt_ack(interrupt_ack),		// input
      
        // Interface to board and icons video control system
        .LOCX_CURSOR(locX_cursor),
        .LOCY_CURSOR (locY_cursor),
        .locX_state(locX_state),
        .locY_state(locY_state),
        .update_state(update_state),
        .wea_state_ram(wea_state_ram),
        .Player_2_v(Player_2_v),
        .Player_1_v(Player_1_v),
        
        // Interface to 7-segment display
        .d0(dig0),
        .d1(dig1),
        .d2(dig2),
        .d3(dig3),
        .d4(dig4),
        .d5(dig5),
        .d6(dig6),
        .d7(dig7),
        .dp(decpts)
    );
    
    // Cursor Icon controller
    cursor_mod cursor_inst(
          .vid_row(vid_row),
          .vid_col(vid_col),
          .locX(locX_cursor),
          .locY(locY_cursor),
          .cursor(cursor),
          .clk(VGA_clk)
          );
    
    // Victory screen controller
    victory_screen vs_sc (
        .clk(sysclk),
        .Player_1_v(Player_1_v),
        .Player_2_v(Player_2_v),
        .data_out_v_s(data_out_v_s),
        .pixel_row(vid_row),
        .pixel_column(vid_col),
        .dis_victory_screen(dis_victory_screen)
    );
      
    // Welcome screen controller
    welcome_screen_module WS(
        .clk(clk),
        .background_signal(background_signal),
        .pixel_row(vid_row),
        .pixel_column(vid_col),
        .data_value_back(data_value_back)
    );
          
           
        
endmodule