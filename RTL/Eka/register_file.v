
module register_file
  (
   clk,
   
   read_addr1,
   read_data1,
   
   read_addr2,
   read_data2,

   write_en,
   write_addr,
   write_data,
   );

   input wire 	     clk;

   input wire [4:0]  read_addr1;
   output reg [31:0] read_data1;
   
   input wire [4:0]  read_addr2;
   output reg [31:0] read_data2;

   input wire 	     write_en;
   input wire [4:0]  write_addr;
   input wire [31:0] write_data;
   
   // Register file
   reg [31:0] 	     mem [31:0];

   always @(*)
     begin
	read_data1 = mem[read_addr1];
	read_data2 = mem[read_addr2];
     end
   
   always @(posedge clk)
     begin : register_file_block
	if (write_en)
	  begin
	     mem[write_addr] <= write_data;
	  end

	// Force register 0 to always have 0
	mem[0] <= 0;
     end
endmodule
