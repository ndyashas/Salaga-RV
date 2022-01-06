/* v1 decoder is a combinational logic.
 * Decoder is responsible for generating all the control
 * signals for the CPU.
 * 
 */

module decoder
  (
   /* Inputs */
   instruction,

   /* Outputs */
   immediate,
   branch_stmt,
   mem_rd,
   mem_wr,
   mem_to_reg,
   ALU_Ctrl,
   ALU_Src,
   Reg_Wr
   );  

   input wire [31:0] instruction;

   output reg [31:0] immediate;
   output reg	     branch_stmt;
   output reg	     mem_rd;
   output reg	     mem_wr;
   output reg	     mem_to_reg;
   output reg [3:0]  ALU_Ctrl;
   output reg	     ALU_Src;
   output reg	     Reg_Wr;

   localparam	     R_TYPE  = 7'b0110011;
   localparam	     I_TYPE  = 7'b0010011;
   localparam	     I_JALR  = 7'b1100111;
   localparam	     I_LOAD  = 7'b0000011;
   localparam	     S_TYPE  = 7'b0100011;
   localparam	     B_TYPE  = 7'b1100011;
   localparam	     U_AUIPC = 7'b0010111;
   localparam	     U_LUI   = 7'b0110111;
   localparam	     J_JAL   = 7'b1101111;

   wire [6:0]	     opcode;
   wire [2:0]	     funct3;
   reg [1:0]	     ALU_Op;

   assign opcode     = instruction[6:0];
   assign funct3     = instruction[14:12];

   always @(*)
     begin
	case (opcode)
	  R_TYPE:
	    begin
	       branch_stmt = 1'b0;
	       mem_rd      = 1'b0;
	       mem_wr      = 1'b0;
	       mem_to_reg  = 1'b0;
	       ALU_Op      = 2'b10;
	       ALU_Src     = 1'b0;
	       Reg_Wr      = 1'b1;
	       immediate   = 32'b0;
	    end // case: R_TYPE
	  I_TYPE:
	    begin
	       branch_stmt = 1'b0;
	       mem_rd      = 1'b0;
	       mem_wr      = 1'b0;
	       mem_to_reg  = 1'b0;
	       ALU_Op      = 2'b10;
	       ALU_Src     = 1'b1;
	       Reg_Wr      = 1'b1;
	       immediate   = {{20{instruction[31]}}, instruction[31:20]};
	    end // case: I_TYPE
	  I_LOAD:
	    begin
	       branch_stmt = 1'b0;
	       mem_rd      = 1'b1;
	       mem_wr      = 1'b0;
	       mem_to_reg  = 1'b1;
	       ALU_Op      = 2'b00;
	       ALU_Src     = 1'b1;
	       Reg_Wr      = 1'b1;
	       immediate   = {{20{instruction[31]}}, instruction[31:20]};
	    end // case: I_LOAD
	  S_TYPE:
	    begin
	       branch_stmt = 1'b0;
	       mem_rd      = 1'b0;
	       mem_wr      = 1'b1;
	       mem_to_reg  = 1'bx;
	       ALU_Op      = 2'b00;
	       ALU_Src     = 1'b1;
	       Reg_Wr      = 1'b0;
	       immediate   = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
	    end // case: S_TYPE
	  B_TYPE:
	    begin
	       branch_stmt = 1'b1;
	       mem_rd      = 1'b0;
	       mem_wr      = 1'b0;
	       mem_to_reg  = 1'bx;
	       ALU_Op      = 2'b01;
	       ALU_Src     = 1'b0;
	       Reg_Wr      = 1'b0;
	       // Immediate is a 32-bit quantity specifying the number of
	       // bytes to add to the PC. immediate will always be aligned
	       // to 16bit words. This is in the ISA to support 'C' instr set
	       // this is not supported in our core.
	       immediate   = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
	    end // case: B_TYPE

	  default:
	    begin
	       branch_stmt = 1'b0;
	       mem_rd      = 1'b0;
	       mem_wr      = 1'b0;
	       mem_to_reg  = 1'bx;
	       ALU_Op      = 2'bx;
	       ALU_Src     = 1'bx;
	       Reg_Wr      = 1'b0;
	       immediate   = 32'bx;
	    end // case: default
	endcase // case (opcode)

	case(ALU_Op)
	  2'b00: // ADD
	    begin
	       ALU_Ctrl = 4'b0000;
	    end
	  2'b01: // SUB
	    begin
	       ALU_Ctrl = 4'b1000;
	    end
	  2'b10:
	    begin
	       if (opcode == R_TYPE)
		 begin
		    ALU_Ctrl = {instruction[30], funct3};
		 end
	       else
		 begin
		    if (funct3 == 3'b101)
		      begin
			 ALU_Ctrl = {instruction[30], funct3}; //SRAI, SRLI
		      end
		    else
		      begin
			 ALU_Ctrl = {1'b0, funct3}; // ADDI, SLLI, SLTI
		      end
		 end
	    end // case: 2'b10
	  2'b11:
	    begin
	       ALU_Ctrl = 4'b0000;
	    end
	endcase
     end

endmodule
