// testbench for the factorial of a number N

module PROCESSOR_P1_TB;

    reg clk1, clk2;
    wire [15:0] PC, IF_ID_NPC, ID_EX_NPC, EX_MEM_NPC, ID_EX_JMP_ADDR;
    wire [3:0] ID_EX_TYPE, EX_MEM_TYPE, MEM_WB_TYPE;
    wire [31:0] IF_ID_IR, ID_EX_IR, EX_MEM_IR,  MEM_WB_IR, ID_EX_A, ID_EX_B, ID_EX_IMM, EX_MEM_ALUOUT, MEM_WB_ALUOUT, out1, out2, out3;
    wire HALTED, BRANCH_TAKEN, BRANCH_FLAG;

    PROCESSOR_RISC DESIGN_A1 (clk1, clk2, out1, out2, out3, PC, IF_ID_IR, ID_EX_IR, EX_MEM_IR,  MEM_WB_IR, IF_ID_NPC, ID_EX_NPC, EX_MEM_NPC, ID_EX_A, ID_EX_B, ID_EX_IMM,
ID_EX_TYPE, EX_MEM_TYPE, MEM_WB_TYPE, EX_MEM_ALUOUT, MEM_WB_ALUOUT, ID_EX_JMP_ADDR, HALTED, BRANCH_TAKEN, BRANCH_FLAG);

    initial 
    begin
        clk1 = 0; clk2 = 0;
        repeat(5000)
        begin
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end

    initial begin
        
        $dumpfile("temp.vcd");
        $dumpvars(0, PROCESSOR_P1_TB);

        DESIGN_A1.MEM[0] = 32'h2c000100;         //R1 = 8
        DESIGN_A1.MEM[1] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[2] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[3] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[4] = 32'h2c200100;         //R2 = 8
        DESIGN_A1.MEM[5] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[6] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[7] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[8] = 32'h20210001;         //R2 = R2 - 1
        DESIGN_A1.MEM[9] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[10] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[11] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[12] = 32'h54200100;        //BEQZ CONDITION if R2 == 0 then go to HALT
        DESIGN_A1.MEM[13] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[14] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[15] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[16] = 32'h08010000;        //MULTIPLY R1 = R1 * R2
        DESIGN_A1.MEM[17] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[18] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[19] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[20] = 32'h583ffe40;        //BNEQZ CONDITION if R2 != 0 then go to the SUB instruction (R2 = R2 - 1)
        DESIGN_A1.MEM[21] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[22] = 32'hfc000000;        //HALT

        DESIGN_A1.HALTED = 0;
        DESIGN_A1.PC = 0;
        DESIGN_A1.BRANCH_TAKEN = 0;

        
        
        #10000 $finish;
    end

endmodule
