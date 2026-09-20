// ============================================================================
// TOP LEVEL
// ============================================================================
module rv32i_7stage_core #(
    parameter IMEM_BYTES = 4096,
    parameter DMEM_BYTES = 32768
)(
    input         clk,
    input         rst,
    output [31:0] debug_pc,
    output [31:0] debug_wb_data,
    output [4:0]  debug_wb_rd,
    output        debug_wb_we
);

    // ------------------------------------------------------------------------
    // IF1
    // ------------------------------------------------------------------------
    wire [31:0] pc_current;
    wire [31:0] pc_plus4_IF1;
    wire [31:0] next_pc;
    wire        valid_IF1;
    assign valid_IF1 = 1'b1;

    // ------------------------------------------------------------------------
    // IF1 -> IF2
    // ------------------------------------------------------------------------
    wire [31:0] PC_IF2;
    wire        valid_IF2;
    wire        flush_control;
    wire        PCWrite;
    wire        PC_IF2_Write;
    wire        IF2_ID1_Write;
    wire        ID1_ID2_Write;
    wire        ID2_EX_Flush;

    // ------------------------------------------------------------------------
    // IF2
    // ------------------------------------------------------------------------
    wire [31:0] Instruction_IF2;
    wire        imem_rd_en = 1'b1;

    instruction_mem u_imem (
        .instruction(Instruction_IF2),
        .pc_addr    (PC_IF2),
        .clk        (clk),
        .rst        (rst),
        .rd_en      (imem_rd_en),
        .wr_en      (1'b0),
        .wr_addr    (32'd0),
        .wr_data_in (32'd0)
    );

    // ------------------------------------------------------------------------
    // IF2 -> ID1
    // ------------------------------------------------------------------------
    wire [31:0] IR_ID1;
    wire [31:0] PC_ID1;
    wire        valid_ID1;

    // Decode fields
    wire [6:0] opcode_ID1 = IR_ID1[6:0];
    wire [2:0] func3_ID1  = IR_ID1[14:12];
    wire [6:0] func7_ID1  = IR_ID1[31:25];
    wire       func7_6_ID1 = IR_ID1[30];
    wire [4:0] rs1_ID1 = IR_ID1[19:15];
    wire [4:0] rs2_ID1 = IR_ID1[24:20];
    wire [4:0] rd_ID1  = IR_ID1[11:7];

    // ------------------------------------------------------------------------
    // ID1 control
    // ------------------------------------------------------------------------
    wire RegWrite_ID1, MemWrite_ID1, MemRead_ID1, Branch_ID1, jump_ID1;
    wire [1:0] Writebacksel_ID1;
    wire [1:0] ALUsrcA_ID1;
    wire       ALUsrcB_ID1;
    wire [2:0] ALU_op_ID1;

    control_unit u_control (
        .RegWrite     (RegWrite_ID1),
        .MemRead      (MemRead_ID1),
        .MemWrite     (MemWrite_ID1),
        .Branch       (Branch_ID1),
        .Jump         (jump_ID1),
        .Writebacksel (Writebacksel_ID1),
        .ALUsrcA      (ALUsrcA_ID1),
        .ALUsrcB      (ALUsrcB_ID1),
        .ALU_op       (ALU_op_ID1),
        .opcode       (opcode_ID1),
        .func3        (func3_ID1)
    );

    // ------------------------------------------------------------------------
    // ID1 -> ID2
    // ------------------------------------------------------------------------
    wire [31:0] PC_ID2;
    wire [4:0] rs1_ID2, rs2_ID2, rd_ID2;
    wire [2:0] func3_ID2;
    wire       func7_6_ID2;
    wire [31:0] IR_ID2;
    wire        valid_ID2;
    wire        RegWrite_ID2, MemWrite_ID2, MemRead_ID2, Branch_ID2, jump_ID2;
    wire [1:0]  Writebacksel_ID2, ALUsrcA_ID2;
    wire        ALUsrcB_ID2;
    wire [2:0]  ALU_op_ID2;

    ID1_ID2_reg u_id1_id2 (
        .clk(clk), .rst(rst), .write_enable(ID1_ID2_Write), .flush(flush_control),
        .PC_ID1(PC_ID1), .rs1_ID1(rs1_ID1), .rs2_ID1(rs2_ID1), .rd_ID1(rd_ID1),
        .func3_ID1(func3_ID1), .func7_6_ID1(func7_6_ID1), .IR_ID1(IR_ID1),
        .valid_ID1(valid_ID1), .RegWrite_ID1(RegWrite_ID1), .MemWrite_ID1(MemWrite_ID1),
        .MemRead_ID1(MemRead_ID1), .Branch_ID1(Branch_ID1), .jump_ID1(jump_ID1),
        .Writebacksel_ID1(Writebacksel_ID1), .ALU_op_ID1(ALU_op_ID1),
        .ALUsrcA_ID1(ALUsrcA_ID1), .ALUsrcB_ID1(ALUsrcB_ID1),
        .PC_ID2(PC_ID2), .rs1_ID2(rs1_ID2), .rs2_ID2(rs2_ID2), .rd_ID2(rd_ID2),
        .func3_ID2(func3_ID2), .func7_6_ID2(func7_6_ID2), .IR_ID2(IR_ID2),
        .valid_ID2(valid_ID2), .RegWrite_ID2(RegWrite_ID2), .MemWrite_ID2(MemWrite_ID2),
        .MemRead_ID2(MemRead_ID2), .Branch_ID2(Branch_ID2), .jump_ID2(jump_ID2),
        .Writebacksel_ID2(Writebacksel_ID2), .ALU_op_ID2(ALU_op_ID2),
        .ALUsrcA_ID2(ALUsrcA_ID2), .ALUsrcB_ID2(ALUsrcB_ID2)
    );

    // ------------------------------------------------------------------------
    // WB signals are declared before ID2 because of explicit bypass.
    // ------------------------------------------------------------------------
    wire        valid_WB;
    wire [31:0] ALU_result_WB;
    wire [31:0] Mem_data_WB;
    wire [31:0] PC_WB;
    wire [4:0]  rd_WB;
    wire        RegWrite_WB;
    wire [1:0]  Writebacksel_WB;

    wire [31:0] wb_data;
    assign wb_data = (Writebacksel_WB == 2'b00) ? Mem_data_WB :
                     (Writebacksel_WB == 2'b10) ? (PC_WB + 32'd4) :
                                                  ALU_result_WB;

    // ------------------------------------------------------------------------
    // ID2 register file + immediate
    // ------------------------------------------------------------------------
    wire [31:0] rs1_rf_ID2;
    wire [31:0] rs2_rf_ID2;
    wire [31:0] rs1_data_ID2;
    wire [31:0] rs2_data_ID2;
    wire [31:0] imm_ID2;

    Register_Bank u_regfile (
        .Rd_data1(rs1_rf_ID2), .Rd_data2(rs2_rf_ID2), .Wr_data(wb_data),
        .Rs1(rs1_ID2), .Rs2(rs2_ID2), .Rd(rd_WB), .clk(clk), .rst(rst),
        .W_en(valid_WB && RegWrite_WB), .Rd_en(valid_ID2)
    );

    immediate_generator u_immgen (.IR(IR_ID2), .imm_out(imm_ID2));

    // ------------------------------------------------------------------------
    // EX signals
    // ------------------------------------------------------------------------
    wire [31:0] PC_EX;
    wire [31:0] rs1_data_EX, rs2_data_EX, imm_EX;
    wire [4:0] rs1_EX, rs2_EX, rd_EX;
    wire [2:0] func3_EX;
    wire       func7_6_EX;
    wire       valid_EX;
    wire       RegWrite_EX, MemWrite_EX, MemRead_EX, Branch_EX, jump_EX;
    wire [1:0] Writebacksel_EX, ALUsrcA_EX;
    wire       ALUsrcB_EX;
    wire [2:0] ALU_op_EX;

    // EX forwarding
    wire [1:0] ForwardA, ForwardB;
    wire [31:0] forwarded_A, forwarded_B;
    wire [31:0] ALU_A_EX, ALU_B_EX;
    wire [31:0] ALU_result_EX;
    wire Eql_EX, Lst_EX, Lst_Unsign_EX, Grt_eql_EX, Grt_eql_Unsign_EX;
    wire [3:0] ALU_ctrl_EX;
    wire branch_taken_EX;
    wire jump_taken_EX;
    wire [1:0] pc_sel_EX;
    wire [31:0] branch_target_EX;
    wire [31:0] jal_target_EX;
    wire [31:0] jalr_target_EX;
    wire [31:0] store_data_EX;

    wire [31:0] mem_forward_data;
    assign mem_forward_data = (Writebacksel_MEM == 2'b10) ? (PC_MEM + 32'd4) : ALU_result_MEM;

    forwarding_unit u_forwarding (
        .rs1_EX(rs1_EX), .rs2_EX(rs2_EX),
        .valid_MEM(valid_MEM), .rd_MEM(rd_MEM), .RegWrite_MEM(RegWrite_MEM),
        .MemRead_MEM(MemRead_MEM), .mem_forward_data(mem_forward_data),
        .valid_WB(valid_WB), .rd_WB(rd_WB), .RegWrite_WB(RegWrite_WB),
        .ForwardA(ForwardA), .ForwardB(ForwardB)
    );

    // Explicit WB -> ID2 bypass. This avoids a same-cycle register-file
    // write/read dependency without requiring uses_rs1/uses_rs2 signals.
    wire bypass_rs1_ID2 = valid_WB && RegWrite_WB && (rd_WB!=5'd0) && (rd_WB==rs1_ID2);
    wire bypass_rs2_ID2 = valid_WB && RegWrite_WB && (rd_WB!=5'd0) && (rd_WB==rs2_ID2);
    assign rs1_data_ID2 = bypass_rs1_ID2 ? wb_data : rs1_rf_ID2;
    assign rs2_data_ID2 = bypass_rs2_ID2 ? wb_data : rs2_rf_ID2;

    assign forwarded_A = (ForwardA==2'b01) ? mem_forward_data :
                         (ForwardA==2'b10) ? wb_data : rs1_data_EX;
    assign forwarded_B = (ForwardB==2'b01) ? mem_forward_data :
                         (ForwardB==2'b10) ? wb_data : rs2_data_EX;

    assign ALU_A_EX = (ALUsrcA_EX==2'b01) ? PC_EX :
                      (ALUsrcA_EX==2'b11) ? 32'd0 : forwarded_A;
    assign ALU_B_EX = ALUsrcB_EX ? imm_EX : forwarded_B;

    assign store_data_EX = forwarded_B;
    assign branch_target_EX = PC_EX + imm_EX;
    assign jal_target_EX    = PC_EX + imm_EX;
    assign jalr_target_EX   = (forwarded_A + imm_EX) & 32'hFFFFFFFE;

    ALU_controlunit u_aluctrl (
        .ALU_op(ALU_op_EX), .func7_6(func7_6_EX), .func3(func3_EX), .ALU_ctrl(ALU_ctrl_EX)
    );

    ALU u_alu (
        .A(ALU_A_EX), .B(ALU_B_EX), .ALU_ctrl(ALU_ctrl_EX), .ALU_Result(ALU_result_EX),
        .Eql(Eql_EX), .Lst(Lst_EX), .Lst_Unsign(Lst_Unsign_EX),
        .Grt_eql(Grt_eql_EX), .Grt_eql_Unsign(Grt_eql_Unsign_EX)
    );

    Branch_ControlUnit u_branch_ctrl (
        .Lst(Lst_EX), .Lst_Unsign(Lst_Unsign_EX), .Grt_eql(Grt_eql_EX),
        .Grt_eql_Unsign(Grt_eql_Unsign_EX), .Eql(Eql_EX), .Branch(Branch_EX),
        .func3(func3_EX), .ALU_op(ALU_op_EX), .flush(),
        .Branch_taken(branch_taken_EX), .Jump_taken(jump_taken_EX), .pc_sel(pc_sel_EX)
    );

    Branch_control_unit u_branch_hazard (
        .branch_taken_EX(branch_taken_EX), .jump_EX(jump_taken_EX),
        .valid_EX(valid_EX), .flush(flush_control)
    );

    assign next_pc = (flush_control) ?
                     ((pc_sel_EX==2'b01) ? branch_target_EX :
                      (pc_sel_EX==2'b10) ? jal_target_EX :
                                           jalr_target_EX) :
                     pc_plus4_IF1;

    // A taken EX-stage redirect always wins over a younger load-use stall.
    PC u_pc (
        .PC_out(pc_current), .PC_in(next_pc), .clk(clk), .rst(rst),
        .PC_hold((~PCWrite) && !flush_control)
    );

    PC_adder u_pc_add (.PC_plus4(pc_plus4_IF1), .PC_in(pc_current));

    IF1_IF2_reg u_if1_if2 (
        .PC_IF2(PC_IF2), .valid_IF2(valid_IF2),
        .PC_IF1(pc_current), .valid_IF1(valid_IF1), .clk(clk), .rst(rst),
        .write_enable(PC_IF2_Write), .flush(flush_control)
    );

    IF2_ID1_reg u_if2_id1 (
        .IR_ID1(IR_ID1), .PC_ID1(PC_ID1), .valid_ID1(valid_ID1),
        .Instruction_IF2(Instruction_IF2), .PC_IF2(PC_IF2), .valid_IF2(valid_IF2),
        .clk(clk), .rst(rst), .write_enable(IF2_ID1_Write), .flush(flush_control)
    );

    wire load_use_hazard;

    // Load-use hazard.
    hazard_detection_unit u_hazard (
        .IR_ID2(IR_ID2), .valid_ID2(valid_ID2),
        .rs1_ID2(rs1_ID2), .rs2_ID2(rs2_ID2),
        .rd_EX(rd_EX), .MemRead_EX(MemRead_EX), .valid_EX(valid_EX),
        .load_use_hazard(load_use_hazard), .PCWrite(PCWrite), .PC_IF2_Write(PC_IF2_Write),
        .IF2_ID1_Write(IF2_ID1_Write), .ID1_ID2_Write(ID1_ID2_Write),
        .ID2_EX_Flush(ID2_EX_Flush)
    );

    ID2_EX_reg u_id2_ex (
        .clk(clk), .rst(rst), .flush(flush_control || ID2_EX_Flush),
        .PC_ID2(PC_ID2), .rs1_data_ID2(rs1_data_ID2), .rs2_data_ID2(rs2_data_ID2),
        .imm_ID2(imm_ID2), .rs1_ID2(rs1_ID2), .rs2_ID2(rs2_ID2), .rd_ID2(rd_ID2),
        .func3_ID2(func3_ID2), .func7_6_ID2(func7_6_ID2), .valid_ID2(valid_ID2),
        .RegWrite_ID2(RegWrite_ID2), .MemWrite_ID2(MemWrite_ID2), .MemRead_ID2(MemRead_ID2),
        .Branch_ID2(Branch_ID2), .jump_ID2(jump_ID2), .Writebacksel_ID2(Writebacksel_ID2),
        .ALU_op_ID2(ALU_op_ID2), .ALUsrcA_ID2(ALUsrcA_ID2), .ALUsrcB_ID2(ALUsrcB_ID2),
        .PC_EX(PC_EX), .rs1_data_EX(rs1_data_EX), .rs2_data_EX(rs2_data_EX), .imm_EX(imm_EX),
        .rs1_EX(rs1_EX), .rs2_EX(rs2_EX), .rd_EX(rd_EX), .func3_EX(func3_EX),
        .func7_6_EX(func7_6_EX), .valid_EX(valid_EX), .RegWrite_EX(RegWrite_EX),
        .MemWrite_EX(MemWrite_EX), .MemRead_EX(MemRead_EX), .Branch_EX(Branch_EX),
        .jump_EX(jump_EX), .Writebacksel_EX(Writebacksel_EX), .ALU_op_EX(ALU_op_EX),
        .ALUsrcA_EX(ALUsrcA_EX), .ALUsrcB_EX(ALUsrcB_EX)
    );

    // ------------------------------------------------------------------------
    // MEM
    // ------------------------------------------------------------------------
    wire        valid_MEM;
    wire [31:0] ALU_result_MEM;
    wire [31:0] store_data_MEM;
    wire [4:0]  rd_MEM;
    wire        RegWrite_MEM, MemWrite_MEM, MemRead_MEM;
    wire [1:0]  Writebacksel_MEM;
    wire [2:0]  func3_MEM;
    wire [31:0] PC_MEM;
    wire [31:0] Mem_data_MEM;

    EX_MEM_reg u_ex_mem (
        .clk(clk), .rst(rst), .valid_EX(valid_EX), .ALU_result_EX(ALU_result_EX),
        .store_data_EX(store_data_EX), .rd_EX(rd_EX), .RegWrite_EX(RegWrite_EX),
        .MemWrite_EX(MemWrite_EX), .MemRead_EX(MemRead_EX),
        .Writebacksel_EX(Writebacksel_EX), .func3_EX(func3_EX), .PC_EX(PC_EX),
        .valid_MEM(valid_MEM), .ALU_result_MEM(ALU_result_MEM), .store_data_MEM(store_data_MEM),
        .rd_MEM(rd_MEM), .RegWrite_MEM(RegWrite_MEM), .MemWrite_MEM(MemWrite_MEM),
        .MemRead_MEM(MemRead_MEM), .Writebacksel_MEM(Writebacksel_MEM),
        .func3_MEM(func3_MEM), .PC_MEM(PC_MEM)
    );

    Data_memory u_dmem (
        .Read_data(Mem_data_MEM), .Write_data(store_data_MEM),
        .MemRead(MemRead_MEM), .MemWrite(MemWrite_MEM), .clk(clk), .rst(rst),
        .Read_addr(ALU_result_MEM), .Write_addr(ALU_result_MEM), .func3(func3_MEM)
    );

    MEM_WB_reg u_mem_wb (
        .clk(clk), .rst(rst), .valid_MEM(valid_MEM),
        .ALU_result_MEM(ALU_result_MEM), .Mem_data_MEM(Mem_data_MEM), .PC_MEM(PC_MEM),
        .rd_MEM(rd_MEM), .RegWrite_MEM(RegWrite_MEM), .Writebacksel_MEM(Writebacksel_MEM),
        .valid_WB(valid_WB), .ALU_result_WB(ALU_result_WB), .Mem_data_WB(Mem_data_WB),
        .PC_WB(PC_WB), .rd_WB(rd_WB), .RegWrite_WB(RegWrite_WB), .Writebacksel_WB(Writebacksel_WB)
    );

    assign debug_pc     = pc_current;
    assign debug_wb_data = wb_data;
    assign debug_wb_rd  = rd_WB;
    assign debug_wb_we  = valid_WB && RegWrite_WB;

endmodule
