`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2023 06:26:34 PM
// Design Name: 
// Module Name: IIC_top_tb
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


module IIC_top_tb(

    );
    
    reg clk=0, tx_enable=0, reset=1;
	reg ack=1;
	wire sda, sda_out;
	wire sda_ctrl;
	reg sda_in = 0;

	wire tx_done;
	wire scl;
	
	always #1 clk = ~clk;
	
	initial begin
		#100 reset = 0;
		#100 tx_enable=1;
		#500 tx_enable=0;
	end
	
	assign sda = sda_ctrl? sda_out: sda_in;
	
	IIC_top inst(
		.CLK100MHZ(clk),
		.btn({tx_enable,reset}),
		.scl(scl),
		.sda(sda),
		.led1_b(sda_ctrl)
		);
    
endmodule
