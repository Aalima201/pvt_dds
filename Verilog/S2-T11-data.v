module lfsr_5bit (
    input clk,    // Clock input
    input rst,    // Reset input
    output reg [4:0] lfsr_out  // 5-bit output
);

    wire feedback;

    // Feedback is taken from bits 5 and 3 (tap positions 4 and 2 in Verilog, 0-indexed)
    assign feedback = ~(lfsr_out[4] ^ lfsr_out[2]); 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // On reset, set LFSR to a non-zero seed value
            lfsr_out <= 5'b00001;
        end else begin
            // Shift the LFSR and insert the feedback bit at position 4
            lfsr_out <= {lfsr_out[3:0], feedback};
        end
    end

endmodule

module level1(
    input wire R1, R2, R3, R4, R5,       //R : Random Input bits
    input wire E1, E2, E3, E4, E5,       //E : Expected Output bits
    output wire O1, O2, O3, O4, O5,      //O : Actual Output bits
    output wire LEVEL1_PASSED            //Equals to one if Level 1 is passed
);

    wire notE5, x2, R2S0, R2I0, R2I1, R2E, MUXR2, x3, R3S0, R3I0, R3I1, R3E, MUXR3, x4, R4S0, R4I0, R4I1, R4E, MUXR4;

    // Not gate for E5
    assign notE5 = ~E5;

    assign E1=1;
    assign E2=1;
    assign E3=1;
    assign E4=1;
    assign E5=0;

    // Output O1 is directly R1
    assign O1 = R1;

    // Logic for R2
    assign x2 = R2 & (~(R1 ^ E1));
    assign R2S0 = x2 ^ E2;
    assign R2I0 = x2; 
    assign R2I1 = E2;
    assign R2E = ~(R1 ^ E1);
    assign MUXR2 = R2E ? (R2S0 ? R2I1 : R2I0) : 1'b0; //Checking the R2 and  correcting it, if it's wrong
    assign O2 = MUXR2; //R2 after correction

    // Logic for R3
    assign x3 = R3 & MUXR2;
    assign R3S0 = x3 ^ E3;
    assign R3I0 = x3;
    assign R3I1 = E3;
    assign R3E = MUXR2;
    assign MUXR3 = R3E ? (R3S0 ? R3I1 : R3I0) : 1'b0; //Checking the R3 and  correcting it, if it's wrong
    assign O3 = MUXR3; //R3 after correction

    // Logic for R4
    assign x4 = R4 & MUXR3;
    assign R4S0 = x4 ^ E4;
    assign R4I0 = x4;
    assign R4I1 = E4;
    assign R4E = MUXR3;
    assign MUXR4 = R4E ? (R4S0 ? R4I1 : R4I0) : 1'b0; //Checking the R4 and  correcting it, if it's wrong
    assign O4 = MUXR4; //R4 after correction

    // Output O5 is directly R5
    //Since R5 is non-essential subsystem
    assign O5 = R5;

    // Passing condition for Level 1 :
    //All crucial subsystems(O1,O2,O3,O4) should be working
    assign LEVEL1_PASSED = O1 & O2 & O3 & O4; 

endmodule
module level2(
    input wire clk,          // Clock input
    input wire rst,          // Reset input
    input wire E1L2, E2L2, E3L2, E4L2, E5L2, // E: Expected Output bits
    input wire SWITCH1L2,    // Switch input for controlling R4L2
    output wire O1L2, O2L2, O3L2, O4L2, O5L2, // O: Actual Output bits
    output wire LEVEL2_PASSED, // Equals 1 if Level 2 is passed
    output wire userR4L2     // Output for turning on/off subsystem R4
);

    wire [4:0] lfsr_out;    // Output from the LFSR
    wire R1L2, R2L2, R3L2, R4L2, R5L2; // Random input bits taken from LFSR output

    // Instantiate the LFSR module
    lfsr_5bit lfsr_inst (
        .clk(clk),
        .rst(rst),
        .lfsr_out(lfsr_out)
    );

    // Assign LFSR outputs to the random input bits R1L2 to R5L2
    assign R1L2 = lfsr_out[0];
    assign R2L2 = lfsr_out[1];
    assign R3L2 = lfsr_out[2];
    assign R4L2 = lfsr_out[3];
    assign R5L2 = lfsr_out[4];

    wire notE5, x2, R2S0, R2I0, R2I1, R2E, MUXR2, x3, R3S0, R3I0, R3I1, R3E, MUXR3, x4, R4S0, R4I0, R4I1, R4E, MUXR4;

    // Not gate for E5L2
    assign notE5 = ~E5L2;

    assign E2L2=1;
    assign E1L2=1;
    assign E3L2=1;
    assign E4L2=0;
    assign E5L2=0;

    // Output O1L2 is directly R1L2
    assign O1L2 = R1L2;

    // Logic for R2L2
    assign x2 = R2L2 & (~(R1L2 ^ E1L2));
    assign R2S0 = x2 ^ E2L2;
    assign R2I0 = x2; // Correcting the undefined x1
    assign R2I1 = E2L2;
    assign R2E = ~(R1L2 ^ E1L2);
    assign MUXR2 = R2E ? (R2S0 ? R2I1 : R2I0) : 1'b0;   //Checking the R2L2 and  correcting it, if it's wrong
    assign O2L2 = MUXR2;  //R2L2 after correction


    // Logic for R3L2
    assign x3 = R3L2 & MUXR2;
    assign R3S0 = x3 ^ E3L2;
    assign R3I0 = x3;
    assign R3I1 = E3L2;
    assign R3E = MUXR2;
    assign MUXR3 = R3E ? (R3S0 ? R3I1 : R3I0) : 1'b0;  //Checking the R3 and  correcting it, if it's wrong
    assign O3L2 = MUXR3;  //R3L2 after correction

    // Logic for R4L2
    assign x4 = R4L2 & MUXR3;
    assign R4S0 = x4 ^ E4L2;
    assign R4I0 = x4;
    assign R4I1 = E4L2;
    assign R4E = SWITCH1L2;
    assign MUXR4 = R4E ? (R4S0 ? R4I1 : R4I0) : 1'b0;  //Checking the R4 and correcting it, if it's wrong
    assign O4L2 = MUXR4;  //R4L2 after correction

    // Output O5L2 is directly R5L2
    assign O5L2 = R5L2;

    // Condition for R4L2 if the user wants to switch the subsystem off
    assign userR4L2 = (SWITCH1L2) ? 1 : 0;
    assign O4L2 = (userR4L2) ? 0 : R4L2;
    // Passing condition for Level 2:
    // All crucial subsystems (O1L2, O2L2, O3L2) should be working
    assign LEVEL2_PASSED = O1L2 & O2L2 & O3L2;
    

endmodule
// Level 3 Module that uses LFSR outputs as input
module level3(
    input wire clk,          // Clock input
    input wire rst,          // Reset input
    input wire E1L3, E2L3, E3L3, E4L3, E5L3,  // E: Expected Output bits
    input wire SWITCH1L3,    // Switch input for controlling R4L3
    input wire SWITCH2L3,    // Switch input for controlling R3L3
    output wire O1L3, O2L3, O3L3, O4L3, O5L3, // O: Actual Output bits
    output wire LEVEL3_PASSED, // Equals 1 if Level 3 is passed
    output wire userR4L3,    // Output for turning on/off subsystem R4L3
    output wire userR3L3     // Output for turning on/off subsystem R3L3
);

    wire [4:0] lfsr_out;    // Output from the LFSR
    wire R1L3, R2L3, R3L3, R4L3, R5L3; // Random input bits taken from LFSR output

    // Instantiate the LFSR module
    lfsr_5bit lfsr_inst (
        .clk(clk),
        .rst(rst),
        .lfsr_out(lfsr_out)
    );

    // Assign LFSR outputs to the random input bits R1L3 to R5L3
    assign R1L3 = lfsr_out[0];
    assign R2L3 = lfsr_out[1];
    assign R3L3 = lfsr_out[2];
    assign R4L3 = lfsr_out[3];
    assign R5L3 = lfsr_out[4];

    wire notE5, x2, R2S0, R2I0, R2I1, R2E, MUXR2, x3, R3S0, R3I0, R3I1, R3E, MUXR3, x4, R4S0, R4I0, R4I1, R4E, MUXR4;

    // Not gate for E5L3
    assign notE5 = ~E5L3;

    assign E1L3=1;
    assign E2L3=1;
    assign E3L3=0;
    assign E4L3=0;
    assign E5L3=0;



    // Output O1L3 is directly R1L3
    assign O1L3 = R1L3;

    // Logic for R2L3
    assign x2 = R2L3 & (~(R1L3 ^ E1L3));
    assign R2S0 = x2 ^ E2L3;
    assign R2I0 = x2; // Correcting the undefined x1
    assign R2I1 = E2L3;
    assign R2E = ~(R1L3 ^ E1L3);
    assign MUXR2 = R2E ? (R2S0 ? R2I1 : R2I0) : 1'b0;   //Checking the R2L3 and correcting it if it's wrong
    assign O2L3 = MUXR2;     //R2L3 after correction
    // Logic for R3L3
    assign x3 = R3L3 & MUXR2;
    assign R3S0 = x3 ^ E3L3;
    assign R3I0 = x3;
    assign R3I1 = E3L3;
    assign R3E = SWITCH2L3;
    assign MUXR3 = R3E ? (R3S0 ? R3I1 : R3I0) : 1'b0;   //Checking the R3L3 and correcting it if it's wrong  
    assign O3L3 = MUXR3;    //R3L3 after correction

    // Logic for R4L3
    assign x4 = R4L3 & MUXR3;
    assign R4S0 = x4 ^ E4L3;
    assign R4I0 = x4;
    assign R4I1 = E4L3;
    assign R4E = SWITCH1L3;
    assign MUXR4 = R4E ? (R4S0 ? R4I1 : R4I0) : 1'b0;   //Checking the R4L3 and correcting it if it's wrong
    assign O4L3 = MUXR4;  //R4L3 after correction

    // Output O5L3 is directly R5L3
    assign O5L3 = R5L3;

    // Conditions for switching subsystems R3L3 and R4L3 off
    assign userR3L3 = (SWITCH1L3) ? 1 : 0;
    assign userR4L3 = (SWITCH2L3) ? 1 : 0;
    assign O3L3 = (userR3L3) ? 0 : R3L3;
    assign O4L3 = (userR4L3) ? 0 : R4L3;

    // Passing condition for Level 3:
    // All crucial subsystems (O1L3, O2L3) should be working
     assign LEVEL3_PASSED = O1L3 & O2L3;
endmodule

