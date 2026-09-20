// ================================================================
// HAZARD DETECTION UNIT
//
// In this seven-stage pipeline the load is in EX while the dependent
// instruction is in ID2. One stall cycle is sufficient because after
// the stall the load reaches WB when the dependent instruction reaches EX.
// ================================================================
module hazard_detection_unit(
    input  [4:0] rs1_ID2,
    input  [4:0] rs2_ID2,
    input        uses_rs1_ID2,
    input        uses_rs2_ID2,
    input  [4:0] rd_EX,
    input        MemRead_EX,
    input        valid_EX,

    output       load_use_hazard,
    output       PCWrite,
    output       PC_IF2_Write,
    output       IF2_ID1_Write,
    output       ID1_ID2_Write,
    output       ID2_EX_Flush
);

    // Only an EX-stage load creates an unavoidable one-cycle RAW hazard.
    // ALU/JAL/JALR results are handled by forwarding, while WB->ID2 is
    // handled by the dedicated ID2 bypass in forwarding_unit.
    assign load_use_hazard =
        valid_EX &&
        MemRead_EX &&
        (rd_EX != 5'd0) &&
        (
            (uses_rs1_ID2 && (rd_EX == rs1_ID2)) ||
            (uses_rs2_ID2 && (rd_EX == rs2_ID2))
        );

    // Freeze the front end and inject one bubble into EX.
    assign PCWrite       = ~load_use_hazard;
    assign PC_IF2_Write  = ~load_use_hazard;
    assign IF2_ID1_Write = ~load_use_hazard;
    assign ID1_ID2_Write = ~load_use_hazard;
    assign ID2_EX_Flush  = load_use_hazard;

endmodule