
module decoder
  (
   ip_inst,

   write_en,
   immediate,
   alu_opcode,
   alu_src2_from_imm,
   lui_inst
   );

   input wire [31:0] ip_inst;

   output reg 	     write_en;
   output reg [31:0] immediate;
   output reg [3:0]  alu_opcode;
   output reg 	     alu_src2_from_imm;
   output reg 	     lui_inst;

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
	opcode                   = ip_inst[6:0];

	immediate_I              = {{20{ip_inst[31]}}, ip_inst[31:20]};
	immediate_S              = {{20{ip_inst[31]}}, ip_inst[31:25], ip_inst[11:7]};
	immediate_B              = {{20{ip_inst[31]}}, ip_inst[7], ip_inst[30:25], ip_inst[11:8], 1'b0};
	immediate_U              = {ip_inst[31:12], 12'h0};
	immediate_J              = {{12{ip_inst[31]}}, ip_inst[19:12], ip_inst[20], ip_inst[30:21], 1'b0};

	// Values that will be changed based on opcode
	write_en                 = 1'b0;
	immediate                = 32'hx;
	alu_opcode               = 4'hx;
	alu_src2_from_imm        = 1'b0;

	lui_inst                 = 1'b0;

	case (opcode)
	  7'b0110111: // U-LUI
	    begin
	       write_en          = 1'b1;
	       immediate         = immediate_U;
	       alu_opcode        = 4'h0;
	       alu_src2_from_imm = 1'b1;
	       lui_inst          = 1'b1;
	    end
	endcase
     end

endmodule
