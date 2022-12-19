// General test bench to test the overall processor

`timescale 1ns/1ps

module tb;
   reg 	clk, reset;

   wire [31:0] inst_addr;
   wire        inst_valid;
   wire [31:0] inst_from_imem;

   wire [31:0] data_addr;
   wire        data_wr;
   wire [3:0]  data_mask;
   wire [31:0] data_from_proc;
   wire        data_rd;
   wire        data_valid;
   wire [31:0 ] data_from_dmem;

   // Keeping track of parameter
   integer 	clocks;

   // Misc
   integer 	i;
   integer 	dump_file;

   always #5 clk = ~clk;

   initial
     begin
	// Dumping waveforms
	$dumpfile("wave.vcd");
	$dumpvars(0, tb);

	// Set up initial values
	$readmemh("imem.fill", imem_0.mem);
	$readmemh("dmem.fill", dmem_0.mem);

	clk       <= 1'b0;
	reset     <= 1'b1;
	clocks    <= 0;
	repeat(5) @(negedge clk);
	reset     <= 1'b0;

	// Wait till program complestes.
	// Program completion is detected by fetching
	// the instruction 32'h0;
	wait(inst_from_imem == 32'h0);

	$display("The program completed in %d cycles", clocks);
	// Drain pipelines
	repeat(5) @(negedge clk);

	// Dump the contents of DMEM into a file
	dump_file = $fopen("dmem_actual.dump");
	for (i = 0; i < 8; i = i + 1)
	  begin
	     $fdisplay(dump_file, "Memory location %d : %h", 4*i, dmem_0.mem[i]);
	  end

	// Dump the contents of register file into a file
	dump_file = $fopen("rf_actual.dump");
	for (i = 0; i < 32; i = i + 1)
	  begin
	     $fdisplay(dump_file, "Register %d : %h", i, processor_0.register_file_0.mem[i]);
	  end
	$fclose(dump_file);
	$finish;
     end

   always @(posedge clk)
     begin
	if (reset)
	  begin
	     clocks <= 0;
	  end
	else
	  begin
	     clocks <= clocks + 1;
	  end
     end


   initial
     begin
	// To avoid infinite loops
	#1000
	  $display("Test timeout.");
	$finish;
     end

   // Instantiations of processor, imem, and dmem
   // Connect processor to IMEM and DMEM
   processor processor_0
     (
      .clk(clk),
      .reset(reset),

      .op_inst_addr(inst_addr),
      .ip_inst_valid(inst_valid),
      .ip_inst_from_imem(inst_from_imem),

      .op_data_addr(data_addr),

      .op_data_wr(data_wr),
      .op_data_mask(data_mask),
      .op_data_from_proc(data_from_proc),

      .op_data_rd(data_rd),
      .ip_data_valid(data_valid),
      .ip_data_from_dmem(data_from_dmem)
      );

   imem #(.SIZE_IN_BYTES(20)) imem_0
     (
      .ip_inst_addr(inst_addr),
      .op_inst_valid(inst_valid),
      .op_inst_from_imem(inst_from_imem)
      );

   dmem #(.SIZE_IN_BYTES(8)) dmem_0
     (
      .clk(clk),

      .ip_data_addr(data_addr),

      .ip_data_wr(data_wr),
      .ip_data_mask(data_mask),
      .ip_data_from_proc(data_from_proc),

      .ip_data_rd(data_rd),
      .op_data_valid(data_valid),
      .op_data_from_dmem(data_from_dmem)
      );

endmodule
