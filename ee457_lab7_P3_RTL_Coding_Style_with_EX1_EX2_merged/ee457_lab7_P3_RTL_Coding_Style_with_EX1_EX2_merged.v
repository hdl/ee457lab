// File: ee457_lab7_P3_RTL_Coding_Style.v 
// This is basically a re-writing of the earlier file "ee457_lab7_P3.v" in RTL coding style
// Written by Gandhi Puvvada, Oct 12, 2010, Nov 21, 2010
// Here, we want to reduce unnecessary hierarchy. So we are not using the 
// components defined in ee457_lab7_components.v. Instead we are coding them inline. 
// Also, we could avoid coding the mux select lines separately, comparator outputs separately.
// These can be implicitly defined in the if..else.. statements.
// The code is short, easy to understand and maintain.
// This is the recommended style.

// This design supports SUB3, ADD4, ADD1, and MOV instructions.

`timescale 1 ns / 100 ps

module ee457_lab7_P3 (CLK,RSTB);
input CLK,RSTB;


// signals -- listed stagewise
// Signals such as PC_OUT were wires in ee457_lab7_P3.v.
// Here they are changed to "reg".

// IF stage signals
reg [7:0] PC_OUT;
reg [31:0] memory [0:63]; // instruction memory 64x32
wire [31:0] IF_INSTR_combinational;
reg [31:0] IF_INSTR;

// ID stage signals
// reg ID_XMEX1, ID_XMEX2; // Outputs of the comparison station in ID-stage. 
// The above line is commented out and the above two signals are declared 
// with in the named procedural block, "Main_Clocked_Block" later to show how to curtail visibility of local signals.

// Notice that we declared below two signals: a wire signal called STALL_combinational and a reg signal called STALL.
// We explained later why we have declared these two signals. 
reg STALL;
reg STALL_Q;
wire STALL_combinational; // Declared as wire, as we intend to produce it using a continuous assign statement (outside the procedural block). 
reg ID_MOV,ID_SUB3,ID_ADD4,ID_ADD1; // We did not declare ID_MOV_OUT,ID_SUB3_OUT,ID_ADD4_OUT,ID_ADD1_OUT as it is considered as "too much detailing".
reg [3:0] ID_XA,ID_RA; // 4-bit source register and write register IDs
reg [15:0] reg_file [0:15] ; // register file 16x16
reg [15:0] ID_XD; // Data at ID_XA
reg [31:0] ID_INSTR;
reg ID_XMEX12; // Outputs of the comparison station in ID stage.

// EX12 stage signals
reg EX12_MOV,EX12_SUB3,EX12_ADD4,EX12_ADD1,EX12_XMEX12; 
reg FORW,SKIP1,SKIP2; // intermediate signals in EX1
reg [3:0] EX12_RA; // 4-bit write register ID
reg [15:0] EX12_XD,EX12_SUB3_IN,EX12_SUB3_OUT,EX12_ADD4_IN, EX12_ADD4_OUT, EX12_XD_OUT;
reg [31:0] EX12_INSTR;

// WB stage signals
reg WB_WRITE;
reg [3:0] WB_RA; // 4-bit write register ID
reg [15:0] WB_RD;
reg [31:0] WB_INSTR;


assign IF_INSTR_combinational = memory[PC_OUT[5:0]]; // instruction is read from the instruction memory;

assign STALL_combinational =EX12_ADD1&(~STALL_Q);// if the ID stage instruction's source register matches with the EX1 stage instruction's destination register
//								& // and further
//								(ID_SUB3 | ID_ADD1) // if the instruction in ID is a kind of instruction who will insist on receiving help at the beginning of the clock in EX1 itself when he reaches EX1
//								& // and further
//								(EX1_ADD4 | EX1_ADD1) // if the instruction in EX1 is a kind of instruction who will can't help at the beginning of the clock when he is in EX2 as he is still producing his result
//								; // then we need to stall the dependent instruction in ID stage.
								
// At the beginning of the "else // referring to else if posedge CLK" portion of the "clocked always procedural block"
// we produced STALL using blocking assignments and used it immediately to stall the PC and IF/ID registers.
// However, in the ModelSim waveform display, the STALL signal is displayed "after" the clock-edge at
// which it is supposed to take action, leading to possible confusion to a new reader (a novice) of 
// modelsim waveforms for designs expressed in Verilog.
// One can produce STALL_combinational as shown above and use it in place of the STALL below to stall the pipeline.
// Notice that the STALL_combinational waveform is easier to understand.
// Also notice the STALL (produced through blocked assignment) is initially unknown as it is not 
// initialized (and it is not necessary to initialize it) under reset (under "if (RSTB == 1'b0)").
// My recommendation: It is best not to display (in waveform) signals assigned using blocked assignments in a clocked always block.


//--------------------------------------------------
always @(negedge CLK) // due to writing at negative edge, internal forwarding became automatic!
  begin : RegFile_Block
	if (WB_WRITE)
	begin
	   reg_file[WB_RA] <= WB_RD;
	end
  end
//--------------------------------------------------
always @(posedge CLK, negedge RSTB)

  begin : Main_Clocked_Block 	
 						   
	if (RSTB == 1'b0)
	  begin
		STALL_Q <= 1'b0; 
		// IF stage
		PC_OUT <= 8'h00;
		
		// ID Stage
		// Notice: ID_XD is not a physical register. So do not initalize it (no need to write "ID_XD <= 16'hXXXX;")
		//          and later do not assign to it using a non-blocking assignment.	
		// 			Similarly ID_XMEX1, ID_XMEX2, and STALL are not physical registers.	So no initialization for these also.	
		ID_XA <= 4'hX; 
		ID_RA <= 4'hX;
		ID_INSTR <= 32'h00000000; // we could put 32'hXXXXXXXX but, we want to report a NOP in TimeSpace.txt
		ID_MOV  <= 1'b0;
		ID_SUB3 <= 1'b0; 
		ID_ADD4 <= 1'b0; 
		ID_ADD1 <= 1'b0; 
		// please notice that the control signals (ID_MOV, etc.) are inactivated to make sure
		// that a BUBBLE occupies the stage during reset. When control signals
		// are turned to zero, data can be don't care. See "EX1_XD <= 16'hXXXX;" below.
		
		// EX1 Stage
		EX12_XD <= 16'hXXXX;
		EX12_RA <= 4'hX;
		EX12_INSTR <= 32'h00000000; // we could put 32'hXXXXXXXX but, we want to report a NOP in TimeSpace.txt
		EX12_MOV  <= 1'b0;
		EX12_SUB3 <= 1'b0; 
		EX12_ADD4 <= 1'b0; 
		EX12_ADD1 <= 1'b0; 
		EX12_XMEX12 <= 1'bX;
		
		// WB Stage
		WB_RD <= 16'hXXXX;
		WB_INSTR <= 32'h00000000; // we could put 32'hXXXXXXXX but, we want to report a NOP in TimeSpace.txt
		WB_RA <= 4'hX;
		WB_WRITE <= 1'b0; // to see that a BUBBLE occupies the WB stage initially

	  end	
	  
	else // else if posedge CLK
	
	  begin
		ID_XMEX12 = (ID_XA == EX12_RA);
		STALL_Q	 <= EX12_ADD1&(~STALL_Q);
		STALL= EX12_ADD1&(~STALL_Q);
		if (~(EX12_ADD1&(~STALL_Q))) // if STALL is *not* true, the PC and the IF/ID registers may be updated.
			begin
			// PC
				PC_OUT <= PC_OUT + 1;

			// IF stage logic and IF_ID stage register
				IF_INSTR = memory[PC_OUT[5:0]]; // instruction is read from the instruction memory using blocking assignment
				// IF_ID stage register
				ID_XA <= IF_INSTR[3:0]; 
				ID_RA <= IF_INSTR[7:4];
				ID_MOV  <= IF_INSTR[31];
				ID_SUB3 <= IF_INSTR[30]; 
				ID_ADD4 <= IF_INSTR[29]; 
				ID_ADD1 <= IF_INSTR[28]; 
				ID_INSTR <= IF_INSTR; // carry the instruction for reverse assembling and displaying in Time-Space diagram

			// ID stage logic and ID_EX1 stage register
				// ID stage logic
				ID_XD = reg_file[ID_XA]; // register content is read from the register file using blocking assignment
				
				EX12_XD <= ID_XD;
				EX12_RA <= ID_RA;
				EX12_MOV <=   ID_MOV;
				EX12_SUB3 <=  ID_SUB3; 
				EX12_ADD4 <=  ID_ADD4;
				EX12_ADD1 <=  ID_ADD1;
				EX12_XMEX12 <= ID_XMEX12;
				EX12_INSTR <= ID_INSTR;
			
			// EX12 stage logic and EX2_WB stage register
				// EX12 stage logic
				FORW =(EX12_MOV | EX12_SUB3 | EX12_ADD4 | EX12_ADD1)& EX12_XMEX12 & WB_WRITE;
				if (FORW)
					EX12_SUB3_IN = WB_RD;
				else
					EX12_SUB3_IN = EX12_XD;

				EX12_SUB3_OUT = EX12_SUB3_IN + (-3); // sub 3
				SKIP1 = (~(EX12_SUB3 | EX12_ADD1)); // notice the blocking assignment
				if (SKIP1 == 1)
					EX12_ADD4_IN= EX12_SUB3_IN; // notice the non-blocking assignment
				else
					EX12_ADD4_IN= EX12_SUB3_OUT; // notice the non-blocking assignment

				EX12_ADD4_OUT= EX12_ADD4_IN + 4;  //add 4
				SKIP2 = ~(EX12_ADD1 | EX12_ADD4);
				if (SKIP2)
					EX12_XD_OUT = EX12_ADD4_IN;
				else			
					EX12_XD_OUT = EX12_ADD4_OUT;
				// EX12_WB stage register
				WB_RD <= EX12_XD_OUT;
				WB_RA <= EX12_RA;
				WB_WRITE <= EX12_MOV | EX12_SUB3 | EX12_ADD4 | EX12_ADD1;	
				WB_INSTR <= EX12_INSTR; // carry the instruction for reverse assembling and displaying in Time-Space diagram

				
			// WB stage logic 
				end // end~  if(~stall)
				
			end
		// stall...do nothing
	  
  end

//--------------------------------------------------
endmodule
