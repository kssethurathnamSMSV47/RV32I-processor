module immediate_generator(imm_out, IR);

    input [31:0] IR;
    output reg [31:0] imm_out;

    always @(*)
    begin
        case(IR[6:0])
        7'b0000011  :   begin
                        imm_out = {{20{IR[31]}} , {IR[31:20]}};
        end
        7'b0010011  :   begin
                        imm_out = {{20{IR[31]}} , {IR[31:20]}};
        end
        7'b0010111  :   begin
                        imm_out = {{IR[31:12]}, {12{1'b0}}};
        end
        7'b0100011  :   begin
                        imm_out = {{20{IR[31]}}, {IR[31:25]}, {IR[11:7]}};
        end
        7'b1100011  :   begin
                        imm_out = {{19{IR[31]}}, {IR[31]}, {IR[7]}, {IR[31:25]}, {IR[11:8]}, {1'b0}};
        end
        7'b1100111  :   begin
                        imm_out = {{20{IR[31]}} , {IR[31:20]}};
        end
        7'b1101111  :   begin
                        imm_out = {{11{IR[31]}}, IR[31], IR[19:12], IR[20], IR[30:21], 1'b0};
        end
        default     :   imm_out = 32'b0;
        endcase
    end

endmodule