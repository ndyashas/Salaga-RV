/*
 * Data memory. This data memory has asynchronous reads.
 * Writes are synchronous.
 */

module dmem
  #(
    parameter SIZE_IN_BYTES=1024
   )
  (
   clk,

   ip_data_addr,

   ip_data_wr,
   ip_data_mask,
   ip_data_from_proc,

   ip_data_rd,
   op_data_valid,
   op_data_from_dmem
   );

   input wire 	     clk;

   input wire [31:0] ip_data_addr;

   input wire 	     ip_data_wr;
   input wire [3:0]  ip_data_mask;
   input wire [31:0] ip_data_from_proc;

   input wire 	     ip_data_rd;
   output reg 	     op_data_valid;
   output reg [31:0] op_data_from_dmem;

   reg [31:0] 	     mask;

   // Data memory
   reg [31:0] 	     mem [SIZE_IN_BYTES-1:0];

   always @(*)
     begin : dmem_read_block
	// Ignore ip_data_rd for now. Treat all cycles as read cycles.
	op_data_valid     = 1'b1;
	op_data_from_dmem = mem[ip_data_addr[$clog2(SIZE_IN_BYTES)-1:0]];
     end

   always @(posedge clk)
     begin : dmem_write_block
	if (ip_data_wr)
	  begin
	     if (ip_data_mask[0])
	       mem[ip_data_addr[$clog2(SIZE_IN_BYTES)-1+2:2]][7:0]   <= ip_data_from_proc[7:0];
	     if (ip_data_mask[1])
	       mem[ip_data_addr[$clog2(SIZE_IN_BYTES)-1+2:2]][15:8]  <= ip_data_from_proc[15:8];
	     if (ip_data_mask[2])
	       mem[ip_data_addr[$clog2(SIZE_IN_BYTES)-1+2:2]][23:16] <= ip_data_from_proc[23:16];
	     if (ip_data_mask[3])
	       mem[ip_data_addr[$clog2(SIZE_IN_BYTES)-1+2:2]][31:24] <= ip_data_from_proc[31:24];
	  end
     end

endmodule
