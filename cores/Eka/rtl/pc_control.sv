/* Separate module for PC */

module pc_control
  #(
    parameter ADDR_WIDTH=32,
    parameter RESET_ADDR=30'h0000_0000
    )
  (
   /* Inputs */
   clk,
   reset,
   branch_stmt,
   zero,
   stall,
   funct3,
   immediate,

   /* Outputs */
   PC,
   pc_next,
   pc_plus_four
   );

   input wire			 clk;
   input wire			 reset;
   input wire			 branch_stmt;
   input wire			 zero;
   input wire			 stall;
   input wire [2:0]		 funct3;
   input wire [31:0]		 immediate;

   output reg [ADDR_WIDTH-1-2:0] PC; // The lower two bits are always 0.
   output reg [ADDR_WIDTH-1-2:0] pc_next;
   output reg [ADDR_WIDTH-1-2:0] pc_plus_four;

   reg				 branch_success;

   // Calculation of pc_next
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
	pc_plus_four = PC + 30'b1;
	pc_next      = (branch_success == 1'b1) ? PC + immediate[31:2] : PC + 30'b1; // Ignore compressed instructions
     end

   always @(posedge clk)
     begin
	if (reset)
	  begin
	     PC <= RESET_ADDR;
	  end
	else
	  begin
	     if (!stall)
	       begin
		  PC <= pc_next;
	       end
	  end
     end

endmodule
