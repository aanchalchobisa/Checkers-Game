`timescale 1ns / 1ps
// icon.v - Module to display the icons for the game. 
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
// There are four icons designed, two for each player, one when the pawn is just a simple man and one when 
// it then converts to a king, We have designed separate icons for each player. Each icon is a 56*56 size. 
//To design the icons, we created the icon in paint and then run a python script to generate the .Coe file.
//////////////////////////////////////////////////////////////////////////////////////////////////////////


module icon(
    input [9:0] vid_row,			// video logic row address
    input [9:0] vid_col,			// video logic col address
    input [7:0] locX,locY,			// X-coordinate of Icon's location and Y-coordinate of Icon's location
    input [7:0] icon_state,			// Icon state to display the logic
    output reg [7:0] icon,			// Icon value
  //  output reg [7:0] led,
    input clk						// The system clock
    );
    
    reg [11:0] addr;				// Address variable
    reg [11:0] addr_1, addr_2, addr_3, addr_4;	// Icon Variables to address the variables 
    reg [6:0] counter_icon = 0;			// counter_icon value
    //reg [7:0] previous_pixel_row = 0;
    
    
    wire [7:0] pixel_col, pixel_row; 	// Scaling the vid_col and vid_row to fit in the 512 * 512 image
    wire  [7:0] icon_1_d,icon_2_d, icon_king_1, icon_king_2; // Different icons for the icon 1 and 2, king icon 1 and icon 2
    
   assign pixel_col = vid_col >> 2;		//	Scaling the pixel_col to fit in the 512 * 512 image
   assign pixel_row = vid_row >> 2;		// Scaling the pixel_row to fit in the 512 * 512 image
   
   
   always@ (posedge clk) begin
            
            
         if ((pixel_col == locX) && (pixel_row == locY)) begin		// Initial state 
            
            addr <= 0;
            addr_1 <= 0; 
            addr_2 <= 0;
            addr_3 <= 0;
            addr_4 <= 0;
            counter_icon <= counter_icon + 1;

          
            end
         else icon <= 0;											// Else icon is different
          
         if ((pixel_col> locX) && (pixel_col < locX+15) ) begin		// Boundary conditions to decide the proper addressing
            if ((pixel_row>locY ) && (pixel_row < locY+15))begin
               
                     if ((pixel_col > 8'h0e && pixel_col <= 8'h1c) || (pixel_col > 8'h00 && pixel_col <= 8'h0e))begin
                        addr_1 <= addr_1 + 1;						// This is for address 1
                        addr <= addr_1;
                     end
                     
                     else if ((pixel_col > 8'h2a && pixel_col <= 8'h38) || (pixel_col > 8'h1c && pixel_col <= 8'h2a) ) begin
                        addr_2 <= addr_2 + 1;						// This is for address 2
                        addr <= addr_2;
                     end 
                                        
                     else if ((pixel_col > 8'h46 && pixel_col <= 8'h54) || (pixel_col > 8'h38 && pixel_col <= 8'h46) ) begin
                        addr_3 <= addr_3 + 1;						// This is for address 3
                        addr <= addr_3;
                     end
                     
                     else if ((pixel_col > 8'h62 && pixel_col <= 8'h70) || (pixel_col > 8'h54 && pixel_col <= 8'h62)) begin
                        addr_4 <= addr_4 + 1;						// This is for address 4
                        addr <= addr_4;
                     end

                         //previous_pixel_row <= pixel_row;
                  case (icon_state)						// Depending upon the icon decision, the relevant icon is displayed
                    0: icon <= 0;						// No icon is displayed
                    1: icon <= icon_1_d;				// Icon 1 is displayed     
                    2: icon <= icon_2_d;				// Icon 2 is displayed
                    3: icon <= icon_king_1;				// Icon king 1 is displayed
                    4: icon <= icon_king_2;				// Icon king 2 is displayed
                    default : icon <= 0;
                   endcase

               end
                   
          else icon <= 0; 								// Icon is displayed
                      
                            
             end
       end      
      
      ICON_1 icon1 (
          .clka(clk),
          .addra(addr),
          .douta(icon_1_d)
        );
      
      ICON_2 icon2 (
          .clka(clk),
          .addra(addr),
          .douta(icon_2_d)
        );
        
        icon_king_p1 iconk1
          (
            .clka(clk),
             .addra(addr),
             .douta(icon_king_1)
          );
          
           icon_king_p2 iconk2
                   (
                     .clka(clk),
                      .addra(addr),
                      .douta(icon_king_2)
                   );
                
     
endmodule
