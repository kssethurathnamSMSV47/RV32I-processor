// testbench for finding the modulo of A and B (A % B)

module PROCESSOR_P1_TB;

    reg clk1, clk2;
    wire [15:0] PC, IF_ID_NPC, ID_EX_NPC, EX_MEM_NPC, ID_EX_JMP_ADDR;
    wire [3:0] ID_EX_TYPE, EX_MEM_TYPE, MEM_WB_TYPE;
    wire [31:0] IF_ID_IR, ID_EX_IR, EX_MEM_IR,  MEM_WB_IR, ID_EX_A, ID_EX_B, ID_EX_IMM, EX_MEM_ALUOUT, MEM_WB_ALUOUT, R1, R2, R3, R4, R5;
    wire HALTED, BRANCH_TAKEN, BRANCH_FLAG;

    PROCESSOR_RISC DESIGN_A1 (clk1, clk2, R1, R2, R3, R4, R5, PC, IF_ID_IR, ID_EX_IR, EX_MEM_IR,  MEM_WB_IR, IF_ID_NPC, ID_EX_NPC, EX_MEM_NPC, ID_EX_A, ID_EX_B, ID_EX_IMM,
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

        DESIGN_A1.MEM[0] = 32'h2c0002a0;         //R1 = 21
        DESIGN_A1.MEM[1] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[2] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[3] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[4] = 32'h2c200080;         //R2 = 4
        DESIGN_A1.MEM[5] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[6] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[7] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[8] = 32'h10400000;         //mov r3 = r1
        DESIGN_A1.MEM[9] = 32'h3c842000;         //Delay
        DESIGN_A1.MEM[10] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[11] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[12] = 32'h60221800;        //stl r4 r2 r3
        DESIGN_A1.MEM[13] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[14] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[15] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[16] = 32'h586001c0;        //bneqz
        DESIGN_A1.MEM[17] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[18] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[19] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[20] = 32'h04411000;        // sub r3 r2 r3
        DESIGN_A1.MEM[21] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[22] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[23] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[24] = 32'h60222000;        //stl r5 r2 r3
        DESIGN_A1.MEM[25] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[26] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[27] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[28] = 32'h549ffec0;        //beqz
        DESIGN_A1.MEM[29] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[30] = 32'h3c842000;        //Delay
        DESIGN_A1.MEM[31] = 32'hfc000000;        //HALT

        DESIGN_A1.HALTED = 0;
        DESIGN_A1.PC = 0;
        DESIGN_A1.BRANCH_TAKEN = 0;

        $monitor($time, " clk1 = %b, clk2 = %b, PC = %h, IF_ID_NPC = %h, ID_EX_NPC = %h, EX_MEM_NPC = %h, ID_EX_JMP_ADDR = %h, ID_EX_TYPE = %h, EX_MEM_TYPE = %h, MEM_WB_TYPE = %h, ");
        
        
        #10000 $finish;
    end

endmodule
