/*
 * A simple single cycle RISC-V (rv32i) CPU
 */

module processor
  (
   // General inputs
   clk,
   reset,

   // Instruction IO
   op_inst_addr,
   ip_inst_valid,
   ip_inst_from_imem,

   // Data IO
   op_data_addr,

   op_data_wr,
   op_data_mask,
   op_data_from_proc,

   op_data_rd,
   ip_data_valid,
   ip_data_from_dmem,
   );

   // General inputs
   input wire 	     clk;
   input wire 	     reset;

   // Instruction IO
   output reg [31:0] op_inst_addr;
   input wire 	     ip_inst_valid;
   input wire [31:0] ip_inst_from_imem;

   // Data IO
   output reg [31:0] op_data_addr;

   output wire 	     op_data_wr;
   output reg [3:0]  op_data_mask;
   output reg [31:0] op_data_from_proc;

   output wire 	     op_data_rd;
   input wire 	     ip_data_valid;
   input wire [31:0 ] ip_data_from_dmem;


   // Internal variables
   reg [31:0] 	      PC;
   reg [31:0] 	      next_pc;

   wire [4:0] 	      rf_read_addr1;
   wire [4:0] 	      rf_read_addr2;
   wire 	      rf_write_en;
   wire [4:0]	      rf_write_addr;

   wire [31:0] 	      rf_read_data1;
   wire [31:0] 	      rf_read_data2;
   reg [31:0] 	      rf_write_data;

   wire [31:0] 	      immediate;
   wire [2:0] 	      funct3;
   wire [6:0] 	      FUNCT7;

   reg [31:0] 	      alu_src1;
   reg [31:0] 	      alu_src2;

   wire [3:0] 	      alu_opcode;
   wire 	      i_type_inst;
   wire 	      branch_inst;

   wire 	      minus_is_zero;
   wire 	      less_than;
   wire 	      less_than_unsigned;
   wire [31:0] 	      alu_result;

   reg 		      branch_success;


   always @(posedge clk)
     begin
	if (reset) PC <= 0;
	else       PC <= next_pc;
     end


   always @(*)
     begin
	op_inst_addr      = PC;

	// Calculating next PC
	next_pc           = PC + 32'h4; // Default
	branch_success    = 1'b0;       // Initialize branch_success to false

	if (branch_inst) // Replace with a big if statement?
	  begin
	     case (funct3)
	       3'b000: // BEQ
		 if (minus_is_zero)            next_pc = PC + immediate;
	       3'b001: // BNEQ
		 if (!minus_is_zero)           next_pc = PC + immediate;
	       3'b100: // BLT
		 if (less_than)                next_pc = PC + immediate;
	       3'b101: // BGE
		 if (!less_than)               next_pc = PC + immediate;
	       3'b110: // BLTU
		 if (less_than_unsigned)       next_pc = PC + immediate;
	       3'b111: // BGEU
		 if (!less_than_unsigned)      next_pc = PC + immediate;
	     endcase
	  end

	// Sources for ALU
	alu_src1          = rf_read_data1;
	alu_src2          = (i_type_inst == 1'b1) ? immediate : rf_read_data2;

	// Write back
	rf_write_data     = alu_result;
     end


   // Instantiations of decoder, register file, and ALU
   decoder decoder_0
     (
      .ip_inst(ip_inst_from_imem),

      .write_en(rf_write_en),
      .write_addr(rf_write_addr),
      .read_addr1(rf_read_addr1),
      .read_addr2(rf_read_addr2),
      .immediate(immediate),
      .mem_write_en(op_data_wr),
      .mem_read_en(op_data_rd),
      .funct3(funct3),
      .funct7(FUNCT7),
      .alu_opcode(alu_opcode),
      .i_type_inst(i_type_inst),
      .branch_inst(branch_inst)
   );

   register_file register_file_0
     (
      .clk(clk),

      .read_addr1(rf_read_addr1),
      .read_data1(rf_read_data1),

      .read_addr2(rf_read_addr2),
      .read_data2(rf_read_data2),

      .write_en(rf_write_en),
      .write_addr(rf_write_addr),
      .write_data(rf_write_data)
      );

   alu alu_0
     (
      .alu_src1(alu_src1),
      .alu_src2(alu_src2),
      .alu_opcode(alu_opcode),

      .minus_is_zero(minus_is_zero),
      .less_than(less_than),
      .less_than_unsigned(less_than_unsigned),
      .alu_result(alu_result)
      );

endmodule
