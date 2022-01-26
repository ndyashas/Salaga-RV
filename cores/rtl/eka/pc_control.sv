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
   Less_than,
   Less_than_unsigned,
   stall,
   jump,
   funct3,
   immediate,
   ALU_result,

   /* Outputs */
   PC,
   pc_plus_four
   );

   input wire			 clk;
   input wire			 reset;
   input wire			 branch_stmt;
   input wire			 zero;
   input wire			 Less_than;
   input wire			 Less_than_unsigned;
   input wire			 stall;
   input wire			 jump;
   input wire [2:0]		 funct3;
   input wire [31:0]		 immediate;
   input wire [31:0]		 ALU_result;

   output reg [ADDR_WIDTH-1-2:0] PC; // The lower two bits are always 0.
   output reg [ADDR_WIDTH-1-2:0] pc_plus_four;

   reg [ADDR_WIDTH-1-2:0]	 pc_next;
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
	       3'b100:
		 begin
		    branch_success = Less_than;
		 end
	       3'b110:
		 begin
		    branch_success = Less_than_unsigned;
		 end
	       3'b101:
		 begin
		    branch_success = ~(Less_than | zero);
		 end
	       3'b111:
		 begin
		    branch_success = ~(Less_than_unsigned | zero);
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

	pc_plus_four = PC + 30'b1;

	// immediate holds the number of bytes offset. We ignore the lower
	// 2 bits as our core only supports 32-bit instructions.
	if (jump == 1'b1)
	  begin
	     pc_next = ALU_result[31:2];
	  end
	else if (branch_success == 1'b1) // Ignoring compressed instruction extension
	  begin
	     pc_next = PC + immediate[31:2];
	  end
	else
	  begin
	     pc_next = PC + 30'b1;
	  end
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
