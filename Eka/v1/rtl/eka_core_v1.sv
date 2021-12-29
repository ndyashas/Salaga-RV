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
   reg [ADDR_WIDTH-1-2:0] 	PC; // The lower two bits are always 0.
   wire 			branch_stmt;
   wire 			mem_to_reg;
   wire [1:0] 			ALU_Op;
   wire 			ALU_Src;
   wire 			Reg_Wr;

   // Temporary wires
   wire [31:0]			WRITE_DATA, read_data1, read_data2, ALU_RESULT;
   wire [4:0]			read_addr1, read_addr2, write_addr;
   wire				ADD_SUB_SEL, ZERO;

   assign inst_addr  = {PC, 2'b0};
   assign read_addr1 = instruction[19:15]; // rs1
   assign read_addr2 = instruction[24:20]; // rs2
   assign write_addr = instruction[11:7];  // rd

   decoder decoder_inst(.instruction(instruction),
			.branch_stmt(branch_stmt),
			.mem_rd(mem_rd),
			.mem_wr(mem_wr),
			.mem_to_reg(mem_to_reg),
			.ALU_Op(ALU_Op),
			.ALU_Src(ALU_Src),
			.Reg_Wr(Reg_Wr));

   register_file register_file_inst(.clk(clk),
				    .read_addr1(read_addr1),
				    .read_addr2(read_addr1),
				    .write_en(Reg_Wr),
				    .write_addr(write_addr),
				    .write_data(WRITE_DATA),
				    .read_data1(read_data1),
				    .read_data2(read_data2));


   alu alu_inst(.alu_src1(read_data1),
		.alu_src2(read_data2),
		.ALU_Op(ALU_Op),
		.add_sub_sel(ADD_SUB_SEL),
		.zero(ZERO),
		.ALU_result(ALU_RESULT));


   always @(posedge clk)
     begin
	if (reset)
	  begin
	     PC <= RESET_ADDR;
	  end
	else
	  begin
	     PC <= PC + 30'b1;
	  end
     end

endmodule
