/*
 * The Salaga SoC.
 */

module SoC
  #(
    parameter RESET_PC_VALUE=32'h00000000,
    parameter IMEM_SIZE_IN_WORDS=32,
    parameter DMEM_SIZE_IN_WORDS=32
    )
  (
   clk,
   reset,

   tx,
   rx
   );

   input wire  clk;
   input wire  reset;

   output wire tx;
   input wire  rx;

   wire [31:0] inst_addr;
   wire        inst_valid;
   wire [31:0] inst_from_imem;

   wire [31:0] data_addr;
   wire        data_wr;
   wire [3:0]  data_mask;
   wire [31:0] data_from_proc;
   wire        data_rd;
   wire        data_valid;
   wire [31:0] data_from_dmem;

   // End of simulation is detected by a call to ebreak
   reg [31:0] 	inst_from_imem_to_proc;
   reg 		uart_access;
   reg 		uart_wr;
   reg 		uart_rd;
   reg [7:0] 	uart_tx_data;
   wire [7:0] 	uart_rx_data;
   wire 	uart_busy;
   wire 	uart_valid;
   reg [31:0] 	uart_data_to_proc;

   reg [31:0] 	data_to_proc;
   reg 		data_wr_to_dmem;

   always @(*)
     begin
	// Stop sending new instructions if 'ebreak' is encountered
	if (inst_from_imem_to_proc == 32'h0010_0073) inst_from_imem_to_proc = 32'h0010_0073;
	else                                         inst_from_imem_to_proc = inst_from_imem;
     end

   // UART IO
   always @(*)
     begin
	uart_access                 = data_addr[31];
	uart_wr                     = uart_access & data_wr;
	uart_rd                     = uart_access & data_rd;
	uart_tx_data                = data_from_proc[7:0];
	uart_data_to_proc           = {20'hx, 2'b0, uart_valid, uart_busy, uart_rx_data};

	data_to_proc                = (uart_access == 1'b1) ? uart_data_to_proc : data_from_dmem;
	data_wr_to_dmem             = (uart_access == 1'b1) ? 1'b0 : data_wr;
     end

// `ifdef _SIM_
//    always @(posedge clk)
//      begin
// 	if (wr)
// 	  begin
// 	     $write("%c", tx_data);
// 	     $fflush(32'h8000_0001);
// 	  end
//      end
// `endif


   // Instantiations of the IO
   buart buart_0
     (
      .clk(clk),
      .resetq(~reset),
      .tx(tx),
      .rx(rx),
      .wr(uart_wr),
      .rd(uart_rd),
      .tx_data(uart_tx_data),
      .rx_data(uart_rx_data),
      .busy(uart_busy),
      .valid(uart_valid)
      );

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
      .ip_data_from_dmem(data_to_proc)
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

      .ip_data_wr(data_wr_to_dmem),
      .ip_data_mask(data_mask),
      .ip_data_from_proc(data_from_proc),

      .ip_data_rd(data_rd),
      .op_data_valid(data_valid),
      .op_data_from_dmem(data_from_dmem)
      );

endmodule
