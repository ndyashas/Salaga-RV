/* ALU */

module alu
  (
   /* Inputs */
   alu_src1,
   alu_src2,
   ALU_Ctrl,

   /* Output */
   zero,
   Less_than,
   Less_than_unsigned,
   ALU_result
   );

   // Port wires and regesters
   input wire [31:0]       alu_src1;
   input wire [31:0]	   alu_src2;
   input wire [3:0]	   ALU_Ctrl;

   output reg [31:0]	   ALU_result;
   output reg		   zero;
   output reg		   Less_than;
   output reg		   Less_than_unsigned;

   reg [32:0]		   ALU_minus;

   always @(*)
     begin
	// Use a single 33 bits subtract to do subtraction and all
	// comparitions. Borrowed from (BrunoLevy/learn-fpga), (swapforth/J1)
	ALU_minus = {1'b1, ~alu_src2} + {1'b0, alu_src1} + 33'b1;
	Less_than = (alu_src1[31] ^ alu_src2[31]) ? alu_src1[31] : ALU_minus[32];
	Less_than_unsigned = ALU_minus[32];
	zero = (ALU_minus[31:0] == 32'b0);

	case(ALU_Ctrl)
	  4'b0000:
	    begin
	       ALU_result = alu_src1 + alu_src2;
	    end
	  4'b0110:
	    begin
	       ALU_result = alu_src1 | alu_src2;
	    end
	  4'b0111:
	    begin
	       ALU_result = alu_src1 & alu_src2;
	    end
	  4'b0100:
	    begin
	       ALU_result = alu_src1 ^ alu_src2;
	    end
	  4'b1000:
	    begin
	       ALU_result = ALU_minus[31:0];
	    end
	  4'b0010:
	    begin
	       ALU_result = {31'b0, Less_than};
	    end
	  4'b0011:
	    begin
	       ALU_result = {31'b0, Less_than_unsigned};
	    end
	  4'b0001:
	    begin
	       ALU_result = alu_src1 << alu_src2;
	    end
	  4'b0101:
	    begin
	       ALU_result = alu_src1 >> alu_src2;
	    end
	  4'b1101:
	    begin
	       ALU_result = alu_src1 >>> alu_src2;
	    end
	  default:
	    begin
	       ALU_result = 32'bx;
	    end
	endcase
     end
endmodule
