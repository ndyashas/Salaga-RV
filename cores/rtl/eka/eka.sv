/*
 * This is a Single-Cycle-CPU. This core assumes that instruction and data caches
 * will never have any misses, and will take one clock-cycle to serve their
 * operations.
 */

module eka
  #(
    parameter ADDR_WIDTH=32,
    parameter RESET_ADDR=30'h0000_0000
    )
   (
    /* Inputs */
    clk,
    reset,
    instruction,
    mem_rd_data,
    inst_valid,
    data_stall,

    /* Outputs */
    inst_addr,
    data_addr,
    mem_wr_data,
    mem_wr_mask,
    mem_wr,
    mem_rd
   );


   // Port wires and regesters
   input wire 			clk;           // Processor clock.
   input wire 			reset;         // Reset processor.
   input wire [31:0] 		instruction;   // Fetched instruction from the memory.
   input wire [31:0] 		mem_rd_data;   // Read data coming from the memory.
   input wire			inst_valid;    // Instruction valid. Can be used as !inst_stall
   input wire			data_stall;    // Data stall.

   output wire [ADDR_WIDTH-1:0] inst_addr;     // Address of the instruction to be read/written.
   output wire [31:0] 		data_addr;     // Address of the data to be read/written.
   output wire [31:0] 		mem_wr_data;   // Data to be written.
   output wire [3:0]		mem_wr_mask;   // Memory mask. To be used as bank enables for byte-wide banks.
   output wire 			mem_wr;        // Asserted when the processor intends to write.
   output wire 			mem_rd;        // Required to disqualify unneccecary memory reads. Useful in the future?
   
   
   // Local wires and regesters
   wire [ADDR_WIDTH-1-2:0]	PC; // The lower two bits are always 0.
   wire [ADDR_WIDTH-1-2:0]	pc_plus_four;
   wire 			branch_stmt;
   wire 			mem_to_reg;
   wire [3:0] 			ALU_Ctrl;
   wire 			ALU_Src;
   wire 			Reg_Wr;

   wire [31:0]			read_data1, read_data2, ALU_result;
   reg [31:0]			write_data;
   wire [31:0]			immediate;
   reg [31:0]			alu_leg2, alu_leg1;
   reg [31:0]			masked_mem_wr_data;
   reg [31:0]			masked_mem_rd_data;
   reg [4:0]			reg_file_read_addr1;
   reg [4:0]			read_addr1, read_addr2, write_addr;
   wire				zero;
   wire				r1_zero;
   wire				r1_pc;
   reg [2:0]			funct3;
   reg				stall;
   wire				jump;
   reg [3:0]			mem_mask;
   reg				Less_than_unsigned;
   reg				Less_than;


   assign inst_addr         = {PC, 2'b0};
   assign data_addr         = ALU_result;
   assign mem_wr_data       = masked_mem_wr_data;
   assign mem_wr_mask       = mem_mask;

   always @(*)
     begin
	read_addr2          = instruction[24:20];
	read_addr1          = instruction[19:15];
	write_addr          = instruction[11:7];
	funct3              = instruction[14:12];

	reg_file_read_addr1 = (r1_zero == 1'b1) ? 5'b0 : read_addr1;

	alu_leg1            = (r1_pc == 1'b1) ? {PC, 2'b0} : read_data1;
	alu_leg2            = (ALU_Src == 1'b1) ? immediate : read_data2;

	stall               = (!inst_valid) | data_stall;

	// Generation of memory_wr_mask
	mem_mask = 4'b0000;
	masked_mem_rd_data = mem_rd_data;
	if (funct3[1:0] == 2'b00) // byte access
	  begin
	     case(data_addr[1:0])
	       2'b00:
		 begin
		    mem_mask = 4'b0001;
		    masked_mem_rd_data = {{24{!funct3[2] & mem_rd_data[7]}}, mem_rd_data[7:0]};
		 end
	       2'b01:
		 begin
		    mem_mask = 4'b0010;
		    masked_mem_rd_data = {{24{!funct3[2] & mem_rd_data[15]}}, mem_rd_data[15:8]};
		 end
	       2'b10:
		 begin
		    mem_mask = 4'b0100;
		    masked_mem_rd_data = {{24{!funct3[2] & mem_rd_data[23]}}, mem_rd_data[23:16]};
		 end
	       2'b11:
		 begin
		    mem_mask = 4'b1000;
		    masked_mem_rd_data = {{24{!funct3[2] & mem_rd_data[31]}}, mem_rd_data[31:24]};
		 end
	     endcase
	  end
	else if (funct3[1:0] == 2'b01) // half word access
	  begin
	     case(data_addr[1])
	       1'b0:
		 begin
		    mem_mask = 4'b0011;
		    masked_mem_rd_data = {{16{!funct3[2] & mem_rd_data[15]}}, mem_rd_data[15:0]};
		 end
	       1'b1:
		 begin
		    mem_mask = 4'b1100;
		    masked_mem_rd_data = {{16{!funct3[2] & mem_rd_data[31]}}, mem_rd_data[31:16]};
		 end
	     endcase
	  end
	else if (funct3[1:0] == 2'b10) // word access
	  begin
	     mem_mask = 4'b1111;
	     masked_mem_rd_data = mem_rd_data;
	  end
	else // unknown access, probably double word access, unsupported
	  begin
	     mem_mask = 4'b0000;
	     masked_mem_rd_data = mem_rd_data;
	  end

	// This neat code is taken from Bruno Levy's project here: https://github.com/BrunoLevy/learn-fpga
	masked_mem_wr_data[7:0]   = read_data2[7:0];
	masked_mem_wr_data[15:8]  = (data_addr[0] == 1'b1) ? read_data2[7:0]  : read_data2[15:8];
	masked_mem_wr_data[23:16] = (data_addr[1] == 1'b1) ? read_data2[7:0]  : read_data2[23:16];
	masked_mem_wr_data[31:24] = (data_addr[0] == 1'b1) ? read_data2[7:0]  :
				    (data_addr[1] == 1'b1) ? read_data2[15:8] : read_data2[31:24];


	if (jump == 1'b1)
	  begin
	     write_data     = {pc_plus_four, 2'b00};
	  end
	else
	  begin
	     if (mem_to_reg == 1'b1)
	       begin
		  write_data = masked_mem_rd_data;
	       end
	     else
	       begin
		  write_data = ALU_result;
	       end
	  end // else: !if(jump == 1'b1)
     end


   decoder decoder_inst(.instruction(instruction),
			.immediate(immediate),
			.branch_stmt(branch_stmt),
			.mem_rd(mem_rd),
			.mem_wr(mem_wr),
			.mem_to_reg(mem_to_reg),
			.r1_zero(r1_zero),
			.r1_pc(r1_pc),
			.jump(jump),
			.ALU_Ctrl(ALU_Ctrl),
			.ALU_Src(ALU_Src),
			.Reg_Wr(Reg_Wr));


   register_file register_file_inst(.clk(clk),
				    .read_addr1(reg_file_read_addr1),
				    .read_addr2(read_addr2),
				    .write_en(Reg_Wr),
				    .write_addr(write_addr),
				    .write_data(write_data),
				    .read_data1(read_data1),
				    .read_data2(read_data2));


   alu alu_inst(.alu_src1(alu_leg1),
		.alu_src2(alu_leg2),
		.ALU_Ctrl(ALU_Ctrl),
		.zero(zero),
		.Less_than(Less_than),
		.Less_than_unsigned(Less_than_unsigned),
		.ALU_result(ALU_result));


   pc_control
     #(
       .ADDR_WIDTH(ADDR_WIDTH),
       .RESET_ADDR(RESET_ADDR)
       )
   pc_control_inst(.clk(clk),
		   .reset(reset),
		   .branch_stmt(branch_stmt),
		   .zero(zero),
		   .Less_than(Less_than),
		   .Less_than_unsigned(Less_than_unsigned),
		   .stall(stall),
		   .jump(jump),
		   .funct3(funct3),
		   .immediate(immediate),
		   .ALU_result(ALU_result),
		   .PC(PC),
		   .pc_plus_four(pc_plus_four)
		   );

endmodule
