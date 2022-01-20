/* 
 * This module brings the core, and the two L1 caches together. 
 */

module eka_chip
  (
   clk,
   reset
   );

   input wire  clk;
   input wire  reset;

   wire [31:0] instruction;
   wire [31:0] mem_rd_data;
   wire	       inst_stall;
   wire	       data_stall;
   wire [31:0] inst_addr;
   wire [31:0] mem_wr_data;
   wire [3:0]  mem_wr_mask;
   wire	       mem_wr;
   wire	       mem_rd;
   wire [31:0] data_addr;   


   eka_core_v1 eka_core_v1
     (.clk(clk),
      .reset(reset),
      .instruction(instruction),
      .mem_rd_data(mem_rd_data),
      .inst_valid(~inst_stall),
      .data_stall(data_stall),
      .inst_addr(inst_addr),
      .data_addr(data_addr),
      .mem_wr_data(mem_wr_data),
      .mem_wr_mask(mem_wr_mask),
      .mem_wr(mem_wr),
      .mem_rd(mem_rd)
      );

   l1_memory_module l1_inst_cache
     (.clk(clk),
      .read_en(1'b1),
      .read_addr(inst_addr),
      .write_en(1'b0),
      .write_addr(32'bx),
      .write_mask(4'bx),
      .write_data(32'bx),
      .read_data(instruction),
      .stall(inst_stall)
      );

   l1_memory_module l1_data_cache
     (.clk(clk),
      .read_en(mem_rd),
      .read_addr(data_addr),
      .write_en(mem_wr),
      .write_addr(data_addr),
      .write_mask(mem_wr_mask),
      .write_data(mem_wr_data),
      .read_data(mem_rd_data),
      .stall(data_stall)
      );

endmodule
