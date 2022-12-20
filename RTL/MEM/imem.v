/*
 * Instruction memory. This instruction memory has asynchronous reads.
 * Writes are synchronous and are expected to happen before starting the
 * processor.
 */

module imem
  #(
    parameter SIZE_IN_WORDS=1024
   )
  (
   ip_inst_addr,
   op_inst_valid,
   op_inst_from_imem,
   );

   input wire [31:0]  ip_inst_addr;
   output reg [31:0]  op_inst_from_imem;
   output reg 	      op_inst_valid;

   // Instruction memory
   reg [31:0] 	     mem [SIZE_IN_WORDS-1:0];

   always @(*)
     begin : imem_block
	op_inst_valid     = 1'b1;
	op_inst_from_imem = mem[ip_inst_addr[$clog2(SIZE_IN_WORDS)-1+2:2]];
     end

endmodule
