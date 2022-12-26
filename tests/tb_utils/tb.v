// General test bench to test the overall processor

`timescale 1ns/1ps

module tb;
   reg 	clk, reset;
   wire tx, rx;

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
	$readmemh("imem.fill", SoC_0.imem_0.mem);
	$readmemh("dmem.fill", SoC_0.dmem_0.mem);

	clk       <= 1'b0;
	reset     <= 1'b1;
	clocks    <= 0;
	repeat(5) @(negedge clk);
	reset     <= 1'b0;

	// Wait till program complestes.
	// Program completion is detected by fetching
	// the instruction 32'h0;
	wait(SoC_0.inst_from_imem == 32'h0);

	$display("The program completed in %d cycles", clocks);
	// Drain pipelines
	repeat(5) @(negedge clk);

	// Dump the contents of DMEM into a file
	dump_file = $fopen("dmem_actual.dump");
	for (i = 0; i < 8; i = i + 1)
	  begin
	     $fdisplay(dump_file, "Memory location %d : %h", 4*i, SoC_0.dmem_0.mem[i]);
	  end

	// Dump the contents of register file into a file
	dump_file = $fopen("rf_actual.dump");
	for (i = 0; i < 32; i = i + 1)
	  begin
	     $fdisplay(dump_file, "Register %d : %h", i, SoC_0.processor_0.register_file_0.mem[i]);
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

   SoC SoC_0
     (
      .clk(clk),
      .reset(reset),
      .tx(tx),
      .rx(rx)
      );

endmodule
