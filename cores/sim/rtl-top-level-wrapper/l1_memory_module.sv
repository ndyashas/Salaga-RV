`include "config/config.svh";

module l1_memory_module
  #(
    LOGICAL_ADD_WIDTH=`CACHE_ADDRESS_SIZE
    )
  (
   /* Inputs */
   clk,
   read_en,
   read_addr,
   write_en,
   write_addr,
   write_mask,
   write_data,

   /* Outputs */
   read_data,
   stall
   );

   
   input wire	      clk;
   input wire	      read_en;  // Currently not important
   input wire [31:0]  read_addr;
   input wire	      write_en;
   input wire [31:0]  write_addr;
   input wire [3:0]   write_mask;
   input wire [31:0]  write_data;
   
   output reg [31:0] read_data;
   output reg	      stall;


   reg [7:0]	     l1_memory_bank_0 [0:2**(LOGICAL_ADD_WIDTH-2)-1]; // LSB
   reg [7:0]	     l1_memory_bank_1 [0:2**(LOGICAL_ADD_WIDTH-2)-1];
   reg [7:0]	     l1_memory_bank_2 [0:2**(LOGICAL_ADD_WIDTH-2)-1];
   reg [7:0]	     l1_memory_bank_3 [0:2**(LOGICAL_ADD_WIDTH-2)-1]; // MSB


   always @(posedge clk)
     begin
	if (write_en)
	  begin
	     if (write_mask[0] == 1'b1)
	       begin
		  l1_memory_bank_0[write_addr[LOGICAL_ADD_WIDTH-1:2]] <= write_data[7:0];
	       end
	     if (write_mask[1] == 1'b1)
	       begin
		  l1_memory_bank_1[write_addr[LOGICAL_ADD_WIDTH-1:2]] <= write_data[15:8];
	       end
	     if (write_mask[2] == 1'b1)
	       begin
		  l1_memory_bank_2[write_addr[LOGICAL_ADD_WIDTH-1:2]] <= write_data[23:16];
	       end
	     if (write_mask[3] == 1'b1)
	       begin
		  l1_memory_bank_3[write_addr[LOGICAL_ADD_WIDTH-1:2]] <= write_data[31:24];
	       end
	  end
     end

   always @(*)
     begin
	stall            = 1'b0;
	read_data[7:0]   = l1_memory_bank_0[read_addr[LOGICAL_ADD_WIDTH-1:2]];
	read_data[15:8]  = l1_memory_bank_1[read_addr[LOGICAL_ADD_WIDTH-1:2]];
	read_data[23:16] = l1_memory_bank_2[read_addr[LOGICAL_ADD_WIDTH-1:2]];
	read_data[31:24] = l1_memory_bank_3[read_addr[LOGICAL_ADD_WIDTH-1:2]];
     end

endmodule
