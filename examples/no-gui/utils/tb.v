// General test bench to test the overall processor

`timescale 1ns/1ps

module tb;
   reg 	clk, reset;
   wire tx, rx, uart_busy, uart_valid;
   wire [7:0] uart_rx_data;


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

	for (i = 0; i < 32; i = i + 1)
	  begin
	     SoC_0.processor_0.register_file_0.mem[i] = 0;
	  end

	clk       <= 1'b0;
	reset     <= 1'b1;
	clocks    <= 0;
	repeat(2) @(negedge clk);
	reset     <= 1'b0;

	// Wait till program complestes.
	// Program completion is detected by fetching
	// the 'ebreak' instruction;
	wait(SoC_0.inst_from_imem == 32'h0010_0073);

	$display("\nThe program completed in %d cycles", clocks);
	// Drain pipelines
	repeat(5) @(negedge clk);

	// Dump the contents of DMEM into a file
	dump_file = $fopen("dmem_actual.dump");
	for (i = 0; i < 20; i = i + 1)
	  begin
	     $fdisplay(dump_file, "Memory location %d : %h", 4*i, SoC_0.dmem_0.mem[i]);
	  end

	// // Dump the contents of register file into a file
	// dump_file = $fopen("rf_actual.dump");
	// for (i = 0; i < 32; i = i + 1)
	//   begin
	//      $fdisplay(dump_file, "Register %d : %h", i, SoC_0.processor_0.register_file_0.mem[i]);
	//   end
	// $fclose(dump_file);
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


   SoC
     #(
       .RESET_PC_VALUE(32'h00000050),
       .IMEM_SIZE_IN_WORDS(2048),
       .DMEM_SIZE_IN_WORDS(2048)
       )
     SoC_0
     (
      .clk(clk),
      .reset(reset),
      .tx(tx),
      .rx(rx)
      );

   // To print out
   buart buart_0
     (
      .clk(clk),
      .resetq(~reset),
      .tx(rx),
      .rx(tx),
      .wr(1'b0),
      .rd(1'b1),
      .tx_data(8'h0),
      .rx_data(uart_rx_data),
      .busy(uart_busy),
      .valid(uart_valid)
      );

   always @(posedge clk)
     begin
	if (uart_valid)
	  begin
	     $write("%c", uart_rx_data);
	     $fflush(32'h8000_0001);
	  end
     end

endmodule
