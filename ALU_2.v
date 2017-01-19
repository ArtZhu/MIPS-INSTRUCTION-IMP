`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:34:56 10/29/2015 
// Design Name: 
// Module Name:    ALU_2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

	/***
	 *	and		0000
	 *	or		0001
	  	add		0010
						0011
	 		sll		0100
			srl		0101

	 		and(~)1000
			or(~) 1001
	 		sub 	1010
	 		slt		1011
									*
									*
	 							***/
module alu32
	#(parameter WIDTH = 32)
	(
	input [WIDTH-1:0] A, B,
	//SLL
	input [3:0] F, 
	input [4:0] shamt,
	output reg [WIDTH-1:0] Y,
	output reg Zero
	);

	//SLL, SRL
	wire[WIDTH-1:0] d0, d1, d2, d3, d4, d5;
	wire[WIDTH-1:0] actualB;
	wire cout;

	
	//SLL
	assign actualB = F[3]? ~B:B;
	assign d0 = A & actualB;
	assign d1 = A | actualB;
	assign {cout, d2} = A + actualB + F[3];
	assign d3 = d2[WIDTH-1];
	//SLL
	assign d4 = actualB << shamt;
	//SRL
	assign d5 = actualB >> shamt;
	
	
	
	always @ (*) begin
		case(F[2:0])
			3'b000: Y = d0;
			3'b001: Y = d1;
			3'b010: Y = d2;
			3'b011: Y = d3;
			3'b100: Y = d4;
			3'b101: Y = d5;
			default: Y = d0;
		endcase
		Zero = (Y==0);
	end

endmodule

