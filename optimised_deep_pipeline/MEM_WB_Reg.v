// ================================================================
// MEM -> WB PIPELINE REGISTER
// ================================================================
module MEM_WB_reg(
    input clk,
    input rst,
    input        valid_MEM,
    input [31:0] ALU_result_MEM,
    input [31:0] Mem_data_MEM,
    input [31:0] PC_plus4_MEM,
    input [4:0]  rd_MEM,
    input        RegWrite_MEM,
    input [1:0]  Writebacksel_MEM,

    output reg        valid_WB,
    output reg [31:0] ALU_result_WB,
    output reg [31:0] Mem_data_WB,
    output reg [31:0] PC_plus4_WB,
    output reg [4:0]  rd_WB,
    output reg        RegWrite_WB,
    output reg [1:0]  Writebacksel_WB
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_WB <= 0;
            ALU_result_WB <= 0;
            Mem_data_WB <= 0;
            PC_plus4_WB <= 0;
            rd_WB <= 0;
            RegWrite_WB <= 0;
            Writebacksel_WB <= 0;
        end
        else begin
            valid_WB <= valid_MEM;
            ALU_result_WB <= ALU_result_MEM;
            Mem_data_WB <= Mem_data_MEM;
            PC_plus4_WB <= PC_plus4_MEM;
            rd_WB <= rd_MEM;
            RegWrite_WB <= RegWrite_MEM;
            Writebacksel_WB <= Writebacksel_MEM;
        end
    end
endmodule