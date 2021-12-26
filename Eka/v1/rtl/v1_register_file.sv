/* Register file of depth 32 registers */

module register_file
  (
   /* Inputs */
   clk,
   read_addr1,
   read_addr2,
   write_en,
   write_addr,
   write_data,
   
   /* Outputs */
   read_data1,
   read_data2
   );

   // IO
   input wire 	      clk;
   input wire [31:0]  write_data;
   input wire [4:0]   read_addr1;
   input wire [4:0]   read_addr2;
   input wire [4:0]   write_addr;
   input wire 	      write_en;

   output reg [31:0] read_data1;
   output reg [31:0] read_data2;

   // Local wires
   reg [31:0] 	      reg_file [0:31];

   always @(posedge clk)
     begin
	if (write_en)
	  begin
	     reg_file[write_addr] <= write_data;
	     reg_file[0] <= 32'h0; // To overwrite any writes to the 0th location
	  end
	read_data1 <= reg_file[read_addr1];
	read_data2 <= reg_file[read_addr2];
     end

endmodule
