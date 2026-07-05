module processor_tb;

// Clock and Reset
reg Clk;
reg Reset;

processor RISC (
    .Clk(Clk),
    .Reset(Reset),
);


initial begin
    Clk = 0;
end

always #5 clk = ~clk;


initial begin
    Reset = 0;
    #20;
    Reset = 1;
end
endmodule
