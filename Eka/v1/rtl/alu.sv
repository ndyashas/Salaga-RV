/* ALU */

module alu
  (
   /* Inputs */
   alu_src1,
   alu_src2,
   ALU_Ctrl,

   /* Output */
   zero,
   ALU_result
   );

   // Port wires and regesters
   input wire [31:0]       alu_src1;
   input wire [31:0]	   alu_src2;
   input wire [3:0]	   ALU_Ctrl;

   output reg [31:0]	   ALU_result;
   output reg		   zero;

   always @(*)
     begin
	zero = (alu_src1 - alu_src2 == 32'b0) ? 1'b1 : 1'b0;

	case(ALU_Ctrl)
	  4'b0000:
	    begin
	       ALU_result = alu_src1 + alu_src2;
	    end
	  4'b1000:
	    begin
	       ALU_result = alu_src1 - alu_src2;
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

	  default:
	    begin
	       ALU_result = 32'bx;
	    end
	endcase
     end
endmodule
