// ================================================================
// ID2 -> EX PIPELINE REGISTER
// ================================================================
module ID2_EX_reg(
    input clk, input rst, input flush,
    input [31:0] PC_ID2,
    input [31:0] rs1_data_ID2, input [31:0] rs2_data_ID2, input [31:0] imm_ID2,
    input [4:0] rs1_ID2, input [4:0] rs2_ID2, input [4:0] rd_ID2,
    input [2:0] func3_ID2, input func7_6_ID2, input valid_ID2,
    input RegWrite_ID2, input MemWrite_ID2, input MemRead_ID2,
    input Branch_ID2, input jump_ID2, input [1:0] Writebacksel_ID2,
    input [2:0] ALU_op_ID2, input [1:0] ALUsrcA_ID2, input ALUsrcB_ID2,

    output reg [31:0] PC_EX,
    output reg [31:0] rs1_data_EX, output reg [31:0] rs2_data_EX,
    output reg [31:0] imm_EX, output reg [4:0] rs1_EX, output reg [4:0] rs2_EX,
    output reg [4:0] rd_EX, output reg [2:0] func3_EX, output reg func7_6_EX,
    output reg valid_EX,
    output reg RegWrite_EX, output reg MemWrite_EX, output reg MemRead_EX,
    output reg Branch_EX, output reg jump_EX, output reg [1:0] Writebacksel_EX,
    output reg [2:0] ALU_op_EX, output reg [1:0] ALUsrcA_EX, output reg ALUsrcB_EX
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            PC_EX <= 32'd0;
            rs1_data_EX <= 32'd0; rs2_data_EX <= 32'd0; imm_EX <= 32'd0;
            rs1_EX <= 5'd0; rs2_EX <= 5'd0; rd_EX <= 5'd0;
            func3_EX <= 3'd0; func7_6_EX <= 1'b0; valid_EX <= 1'b0;
            RegWrite_EX <= 1'b0; MemWrite_EX <= 1'b0; MemRead_EX <= 1'b0;
            Branch_EX <= 1'b0; jump_EX <= 1'b0; Writebacksel_EX <= 2'b00;
            ALU_op_EX <= 3'b000; ALUsrcA_EX <= 2'b00; ALUsrcB_EX <= 1'b0;
        end
        else begin
            PC_EX <= PC_ID2;
            rs1_data_EX <= rs1_data_ID2; rs2_data_EX <= rs2_data_ID2;
            imm_EX <= imm_ID2; rs1_EX <= rs1_ID2; rs2_EX <= rs2_ID2; rd_EX <= rd_ID2;
            func3_EX <= func3_ID2; func7_6_EX <= func7_6_ID2; valid_EX <= valid_ID2;
            RegWrite_EX <= RegWrite_ID2; MemWrite_EX <= MemWrite_ID2;
            MemRead_EX <= MemRead_ID2; Branch_EX <= Branch_ID2; jump_EX <= jump_ID2;
            Writebacksel_EX <= Writebacksel_ID2; ALU_op_EX <= ALU_op_ID2;
            ALUsrcA_EX <= ALUsrcA_ID2; ALUsrcB_EX <= ALUsrcB_ID2;
        end
    end
endmodule