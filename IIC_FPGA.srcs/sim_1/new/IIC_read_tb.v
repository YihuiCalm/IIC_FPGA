`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2023 05:48:25 PM
// Design Name: 
// Module Name: IIC_read_tb
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


module IIC_read_tb;

	reg clk=0, rx_enable=1, reset=1;
	reg [6:0] dev_addr=7'b0101010;
	reg [7:0] byte_addr=8'hcc;

	wire sda, sda_out;
	wire sda_ctrl;
	reg sda_in = 0;
	
	wire [7:0] byte_data;
	wire tx_done;
	wire scl;
	
	always #1 clk = ~clk;
	
	initial begin
		#10 reset = 0;

		#100 rx_enable=0;
		
		#140 sda_in = 1;
	end
	
	assign sda = sda_ctrl? sda_out: sda_in;
	
	IIC_read inst(
		.clk(clk),
		.rx_enable(rx_enable),
		.reset(reset),
		.dev_addr(dev_addr),
		.byte_addr(byte_addr),
		.byte_data(byte_data),
		.rx_done(rx_done),
		.scl(scl),
		.sda(sda),
		.sda_ctrl(sda_ctrl)
		);

endmodule
