module instruction_mem(instruction, pc_addr, clk, rst, rd_en,
wr_en, wr_addr, wr_data_in);

    input [31:0] pc_addr;
    input clk, rst, rd_en, wr_en;
    input [31:0] wr_addr;
    input [31:0] wr_data_in;
    output reg [31:0] instruction;

    reg [7:0] IMEM [0:4095];

    wire [11:0] rd_idx;
    wire [11:0] wr_idx;

    assign rd_idx = pc_addr[11:0];
    assign wr_idx = wr_addr[11:0];

    integer i;

    always @(*)
    begin
        if(rd_en)
        begin
            instruction = {
                IMEM[rd_idx[11:0] + 12'd3],
                IMEM[rd_idx[11:0] + 12'd2],
                IMEM[rd_idx[11:0] + 12'd1],
                IMEM[rd_idx[11:0]]
            };
        end
        else begin
            instruction = 32'b0;
        end
    end

    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            for(i=0;i<4096;i=i+1)
            begin
                IMEM[i] <= 0;
            end
        end
        else begin
            if(wr_en)
            begin
                IMEM[wr_idx[11:0]]     <= wr_data_in[7:0];
                IMEM[wr_idx[11:0] + 1] <= wr_data_in[15:8];
                IMEM[wr_idx[11:0] + 2] <= wr_data_in[23:16];
                IMEM[wr_idx[11:0] + 3] <= wr_data_in[31:24];
            end
        end
    end

endmodule