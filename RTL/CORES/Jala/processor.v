/*
 * A 5-staged pipelined RISC-V (rv32i) CPU
 */

module processor
  #(
    parameter RESET_PC_VALUE=32'h00000000
    )
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
   ip_data_from_dmem
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

   output reg 	     op_data_wr;
   output reg [3:0]  op_data_mask;
   output reg [31:0] op_data_from_proc;

   output reg 	     op_data_rd;
   input wire 	     ip_data_valid;
   input wire [31:0] ip_data_from_dmem;

   // WB stage signals are used for forwarding. Thus, declared
   // at the top.
   reg 		     mem_wb_write_en;
   reg [4:0] 	     mem_wb_write_addr;
   reg [31:0] 	     mem_wb_write_data;

   reg 		     mem_wb_jump_inst;

   // Misc signals from other stages that affect previous stages.
   reg 		     ex_mem_jump_inst;
   reg [31:0] 	     mem_wb_PC;
   reg 		     id_stall;

   // Mem stage signals are used for branch, jump signals. Thus,
   // declared at the top.
   reg [31:0] 	     jump_next_pc;
   reg 		     ex_mem_branch_successful;


   //--------------------------- IF Stage ---------------------------
   reg [31:0] 	     PC;
   reg [31:0] 	     next_pc;

   reg [31:0] 	     if_id_ip_inst_from_imem;

   reg [31:0] 	     if_id_PC;
   reg 		     flush_if;
   reg 		     if_id_flush_if;

   always @(*)
     begin
	op_inst_addr      = PC;
	next_pc           = (ex_mem_branch_successful | ex_mem_jump_inst) ? jump_next_pc : PC + 32'h4;
     end

   always @(posedge clk)
     begin
	if (reset)             PC     <= RESET_PC_VALUE;
	else if (!id_stall)    PC     <= next_pc;
     end

   // IF-ID stage register
   always @(posedge clk)
     begin
	if (!id_stall)
	  begin
	     if_id_ip_inst_from_imem       <= ip_inst_from_imem;
	     if_id_PC                      <= PC;
	  end

	if (reset)           if_id_flush_if <= 1'b1;
	else if (!id_stall)  if_id_flush_if <= flush_if;
     end

   //--------------------------- ID Stage  ---------------------------
   wire        id_write_en;
   wire [31:0] id_immediate;
   wire [3:0]  id_alu_opcode;
   wire        id_alu_src1_from_pc;
   wire        id_alu_src2_from_imm;
   wire        id_mem_write_en;
   wire        id_mem_read_en;
   wire [2:0]  id_funct3;
   wire        id_lui_inst;
   wire        id_store_inst;
   wire        id_branch_inst;
   wire        id_jump_inst;

   reg [4:0]   id_read_addr1;
   reg [4:0]   id_read_addr2;
   reg [4:0]   id_write_addr;

   wire [31:0] id_read_data1;
   wire [31:0] id_read_data2;

   reg 	       id_rs1_matches_s1;
   reg 	       id_rs2_matches_s1;
   reg 	       id_rs1_matches_s2;
   reg 	       id_rs2_matches_s2;
   reg 	       id_rs2_matches_s1_st;
   reg 	       id_rs2_matches_s2_st;

   reg [4:0]   id_ex_write_addr;
   reg 	       id_ex_write_en;
   reg [31:0]  id_ex_immediate;
   reg [3:0]   id_ex_alu_opcode;
   reg 	       id_ex_alu_src1_from_pc;
   reg 	       id_ex_alu_src2_from_imm;
   reg [31:0]  id_ex_read_data1;
   reg [31:0]  id_ex_read_data2;

   reg 	       id_ex_mem_write_en;
   reg 	       id_ex_mem_read_en;

   reg [2:0]   id_ex_funct3;
   reg 	       id_ex_rs1_matches_s1;
   reg 	       id_ex_rs2_matches_s1;
   reg 	       id_ex_rs1_matches_s2;
   reg 	       id_ex_rs2_matches_s2;
   reg 	       id_ex_rs2_matches_s1_st;
   reg 	       id_ex_rs2_matches_s2_st;
   reg [31:0]  id_ex_PC;

   reg 	       id_ex_branch_inst;
   reg 	       id_ex_jump_inst;

   reg 	       flush_id;
   reg 	       flush_ex;

   reg [31:0]  id_inst_from_imem;

   always @(*)
     begin
	flush_if                 = ex_mem_branch_successful | ex_mem_jump_inst;
	flush_id                 = ex_mem_branch_successful | ex_mem_jump_inst;
	flush_ex                 = ex_mem_branch_successful | ex_mem_jump_inst;

	id_inst_from_imem[0]     = (reset | if_id_flush_if) ? 1'b0 : if_id_ip_inst_from_imem[0];
	id_inst_from_imem[31:1]  = if_id_ip_inst_from_imem[31:1];

	id_read_addr1            = (id_lui_inst == 1'b1) ? 5'h0 : if_id_ip_inst_from_imem[19:15];
	id_read_addr2            = if_id_ip_inst_from_imem[24:20];
	id_write_addr            = if_id_ip_inst_from_imem[11:7];

	// Generate forwarding signals
	// Forwarding from MEM to a junior in EX
	id_rs1_matches_s1        = ((id_read_addr1 != 5'h0) && (id_read_addr1 == id_ex_write_addr) && (id_ex_write_en) && (~id_alu_src1_from_pc)) ? 1'b1 : 1'b0;

	// Forwarding from WB to a junior in EX
	id_rs2_matches_s1        = ((id_read_addr2 != 5'h0) && (id_read_addr2 == id_ex_write_addr) && (id_ex_write_en) && (~id_alu_src2_from_imm)) ? 1'b1 : 1'b0;

	// Forwarding from WB to a junior in EX
	id_rs1_matches_s2        = ((id_read_addr1 != 5'h0) && (id_read_addr1 == ex_mem_write_addr) && (ex_mem_write_en) && (~id_alu_src1_from_pc)) ? 1'b1 : 1'b0;
	id_rs2_matches_s2        = ((id_read_addr2 != 5'h0) && (id_read_addr2 == ex_mem_write_addr) && (ex_mem_write_en) && (~id_alu_src2_from_imm)) ? 1'b1 : 1'b0;

	// Forwarding signal for store junior
	id_rs2_matches_s1_st     = ((id_read_addr2 != 5'h0) && (id_read_addr2 == id_ex_write_addr) && (id_ex_write_en)) ? 1'b1 : 1'b0;
	id_rs2_matches_s2_st     = ((id_read_addr2 != 5'h0) && (id_read_addr2 == ex_mem_write_addr) && (ex_mem_write_en)) ? 1'b1 : 1'b0;

	// Stalls -> When a dependent junior instruction arrives behind a load instruction.
	id_stall                 = (id_rs1_matches_s1 | id_rs2_matches_s1) & id_ex_mem_read_en & (~flush_ex);
     end

   // ID-EX stage register
   always @(posedge clk)
     begin
	if (reset | flush_id | id_stall)
	  begin
	     id_ex_write_en      <= 1'b0;
	     id_ex_mem_write_en  <= 1'b0;
	     id_ex_mem_read_en   <= 1'b0;
	     id_ex_branch_inst   <= 1'b0;
	     id_ex_jump_inst     <= 1'b0;
	  end
	else
	  begin
	     id_ex_write_en      <= id_write_en ;
	     id_ex_mem_write_en  <= id_mem_write_en;
	     id_ex_mem_read_en   <= id_mem_read_en;
	     id_ex_branch_inst   <= id_branch_inst;
	     id_ex_jump_inst     <= id_jump_inst;
	  end

	id_ex_write_addr         <= id_write_addr;

	id_ex_immediate          <= id_immediate;
	id_ex_alu_opcode         <= id_alu_opcode;
	id_ex_alu_src1_from_pc   <= id_alu_src1_from_pc;
	id_ex_alu_src2_from_imm  <= id_alu_src2_from_imm;

	id_ex_read_data1         <= id_read_data1;
	id_ex_read_data2         <= id_read_data2;

	id_ex_funct3             <= id_funct3;
	id_ex_rs1_matches_s1     <= id_rs1_matches_s1;
	id_ex_rs2_matches_s1     <= id_rs2_matches_s1;
	id_ex_rs1_matches_s2     <= id_rs1_matches_s2;
	id_ex_rs2_matches_s2     <= id_rs2_matches_s2;
	id_ex_rs2_matches_s1_st  <= id_rs2_matches_s1_st;
	id_ex_rs2_matches_s2_st  <= id_rs2_matches_s2_st;

	id_ex_PC                 <= if_id_PC;
     end

   //--------------------------- EX Stage  ---------------------------
   reg [31:0]  alu_src1;
   reg [31:0]  alu_src2;

   wire [31:0] ex_alu_result;
   wire        ex_minus_is_zero;
   wire        ex_less_than;
   wire        ex_less_than_unsigned;

   reg 	       ex_mem_write_en;
   reg [4:0]   ex_mem_write_addr;
   reg [31:0]  ex_mem_alu_result;

   reg 	       ex_mem_rs2_matches_s1_st;
   reg 	       ex_mem_rs2_matches_s2_st;

   reg 	       ex_mem_mem_write_en;
   reg 	       ex_mem_mem_read_en;

   reg [31:0]  ex_mem_read_data2;
   reg [2:0]   ex_mem_funct3;

   reg 	       ex_mem_branch_inst;

   reg [31:0]  ex_mem_PC;
   reg [31:0]  ex_mem_immediate;

   reg 	       ex_mem_minus_is_zero;
   reg 	       ex_mem_less_than;
   reg 	       ex_mem_less_than_unsigned;

   always @(*)
     begin
	alu_src1                 = (id_ex_alu_src1_from_pc == 1'b1)  ? id_ex_PC : id_ex_read_data1;
	alu_src2                 = (id_ex_alu_src2_from_imm == 1'b1) ? id_ex_immediate : id_ex_read_data2;

	// Forwarding help from WB stage
	if (id_ex_rs1_matches_s2 == 1'b1) alu_src1 = mem_wb_write_data;
	if (id_ex_rs2_matches_s2 == 1'b1) alu_src2 = mem_wb_write_data;

	// Forwarding help from MEM stage
	if (id_ex_rs1_matches_s1 == 1'b1) alu_src1 = ex_mem_alu_result;
	if (id_ex_rs2_matches_s1 == 1'b1) alu_src2 = ex_mem_alu_result;
     end

   // EX-MEM stage register
   always @(posedge clk)
     begin
	if (reset | flush_ex)
	  begin
	     ex_mem_write_en     <= 1'b0;
	     ex_mem_mem_write_en <= 1'b0;
	     ex_mem_mem_read_en  <= 1'b0;
	     ex_mem_branch_inst  <= 1'b0;
	     ex_mem_jump_inst    <= 1'b0;
	  end
	else
	  begin
	     ex_mem_write_en     <= id_ex_write_en;
	     ex_mem_mem_write_en <= id_ex_mem_write_en;
	     ex_mem_mem_read_en  <= id_ex_mem_read_en;
	     ex_mem_branch_inst  <= id_ex_branch_inst;
	     ex_mem_jump_inst    <= id_ex_jump_inst;
	  end

	ex_mem_write_addr        <= id_ex_write_addr;
	ex_mem_read_data2        <= (id_ex_rs2_matches_s2_st == 1'b1) ? mem_wb_write_data : id_ex_read_data2;
	ex_mem_alu_result        <= ex_alu_result;

	ex_mem_funct3            <= id_ex_funct3;
	ex_mem_rs2_matches_s1_st <= id_ex_rs2_matches_s1_st;

	ex_mem_PC                <= id_ex_PC;
	ex_mem_immediate         <= id_ex_immediate;

	ex_mem_minus_is_zero     <= ex_minus_is_zero;
	ex_mem_less_than         <= ex_less_than;
	ex_mem_less_than_unsigned <= ex_less_than_unsigned;
     end

   //--------------------------- MEM Stage ---------------------------
   reg [31:0]   op_data_from_proc_raw;
   reg [31:0] 	masked_data_from_dmem;

   always @(*)
     begin
	op_data_addr             = ex_mem_alu_result;
	op_data_wr               = ex_mem_mem_write_en;
	op_data_rd               = ex_mem_mem_read_en;

	// Data for stores
	// This neat code is taken from Bruno Levy's project here: https://github.com/BrunoLevy/learn-fpga
	// We need to align the byte/half-byte at the right place along with sending the write mask to the
	// DMEM.
	op_data_from_proc_raw    = (ex_mem_rs2_matches_s1_st == 1'b1) ? mem_wb_write_data : ex_mem_read_data2;
	op_data_from_proc[7:0]   = op_data_from_proc_raw[7:0];
	op_data_from_proc[15:8]  = (op_data_addr[0] == 1'b1) ? op_data_from_proc_raw[7:0]  : op_data_from_proc_raw[15:8];
	op_data_from_proc[23:16] = (op_data_addr[1] == 1'b1) ? op_data_from_proc_raw[7:0]  : op_data_from_proc_raw[23:16];
	op_data_from_proc[31:24] = (op_data_addr[0] == 1'b1) ? op_data_from_proc_raw[7:0]  :
				   (op_data_addr[1] == 1'b1) ? op_data_from_proc_raw[15:8] : op_data_from_proc_raw[31:24];

	op_data_mask = 4'b1111; // Default word access
	case (ex_mem_funct3[1:0])
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

	// Data from loads
	masked_data_from_dmem    = ip_data_from_dmem;
	case (ex_mem_funct3[1:0])
	  2'b00: // Byte access
	    begin
	       case (op_data_addr[1:0])
		 2'b00: masked_data_from_dmem = {{24{~ex_mem_funct3[2] & ip_data_from_dmem[7]}}, ip_data_from_dmem[7:0]};
		 2'b01: masked_data_from_dmem = {{24{~ex_mem_funct3[2] & ip_data_from_dmem[15]}}, ip_data_from_dmem[15:8]};
		 2'b10: masked_data_from_dmem = {{24{~ex_mem_funct3[2] & ip_data_from_dmem[23]}}, ip_data_from_dmem[23:16]};
		 2'b11: masked_data_from_dmem = {{24{~ex_mem_funct3[2] & ip_data_from_dmem[31]}}, ip_data_from_dmem[31:24]};
	       endcase
	    end
	  2'b01: // Half word access
	    begin
	       case (op_data_addr[1])
		 1'b0: masked_data_from_dmem = {{16{~ex_mem_funct3[2] & ip_data_from_dmem[15]}}, ip_data_from_dmem[15:0]};
		 1'b1: masked_data_from_dmem = {{16{~ex_mem_funct3[2] & ip_data_from_dmem[31]}}, ip_data_from_dmem[31:16]};
	       endcase
	    end
	endcase

	// Branch instruction
	ex_mem_branch_successful  = 1'b0;
	jump_next_pc              = 32'hx;
	if (ex_mem_branch_inst)
	  begin
	     case (ex_mem_funct3)
	       3'b000: // BEQ
		 if (ex_mem_minus_is_zero)            ex_mem_branch_successful  = 1'b1;
	       3'b001: // BNEQ
		 if (!ex_mem_minus_is_zero)           ex_mem_branch_successful  = 1'b1;
	       3'b100: // BLT
		 if (ex_mem_less_than)                ex_mem_branch_successful  = 1'b1;
	       3'b101: // BGE
		 if (!ex_mem_less_than)               ex_mem_branch_successful  = 1'b1;
	       3'b110: // BLTU
		 if (ex_mem_less_than_unsigned)       ex_mem_branch_successful  = 1'b1;
	       3'b111: // BGEU
		 if (!ex_mem_less_than_unsigned)      ex_mem_branch_successful  = 1'b1;
	     endcase
	  end // if (ex_mem_branch_inst)

	if (ex_mem_jump_inst)                  jump_next_pc = ex_mem_alu_result; //ex_mem_PC + 32'h4;
	if (ex_mem_branch_successful)          jump_next_pc = ex_mem_PC + ex_mem_immediate;
     end

   // MEM-WB stage register
   always @(posedge clk)
     begin
	if (reset)
	  begin
	     mem_wb_write_en     <= 1'b0;
	  end
	else
	  begin
	     mem_wb_write_en     <= ex_mem_write_en;
	  end

	mem_wb_PC                <= ex_mem_PC;
	mem_wb_jump_inst         <= ex_mem_jump_inst;
	mem_wb_write_addr        <= ex_mem_write_addr;
	mem_wb_write_data        <= (ex_mem_mem_read_en == 1'b1) ? masked_data_from_dmem :
				    (ex_mem_jump_inst) ? ex_mem_PC + 32'h4 : ex_mem_alu_result;
     end

   //--------------------------- WB Stage  ---------------------------



   //=================================================================
   // Instantiation of decoder, register file, and ALU

   decoder decoder_0
     (
      .ip_inst(id_inst_from_imem),

      .write_en(id_write_en),
      .immediate(id_immediate),
      .alu_opcode(id_alu_opcode),
      .alu_src1_from_pc(id_alu_src1_from_pc),
      .alu_src2_from_imm(id_alu_src2_from_imm),
      .mem_write_en(id_mem_write_en),
      .mem_read_en(id_mem_read_en),
      .funct3(id_funct3),
      .lui_inst(id_lui_inst),
      .store_inst(id_store_inst),
      .branch_inst(id_branch_inst),
      .jump_inst(id_jump_inst)
      );

   register_file register_file_0
     (
      .clk(clk),

      .read_addr1(id_read_addr1),
      .read_data1(id_read_data1),

      .read_addr2(id_read_addr2),
      .read_data2(id_read_data2),

      .write_en(mem_wb_write_en),
      .write_addr(mem_wb_write_addr),
      .write_data(mem_wb_write_data)
      );

   alu alu_0
     (
      .alu_src1(alu_src1),
      .alu_src2(alu_src2),
      .alu_opcode(id_ex_alu_opcode),

      .minus_is_zero(ex_minus_is_zero),
      .less_than(ex_less_than),
      .less_than_unsigned(ex_less_than_unsigned),
      .alu_result(ex_alu_result)
      );

endmodule
