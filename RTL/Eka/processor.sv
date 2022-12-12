/*
 * A simple single cycle RISC-V (rv32i) CPU
 */

module processor
  (
   // General inputs
   clk,
   reset,

   // Instruction IO
   op_inst_addr,
   ip_inst_valid,
   ip_inst_from_imem,

   // Data IO
   op_data_addr,

   op_data_wr,
   op_data_mask,
   op_data_from_proc,

   op_data_rd,
   ip_data_valid,
   ip_data_from_dmem,
   );

   // General inputs
   input wire 	     clk;
   input wire 	     reset;

   // Instruction IO
   output reg [31:0] op_inst_addr;
   input wire 	     ip_inst_valid;
   input wire 	     ip_inst_from_imem;

   // Data IO
   output reg [31:0] op_data_addr;

   output reg 	     op_data_wr;
   output reg [3:0]  op_data_mask;
   output reg [31:0] op_data_from_proc;

   output reg 	     op_data_rd;
   input wire 	     ip_data_valid;
   input wire [31:0 ] ip_data_from_dmem;


endmodule
