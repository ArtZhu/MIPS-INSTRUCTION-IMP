//------------------------------------------------
// mipssingle.v
// David_Harris@hmc.edu 23 October 2005
// Single-cycle MIPS processor
//------------------------------------------------

// single-cycle MIPS processor
module mips(input         clk, reset,
            output [31:0] pc,
            input  [31:0] instr,
            output        memwrite,
            output [31:0] aluout, writedata,
            input  [31:0] readdata,
						output regwrite, regdst, logicext, alusrc, branch, branchnot, memtoreg, jump,
						output [31:0] srca, srcb,
						output zero,
						//Lh
						output [1:0] bytes, 
						//Jr
						output jrflag
						);

  wire [3:0]  alucontrol;

  controller c(instr[31:26], instr[5:0],
               memtoreg, memwrite, branch, branchnot,
               alusrc, regdst, regwrite, logicext, jump,
               alucontrol,
					//Lui
					luiflag,
					//Jal
					jalflag,
					//Blez
					blezflag, 
					//Lh
					bytes,
					//Jr
					jrflag);
  datapath dp(clk, reset, memtoreg, branch, branchnot,
              alusrc, regdst, regwrite, logicext, jump,
              alucontrol,
              pc, instr,
              aluout, writedata, 
				  srca, srcb,
				  readdata,
				  //Lui
				  luiflag, zero, 
				  //Jal
				  jalflag,
				  //Blez
				  blezflag,
				  //Jr
				  jrflag);
endmodule

/*	controller */
module controller	(	input  [5:0] op, funct,
                  	output       memtoreg, memwrite,
                  	output       branch, branchnot, alusrc,
                  	output       regdst, regwrite,
				   		output			 logicext,
                  	output       jump,
                  	output [3:0] alucontrol,
							//Lui
							output			 luiflag,
							//Jal
							output			 jalflag,
							//Blez
							output			 blezflag,
							//Lh
							output [1:0] bytes,
							//Jr
							output			 jrflag
							);

	wire [2:0] aluop;																	

  maindec md(op, memtoreg, memwrite, branch, branchnot,
             alusrc, regdst, regwrite, logicext, jump,
             aluop, 
				 //Lui
				 luiflag, 
				 //Jal
				 jalflag,
				 //Blez
				 blezflag,
				 //Lh
				 bytes
				 );
  aludec  ad(funct, aluop, alucontrol, 
				 //Jr
				 jrflag);
endmodule

/*	maindec	*/
module maindec	(	input  [5:0]	op,
               	output     	  memtoreg, memwrite,
               	output     	  branch, branchnot, alusrc,
               	output     	  regdst, regwrite,
			   		output				logicext,
               	output       	jump,
			   		output [2:0]	aluop,
						//Lui, Jal
						output				luiflag, jalflag,
						//Blez
						output				blezflag,
						//Lh
						output [1:0]	bytes
						);										

	//All instructions
	reg [16:0] controls;																

  assign {regwrite, regdst, alusrc,
          branch, branchnot, memwrite,
          memtoreg, logicext, jump, aluop, 
			 //Lui, Jal
			 luiflag, jalflag,
			 //Blez
			 blezflag,
			 //Lh
			 bytes
			 } = controls;

	/***
	 *	    Rtype = 3'b100;
	 *	    add	  = 3'b000;
	 		 sub   = 3'b001;
	  	    or    = 3'b011;
	  		 blez  = 3'b101;
										*
										*
	 	   						 ***/
  always @( * )
    case(op)
      6'b000000: controls <= 17'b11000000010000000; //Rtyp
      6'b100011: controls <= 17'b10100010000000000; //LW
      6'b101011: controls <= 17'b00100100000000000; //SW
      6'b000100: controls <= 17'b00010000000100000; //BEQ
      6'b001000: controls <= 17'b10100000000000000; //ADDI
      6'b000010: controls <= 17'b00000000100000000; //J
	   6'b001101: controls <= 17'b10100001001100000; //ORI	
	   6'b000101: controls <= 17'b00011000000100000; //BNE

		6'b001111: controls <= 17'b10100000000010000; //Lui
		6'b000011: controls <= 17'b10000000100001000; //Jal
		6'b000110: controls <= 17'b00010000010100100; //Blez
		6'b001010: controls <= 17'b10100000010100000; //Slti
		6'b100001: controls <= 17'b10100010000000010; //Lh

      default:   controls <= 17'bxxxxxxxxxxxxxxxxx; //???
    endcase
endmodule

/*	aludec	*/
module aludec	(	input      [5:0] funct,
						input			 [2:0] aluop,								
						output reg [3:0] alucontrol,
						//Jr
						output			jrflag);

	/***
	 *	and		0000
	 *	or			0001
	  	add		0010
					0011
	 	sll		0100
		srl		0101

	 	and(~)	1000
		or(~) 	1001
	 	sub 		1010
	 	slt		1011
							     *
								  *
	 							***/
	//Jr
	assign jrflag = (funct == 8);

  always @( * )
    case(aluop)
      3'b000: alucontrol <= 4'b0010;  // add
      3'b001: alucontrol <= 4'b1010;  // sub
	   3'b011: alucontrol <= 4'b0001;  // or					
		3'b101: alucontrol <= 4'b1011;	// slt(blez | slti)
      default: case(funct)          // RTYPE
          6'b100000: alucontrol <= 4'b0010; // ADD
          6'b100010: alucontrol <= 4'b1010; // SUB
          6'b100100: alucontrol <= 4'b0000; // AND
          6'b100101: alucontrol <= 4'b0001; // OR
          6'b101010: alucontrol <= 4'b1011; // SLT
			 6'b000000: alucontrol <= 4'b0100; // SLL
			 //Jr
			 6'b001000: alucontrol <= 4'b0010; // Jr
			 //Srl
			 6'b000010: alucontrol <= 4'b0101; // SRL
          default:   alucontrol <= 4'bxxxx; // ???
        endcase
    endcase
endmodule

/*	datapath	*/
module datapath(input    	    clk, reset,
                input    	    memtoreg, branch, branchnot,
                input    	    alusrc, regdst,
                input    	    regwrite, 
					 input				  logicext,									
					 input					jump,
                input  [3:0]  alucontrol,
                output [31:0] pc,
                input  [31:0] instr,
                output [31:0] aluout, writedata,
					 output [31:0] srca, srcb,
                input  [31:0] readdata,
					 //Lui
					 input					luiflag,
					 output					zero,
					 //Jal
					 input					jalflag,
					 //Blez
					 input					blezflag,
					 //Jr
					 input					jrflag
					 );

  wire [4:0]  writereg; 	
  wire		  branchflag2;	//(blez(alu slt) and normal branch)
  wire        branchflag, pcsrc;
  wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
  wire [31:0] pcjump;
  wire [31:0] immext;																			
  wire [31:0] sext, zext;
  //Lui
  wire [31:0] extout, luiout;
  wire [31:0] sextsh;													 
  wire [31:0] result;
  
  //Jal
  wire [4:0]	a3;
  wire [31:0] wd3;
  
  //Blez
  wire	equal;
  //Jr
  wire	[31:0] pcn;
	
  // next PC logic
	/* select bne or beq */
  //Blez
  assign equal = (srca == srcb);
  assign branchflag2 = blezflag? (aluout[0] | equal):branchflag;	
  assign branchflag = branchnot? ~zero:zero;		
  assign pcjump = {pcplus4[31:28], instr[25:0], 2'b00};					
  //Jr
  mux2 #(32) jumpmux(pcnext, aluout,
							jrflag, pcn);

  assign pcsrc = branch & branchflag2;	

  //Jr
  flopr #(32) pcreg(clk, reset, pcn, pc);
  adder       pcadd1(pc, 32'b100, pcplus4);
  sl2         immsh(sext, sextsh);
  adder       pcadd2(pcplus4, sextsh, pcbranch);
  mux2 #(32)  pcbrmux(pcplus4, pcbranch, pcsrc,
                    pcnextbr);
  mux2 #(32)  pcmux(pcnextbr, pcjump, jump,
                    pcnext);
  //Blez
  mux2 #(5)		a3mux(writereg, 5'b11111,
							jalflag, a3);
  mux2 #(32)	pcnmux(result, pcplus4,
							jalflag, wd3);

  // register file logic
  regfile     rf(clk, regwrite, instr[25:21],
                 		instr[20:16], a3,
                 		wd3, srca, writedata);
  mux2 #(5)   wrmux(instr[20:16], instr[15:11],
                    regdst, writereg);
  mux2 #(32)  resmux(aluout, readdata,
                    memtoreg, result);
	/* extension select */
  signext     se(instr[15:0], sext);											
  zeroext			ze(instr[15:0], zext);											
  mux2 #(32)	extmux(sext, zext,														
					 					logicext, extout);
  //Lui
  luiext			lui(instr[15:0], luiout);
  mux2 #(32)  luimux(extout, luiout,
							luiflag, immext);

  // ALU logic
  mux2 #(32)  srcbmux(writedata, immext, 		//srcb in graph in writedata here
				 			alusrc, srcb);
  alu32       alu(srca, srcb, alucontrol,
							instr[10:6],
                  	aluout, zero);
endmodule
