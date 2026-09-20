module Register_Bank(Rd_data1, Rd_data2, Wr_data, Rs1, Rs2, Rd, clk, rst, W_en, Rd_en);

    input clk, rst;
    input [4:0] Rs1, Rs2, Rd;
    input W_en, Rd_en;
    input [31:0] Wr_data;
    output reg [31:0] Rd_data1, Rd_data2;

    integer k;

    reg [31:0] Reg_mem [0:31];

    //assign Rd_data1 = Rd_en ? Reg_mem[Rs1] : 32'b0;
    //assign Rd_data2 = Rd_en ? Reg_mem[Rs2] : 32'b0;

    always @(*)
    begin
        if(Rd_en)
         begin
            Rd_data1 = (Rs1 == 0) ? 32'd0 : Reg_mem[Rs1];
            Rd_data2 = (Rs2 == 0) ? 32'd0 : Reg_mem[Rs2];
         end
        else begin
            Rd_data1 = 32'd0;
            Rd_data2 = 32'd0;
        end
    end

    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            for(k=0;k<32;k=k+1)
            begin
                Reg_mem[k] <= 0;
            end
        end
        else begin
            if(W_en && (Rd != 0))
            begin
                Reg_mem[Rd] <= Wr_data;
            end
        end
    end

endmodule