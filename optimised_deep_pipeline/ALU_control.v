//    ALU_ctrl
//    4'b0000 = Add
//    4'b0001 = Shift Left Logical
//    4'b0010 = Set Less Than
//    4'b0011 = Set Less Than unsigned
//    4'b0100 = Xor
//    4'b0101 = Shift Right Logical
//    4'b0110 = Shift Right Arithmetic
//    4'b0111 = OR
//    4'b1000 = AND
//    4'b1001 = copy B
//    4'b1010 = Sub

module ALU_controlunit(ALU_ctrl, ALU_op, func7_6, func3);

    input [2:0] ALU_op;
    input func7_6;
    input [2:0] func3;
    output reg [3:0] ALU_ctrl;

    always @(*)
    begin
        case(ALU_op)
        3'b000  :   ALU_ctrl = 4'b0000;
        3'b001  :   begin
                    case(func3)
                    3'b000  :   ALU_ctrl = func7_6 ? 4'b1010 : 4'b0000;
                    3'b001  :   ALU_ctrl = 4'b0001;
                    3'b010  :   ALU_ctrl = 4'b0010;
                    3'b011  :   ALU_ctrl = 4'b0011;
                    3'b100  :   ALU_ctrl = 4'b0100;
                    3'b101  :   ALU_ctrl = func7_6 ? 4'b0110 : 4'b0101;
                    3'b110  :   ALU_ctrl = 4'b0111;
                    3'b111  :   ALU_ctrl = 4'b1000;
                    default :   ALU_ctrl = 4'b0000;
                    endcase
        end
        3'b010  :   begin
                    case(func3)
                    3'b000  :   ALU_ctrl = 4'b0000;
                    3'b001  :   ALU_ctrl = 4'b0001;
                    3'b010  :   ALU_ctrl = 4'b0010;
                    3'b011  :   ALU_ctrl = 4'b0011;
                    3'b100  :   ALU_ctrl = 4'b0100;
                    3'b101  :   ALU_ctrl = func7_6 ? 4'b0110 : 4'b0101;
                    3'b110  :   ALU_ctrl = 4'b0111;
                    3'b111  :   ALU_ctrl = 4'b1000;
                    default :   ALU_ctrl = 4'b0000;
                    endcase
        end
        3'b011  :   begin
                    ALU_ctrl = 4'b0000;
        end
        3'b100  :   begin
                    ALU_ctrl = 4'b0000;
        end
        3'b101  :   begin
                    ALU_ctrl = 4'b0000;
        end
        3'b110  :   begin
                    ALU_ctrl = 4'b1001;
        end
        3'b111  :   begin
                    ALU_ctrl = 4'b0000;
        end
        default :   ALU_ctrl = 4'b0000;
        endcase
    end

endmodule