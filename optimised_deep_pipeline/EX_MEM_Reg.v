// ================================================================
// EX -> MEM PIPELINE REGISTER
// ================================================================
module EX_MEM_reg(
    input clk,
    input rst,
    input        valid_EX,
    input [31:0] ALU_result_EX,
    input [31:0] store_data_EX,
    input [4:0]  rd_EX,
    input        RegWrite_EX,
    input        MemWrite_EX,
    input        MemRead_EX,
    input [1:0]  Writebacksel_EX,
    input [2:0] func3_EX,
    input [31:0] PC_EX,

    output reg        valid_MEM,
    output reg [31:0] ALU_result_MEM,
    output reg [31:0] store_data_MEM,
    output reg [4:0]  rd_MEM,
    output reg        RegWrite_MEM,
    output reg        MemWrite_MEM,
    output reg        MemRead_MEM,
    output reg [1:0]  Writebacksel_MEM,
    output reg [2:0] func3_MEM,
    output reg [31:0] PC_MEM
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_MEM <= 0;
            ALU_result_MEM <= 0;
            store_data_MEM <= 0;
            rd_MEM <= 0;
            RegWrite_MEM <= 0;
            MemWrite_MEM <= 0;
            MemRead_MEM <= 0;
            Writebacksel_MEM <= 0;
            func3_MEM <= 0;
            PC_MEM <= 0;
        end
        else begin
            valid_MEM <= valid_EX;
            ALU_result_MEM <= ALU_result_EX;
            store_data_MEM <= store_data_EX;
            rd_MEM <= rd_EX;
            RegWrite_MEM <= RegWrite_EX;
            MemWrite_MEM <= MemWrite_EX;
            MemRead_MEM <= MemRead_EX;
            Writebacksel_MEM <= Writebacksel_EX;
            func3_MEM <= func3_EX;
            PC_MEM <= PC_EX;
        end
    end
endmodule