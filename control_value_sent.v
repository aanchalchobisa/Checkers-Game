`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
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
// This module provides the state value to display the icon on the white squares of the board. It consists of a RAM which will be written
// by the picoblaze. The module reads in the Displaying pixel column and row values and then sends the address for the corresponding white square. 
// The state value is read from the RAM and then sent to the icon module. The state is updated from the picoblaze.
//////////////////////////////////////////////////////////////////////////////////////////////////////////

module control_value_sent(
    input clk,
    output reg [7:0] IconVal,
    output reg [7:0] LocX,
    output reg [7:0] LocY,
    input [7:0] pixel_row,
    input [7:0] pixel_col,
	input [7:0] locX_state,
	input [7:0] locY_state,
	input [7:0] update_state,
	input 		wea_state_ram
    );
	
	
    
  wire [7:0] pixel_row_rom ;
  wire [7:0] pixel_col_rom ;
  reg [4:0] addr_rom_xy;
  
  initial addr_rom_xy = 0;
  
  reg [4:0] addr_b, addr_a;
  wire [7:0] state_data;
  
 
 
 // Logic to generate the address of the RAM and read the state for a specific white square of the board.
 
  always @ (posedge clk)
    begin
    if (pixel_row >= 8'h0 && pixel_row < 8'h0e ) begin
        if (pixel_col >= 8'h0e && pixel_col < 8'h1c) begin
            LocX <= 8'h0e;
            addr_b <= 0;
            IconVal <= state_data;
            
            
        end
        
        else if (pixel_col >= 8'h2a && pixel_col < 8'h38) begin
            LocX <= 8'h2a;
            addr_b <= 1;
            IconVal <= state_data;
        end  
        
        else if (pixel_col >= 8'h46 && pixel_col < 8'h54) begin
            LocX <= 8'h46;
            addr_b <= 2;
            IconVal <= state_data;            
        end  
        
        else if (pixel_col >= 8'h62 && pixel_col < 8'h70) begin
            LocX <= 8'h62;
            addr_b <= 3;
            IconVal <= state_data;            
        end 
        
               
        LocY <= 8'h00;
    end
    else if (pixel_row >= 8'h0e && pixel_row < 8'h1c ) begin
        if (pixel_col >= 8'h00 && pixel_col < 8'h0e) begin
            LocX <= 8'h00;
            addr_b <= 4;
            IconVal <= state_data;
            
        end
        
        else if (pixel_col >= 8'h1c && pixel_col < 8'h2a) begin
            LocX <= 8'h1c;
            addr_b <= 5;
            IconVal <= state_data;            
        end  
        
        else if (pixel_col >= 8'h38 && pixel_col < 8'h46) begin
            LocX <= 8'h38;
            addr_b <= 6;
            IconVal <= state_data;            
        end  
        
        else if (pixel_col >= 8'h54 && pixel_col < 8'h62) begin
            LocX <= 8'h54;
            addr_b <= 7;
            IconVal <= state_data;            
        end 
                  
        LocY <= 8'h0e;
       end
         
    else if (pixel_row >= 8'h1c && pixel_row < 8'h2a ) begin
          if (pixel_col >= 8'h0e && pixel_col < 8'h1c) begin
              LocX <= 8'h0e;
              addr_b <= 8;
              IconVal <= state_data;              
          end
          
          else if (pixel_col >= 8'h2a && pixel_col < 8'h38) begin
              LocX <= 8'h2a;
              addr_b <= 9;
              IconVal <= state_data;              
          end  
          
          else if (pixel_col >= 8'h46 && pixel_col < 8'h54) begin
              LocX <= 8'h46;
              addr_b <= 10;
              IconVal <= state_data;               
          end  
          
          else if (pixel_col >= 8'h62 && pixel_col < 8'h70) begin
              LocX <= 8'h62;
              addr_b <= 11;
              IconVal <= state_data;               
          end 
          
                 
          LocY <= 8'h1c;
      end
    else if (pixel_row >= 8'h2a && pixel_row < 8'h38 ) begin
          if (pixel_col >= 8'h00 && pixel_col < 8'h0e) begin
              LocX <= 8'h00;
              addr_b <= 12;
              IconVal <= state_data;               
          end
          
          else if (pixel_col >= 8'h1c && pixel_col < 8'h2a) begin
              LocX <= 8'h1c;
              addr_b <= 13;
              IconVal <= state_data;               
          end  
          
          else if (pixel_col >= 8'h38 && pixel_col < 8'h46) begin
              LocX <= 8'h38;
              addr_b <= 14;
              IconVal <= state_data;               
          end  
          
          else if (pixel_col >= 8'h54 && pixel_col < 8'h62) begin
              LocX <= 8'h54;
              addr_b <= 15;
              IconVal <= state_data;               
          end 
                    
          LocY <= 8'h2a;
         end
         
    else if (pixel_row >= 8'h38 && pixel_row < 8'h46 ) begin
         if (pixel_col >= 8'h0e && pixel_col < 8'h1c) begin
             LocX <= 8'h0e;
             addr_b <= 16;
             IconVal <= state_data;              
         end
         
         else if (pixel_col >= 8'h2a && pixel_col < 8'h38) begin
             LocX <= 8'h2a;
             addr_b <= 17;
             IconVal <= state_data;               
         end  
         
         else if (pixel_col >= 8'h46 && pixel_col < 8'h54) begin
             LocX <= 8'h46;
             addr_b <= 18;
             IconVal <= state_data;               
         end  
         
         else if (pixel_col >= 8'h62 && pixel_col < 8'h70) begin
             LocX <= 8'h62;
             addr_b <= 19;
             IconVal <= state_data;               
         end 
         
                
         LocY <= 8'h38;
         end
     else if (pixel_row >= 8'h46 && pixel_row < 8'h54 ) begin
         if (pixel_col >= 8'h00 && pixel_col < 8'h0e) begin
             LocX <= 8'h00;
             addr_b <= 20;
             IconVal <= state_data;               
         end
         
         else if (pixel_col >= 8'h1c && pixel_col < 8'h2a) begin
             LocX <= 8'h1c;
             addr_b <= 21;
             IconVal <= state_data;               
         end  
         
         else if (pixel_col >= 8'h38 && pixel_col < 8'h46) begin
             LocX <= 8'h38;
             addr_b <= 22;
             IconVal <= state_data;               
         end  
         
         else if (pixel_col >= 8'h54 && pixel_col < 8'h62) begin
             LocX <= 8'h54;
             addr_b <= 23;
             IconVal <= state_data;               
         end 
                   
         LocY <= 8'h46;
        end
          
     else if (pixel_row >= 8'h54 && pixel_row < 8'h62 ) begin
       if (pixel_col >= 8'h0e && pixel_col < 8'h1c) begin
           LocX <= 8'h0e;
           addr_b <= 24;
           IconVal <= state_data;             
       end
       
       else if (pixel_col >= 8'h2a && pixel_col < 8'h38) begin
           LocX <= 8'h2a;
           addr_b <= 25;
           IconVal <= state_data;            
       end  
       
       else if (pixel_col >= 8'h46 && pixel_col < 8'h54) begin
           LocX <= 8'h46;
           addr_b <= 26;
           IconVal <= state_data;            
       end  
       
       else if (pixel_col >= 8'h62 && pixel_col < 8'h70) begin
           LocX <= 8'h62;
           addr_b <= 27;
           IconVal <= state_data;            
       end 
       
              
       LocY <= 8'h54;
       end
     else if (pixel_row >= 8'h62 && pixel_row < 8'h70 ) begin
           if (pixel_col >= 8'h00 && pixel_col < 8'h0e) begin
               LocX <= 8'h00;
               addr_b <= 28;
               IconVal <= state_data;                
           end
           
           else if (pixel_col >= 8'h1c && pixel_col < 8'h2a) begin
               LocX <= 8'h1c;
               addr_b <= 29;
               IconVal <= state_data;            
           end  
           
           else if (pixel_col >= 8'h38 && pixel_col < 8'h46) begin
               LocX <= 8'h38;
               addr_b <= 30;
               IconVal <= state_data;               
           end  
           
           else if (pixel_col >= 8'h54 && pixel_col < 8'h62) begin
               LocX <= 8'h54;
               addr_b <= 31;
               IconVal <= state_data;               
           end 
                     
           LocY <= 8'h62;
          end
  end     
  
// Logic to generate the address of the RAM for a specific white square of the board.

always @ (posedge clk)
    begin
    if (locY_state >= 8'h00 && locY_state < 8'h0e ) begin
        if (locX_state >= 8'h0e && locX_state < 8'h1c) begin
            addr_a <= 0;
           
            
            
        end
        
        else if (locX_state >= 8'h2a && locX_state < 8'h38) begin
            addr_a <= 1;
           
        end  
        
        else if (locX_state >= 8'h46 && locX_state < 8'h54) begin
            addr_a <= 2;
                       
        end  
        
        else if (locX_state >= 8'h62 && locX_state < 8'h70) begin
            addr_a <= 3;
                       
        end 

    end
    else if (locY_state >= 8'h0e && locY_state < 8'h1c ) begin
        if (locX_state >= 8'h00 && locX_state < 8'h0e) begin
            addr_a <= 4;
           
            
        end
        
        else if (locX_state >= 8'h1c && locX_state < 8'h2a) begin
            addr_a <= 5;
                       
        end  
        
        else if (locX_state >= 8'h38 && locX_state < 8'h46) begin
            addr_a <= 6;
                       
        end  
        
        else if (locX_state >= 8'h54 && locX_state < 8'h62) begin
            addr_a <= 7;
                       
        end 
                  

       end
         
    else if (locY_state >= 8'h1c && locY_state < 8'h2a ) begin
          if (locX_state >= 8'h0e && locX_state < 8'h1c) begin
              addr_a <= 8;
                           
          end
          
          else if (locX_state >= 8'h2a && locX_state < 8'h38) begin
              addr_a <= 9;
                           
          end  
          
          else if (locX_state >= 8'h46 && locX_state < 8'h54) begin
              addr_a <= 10;
                            
          end  
          
          else if (locX_state >= 8'h62 && locX_state < 8'h70) begin
              addr_a <= 11;
                            
          end 
          
    
      end
    else if (locY_state >= 8'h2a && locY_state < 8'h38 ) begin
          if (locX_state >= 8'h00 && locX_state < 8'h0e) begin
              addr_a <= 12;
                            
          end
          
          else if (locX_state >= 8'h1c && locX_state < 8'h2a) begin
              addr_a <= 13;
                            
          end  
          
          else if (locX_state >= 8'h38 && locX_state < 8'h46) begin
              addr_a <= 14;
                            
          end  
          
          else if (locX_state >= 8'h54 && locX_state < 8'h62) begin
              addr_a <= 15;
                            
          end 
  
         end
         
    else if (locY_state >= 8'h38 && locY_state < 8'h46 ) begin
         if (locX_state >= 8'h0e && locX_state < 8'h1c) begin
             addr_a <= 16;
                          
         end
         
         else if (locX_state >= 8'h2a && locX_state < 8'h38) begin
             addr_a <= 17;
                           
         end  
         
         else if (locX_state >= 8'h46 && locX_state < 8'h54) begin
             addr_a <= 18;
                           
         end  
         
         else if (locX_state >= 8'h62 && locX_state < 8'h70) begin
             addr_a <= 19;
                           
         end 
         
                
         end
     else if (locY_state >= 8'h46 && locY_state < 8'h54 ) begin
         if (locX_state >= 8'h00 && locX_state < 8'h0e) begin
             addr_a <= 20;
                           
         end
         
         else if (locX_state >= 8'h1c && locX_state < 8'h2a) begin
             addr_a <= 21;
                           
         end  
         
         else if (locX_state >= 8'h38 && locX_state < 8'h46) begin
             addr_a <= 22;
                           
         end  
         
         else if (locX_state >= 8'h54 && locX_state < 8'h62) begin
             addr_a <= 23;
                           
         end 
                   
       
        end
          
     else if (locY_state >= 8'h54 && locY_state < 8'h62 ) begin
       if (locX_state >= 8'h0e && locX_state < 8'h1c) begin
           addr_a <= 24;
                       
       end
       
       else if (locX_state >= 8'h2a && locX_state < 8'h38) begin
           addr_a <= 25;
                      
       end  
       
       else if (locX_state >= 8'h46 && locX_state < 8'h54) begin
           addr_a <= 26;
                      
       end  
       
       else if (locX_state >= 8'h62 && locX_state < 8'h70) begin
           addr_a <= 27;
                      
       end 
       
              
       end
     else if (locY_state >= 8'h62 && locY_state < 8'h70 ) begin
           if (locX_state >= 8'h00 && locX_state < 8'h0e) begin
               addr_a <= 28;
                              
           end
           
           else if (locX_state >= 8'h1c && locX_state < 8'h2a) begin
               addr_a <= 29;
                          
           end  
           
           else if (locX_state >= 8'h38 && locX_state < 8'h46) begin
               addr_a <= 30;
                             
           end  
           
           else if (locX_state >= 8'h54 && locX_state < 8'h62) begin
               addr_a <= 31;
                             
           end 
                     
        
          end
  end                    
                       
        
//Block RAM instantion for the storing of the states          
icon_state_ram1 isr
    (
      .clka(clk),
      .wea(wea_state_ram),
      .addra(addr_a),
      .dina(update_state),
      .clkb(clk),
      .addrb(addr_b),
      .doutb(state_data)
    );
            
endmodule
