//------------------------------------------------
// mipsmem.v
// David_Harris@hmc.edu 23 October 2005
// External memories used by MIPS processors
//------------------------------------------------


module dmem(input         clk, we,
            input  [31:0] a, wd,
            output reg [31:0] rd,
						//Lh
						input  [1:0]	bytes,
						output reg [31:0] rawd
						);

  reg  [31:0] RAM[63:0];

//  reg [31:0] rawd;
  reg [7:0] p0, p1, p2, p3;
  
  always @(*) begin
	  rawd = RAM[a[31:2]];
	  p0 = rawd [7:0];
	  p1 = rawd [15:8];
	  p2 = rawd [23:16];
	  p3 = rawd [31:24];
  end
  
  always @(*)
	case(bytes)
		2:
			case(a[1])
				1: rd <= {{16{p3[7]}}, p3, p2};
				0:	rd <= {{16{p1[7]}}, p1, p0};
			endcase
		1:
			case(a[1:0])
				3: rd <= {{24{p3[7]}}, p3};
				2: rd <= {{24{p2[7]}}, p2};
				1: rd <= {{24{p1[7]}}, p1};
				0: rd <= {{24{p0[7]}}, p0};
			endcase
		default: rd <= rawd; 
	endcase
	
  always @(posedge clk)
    if (we) 
			RAM[a[31:2]] <= wd;
			

endmodule


