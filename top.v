module top(input clk, reset, 
           output [31:0] aluout, writedata, readdata, output memwrite,
			  output regwrite, regdst, logicext, alusrc, branch, branchnot, memtoreg, jump,
			  output [31:0] srca, srcb,
			  output [31:0] instr,
			  output [31:0] pc, 
				//Lh
				output [1:0]  bytes,
				//Jr
				output	jrflag,
				output [31:0] rawd
			  );

  // instantiate devices to be tested
  mips dut(clk, reset, pc, instr,
           memwrite, aluout, writedata, readdata, regwrite, regdst, logicext, alusrc, branch, branchnot, memtoreg, jump, srca, srcb,
					 zero, 
					 //Lh
					 bytes,
					 //Jr
					 jrflag
					 );
  imem imem(pc[7:2], instr);
  dmem dmem(clk, memwrite, aluout, 
            writedata, readdata, 
						//Lh
						bytes,
						rawd);

endmodule
