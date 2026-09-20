// ================================================================
// CONTROL HAZARD / REDIRECT UNIT
// Static-not-taken baseline because BPU is not integrated yet.
// ================================================================
module Branch_control_unit(
    input  branch_taken_EX,
    input  jump_EX,
    input  valid_EX,
    output flush
);
    assign flush = valid_EX && (branch_taken_EX || jump_EX);
endmodule