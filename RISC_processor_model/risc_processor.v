module PROCESSOR_RISC(clk, rst, R1, R2, R3, R4, R5, PC, IF_ID_IR, ID_EX_IR, EX_MEM_IR,  MEM_WB_IR, IF_ID_NPC, ID_EX_NPC, EX_MEM_NPC, ID_EX_A, ID_EX_B, ID_EX_IMM,
ID_EX_TYPE, EX_MEM_TYPE, MEM_WB_TYPE, EX_MEM_ALUOUT, MEM_WB_ALUOUT, ID_EX_JMP_ADDR, HALTED, BRANCH_TAKEN, BRANCH_FLAG);

    input clk, rst;
    output [15:0] PC, IF_ID_NPC, ID_EX_NPC, EX_MEM_NPC, ID_EX_JMP_ADDR;
    output [3:0] ID_EX_TYPE, EX_MEM_TYPE, MEM_WB_TYPE;
    output [31:0] IF_ID_IR, ID_EX_IR, EX_MEM_IR,  MEM_WB_IR, ID_EX_A, ID_EX_B, ID_EX_IMM, EX_MEM_ALUOUT, MEM_WB_ALUOUT, R1, R2, R3, R4, R5;
    output HALTED, BRANCH_TAKEN, BRANCH_FLAG;

    reg [15:0] PC;
    reg [31:0] IF_ID_IR;
    reg [15:0] IF_ID_NPC;
    reg [31:0] ID_EX_A, ID_EX_B, ID_EX_IR, ID_EX_IMM;
    reg [15:0] ID_EX_JMP_ADDR;
    reg [15:0] ID_EX_NPC, EX_MEM_NPC;
    reg [3:0]  ID_EX_TYPE, EX_MEM_TYPE, MEM_WB_TYPE;
    reg [31:0] EX_MEM_ALUOUT, EX_MEM_TEMP, EX_MEM_IR;
    reg [31:0] MEM_WB_ALUOUT, MEM_WB_IR, MEM_WB_LMD;
    reg BRANCH_FLAG;

    reg HALTED, BRANCH_TAKEN;

    reg ZERO, CARRY, PARITY;

    reg [31:0] REG [0:31];
    reg [31:0] MEM [0:255];

    assign R1 = REG[0];
    assign R2 = REG[1];
    assign R3 = REG[2];
    assign R4 = REG[3];
    assign R5 = REG[4];

    parameter ADD = 6'b000000, SUB = 6'b000001, MUL = 6'b000010, DIV = 6'b000011, MOV = 6'b000100, SHIFTL = 6'b000101, SHIFTR = 6'b000110, 
              ADDI = 6'b000111, SUBI = 6'b001000, MULI = 6'b001001, DIVI = 6'b001010, MOVI = 6'b001011, LWD = 6'b001100, STR = 6'b001101,
              AND = 6'b001110, OR = 6'b001111, CMP = 6'b010000, XOR = 6'b010001, ANDI = 6'b010010, ORI = 6'b010011, XORI = 6'b010100,
              BEQZ = 6'b010101, BNEQZ = 6'b010110, STEQZ = 6'b010111, STL = 6'b011000, COMP = 6'b011001,/* JMP = 6'b011010,*/ HLT = 6'b111111;

    parameter R_TYPE = 4'b0000, I_TYPE = 4'b0001, LOGIC_OPR_RR = 4'b0010, LOGIC_OPR_RI = 4'b0011, BRANCH = 4'b0100/*, JUMP = 4'b0101*/, LOAD = 4'b0110, STORE = 4'b0111, HALT = 4'b1111;

    always @(posedge rst)
    begin
        REG[0]  <= 32'b0;  REG[1]  = 32'b0; REG[2]  = 32'b0;  REG[3]  <= 32'b0;  REG[4]  = 32'b0;  REG[5]  = 32'b0;  REG[6]  <= 32'b0;  REG[7]  = 32'b0;  REG[8]  = 32'b0;
        REG[9]  <= 32'b0;  REG[10] = 32'b0; REG[11] = 32'b0;  REG[12] <= 32'b0;  REG[13] = 32'b0;  REG[14] = 32'b0;  REG[15] <= 32'b0;  REG[16] = 32'b0;  REG[17] = 32'b0;
        REG[18] <= 32'b0;  REG[19] = 32'b0; REG[20] = 32'b0;  REG[21] <= 32'b0;  REG[22] = 32'b0;  REG[23] = 32'b0;  REG[24] <= 32'b0;  REG[25] = 32'b0;  REG[26] = 32'b0;
        REG[27] <= 32'b0;  REG[28] = 32'b0; REG[29] = 32'b0;  REG[30] <= 32'b0;  REG[31] = 32'b0;
    end

    always @(posedge clk)
    begin
        if(((EX_MEM_IR[31:26] == BEQZ) && (BRANCH_FLAG == 1)) || ((EX_MEM_IR[31:26] == BNEQZ) && (BRANCH_FLAG == 0)))
        begin
            PC <= EX_MEM_ALUOUT + 1;
            IF_ID_IR <= MEM[EX_MEM_ALUOUT];
            IF_ID_NPC <= EX_MEM_ALUOUT + 1;
            BRANCH_TAKEN <= 1'b1;
        end
        else begin
            IF_ID_IR <= MEM[PC];
            IF_ID_NPC <= PC + 1;
            PC <= PC + 1;
        end
    end

    always @(posedge clk)
    begin
        if(HALTED == 0)
        begin
            ID_EX_IR <= IF_ID_IR;
            ID_EX_NPC <= IF_ID_NPC;
            ID_EX_IMM <= {{16{IF_ID_IR[15]}}, {IF_ID_IR[15:0]}};

            case(IF_ID_IR[31:26])
                ADD, SUB, MUL, DIV, MOV, SHIFTR, SHIFTL, STL, COMP, STEQZ   :   ID_EX_TYPE <= R_TYPE;
                ADDI, SUBI, MULI, DIVI, MOVI                                :   ID_EX_TYPE <= I_TYPE;
                LWD                                                         :   ID_EX_TYPE <= LOAD;
                STR                                                         :   ID_EX_TYPE <= STORE;
                BEQZ, BNEQZ                                                 :   begin
                                                                                ID_EX_TYPE <= BRANCH;
                                                                                ID_EX_JMP_ADDR <= IF_ID_IR[20:5];
                                                                                end
                AND, OR, CMP, XOR                                           :   ID_EX_TYPE <= LOGIC_OPR_RR;
                ANDI, ORI, XORI                                             :   ID_EX_TYPE <= LOGIC_OPR_RI;
                /*JMP                                                         :   begin
                                                                                ID_EX_TYPE <= JUMP;
                                                                                ID_EX_JMP_ADDR <= ID_EX_IR[20:5];
                                                                                end*/
                HLT                                                         :   ID_EX_TYPE <= HALT;
            endcase
        end
    end

    always @(posedge clk)
    begin
        if(HALTED == 0)
        begin
            EX_MEM_IR <= ID_EX_IR;
            EX_MEM_NPC <= ID_EX_NPC;
            EX_MEM_TYPE <= ID_EX_TYPE;
            BRANCH_TAKEN <= 0;

            case(ID_EX_TYPE)
                R_TYPE  :   begin
                            case(ID_EX_IR[31:26])
                                ADD    :    EX_MEM_ALUOUT <= ID_EX_A + ID_EX_B;
                                SUB    :    EX_MEM_ALUOUT <= ID_EX_A - ID_EX_B;
                                MUL    :    EX_MEM_ALUOUT <= ID_EX_A * ID_EX_B;
                                DIV    :    EX_MEM_ALUOUT <= ID_EX_A / ID_EX_B;
                                MOV    :    EX_MEM_ALUOUT <= ID_EX_B;
                                SHIFTL :    EX_MEM_ALUOUT <= ID_EX_B << 1;
                                SHIFTR :    EX_MEM_ALUOUT <= ID_EX_B >> 1;
                                STL    :    begin
                                            if(ID_EX_A > ID_EX_B) EX_MEM_ALUOUT <= 1'b1;
                                            else EX_MEM_ALUOUT <= 1'b0;
                                            end
                                COMP   :    begin
                                            if(ID_EX_A == ID_EX_B) begin EX_MEM_ALUOUT <= 1'b1; end
                                            else begin EX_MEM_ALUOUT <= 1'b0; end
                                            end
                                STEQZ  :    begin
                                            if(ID_EX_B == 32'b0) begin EX_MEM_ALUOUT <= 1'b1; end
                                            else begin EX_MEM_ALUOUT <= 1'b0; end
                                            end
                            endcase
                end
                I_TYPE  :   begin
                            case(ID_EX_IR[31:26])
                                ADDI   :    EX_MEM_ALUOUT <= ID_EX_A + ID_EX_IMM;
                                SUBI   :    EX_MEM_ALUOUT <= ID_EX_A - ID_EX_IMM;
                                MULI   :    EX_MEM_ALUOUT <= ID_EX_A * ID_EX_IMM;
                                DIVI   :    EX_MEM_ALUOUT <= ID_EX_A / ID_EX_IMM;
                                MOVI   :    EX_MEM_ALUOUT <= ID_EX_IR[20:5];
                            endcase
                end
                LOAD    :   begin
                            case(ID_EX_IR[31:26])
                                LWD    :    EX_MEM_ALUOUT <= ID_EX_B + ID_EX_IMM;
                            endcase
                end
                STORE   :   begin
                            case(ID_EX_IR[31:26])
                                STR    :    begin
                                            EX_MEM_TEMP   <= ID_EX_A;
                                            EX_MEM_ALUOUT <= ID_EX_B + ID_EX_IMM;
                                            end
                            endcase
                end
                LOGIC_OPR_RR : begin
                                case(ID_EX_IR[31:26])
                                    AND    :    EX_MEM_ALUOUT <= ID_EX_A & ID_EX_B;
                                    OR     :    EX_MEM_ALUOUT <= ID_EX_A | ID_EX_B;
                                    XOR    :    EX_MEM_ALUOUT <= ID_EX_A ^ ID_EX_B;
                                    CMP    :    EX_MEM_ALUOUT <= ~(ID_EX_B);
                                endcase
                end
                LOGIC_OPR_RI : begin
                                case(ID_EX_IR[31:26])
                                    ANDI   :    EX_MEM_ALUOUT <= ID_EX_A & ID_EX_IMM;
                                    ORI    :    EX_MEM_ALUOUT <= ID_EX_A | ID_EX_IMM;
                                    XORI   :    EX_MEM_ALUOUT <= ID_EX_A ^ ID_EX_IMM;
                                endcase
                end
                BRANCH  :   begin
                            EX_MEM_ALUOUT <= ID_EX_NPC + ID_EX_JMP_ADDR;
                            BRANCH_FLAG <= (ID_EX_A == 32'b0);
                end
            endcase
        end
    end

    always @(posedge clk)
    begin
        if(HALTED == 0)
        begin
            MEM_WB_IR <= EX_MEM_IR;
            MEM_WB_TYPE <= EX_MEM_TYPE;

            case(EX_MEM_TYPE)
                R_TYPE       :   MEM_WB_ALUOUT <= EX_MEM_ALUOUT;
                I_TYPE       :   MEM_WB_ALUOUT <= EX_MEM_ALUOUT;
                LOGIC_OPR_RR :   MEM_WB_ALUOUT <= EX_MEM_ALUOUT;
                LOGIC_OPR_RI :   MEM_WB_ALUOUT <= EX_MEM_ALUOUT;
                LOAD         :   MEM_WB_LMD    <= MEM[EX_MEM_ALUOUT]; 
                STORE        :   if(BRANCH_TAKEN == 0) MEM[EX_MEM_ALUOUT] <= EX_MEM_TEMP;
            endcase
        end
    end

    always @(posedge clk)
    begin
        if(BRANCH_TAKEN == 0)
        begin
            case(MEM_WB_TYPE)
                R_TYPE  :   begin
                            case(MEM_WB_IR[31:26])
                                ADD, SUB, MUL, DIV :  REG[MEM_WB_IR[15:11]] <= MEM_WB_ALUOUT;
                                MOV                :  REG[MEM_WB_IR[25:21]] <= MEM_WB_ALUOUT;
                                SHIFTL, SHIFTR     :  REG[MEM_WB_IR[25:21]] <= MEM_WB_ALUOUT;
                                STL, COMP          :  REG[MEM_WB_IR[15:11]] <= MEM_WB_ALUOUT;
                                STEQZ              :  REG[MEM_WB_IR[25:21]] <= MEM_WB_ALUOUT;
                            endcase
                end
                I_TYPE  :   begin
                            case(MEM_WB_IR[31:26])
                                ADDI, SUBI, MULI, DIVI  :   REG[MEM_WB_IR[20:16]] <= MEM_WB_ALUOUT;
                                MOVI                    :   REG[MEM_WB_IR[25:21]] <= MEM_WB_ALUOUT;
                            endcase
                end
                LOGIC_OPR_RR : begin
                            case(MEM_WB_IR[31:26])
                                AND, OR, XOR    :   REG[MEM_WB_IR[15:11]] <= MEM_WB_ALUOUT;
                                CMP             :   REG[MEM_WB_IR[25:21]] <= MEM_WB_ALUOUT;
                            endcase
                end
                LOGIC_OPR_RI :  REG[MEM_WB_IR[20:16]] <= MEM_WB_ALUOUT;

                LOAD    :    REG[MEM_WB_IR[25:21]]  <=   MEM_WB_LMD;

                HALT    :    HALTED <= 1'b1;
            endcase
        end
    end

    always @(posedge clk)
    begin
        if(HALTED == 0)
        begin
            case(EX_MEM_IR[31:26])
                ADD,SUB,MUL,DIV,STL,COMP,AND,OR,XOR    :    begin
                                                                if(IF_ID_IR[25:21] == EX_MEM_IR[15:11])
                                                                begin
                                                                    ID_EX_A <= EX_MEM_ALUOUT;
                                                                end
                                                                else if(IF_ID_IR[20:16] == EX_MEM_IR[15:11])
                                                                begin
                                                                    ID_EX_B <= EX_MEM_ALUOUT;
                                                                end
                                                                else begin
                                                                    ID_EX_A <= REG[IF_ID_IR[25:21]];
                                                                    ID_EX_B <= REG[IF_ID_IR[20:16]];
                                                                end
                end
                MOV,SHIFTL,SHIFTR,STEQZ,MOVI,CMP,LOAD  :    begin
                                                                if(IF_ID_IR[25:21] == EX_MEM_IR[25:21])
                                                                begin
                                                                    ID_EX_A <= EX_MEM_ALUOUT;
                                                                end
                                                                else if(IF_ID_IR[20:16] == EX_MEM_IR[25:21])
                                                                begin
                                                                    ID_EX_B <= EX_MEM_ALUOUT;
                                                                end
                                                                else begin
                                                                    ID_EX_A <= REG[IF_ID_IR[25:21]];
                                                                    ID_EX_B <= REG[IF_ID_IR[20:16]];
                                                                end
                end
                ADDI,SUBI,MULI,DIVI,LOGIC_OPR_RI       :    begin
                                                                if(IF_ID_IR[25:21] == EX_MEM_IR[20:16])
                                                                begin
                                                                    ID_EX_A <= EX_MEM_ALUOUT;
                                                                end
                                                                else if(IF_ID_IR[20:16] == EX_MEM_IR[20:16])
                                                                begin
                                                                    ID_EX_B <= EX_MEM_ALUOUT;
                                                                end
                                                                else begin
                                                                    ID_EX_A <= REG[IF_ID_IR[25:21]];
                                                                    ID_EX_B <= REG[IF_ID_IR[20:16]];
                                                                end
                end
            endcase

            case(MEM_WB_IR[31:26])
                ADD,SUB,MUL,DIV,STL,COMP,AND,OR,XOR    :    begin
                                                                if(IF_ID_IR[25:21] == MEM_WB_IR[15:11])
                                                                begin
                                                                    ID_EX_A <= MEM_WB_ALUOUT;
                                                                end
                                                                else if(IF_ID_IR[20:16] == MEM_WB_IR[15:11])
                                                                begin
                                                                    ID_EX_B <= MEM_WB_ALUOUT;
                                                                end
                                                                else begin
                                                                    ID_EX_A <= REG[IF_ID_IR[25:21]];
                                                                    ID_EX_B <= REG[IF_ID_IR[20:16]];
                                                                end
                end
                MOV,SHIFTL,SHIFTR,STEQZ,MOVI,CMP,LOAD  :    begin
                                                                if(IF_ID_IR[25:21] == MEM_WB_IR[25:21])
                                                                begin
                                                                    ID_EX_A <= MEM_WB_ALUOUT;
                                                                end
                                                                else if(IF_ID_IR[20:16] == MEM_WB_IR[25:21])
                                                                begin
                                                                    ID_EX_B <= MEM_WB_ALUOUT;
                                                                end
                                                                else begin
                                                                    ID_EX_A <= REG[IF_ID_IR[25:21]];
                                                                    ID_EX_B <= REG[IF_ID_IR[20:16]];
                                                                end
                end
                ADDI,SUBI,MULI,DIVI,LOGIC_OPR_RI       :    begin
                                                                if(IF_ID_IR[25:21] == MEM_WB_IR[20:16])
                                                                begin
                                                                    ID_EX_A <= MEM_WB_ALUOUT;
                                                                end
                                                                else if(IF_ID_IR[20:16] == MEM_WB_IR[20:16])
                                                                begin
                                                                    ID_EX_B <= MEM_WB_ALUOUT;
                                                                end
                                                                else begin
                                                                    ID_EX_A <= REG[IF_ID_IR[25:21]];
                                                                    ID_EX_B <= REG[IF_ID_IR[20:16]];
                                                                end
                end
            endcase
        end
    end

endmodule
