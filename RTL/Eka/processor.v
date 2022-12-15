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
   wire 	      alu_src2_from_imm;
   wire 	      branch_inst;
   wire 	      alu_src1_from_pc;
   wire 	      jump_inst;

   wire 	      minus_is_zero;
   wire 	      less_than;
   wire 	      less_than_unsigned;
   wire [31:0] 	      alu_result;

   reg 		      branch_success;
   reg [31:0] 	      masked_data_from_dmem;


   always @(posedge clk)
     begin
	if (reset) PC <= 0;
	else       PC <= next_pc;
     end


   always @(*)
     begin
	op_inst_addr      = PC;

	// Calculating next PC
	next_pc           = (jump_inst == 1'b1) ? alu_result : PC + 32'h4;
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
	alu_src1          = (alu_src1_from_pc == 1'b1) ? PC : rf_read_data1;
	alu_src2          = (alu_src2_from_imm == 1'b1) ? immediate : rf_read_data2;

	// Memory operations
	op_data_addr = alu_result;

	op_data_mask = 4'b1111; // Default word access
	case (funct3[1:0])
	  2'b00: // Byte access
	    begin
	       case (op_data_addr[1:0])
		 2'b00: op_data_mask = 4'b0001;
		 2'b01: op_data_mask = 4'b0010;
		 2'b10: op_data_mask = 4'b0100;
		 2'b11: op_data_mask = 4'b1000;
	       endcase
	    end
	  2'b01: // Half word access
	    begin
	       case (op_data_addr[1])
		 1'b0: op_data_mask = 4'b0011;
		 1'b1: op_data_mask = 4'b1100;
	       endcase
	    end
	endcase

	// Data for stores
	// This neat code is taken from Bruno Levy's project here: https://github.com/BrunoLevy/learn-fpga
	// We need to align the byte/half-byte at the right place along with sending the write mask to the
	// DMEM.
	op_data_from_proc[7:0]   = rf_read_data2[7:0];
	op_data_from_proc[15:8]  = (op_data_addr[0] == 1'b1) ? rf_read_data2[7:0]  : rf_read_data2[15:8];
	op_data_from_proc[23:16] = (op_data_addr[1] == 1'b1) ? rf_read_data2[7:0]  : rf_read_data2[23:16];
	op_data_from_proc[31:24] = (op_data_addr[0] == 1'b1) ? rf_read_data2[7:0]  :
				   (op_data_addr[1] == 1'b1) ? rf_read_data2[15:8] : rf_read_data2[31:24];

	// Data from loads
	masked_data_from_dmem    = ip_data_from_dmem;
	case (funct3[1:0])
	  2'b00: // Byte access
	    begin
	       case (op_data_addr[1:0])
		 2'b00: masked_data_from_dmem = {{24{~funct3[2] &  ip_data_from_dmem[7]}}, ip_data_from_dmem[7:0]};
		 2'b01: masked_data_from_dmem = {{24{~funct3[2] & ip_data_from_dmem[15]}}, ip_data_from_dmem[15:8]};
		 2'b10: masked_data_from_dmem = {{24{~funct3[2] & ip_data_from_dmem[23]}}, ip_data_from_dmem[23:16]};
		 2'b11: masked_data_from_dmem = {{24{~funct3[2] & ip_data_from_dmem[31]}}, ip_data_from_dmem[31:24]};
	       endcase
	    end
	  2'b01: // Half word access
	    begin
	       case (op_data_addr[1])
		 1'b0: masked_data_from_dmem = {{16{~funct3[2] & ip_data_from_dmem[15]}}, ip_data_from_dmem[15:0]};
		 1'b1: masked_data_from_dmem = {{16{~funct3[2] & ip_data_from_dmem[31]}}, ip_data_from_dmem[31:16]};
	       endcase
	    end
	endcase

	// Write back
	if (jump_inst) rf_write_data    = PC + 32'h4;
	else           rf_write_data    = (op_data_rd == 1'b1) ? masked_data_from_dmem : alu_result;
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
      .alu_src2_from_imm(alu_src2_from_imm),
      .branch_inst(branch_inst),
      .alu_src1_from_pc(alu_src1_from_pc),
      .jump_inst(jump_inst)
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
