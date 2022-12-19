
module alu
  (
   alu_src1,
   alu_src2,
   alu_opcode,

   minus_is_zero,
   less_than,
   less_than_unsigned,
   alu_result
   );

   input wire [31:0]       alu_src1;
   input wire [31:0]	   alu_src2;
   input wire [3:0]	   alu_opcode;

   output reg [31:0]	   alu_result;
   output reg		   minus_is_zero;
   output reg		   less_than;
   output reg		   less_than_unsigned;

   reg [32:0]		   alu_minus;

   always @(*)
     begin
	// Use a single 33 bits subtract to do subtraction and all
	// comparitions. Borrowed from (BrunoLevy/learn-fpga), (swapforth/J1)
	alu_minus = {1'b1, ~alu_src2} + {1'b0, alu_src1} + 33'b1;
	less_than = (alu_src1[31] ^ alu_src2[31]) ? alu_src1[31] : alu_minus[32];
	less_than_unsigned = alu_minus[32];
	minus_is_zero = (alu_minus[31:0] == 32'b0);

	alu_result = 32'hx;

	case(alu_opcode)
	  4'b0000:
	    begin
	       alu_result = alu_src1 + alu_src2;
	    end
	  4'b0110:
	    begin
	       alu_result = alu_src1 | alu_src2;
	    end
	  4'b0111:
	    begin
	       alu_result = alu_src1 & alu_src2;
	    end
	  4'b0100:
	    begin
	       alu_result = alu_src1 ^ alu_src2;
	    end
	  4'b1000:
	    begin
	       alu_result = alu_minus[31:0];
	    end
	  4'b0010:
	    begin
	       alu_result = {31'b0, less_than};
	    end
	  4'b0011:
	    begin
	       alu_result = {31'b0, less_than_unsigned};
	    end
	  4'b0001:
	    begin
	       alu_result = alu_src1 << alu_src2;
	    end
	  4'b0101:
	    begin
	       alu_result = alu_src1 >> alu_src2;
	    end
	  4'b1101:
	    begin
	       alu_result = alu_src1 >>> alu_src2;
	    end
	endcase
     end
endmodule
