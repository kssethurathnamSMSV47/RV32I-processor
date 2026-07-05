// Engineer : K.S.SETHURATHNAM
module instruction_mem(
    input  [31:0] read_addr,
    output [31:0] instruction
);

reg [31:0] instruction_reg [0:255];

initial begin
    $readmemh("program.mem", instruction_reg);
end

assign instruction = instruction_reg[read_addr[31:2]];

endmodule
