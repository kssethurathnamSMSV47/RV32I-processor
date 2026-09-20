// ================================================================
// IF1 -> IF2 PIPELINE REGISTER
// ================================================================
module IF1_IF2_reg(
    output reg [31:0] PC_IF2,
    output reg        valid_IF2,
    input      [31:0] PC_IF1,
    input             valid_IF1,
    input             clk,
    input             rst,
    input             write_enable,
    input             flush
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_IF2    <= 32'd0;
            valid_IF2 <= 1'b0;
        end
        else if (flush) begin
            PC_IF2    <= 32'd0;
            valid_IF2 <= 1'b0;
        end
        else if (write_enable) begin
            PC_IF2    <= PC_IF1;
            valid_IF2 <= valid_IF1;
        end
    end
endmodule