module ALU(ALU_Result, Eql, Lst, Lst_Unsign, Grt_eql, Grt_eql_Unsign, A, B, ALU_ctrl);

    input [31:0] A, B;
    input [3:0] ALU_ctrl;
    output Eql, Lst, Lst_Unsign, Grt_eql, Grt_eql_Unsign;
    output reg [31:0] ALU_Result;

    assign Eql             = (A == B);
    assign Lst             = ($signed(A) < $signed(B));
    assign Lst_Unsign      = (A < B);
    assign Grt_eql         = ($signed(A) >= $signed(B));
    assign Grt_eql_Unsign  = (A >= B);

    always @(*)
    begin
        ALU_Result = 0;
        case(ALU_ctrl)
        4'b0000    :    ALU_Result = A + B;
        4'b0001    :    ALU_Result = A << B[4:0];
        4'b0010    :    ALU_Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
        4'b0011    :    ALU_Result = A < B;
        4'b0100    :    ALU_Result = A ^ B;
        4'b0101    :    ALU_Result = A >> B[4:0];
        4'b0110    :    ALU_Result = A >>> $signed(B[4:0]);
        4'b0111    :    ALU_Result = A | B;
        4'b1000    :    ALU_Result = A & B;
        4'b1001    :    ALU_Result = B;
        4'b1010    :    ALU_Result = A - B;
        default    :    ALU_Result = 32'b0;
        endcase
    end

endmodule