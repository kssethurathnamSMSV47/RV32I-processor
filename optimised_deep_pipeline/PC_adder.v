module PC_adder(PC_plus4, PC_in);

    input [31:0] PC_in;
    output [31:0] PC_plus4;

    assign PC_plus4 = PC_in + 4;

endmodule