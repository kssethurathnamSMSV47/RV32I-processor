//  ALUsrcA
//  2'b00 = Rs1
//  2'b01 = PC
//  2'b11 = 0

//  ALUsrcB
//  0 = Rs2
//  1 = immediate value

//  Writebacksel
//  2'b00 = Mem_to_Reg
//  2'b01 = ALU_to_Reg
//  2'b10 = PC+4

//  ALU_op 
//  3'b000 = Load / Store
//  3'b001 = R-Type
//  3'b010 = I-Type
//  3'b011 = auipc
//  3'b100 = jalr
//  3'b101 = jal
//  3'b110 = lui
//  3'b111 = Branch

module control_unit(RegWrite, MemRead, MemWrite, Branch, Jump, Writebacksel,
ALUsrcA, ALUsrcB, opcode, func3, ALU_op);

    input [6:0] opcode;
    input [2:0] func3;
    output reg RegWrite, MemRead, MemWrite, Branch, Jump, ALUsrcB;
    output reg [1:0] ALUsrcA;
    output reg [1:0] Writebacksel;
    output reg [2:0] ALU_op;

    always @(*)
    begin
        RegWrite = 0;
        MemRead = 0;
        MemWrite = 0;
        Branch = 0;
        Jump = 0;
        ALUsrcA = 0;
        ALUsrcB = 0;
        Writebacksel = 0;
        
        case(opcode)
        7'b0000011  :   begin
                        RegWrite = 1;
                        ALUsrcB = 1;
                        Writebacksel = 0;
                        MemRead = 1;
                        ALU_op = 0;
        end
        7'b0010011  :   begin
                        RegWrite = 1;
                        ALUsrcB = 1;
                        ALU_op = 2;
                        Writebacksel = 1;
        end
        7'b0010111  :   begin
                        RegWrite = 1;
                        ALUsrcA = 1;
                        ALUsrcB = 1;
                        ALU_op = 3;
                        Writebacksel = 1;
        end
        7'b0100011  :   begin
                        MemWrite = 1;
                        ALUsrcB = 1;
                        ALU_op = 0;
        end
        7'b0110011  :   begin
                        RegWrite = 1;
                        Writebacksel = 1;
                        ALU_op = 1;
        end
        7'b0110111  :   begin
                        RegWrite = 1;
                        ALUsrcA = 3;
                        ALU_op = 6;
                        ALUsrcB = 1;
                        Writebacksel = 1;
        end
        7'b1100011  :   begin
                        Branch = 1;
                        ALUsrcA = 1;
                        ALUsrcB = 1;
                        ALU_op = 7;
        end
        7'b1100111  :   begin
                        Jump = 1;
                        ALUsrcB = 1;
                        ALU_op = 4;
                        RegWrite = 1;
                        Writebacksel = 2;
        end
        7'b1101111  :   begin
                        RegWrite = 1;
                        Writebacksel = 2;
                        ALUsrcB = 1;
                        ALUsrcA = 1;
                        ALU_op = 5;
        end
        endcase
    end

endmodule