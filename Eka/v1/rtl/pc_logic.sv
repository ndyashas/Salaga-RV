/* PC logic */

module pc_logic
  #(
    parameter ADDR_WIDTH=32,
    parameter RESET_ADDR=30'h0000_0000
   )
  (
   /* Inputs */
   clk,
   reset,
   pc_other_ip,
   pc_other_ip_sel,

   /* Outputs */
   PC
   );

   input wire			 clk;
   input wire			 reset;
   input wire			 pc_other_ip_sel;
   input wire [ADDR_WIDTH-1-2:0] pc_other_ip;
      
   output reg [ADDR_WIDTH-1-2:0] PC;

   always @(posedge clk)
     begin
	if (reset)
	  begin
	     PC <= RESET_ADDR;
	  end
	else
	  begin
	     PC <= (pc_other_ip_sel == 1'b1) ? pc_other_ip : PC + 30'b1;
	  end
     end

endmodule
