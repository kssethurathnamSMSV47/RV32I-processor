module PC(PC_out, PC_in, clk, rst, PC_hold);

    input [31:0] PC_in;
    input clk, rst, PC_hold;
    output reg [31:0] PC_out;

    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            PC_out <= 0;
        end
        else begin
            if(!PC_hold) PC_out <= PC_in;
        end
    end

endmodule