// Engineee : K.S.SETHURATHNAM

module PC(
    input [31:0]PC_in,
    input Clk,
    input Reset,
    input PCWrite,
    
    output reg [31:0]PC_out
    );

always@(posedge Clk or negedge Reset) begin
    if(!Reset) begin
        PC_out <= 32'h00000000;
    end else if(PCWrite) begin
        PC_out <= PC_in;
    end
end
    
endmodule
