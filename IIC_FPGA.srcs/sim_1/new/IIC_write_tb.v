`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2023 05:51:21 PM
// Design Name: 
// Module Name: IIC_write_tb
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

module IIC_write_tb;

	reg clk=0, tx_enable=0, reset=1;
	reg [6:0] dev_addr=7'b0101010;
	reg [7:0] byte_addr=8'hcc;
	reg [7:0] byte_data=8'haa;
	reg ack=1;
	wire sda, sda_out;
	wire sda_ctrl;
	reg sda_in = 0;
	
	
	wire tx_done;
	wire scl;
	
	always #1 clk = ~clk;
	
	initial begin
		#10 reset = 0;
		#10 tx_enable=1;
		#50 tx_enable=0;
	end
	
	assign sda = sda_ctrl? sda_out: sda_in;
	
	IIC_write inst(
		.CLK100MHZ(clk),
		.tx_enable(tx_enable),
		.reset(reset),
		.dev_addr(dev_addr),
		.byte_addr(byte_addr),
		.byte_data(byte_data),
		.tx_done(tx_done),
		.scl(scl),
		.sda(sda),
		.sda_crl(sda_ctrl)
		);

endmodule
