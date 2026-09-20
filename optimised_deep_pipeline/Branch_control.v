// ================================================================
// pc_sel
//   2'b00 : PC + 4
//   2'b01 : Branch target
//   2'b10 : JAL target
//   2'b11 : JALR target
// ================================================================

module Branch_ControlUnit(
    flush,
    Branch_taken,
    Lst,
    Lst_Unsign,
    Grt_eql,
    Grt_eql_Unsign,
    Eql,
    Branch,
    func3,
    pc_sel,
    ALU_op,
    Jump_taken
);

    input        Lst;
    input        Lst_Unsign;
    input        Grt_eql;
    input        Grt_eql_Unsign;
    input        Eql;
    input        Branch;
    input  [2:0] func3;
    input  [2:0] ALU_op;

    output       flush;
    output reg   Branch_taken;
    output reg   Jump_taken;
    output reg [1:0] pc_sel;

    // A redirect occurs whenever a branch or jump is taken.
    assign flush = Branch_taken | Jump_taken;

    always @(*) begin

        // Safe defaults
        pc_sel       = 2'b00;   // PC + 4
        Branch_taken = 1'b0;
        Jump_taken   = 1'b0;

        // ========================================================
        // CONDITIONAL BRANCHES
        // ========================================================
        if (Branch) begin

            case (func3)

                // BEQ
                3'b000: begin
                    if (Eql) begin
                        pc_sel       = 2'b01;
                        Branch_taken = 1'b1;
                    end
                end

                // BNE
                3'b001: begin
                    if (!Eql) begin
                        pc_sel       = 2'b01;
                        Branch_taken = 1'b1;
                    end
                end

                // BLT
                3'b100: begin
                    if (Lst) begin
                        pc_sel       = 2'b01;
                        Branch_taken = 1'b1;
                    end
                end

                // BGE
                3'b101: begin
                    if (Grt_eql) begin
                        pc_sel       = 2'b01;
                        Branch_taken = 1'b1;
                    end
                end

                // BLTU
                3'b110: begin
                    if (Lst_Unsign) begin
                        pc_sel       = 2'b01;
                        Branch_taken = 1'b1;
                    end
                end

                // BGEU
                3'b111: begin
                    if (Grt_eql_Unsign) begin
                        pc_sel       = 2'b01;
                        Branch_taken = 1'b1;
                    end
                end

                default: begin
                    pc_sel       = 2'b00;
                    Branch_taken = 1'b0;
                end

            endcase

        end

        // ========================================================
        // JAL / JALR
        // ========================================================
        else begin

            case (ALU_op)

                // JALR
                3'b100: begin
                    pc_sel     = 2'b11;
                    Jump_taken = 1'b1;
                end

                // JAL
                3'b101: begin
                    pc_sel     = 2'b10;
                    Jump_taken = 1'b1;
                end

                default: begin
                    pc_sel     = 2'b00;
                    Jump_taken = 1'b0;
                end

            endcase

        end
    end

endmodule