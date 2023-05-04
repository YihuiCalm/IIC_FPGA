`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2023 04:43:31 PM
// Design Name: 
// Module Name: IIC_read
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


module IIC_read(
	input clk,
	input rx_enable,
	input reset,
	input [6:0] dev_addr,
	input [7:0] byte_addr,
	
	output reg [7:0] byte_data,
	
	output reg rx_done,
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
	parameter byte_rx = 6'b100000;
	parameter done = 6'b000000;
	
	reg [5:0] state = idle, next = idle;
	
	always @(*) begin
		case (state)
			idle: next = (rx_enable&counter==4'd3)? start: idle;
			start: next = (counter==4'd3)? byte_tx: start;
			byte_tx: next = (counter==4'd3)&(bit_counter==4'd7)? ack_wait: byte_tx;
			ack_wait: begin
				if (counter==4'd3) begin
					if (~ack) next = stop;
					else begin
						case (byte_counter)
							4'd0: next = byte_tx;
							4'd1: next = start;
							4'd2: next = byte_rx;
							4'd3: next = stop;
						endcase
					end
				end
				else next = ack_wait;
			end
			byte_rx: next = (counter==4'd3)&(bit_counter==4'd7)? ack_wait: byte_rx;
			stop: next = (counter==4'd3)? done: stop;
			done: next = done;
		endcase
	end		
	
	always @( posedge clk, posedge reset) begin
		if (reset) state <= idle;
		else state <= next;
	end
	
	// Data counter.
    always @( posedge clk, posedge reset) begin
    	if (reset) begin
    		bit_counter <= 4'd0;
    		byte_counter <= 4'd0;
    	end
    	else if ((counter==3)&((state==byte_tx)|(state==byte_rx))) begin
    		if (bit_counter==4'd7) bit_counter <= 0;
    		else bit_counter <= bit_counter + 4'd1;
    	end
    	else if ((counter==3)&(state==ack_wait)) begin
    		if (byte_counter==4'd3) byte_counter <= 0;
    		else byte_counter <= byte_counter + 4'd1;
    	end
    	else begin
    		bit_counter <= bit_counter;
    		byte_counter <= byte_counter;
    	end
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
    	else if ((state==ack_wait)|(state==byte_rx)) sda_ctrl <= 1'b0;
    	else sda_ctrl <= 1'b1;
    end
    
    // ACK signal.
    always @( posedge clk, posedge reset) begin
    	if (reset) ack <= 0;
    	else if ((next==ack_wait)) begin
    		if ((sda_in==0)&(counter==4'd1)) ack <= 1;
    		else ack <= ack;
    	end
    	else ack <= 0;
    end
    
    // Data organize.
    reg [23:0] data = 0;
    always @( posedge clk, posedge reset) begin
    	if (reset) data <= 24'd0;
    	else if ((next==start)&(byte_counter==4'd0)) data <= {dev_addr,1'b0,byte_addr,dev_addr,1'b1};
    	else if ((next==byte_tx)&(counter==4'd3)) data <= data << 1;
    	else data <= data;
    end
    
    // SDA output/input.
    always @( posedge clk, posedge reset) begin
    	if (reset) begin
    		sda_out <= 1;
    		byte_data <= 0;
    	end
    	else if (next==start) begin
    		case (counter) 
    			4'd3: sda_out <= 1;
    			4'd0: sda_out <= 1;
    			4'd1: sda_out <= 0;
    			4'd2: sda_out <= 0;
    			default:;
    		endcase
    		if (byte_counter==4'd0) byte_data <= 0;
    	end
    	else if (next==stop) begin
    		case (counter) 
    			4'd3: sda_out <= 0;
    			4'd0: sda_out <= 0;
    			4'd1: sda_out <= 1;
    			4'd2: sda_out <= 1;
    			default:;
    		endcase
    		byte_data <= byte_data;
    	end
    	else if (next==byte_tx) begin
    		sda_out <= (counter==4'd3)? data[23]: sda_out;
    		byte_data <= byte_data;
    	end
    	else if (next==byte_rx) begin
    		byte_data <= (counter==4'd1)? {byte_data[6:0],sda_in}: byte_data;
    		sda_out <= 0;
    	end
    	else begin
    		sda_out <= 1;
    		byte_data <= byte_data;
    	end
    end
    
    //Rx_done.
    always @( posedge clk, posedge reset) begin
     	if (reset) rx_done <= 0;
     	else if ((next==stop)&(counter==4'd2)) rx_done <= 1;
     	else rx_done = 0;
     end
     
     
endmodule
