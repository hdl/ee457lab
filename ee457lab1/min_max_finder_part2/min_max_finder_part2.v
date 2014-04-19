// EE457 RTL Exercises
// min_max_finder_part2.v (Part 2 uses one conparison units)
// Written by Nasir Mohyuddin, Gandhi Puvvada 
// June 2, 2010, 
// Given an array of 16 unsigned 8-bit numbers, we need to find the maximum and the minimum number
 

`timescale 1 ns / 100 ps

module min_max_finder_part2 (Max, Min, Start, Clk, Reset, 
				           Qi, Ql, Qcmx, Qcmn, Qd);

input Start, Clk, Reset;
output [7:0] Max, Min;
output Qi, Ql, Qcmx, Qcmn, Qd;

reg [7:0] M [0:15]; 
reg [4:0] state;
reg [7:0] Max;
reg [7:0] Min;
reg [3:0] I;

localparam 
INI  = 	5'b00001, // "Initial" state
LOAD = 	5'b00010, // "Load Max and Min with 1st Element" state
CMx = 	5'b00100, // "1st Compare with the Max and Update Max if needed" state
CMn = 	5'b01000, // "Next Compare with Min and Update Min if needed" state
DONE = 	5'b10000; // "Done finding Min and Max" state

         
         
assign {Qd, Qcmn, Qcmx, Ql, Qi} = state;

always @(posedge Clk, posedge Reset) 

  begin  : CU_n_DU
    if (Reset)
       begin
         state <= INI;
         I <= 4'bXXXX;
	      Max <= 8'bXXXXXXXX;
	      Min <= 8'bXXXXXXXX;
	    end
    else
       begin
           case (state)
	        INI	: 
	          begin
		         // state transitions in the control unit
		         if (Start)
		           state <= LOAD;
		         // RTL operations in the Data Path            	              
		         I <= 0;
	          end
	        LOAD	:
	          begin
		           // RTL operations in the Data Path  
                  Min<=M[I];
                  Max<=M[I];
                  I<=I+1;
		           // state transitions in the control unit
                  state <= CMx;

				   
 	          end
	        
	        CMx :
	          begin 
	             // RTL operations in the Data Path   		                  
               if(M[I]>=Max)
               begin
                  Max<=M[I];
                  I<=I+1;
               end

				 // state transitions in the control unit       
            if(M[I]<Max)
               state<=CMn;
            else if(I==15&&M[I]>=Max)
               state<=DONE;

			  end
	        CMn :
	          begin 
	          // RTL operations in the Data Path   		                  
            if(M[I]<Min)
            begin
               Min<=M[I];    
            end
            I<=I+1;
				 // state transitions in the control unit   
            if(I!=15)
               state<=CMx;
            else
               state<=DONE;

			  end
	        
	        DONE	:
	          begin  
		         // state transitions in the control unit
		           state <= INI; // Transit to INI state unconditionally
		       end    
      endcase
    end 
  end 
endmodule