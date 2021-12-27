/*
 * This is a Single-Cycle-CPU. This core assumes that instruction and data caches
 * will never have any misses, and will take one clock-cycle to serve their
 * operations.
 */

module eka_core_v1
  #(
    parameter ADDR_WIDTH=32,
    parameter RESET_ADDR=32'h0000_0000
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
   wire [31:0]			WRITE_DATA, READ_DATA1, READ_DATA2;
   wire [4:0]			READ_ADDR1, READ_ADDR2, WRITE_ADDR;
   
   decoder decoder_inst(.instruction(instruction),
			.branch_stmt(branch_stmt),
			.mem_rd(mem_rd),
			.mem_wr(mem_wr),
			.mem_to_reg(mem_to_reg),
			.ALU_Op(ALU_Op),
			.ALU_Src(ALU_Src),
			.Reg_Wr(Reg_Wr));

   register_file register_file_inst(.clk(clk),
				    .read_addr1(READ_ADDR1),
				    .read_addr2(READ_ADDR2),
				    .write_en(Reg_Wr),
				    .write_addr(WRITE_ADDR),
				    .write_data(WRITE_DATA),
				    .read_data1(READ_DATA1),
				    .read_data2(READ_DATA2));
   
   
endmodule
