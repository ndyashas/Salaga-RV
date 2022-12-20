/*
 * The Salaga SoC.
 */

module SoC
  #(
    parameter RESET_PC_VALUE=32'h00000000,
    parameter IMEM_SIZE_IN_BYTES=32,
    parameter DMEM_SIZE_IN_BYTES=32
    )
  (
   input clk,
   input reset
   );


   wire [31:0] inst_addr;
   wire        inst_valid;
   wire [31:0] inst_from_imem;

   wire [31:0] data_addr;
   wire        data_wr;
   wire [3:0]  data_mask;
   wire [31:0] data_from_proc;
   wire        data_rd;
   wire        data_valid;
   wire [31:0 ] data_from_dmem;

   // Instantiations of processor, imem, and dmem
   // Connect processor to IMEM and DMEM
   processor #(.RESET_PC_VALUE(RESET_PC_VALUE)) processor_0
     (
      .clk(clk),
      .reset(reset),

      .op_inst_addr(inst_addr),
      .ip_inst_valid(inst_valid),
      .ip_inst_from_imem(inst_from_imem),

      .op_data_addr(data_addr),

      .op_data_wr(data_wr),
      .op_data_mask(data_mask),
      .op_data_from_proc(data_from_proc),

      .op_data_rd(data_rd),
      .ip_data_valid(data_valid),
      .ip_data_from_dmem(data_from_dmem)
      );

   imem #(.SIZE_IN_BYTES(IMEM_SIZE_IN_BYTES)) imem_0
     (
      .ip_inst_addr(inst_addr),
      .op_inst_valid(inst_valid),
      .op_inst_from_imem(inst_from_imem)
      );

   dmem #(.SIZE_IN_BYTES(DMEM_SIZE_IN_BYTES)) dmem_0
     (
      .clk(clk),

      .ip_data_addr(data_addr),

      .ip_data_wr(data_wr),
      .ip_data_mask(data_mask),
      .ip_data_from_proc(data_from_proc),

      .ip_data_rd(data_rd),
      .op_data_valid(data_valid),
      .op_data_from_dmem(data_from_dmem)
      );

endmodule