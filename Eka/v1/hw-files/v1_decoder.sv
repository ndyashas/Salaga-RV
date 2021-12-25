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
   branch_stmt,
   mem_rd,
   mem_wr,
   mem_to_reg,
   ALU_Op,
   ALU_Src,
   Reg_Wr
   );  

   input wire [31:0] instruction;

   output wire 	     branch_stmt;
   output wire 	     mem_rd;
   output wire 	     mem_wr;
   output wire 	     mem_to_reg;
   output wire [1:0] ALU_Op;
   output wire 	     ALU_Src;
   output wire 	     Reg_Wr;

   
   
endmodule
