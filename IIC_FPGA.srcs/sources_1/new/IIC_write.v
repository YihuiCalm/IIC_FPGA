`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2023 10:15:43 AM
// Design Name: 
// Module Name: IIC_tx
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


module IIC_write(
	input clk,
	input tx_enable,
	input reset,
	input [6:0] dev_addr,
	input [7:0] byte_addr,
	input [7:0] byte_data,
	
	output reg tx_done,
	output reg scl = 0,
	inout sda,
	output sda_ctrl
    );
	
	// Global counter configuration.
	reg [3:0] counter = 0;
	always @(posedge clk, posedge reset) begin
		if (reset) counter <= 0;
		else begin
			if (counter == 4'd3) counter <= 4'd0;
			else counter <= counter + 4'd1;
		end
	end
	
	// SDA IO port configuration.
	reg sda_ctrl = 1, sda_out = 1;
	wire sda_in;
	
	assign sda = sda_ctrl? sda_out: 1'bz;
	assign sda_in = sda;
	
	
	reg [3:0] bit_counter = 0;
	reg [3:0] byte_counter = 0;
	reg ack = 0;
	
	// State machine configuration.
	parameter idle = 6'b000001;
	parameter start = 6'b000010;
	parameter byte_tx = 6'b000100;
	parameter ack_wait = 6'b001000;
	parameter stop = 6'b010000;
	parameter done = 6'b100000;
	
	reg [5:0] state = idle, next = idle;
	
	always @(*) begin
		case (state)
			idle: next = (tx_enable&counter==4'd3)? start: idle;
			start: next = (counter==4'd3)? byte_tx: start;
			byte_tx: next = (counter==4'd3)&(bit_counter==4'd7)? ack_wait: byte_tx;
			ack_wait: next = (counter==4'd3)? (ack? ((byte_counter==4'd2)? stop: byte_tx): stop): ack_wait;
			stop: next = (counter==4'd3)? done: stop;
			done: next = done;
		endcase
	end		
	
	always @( posedge clk, posedge reset) begin
		if (reset) state <= idle;
		else state <= next;
	end
	
	// SCL signal.
	always @( posedge clk, posedge reset) begin
		if (reset) scl <= 0;
		else begin
			if (counter==4'd0|counter==4'd1) scl <= 1;
			else scl <= 0;
		end
	end
	
    // SDA input/output control.
    always @( posedge clk, posedge reset) begin
    	if (reset) sda_ctrl <= 1'b1;
    	else if (state==ack_wait) sda_ctrl <= 1'b0;
    	else sda_ctrl <= 1'b1;
    end
    
    // ACK signal.
    always @( posedge clk, posedge reset) begin
    	if (reset) ack <= 0;
    	else if ((state==ack_wait)) begin
    		if ((sda_in==0)&(counter==4'd1)) ack <= 1;
    		else ack <= ack;
    	end
    	else ack <= 0;
    end
    	 
    // Data counter.
    always @( posedge clk, posedge reset) begin
    	if (reset) begin
    		bit_counter <= 4'd0;
    		byte_counter <= 4'd0;
    	end
    	else if ((counter==3)&(state==byte_tx)) begin
    		if (bit_counter==4'd7) bit_counter <= 0;
    		else bit_counter <= bit_counter + 4'd1;
    	end
    	else if ((counter==3)&(state==ack_wait)) begin
    		if (byte_counter==4'd2) byte_counter <= 0;
    		else byte_counter <= byte_counter + 4'd1;
    	end
    	else begin
    		bit_counter <= bit_counter;
    		byte_counter <= byte_counter;
    	end
    end
    
    // Data organize.
    reg [23:0] data = 0;
    always @( posedge clk, posedge reset) begin
    	if (reset) data <= 24'd0;
    	else if (next==start) data <= {dev_addr,1'b0,byte_addr,byte_data};
    	else if ((next==byte_tx)&(counter==4'd3)) data <= data << 1;
    	else data <= data;
    end
    
    // SDA output.
    always @( posedge clk, posedge reset) begin
    	if (reset) sda_out <= 1;
    	else if (next==start) begin
    		case (counter) 
    			4'd0: sda_out <= 1;
    			4'd1: sda_out <= 0;
    			4'd2: sda_out <= 0;
    			default:;
    		endcase
    	end
    	else if (next==stop) begin
    		case (counter) 
    			4'd3: sda_out <= 0;
    			4'd0: sda_out <= 0;
    			4'd1: sda_out <= 1;
    			4'd2: sda_out <= 1;
    			default:;
    		endcase
    	end
    	else if (next==byte_tx) begin
    		sda_out <= (counter==4'd3)? data[23]: sda_out;
    	end
    	else sda_out <= 1;
    end
    
    //Tx_done.
    always @( posedge clk, posedge reset) begin
     	if (reset) tx_done <= 0;
     	else if ((next==stop)&(counter==4'd2)) tx_done <= 1;
     	else tx_done = 0;
     end
    
    	
endmodule
