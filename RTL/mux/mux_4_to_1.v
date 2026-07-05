module mux4to1 #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  [WIDTH-1:0] c,
    input  [WIDTH-1:0] d,
    input  [1:0]sel,
    
    output [WIDTH-1:0] y
);

assign y = (sel == 2'b00) ? a :
           (sel == 2'b01) ? b :
           (sel == 2'b10) ? c :
                            d;
                            
endmodule
