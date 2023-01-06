// General test bench to test the overall processor

`timescale 1ns/1ps

module tb(clk, reset, disp_en, disp_DC, disp_bus);
   input reg 	clk, reset;
   output wire       disp_en, disp_DC;
   output wire [31:0] disp_bus;
   wire tx, rx, uart_busy, uart_valid;
   wire [7:0] uart_rx_data;

   // Keeping track of parameter
   integer 	clocks;

   // Misc
   integer 	i;
   integer 	dump_file;

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

	clocks    = 0;
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
      .rx(rx),
      .disp_en(disp_en),
      .disp_DC(disp_DC),
      .disp_bus(disp_bus)
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
