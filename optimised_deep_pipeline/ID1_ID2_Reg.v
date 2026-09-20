// ================================================================
// ID1 -> ID2 PIPELINE REGISTER
// ================================================================
module ID1_ID2_reg(
    input clk, input rst, input write_enable, input flush,
    input [31:0] PC_ID1,
    input [4:0] rs1_ID1, input [4:0] rs2_ID1, input [4:0] rd_ID1,
    input [2:0] func3_ID1, input func7_6_ID1, input [31:0] IR_ID1,
    input valid_ID1,
    input RegWrite_ID1, input MemWrite_ID1, input MemRead_ID1,
    input Branch_ID1, input jump_ID1, input [1:0] Writebacksel_ID1,
    input [2:0] ALU_op_ID1, input [1:0] ALUsrcA_ID1, input ALUsrcB_ID1,

    output reg [31:0] PC_ID2,
    output reg [4:0] rs1_ID2, output reg [4:0] rs2_ID2, output reg [4:0] rd_ID2,
    output reg [2:0] func3_ID2, output reg func7_6_ID2, output reg [31:0] IR_ID2,
    output reg valid_ID2,
    output reg RegWrite_ID2, output reg MemWrite_ID2, output reg MemRead_ID2,
    output reg Branch_ID2, output reg jump_ID2, output reg [1:0] Writebacksel_ID2,
    output reg [2:0] ALU_op_ID2, output reg [1:0] ALUsrcA_ID2, output reg ALUsrcB_ID2
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            PC_ID2 <= 32'd0;
            rs1_ID2 <= 5'd0; rs2_ID2 <= 5'd0; rd_ID2 <= 5'd0;
            func3_ID2 <= 3'd0; func7_6_ID2 <= 1'b0; IR_ID2 <= 32'h00000013;
            valid_ID2 <= 1'b0;
            RegWrite_ID2 <= 1'b0; MemWrite_ID2 <= 1'b0; MemRead_ID2 <= 1'b0;
            Branch_ID2 <= 1'b0; jump_ID2 <= 1'b0; Writebacksel_ID2 <= 2'b00;
            ALU_op_ID2 <= 3'b000; ALUsrcA_ID2 <= 2'b00; ALUsrcB_ID2 <= 1'b0;
        end
        else if (write_enable) begin
            PC_ID2 <= PC_ID1;
            rs1_ID2 <= rs1_ID1; rs2_ID2 <= rs2_ID1; rd_ID2 <= rd_ID1;
            func3_ID2 <= func3_ID1; func7_6_ID2 <= func7_6_ID1; IR_ID2 <= IR_ID1;
            valid_ID2 <= valid_ID1;
            RegWrite_ID2 <= RegWrite_ID1; MemWrite_ID2 <= MemWrite_ID1;
            MemRead_ID2 <= MemRead_ID1; Branch_ID2 <= Branch_ID1; jump_ID2 <= jump_ID1;
            Writebacksel_ID2 <= Writebacksel_ID1; ALU_op_ID2 <= ALU_op_ID1;
            ALUsrcA_ID2 <= ALUsrcA_ID1; ALUsrcB_ID2 <= ALUsrcB_ID1;
        end
    end
endmodule