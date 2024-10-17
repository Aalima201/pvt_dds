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
    input wire R1, R2, R3, R4, R5,       // R : Random Input bits
    input wire E1, E2, E3, E4, E5,       // E : Expected Output bits
    output wire O1, O2, O3, O4, O5,      // O : Actual Output bits
    output wire LEVEL1_PASSED            // Equals to one if Level 1 is passed
);
    wire notE5, x2, R2S0, R2E, MUXR2,notR2_eq_E1;
    wire x3, R3S0, R3E, MUXR3;
    wire x4, R4S0, R4E, MUXR4;

    // Not gate for E5
    not(notE5, E5);

    // Assign expected outputs
    assign E1 = 1;
    assign E2 = 1;
    assign E3 = 1;
    assign E4 = 1;
    assign E5 = 0;

    // Output O1 is directly R1
    assign O1 = R1;

    // Logic for R2
    wire R2_eq_E1; // R2 should match E1
    xor(R2_eq_E1, R1, E1);
    not(notR2_eq_E1,R2_eq_E1);
    and(x2, R2, notR2_eq_E1); // x2 = R2 & ~ (R1 ^ E1)
    xor(R2S0, x2, E2);
    and(R2E, notR2_eq_E1, 1'b1); // R2E = ~(R1 ^ E1)
    assign MUXR2 = (R2E) ? (R2S0 ? E2 : x2) : 1'b0; // MUX for R2 correction
    assign O2 = MUXR2;

    // Logic for R3
    wire R3_and_MUXR2;
    and(R3_and_MUXR2, R3, MUXR2);
    xor(R3S0, R3_and_MUXR2, E3);
    and(R3E, MUXR2, 1'b1); // R3E = MUXR2
    assign MUXR3 = (R3E) ? (R3S0 ? E3 : R3_and_MUXR2) : 1'b0; // MUX for R3 correction
    assign O3 = MUXR3;

    // Logic for R4
    wire R4_and_MUXR3;
    and(R4_and_MUXR3, R4, MUXR3);
    xor(R4S0, R4_and_MUXR3, E4);
    and(R4E, MUXR3, 1'b1); // R4E = MUXR3
    assign MUXR4 = (R4E) ? (R4S0 ? E4 : R4_and_MUXR3) : 1'b0; // MUX for R4 correction
    assign O4 = MUXR4;

    // Output O5 is directly R5 (non-essential subsystem)
    assign O5 = R5;

    // Passing condition for Level 1
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

    // Instantiate the LFSR module (assumed)
    lfsr_5bit lfsr_inst (
        .clk(clk),
        .rst(rst),
        .lfsr_out(lfsr_out)
    );

    // Assign LFSR outputs to the random input bits
    assign R1L2 = lfsr_out[0];
    assign R2L2 = lfsr_out[1];
    assign R3L2 = lfsr_out[2];
    assign R4L2 = lfsr_out[3];
    assign R5L2 = lfsr_out[4];

    wire notE5, x2, R2S0, R2E, MUXR2,notR2_eq_E1L2;
    wire x3, R3S0, R3E, MUXR3;
    wire x4, R4S0, R4E, MUXR4;

    // Not gate for E5L2
    not(notE5, E5L2);

    // Assign expected outputs
    assign E1L2 = 1;
    assign E2L2 = 1;
    assign E3L2 = 1;
    assign E4L2 = 0;
    assign E5L2 = 0;

    // Output O1L2 is directly R1L2
    assign O1L2 = R1L2;

    // Logic for R2L2
    wire R2_eq_E1L2;
    xor(R2_eq_E1L2, R1L2, E1L2);
    not(notR2_eq_E1L2,R2_eq_E1L2);
    and(x2, R2L2,notR2_eq_E1L2); // x2 = R2L2 & ~ (R1L2 ^ E1L2)
    xor(R2S0, x2, E2L2);
    and(R2E,notR2_eq_E1L2, 1'b1); // R2E = ~(R1L2 ^ E1L2)
    assign MUXR2 = (R2E) ? (R2S0 ? E2L2 : x2) : 1'b0; // MUX for R2 correction
    assign O2L2 = MUXR2;

    // Logic for R3L2
    wire R3_and_MUXR2;
    and(R3_and_MUXR2, R3L2, MUXR2);
    xor(R3S0, R3_and_MUXR2, E3L2);
    and(R3E, MUXR2, 1'b1); // R3E = MUXR2
    assign MUXR3 = (R3E) ? (R3S0 ? E3L2 : R3_and_MUXR2) : 1'b0; // MUX for R3 correction
    assign O3L2 = MUXR3;

    // Logic for R4L2
    wire R4_and_MUXR3;
    and(R4_and_MUXR3, R4L2, MUXR3);
    xor(R4S0, R4_and_MUXR3, E4L2);
    and(R4E, SWITCH1L2, 1'b1); // R4E = SWITCH1L2
    assign MUXR4 = (R4E) ? (R4S0 ? E4L2 : R4_and_MUXR3) : 1'b0; // MUX for R4 correction
    assign O4L2 = MUXR4;

    // Output O5L2 is directly R5L2
    assign O5L2 = R5L2;

    // Condition for R4L2 if the user wants to switch the subsystem off
    assign userR4L2 = SWITCH1L2 ? 1 : 0;
    assign O4L2 = userR4L2 ? 0 : R4L2;

    // Passing condition for Level 2
    assign LEVEL2_PASSED = O1L2 & O2L2 & O3L2;

endmodule
module level3(
    input wire clk,          // Clock input
    input wire rst,          // Reset input
    input wire E1L3, E2L3, E3L3, E4L3, E5L3,  // E: Expected Output bits
    input wire SWITCH1L3,    // Switch input for controlling R4L3
    input wire SWITCH2L3,    // Switch input for controlling R3L3
    output wire O1L3, O2L3, O3L3, O4L3, O5L3, // O: Actual Output bits
    output wire LEVEL3_PASSED, // Equals 1 if Level 3 is passed
    output wire userR4L3,     // Output for turning on/off subsystem R4
    output wire userR3L3      // Output for turning on/off subsystem R3
);

    wire [4:0] lfsr_out;    // Output from the LFSR
    wire R1L3, R2L3, R3L3, R4L3, R5L3; // Random input bits taken from LFSR output

    // Instantiate the LFSR module (assumed)
    lfsr_5bit lfsr_inst (
        .clk(clk),
        .rst(rst),
        .lfsr_out(lfsr_out)
    );

    // Assign LFSR outputs to the random input bits
    assign R1L3 = lfsr_out[0];
    assign R2L3 = lfsr_out[1];
    assign R3L3 = lfsr_out[2];
    assign R4L3 = lfsr_out[3];
    assign R5L3 = lfsr_out[4];

    wire notE5, x2, R2S0, R2E, MUXR2,notR2_eq_E1L3;
    wire x3, R3S0, R3E, MUXR3;
    wire x4, R4S0, R4E, MUXR4;

    // Not gate for E5L3
    not(notE5, E5L3);

    // Assign expected outputs
    assign E1L3 = 1;
    assign E2L3 = 1;
    assign E3L3 = 1;
    assign E4L3 = 0;
    assign E5L3 = 0;

    // Output O1L3 is directly R1L3
    assign O1L3 = R1L3;

    // Logic for R2L3
    wire R2_eq_E1L3;
    xor(R2_eq_E1L3, R1L3, E1L3);
    not(notR2_eq_E1L3,R2_eq_E1L3);
    and(x2, R2L3,notR2_eq_E1L3); // x2 = R2L3 & ~ (R1L3 ^ E1L3)
    xor(R2S0, x2, E2L3);
    and(R2E, notR2_eq_E1L3, 1'b1); // R2E = ~(R1L3 ^ E1L3)
    assign MUXR2 = (R2E) ? (R2S0 ? E2L3 : x2) : 1'b0; // MUX for R2 correction
    assign O2L3 = MUXR2;

    // Logic for R3L3
    wire R3_and_MUXR2;
    and(R3_and_MUXR2, R3L3, MUXR2);
    xor(R3S0, R3_and_MUXR2, E3L3);
    and(R3E, MUXR2, 1'b1); // R3E = MUXR2
    assign userR3L3 = SWITCH2L3 ? 1 : 0;
    assign O3L3 = userR3L3 ? 0 : R3L3; // User control switch for R3L3
    assign MUXR3 = (R3E) ? (R3S0 ? E3L3 : R3_and_MUXR2) : 1'b0; // MUX for R3 correction
    assign O3L3 = MUXR3;

    // Logic for R4L3
    wire R4_and_MUXR3;
    and(R4_and_MUXR3, R4L3, MUXR3);
    xor(R4S0, R4_and_MUXR3, E4L3);
    and(R4E, SWITCH1L3, 1'b1); // R4E = SWITCH1L3
    assign userR4L3 = SWITCH1L3 ? 1 : 0;
    assign O4L3 = userR4L3 ? 0 : R4L3; // User control switch for R4L3
    assign MUXR4 = (R4E) ? (R4S0 ? E4L3 : R4_and_MUXR3) : 1'b0; // MUX for R4 correction
    assign O4L3 = MUXR4;

    // Output O5L3 is directly R5L3
    assign O5L3 = R5L3;

    // Passing condition for Level 3
    assign LEVEL3_PASSED = O1L3 & O2L3; 

endmodule
