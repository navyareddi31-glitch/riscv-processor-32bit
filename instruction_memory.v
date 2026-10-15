// Small asynchronous-read instruction ROM for the learning processor.
// Each entry contains one 32-bit instruction. Byte addresses are word-aligned.
module instruction_memory #(
    parameter WORDS = 64
) (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:WORDS-1];
    integer i;

    // NOP = ADDI x0, x0, 0. Unused locations also execute as NOPs.
    // This example intentionally inserts NOPs between dependent instructions
    // because the starter pipeline has no general ALU forwarding network.
    initial begin
        for (i = 0; i < WORDS; i = i + 1)
            mem[i] = 32'h00000013;

        mem[0]  = 32'h00700093; // addi x1, x0, 7
        mem[1]  = 32'h00000013; // nop
        mem[2]  = 32'h00000013; // nop
        mem[3]  = 32'h00000013; // nop
        mem[4]  = 32'h00500113; // addi x2, x0, 5
        mem[5]  = 32'h00000013; // nop
        mem[6]  = 32'h00000013; // nop
        mem[7]  = 32'h00000013; // nop
        mem[8]  = 32'h002081B3; // add  x3, x1, x2  -> 12
        mem[9]  = 32'h00000013; // nop
        mem[10] = 32'h00000013; // nop
        mem[11] = 32'h00000013; // nop
        mem[12] = 32'h40218233; // sub  x4, x3, x2  -> 7
        mem[13] = 32'h00000013; // nop
        mem[14] = 32'h00000013; // nop
        mem[15] = 32'h00000013; // nop
        mem[16] = 32'h00302023; // sw   x3, 0(x0)
        mem[17] = 32'h00000013; // nop
        mem[18] = 32'h00000013; // nop
        mem[19] = 32'h00000013; // nop
        mem[20] = 32'h00002283; // lw   x5, 0(x0) -> 12
        mem[21] = 32'h00000013; // nop
        mem[22] = 32'h00000013; // nop
        mem[23] = 32'h00000013; // nop
        mem[24] = 32'h00128313; // addi x6, x5, 1 -> 13
        mem[25] = 32'h00000013; // nop
        mem[26] = 32'h00000013; // nop
        mem[27] = 32'h00000013; // nop
        mem[28] = 32'h00000073; // ecall (learning testbench halt convention)
    end

    assign instr = mem[addr[31:2] % WORDS];
endmodule
