/*
 * This is a Single-Cycle-CPU. This core assumes that instruction and data caches
 * will never have any misses, and will take one clock-cycle to serve their
 * operations.
 */

module eka_core_v1
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

    /* Outputs */
    inst_addr,
    data_addr,
    mem_wr_data,
    mem_wr,
    mem_rd
   );


   // Port wires and regesters
   input wire 			clk;           // Processor clock.
   input wire 			reset;         // Reset processor.
   input wire [31:0] 		instruction;   // Fetched instruction from the memory.
   input wire [31:0] 		mem_rd_data;   // Read data coming from the memory.

   output wire [ADDR_WIDTH-1:0] inst_addr;     // Address of the instruction to be read/written.
   output wire [31:0] 		data_addr;     // Address of the data to be read/written.
   output wire [31:0] 		mem_wr_data;   // Data to be written.
   output wire 			mem_wr;        // Asserted when the processor intends to write.
   output wire 			mem_rd;        // Required to disqualify unneccecary memory reads. Useful in the future?
   
   
   // Local wires and regesters
   reg [ADDR_WIDTH-1-2:0] 	PC, pc_next; // The lower two bits are always 0.
   wire 			branch_stmt;
   wire 			mem_to_reg;
   wire [3:0] 			ALU_Ctrl;
   wire 			ALU_Src;
   wire 			Reg_Wr;

   wire [31:0]			write_data, read_data1, read_data2, ALU_result;
   wire [31:0]			alu_leg2, immediate;
   wire [4:0]			read_addr1, read_addr2, write_addr;
   wire				zero;
   wire [2:0]			funct3;

   reg				branch_success;

   assign inst_addr  = {PC, 2'b0};


   assign read_addr2 = instruction[24:20];
   assign read_addr1 = instruction[19:15];
   assign write_addr = instruction[11:7];
   assign data_addr  = ALU_result;
   assign funct3     = instruction[14:12];

   decoder decoder_inst(.instruction(instruction),
			.immediate(immediate),
			.branch_stmt(branch_stmt),
			.mem_rd(mem_rd),
			.mem_wr(mem_wr),
			.mem_to_reg(mem_to_reg),
			.ALU_Ctrl(ALU_Ctrl),
			.ALU_Src(ALU_Src),
			.Reg_Wr(Reg_Wr));

   assign write_data = (mem_to_reg == 1'b1) ? mem_rd_data : ALU_result;

   register_file register_file_inst(.clk(clk),
				    .read_addr1(read_addr1),
				    .read_addr2(read_addr2),
				    .write_en(Reg_Wr),
				    .write_addr(write_addr),
				    .write_data(write_data),
				    .read_data1(read_data1),
				    .read_data2(read_data2));


   assign mem_wr_data = read_data2;
   assign alu_leg2 = (ALU_Src) ? immediate : read_data2;

   alu alu_inst(.alu_src1(read_data1),
		.alu_src2(alu_leg2),
		.ALU_Ctrl(ALU_Ctrl),
		.zero(zero),
		.ALU_result(ALU_result));


   always @(*)
     begin
	if (branch_stmt)
	  begin
	     case(funct3)
	       3'b000: // BEQ
		 begin
		    branch_success = (zero == 1'b1) ? 1'b1 : 1'b0;
		 end
	       3'b001:
		 begin
		    branch_success = (zero != 1'b1) ? 1'b1 : 1'b0;
		 end
	       default:
		 begin
		    branch_success = 1'b0;
		 end
	     endcase
	  end // if (branch_stmt)
	else
	  begin
	     branch_success = 1'b0;
	  end // else: !if(branch_stmt)
	// immediate holds the number of bytes offset. We ignore the lower
	// 2 bits as our core only supports 32-bit instructions.
	pc_next = (branch_success == 1'b1) ? PC + immediate[31:2] : PC + 30'b1; // Ignore compressed instructions
     end

   always @(posedge clk)
     begin
	if (reset)
	  begin
	     PC <= RESET_ADDR;
	  end
	else
	  begin
	     PC <= pc_next;
	  end
     end

endmodule
