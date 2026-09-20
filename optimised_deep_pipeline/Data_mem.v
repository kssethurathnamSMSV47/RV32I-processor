// ================================================================
// BYTE-ADDRESSABLE RV32I DATA MEMORY
//
// Memory organization:
//   8192 bytes = 8 KB
//
// Addressing:
//   Data_Mem[address] = one byte
//
// Supported loads:
//   LB, LH, LW, LBU, LHU
//
// Supported stores:
//   SB, SH, SW
//
// Little-endian organization.
//
// Read  : combinational
// Write : synchronous
// ================================================================

module Data_memory(
    Read_data,
    Write_data,
    MemRead,
    MemWrite,
    clk,
    rst,
    Read_addr,
    Write_addr,
    func3
);

    input         clk;
    input         rst;

    input  [31:0] Read_addr;
    input  [31:0] Write_addr;

    input  [2:0]  func3;

    input         MemRead;
    input         MemWrite;

    input  [31:0] Write_data;

    output reg [31:0] Read_data;

    // ------------------------------------------------------------
    // 8 KB byte-addressable memory
    // ------------------------------------------------------------
    reg [7:0] Data_Mem [0:8191];

    integer i;

    always @(*) begin

        Read_data = 32'h00000000;

        if (MemRead) begin

            case (func3)

                // ------------------------------------------------
                // LB : Load Byte, sign extended
                // ------------------------------------------------
                3'b000: begin

                    Read_data = {
                        {24{Data_Mem[Read_addr[14:0]][7]}},
                        Data_Mem[Read_addr[14:0]]
                    };

                end


                // ------------------------------------------------
                // LH : Load Halfword, sign extended
                //
                3'b001: begin

                    Read_data = {
                        {16{Data_Mem[Read_addr[14:0] + 15'd1][7]}},
                        Data_Mem[Read_addr[14:0] + 15'd1],
                        Data_Mem[Read_addr[14:0]]
                    };

                end


                // ------------------------------------------------
                // LW : Load Word
                //
                3'b010: begin

                    Read_data = {
                        Data_Mem[Read_addr[14:0] + 15'd3],
                        Data_Mem[Read_addr[14:0] + 15'd2],
                        Data_Mem[Read_addr[14:0] + 15'd1],
                        Data_Mem[Read_addr[14:0]]
                    };

                end


                // ------------------------------------------------
                // LBU : Load Byte, zero extended
                // ------------------------------------------------
                3'b100: begin

                    Read_data = {
                        24'h000000,
                        Data_Mem[Read_addr[14:0]]
                    };

                end


                // ------------------------------------------------
                // LHU : Load Halfword, zero extended
                // ------------------------------------------------
                3'b101: begin

                    Read_data = {
                        16'h0000,
                        Data_Mem[Read_addr[14:0] + 15'd1],
                        Data_Mem[Read_addr[14:0]]
                    };

                end


                default: begin
                    Read_data = 32'h00000000;
                end

            endcase

        end

    end


    // ============================================================
    // WRITE LOGIC
    //
    // Writes occur on the rising edge of clk.
    //
    // Little endian:
    //

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            for (i = 0; i < 32768; i = i + 1)
                Data_Mem[i] <= 8'h00;

        end

        else if (MemWrite) begin

            case (func3)

                // ------------------------------------------------
                // SB : Store Byte
                // ------------------------------------------------
                3'b000: begin

                    Data_Mem[Write_addr[14:0]]
                        <= Write_data[7:0];

                end


                // ------------------------------------------------
                // SH : Store Halfword
                //
                3'b001: begin

                    Data_Mem[Write_addr[14:0]]
                        <= Write_data[7:0];

                    Data_Mem[Write_addr[14:0] + 15'd1]
                        <= Write_data[15:8];

                end


                // ------------------------------------------------
                // SW : Store Word
                //
                3'b010: begin

                    Data_Mem[Write_addr[14:0]]
                        <= Write_data[7:0];

                    Data_Mem[Write_addr[14:0] + 15'd1]
                        <= Write_data[15:8];

                    Data_Mem[Write_addr[14:0] + 15'd2]
                        <= Write_data[23:16];

                    Data_Mem[Write_addr[14:0] + 15'd3]
                        <= Write_data[31:24];

                end


                default: begin
                    // No memory write
                end

            endcase

        end

    end

endmodule