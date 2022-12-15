
module decoder
  (
   ip_inst,

   write_en,
   write_addr,
   read_addr1,
   read_addr2,
   immediate,
   mem_write_en,
   mem_read_en,
   funct3,
   funct7,

   alu_opcode,
   i_type_inst
   );

   input wire [31:0] ip_inst;

   output reg 	     write_en;
   output reg [4:0]  write_addr;
   output reg [4:0]  read_addr1;
   output reg [4:0]  read_addr2;
   output reg [31:0] immediate;
   output reg 	     mem_write_en;
   output reg 	     mem_read_en;
   output reg [2:0]  funct3;
   output reg [6:0]  funct7;
   output reg [3:0]  alu_opcode;
   output reg 	     i_type_inst;

   reg [6:0] 	      opcode;

   // Immediate values are calculated differently for different
   // instruction variants.
   reg [31:0] 	      immediate_I;
   reg [31:0] 	      immediate_S;
   reg [31:0] 	      immediate_B;
   reg [31:0] 	      immediate_U;
   reg [31:0] 	      immediate_J;


   always @(*)
     begin
	// Fixed values that do not change
	opcode               = ip_inst[6:0];
	funct3               = ip_inst[14:12];
	funct7               = ip_inst[31:25];
	write_addr           = ip_inst[11:7];
	read_addr1           = ip_inst[19:15];
	read_addr2           = ip_inst[24:20];

	immediate_I          = {{20{ip_inst[31]}}, ip_inst[31:20]};
	immediate_S          = {{20{ip_inst[31]}}, ip_inst[31:25], ip_inst[11:7]};
	immediate_B          = {{20{ip_inst[31]}}, ip_inst[7], ip_inst[30:25], ip_inst[11:8], 1'b0};
	immediate_U          = {ip_inst[31:12], 12'h0};
	immediate_J          = {{12{ip_inst[31]}}, ip_inst[19:12], ip_inst[20], ip_inst[30:21], 1'b0};

	// Values that will be changed based on opcode
	write_en             = 1'b0;
	immediate            = 32'hx;
	mem_write_en         = 1'b0;
	mem_read_en          = 1'b0;
	i_type_inst          = 1'b0;

	case (opcode)
	  7'b0010011: // I-Type
	    begin
	       write_en      = 1'b1;
	       alu_opcode    = (funct3 == 3'b101) ? {ip_inst[30], 3'b101} : {1'b0, funct3};
	       i_type_inst   = 1'b1;
	       immediate     = immediate_I;
	    end
	endcase

     end


endmodule
