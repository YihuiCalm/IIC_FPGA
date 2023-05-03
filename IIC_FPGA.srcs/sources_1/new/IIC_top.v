`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2023 06:16:06 PM
// Design Name: 
// Module Name: IIC_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IIC_top(
	input CLK100MHZ,
	input [1:0] btn,
	
	output scl,
	inout sda,
	output led0_b
    );
    
    wire reset = btn[0];
    
    reg [6:0] dev_addr = 7'b1010000;
    reg [7:0] byte_addr = 8'h23;
    reg [7:0] byte_data = 8'h45;
    
    reg clk = 0;
    reg [11:0] clk_counter;
    always @(posedge CLK100MHZ, posedge btn[0]) begin
    	if (btn[0]) begin
    		clk_counter <= 0;
    		clk <= 0;
    	end
    	else begin
    		if (clk_counter==11'd100) begin
    			clk <= ~clk;
    			clk_counter <= 0;
    		end
    		else begin
    			clk_counter <= clk_counter + 11'd1;
    			clk <= clk;
    		end
    	end
    end
    
    reg tx_enable = 0;
    reg [127:0] tx_enable_reg=0;
    always @(posedge clk, posedge reset) begin
    	if (reset) begin
    		tx_enable_reg <= 0;
    		tx_enable <= 0;
    	end
    	else begin
    		tx_enable_reg <= {tx_enable_reg[126:0],btn[1]};
    		if (&tx_enable_reg) tx_enable <= 1; 
    		else tx_enable <= 0;
    	end
    end
    
    wire tx_done, sda_ctrl;
    
	IIC_write inst(
		.clk(clk),
		.tx_enable(tx_enable),
		.reset(reset),
		.dev_addr(dev_addr),
		.byte_addr(byte_addr),
		.byte_data(byte_data),
		.tx_done(tx_done),
		.scl(scl),
		.sda(sda),
		.sda_ctrl(led0_b)
		);
    
endmodule
