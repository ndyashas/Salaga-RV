/*
 * The Salaga SoC.
 */

module SoC
  #(
    parameter RESET_PC_VALUE=32'h00000000,
    parameter UART_IO_MM_LOC=32'h00000054,
    parameter IMEM_SIZE_IN_WORDS=32,
    parameter DMEM_SIZE_IN_WORDS=32
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

   // End of simulation is detected by a call to ebreak
   reg [31:0] 	inst_from_imem_to_proc;
   reg 		data_rd_from_proc_to_dmem;
   reg 		data_wr_from_proc_to_dmem;
   reg [31:0] 	data_from_dmem_to_proc;
   reg 		uart_wr;

   always @(*)
     begin
	// Stop sending new instructions if 'ebreak' is encountered
	if (inst_from_imem_to_proc == 32'h0010_0073) inst_from_imem_to_proc = 32'h0010_0073;
	else                                         inst_from_imem_to_proc = inst_from_imem;

	// MMIO
	data_rd_from_proc_to_dmem   = data_rd;;
	data_wr_from_proc_to_dmem   = data_wr;;
	data_from_dmem_to_proc      = data_from_dmem;
	if (data_addr == UART_IO_MM_LOC)
	  begin
	     // Reading from device
	     if (data_rd)
	       begin
		  // TODO
		  data_from_dmem_to_proc = 32'h1;
	       end
	  end

	uart_wr = data_wr && (data_addr == UART_IO_MM_LOC);
     end

`ifdef _SIM_
   always @(posedge clk)
     begin
	// Writing to device
	if (data_addr == UART_IO_MM_LOC)
	  begin
	     if (data_wr)
	       begin
		  $write("%c", data_from_proc[7:0]);
		  $fflush(32'h8000_0001);
	       end
	  end
     end
`endif

   // Instantiations of processor, imem, and dmem
   // Connect processor to IMEM and DMEM
   processor #(.RESET_PC_VALUE(RESET_PC_VALUE)) processor_0
     (
      .clk(clk),
      .reset(reset),

      .op_inst_addr(inst_addr),
      .ip_inst_valid(inst_valid),
      .ip_inst_from_imem(inst_from_imem_to_proc),

      .op_data_addr(data_addr),

      .op_data_wr(data_wr),
      .op_data_mask(data_mask),
      .op_data_from_proc(data_from_proc),

      .op_data_rd(data_rd),
      .ip_data_valid(data_valid),
      .ip_data_from_dmem(data_from_dmem_to_proc)
      );

   imem #(.SIZE_IN_WORDS(IMEM_SIZE_IN_WORDS)) imem_0
     (
      .ip_inst_addr(inst_addr),
      .op_inst_valid(inst_valid),
      .op_inst_from_imem(inst_from_imem)
      );

   dmem #(.SIZE_IN_WORDS(DMEM_SIZE_IN_WORDS)) dmem_0
     (
      .clk(clk),

      .ip_data_addr(data_addr),

      .ip_data_wr(data_wr_from_proc_to_dmem),
      .ip_data_mask(data_mask),
      .ip_data_from_proc(data_from_proc),

      .ip_data_rd(data_rd_from_proc_to_dmem),
      .op_data_valid(data_valid),
      .op_data_from_dmem(data_from_dmem)
      );

endmodule
