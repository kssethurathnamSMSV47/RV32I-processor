// ================================================================
// IF2 -> ID1 PIPELINE REGISTER
// ================================================================
module IF2_ID1_reg(
    output reg [31:0] IR_ID1,
    output reg [31:0] PC_ID1,
    output reg        valid_ID1,
    input      [31:0] Instruction_IF2,
    input      [31:0] PC_IF2,
    input             valid_IF2,
    input             clk,
    input             rst,
    input             write_enable,
    input             flush
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            IR_ID1       <= 32'h00000013;
            PC_ID1       <= 32'd0;
            valid_ID1    <= 1'b0;
        end
        else if (flush) begin
            IR_ID1       <= 32'h00000013;
            PC_ID1       <= 32'd0;
            valid_ID1    <= 1'b0;
        end
        else if (write_enable) begin
            IR_ID1       <= Instruction_IF2;
            PC_ID1       <= PC_IF2;
            valid_ID1    <= valid_IF2;
        end
    end
endmodule