// ================================================================
// FORWARDING UNIT
//
// EX stage:
//   00 = register/previously captured operand
//   01 = ALU result from MEM
//   10 = WB result
//
// ID2 stage:
//   0  = register-file read
//   1  = WB result bypassed directly into ID2
//
// Priority for EX is MEM > WB. Loads are never forwarded from MEM
// because their data is not available there in this implementation.
// ================================================================
module forwarding_unit(
    input  [4:0] rs1_EX,
    input  [4:0] rs2_EX,

    input        valid_MEM,
    input  [4:0] rd_MEM,
    input        RegWrite_MEM,
    input        MemRead_MEM,

    input        valid_WB,
    input  [4:0] rd_WB,
    input        RegWrite_WB,

    input  [4:0] rs1_ID2,
    input  [4:0] rs2_ID2,
    input        uses_rs1_ID2,
    input        uses_rs2_ID2,

    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB,
    output reg       ForwardA_ID2,
    output reg       ForwardB_ID2
);

    // ------------------------------------------------------------
    // EX operand A: MEM has priority over WB
    // ------------------------------------------------------------
    always @(*) begin
        ForwardA = 2'b00;

        if (valid_MEM && RegWrite_MEM && !MemRead_MEM &&
            (rd_MEM != 5'd0) && (rd_MEM == rs1_EX)) begin
            ForwardA = 2'b01;
        end
        else if (valid_WB && RegWrite_WB &&
                 (rd_WB != 5'd0) && (rd_WB == rs1_EX)) begin
            ForwardA = 2'b10;
        end
    end

    // ------------------------------------------------------------
    // EX operand B: MEM has priority over WB
    // ------------------------------------------------------------
    always @(*) begin
        ForwardB = 2'b00;

        if (valid_MEM && RegWrite_MEM && !MemRead_MEM &&
            (rd_MEM != 5'd0) && (rd_MEM == rs2_EX)) begin
            ForwardB = 2'b01;
        end
        else if (valid_WB && RegWrite_WB &&
                 (rd_WB != 5'd0) && (rd_WB == rs2_EX)) begin
            ForwardB = 2'b10;
        end
    end

    // ------------------------------------------------------------
    // WB -> ID2 operand A bypass
    // ------------------------------------------------------------
    always @(*) begin
        ForwardA_ID2 = 1'b0;

        if (uses_rs1_ID2 &&
            valid_WB && RegWrite_WB &&
            (rd_WB != 5'd0) && (rd_WB == rs1_ID2)) begin
            ForwardA_ID2 = 1'b1;
        end
    end

    // ------------------------------------------------------------
    // WB -> ID2 operand B bypass
    // ------------------------------------------------------------
    always @(*) begin
        ForwardB_ID2 = 1'b0;

        if (uses_rs2_ID2 &&
            valid_WB && RegWrite_WB &&
            (rd_WB != 5'd0) && (rd_WB == rs2_ID2)) begin
            ForwardB_ID2 = 1'b1;
        end
    end

endmodule