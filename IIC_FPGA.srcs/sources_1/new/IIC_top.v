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
	output led0_b,
	output led1_b
    );
    
    wire reset = btn[0];
    
    reg [6:0] dev_addr = 7'b1010000;
    reg [7:0] byte_addr = 8'h00;
    reg [7:0] byte_data_tx = 8'hac;
    
    reg clk = 0;
    reg [11:0] clk_counter;
    always @(posedge CLK100MHZ, posedge btn[0]) begin
    	if (btn[0]) begin
    		clk_counter <= 0;
    		clk <= 0;
    	end
    	else begin
    		if (clk_counter==11'd150) begin
    			clk <= ~clk;
    			clk_counter <= 0;
    		end
    		else begin
    			clk_counter <= clk_counter + 11'd1;
    			clk <= clk;
    		end
    	end
    end
    
    wire start;   
    reg [127:0] start_reg = 0;
    always @(posedge clk, posedge reset) begin
    	if (reset) begin
    		start_reg <= 0;
    	end
    	else begin
    		start_reg <= {start_reg[126:0],btn[1]};
    	end
    end
    assign start = &start_reg;


     			

    wire tx_done, rx_done;
    
//	Delete comment to use write function.
//	IIC_write inst_write(
//		.clk(clk),
//		.tx_enable(start),
//		.reset(reset),
//		.dev_addr(dev_addr),
//		.byte_addr(byte_addr),
//		.byte_data(byte_data_tx),
//		.tx_done(tx_done),
//		.scl(scl),
//		.sda(sda),
//		.sda_ctrl(led0_b)
//		);
	
	wire [7:0] byte_data_rx;
	
//	Delete comment to use read function.
	IIC_read inst_read(
		.clk(clk),
		.rx_enable(start),
		.reset(reset),
		.dev_addr(dev_addr),
		.byte_addr(byte_addr),
		.byte_data(byte_data_rx),
		.rx_done(rx_done),
		.scl(scl),
		.sda(sda),
		.sda_ctrl(led1_b)
		);
    
endmodule
