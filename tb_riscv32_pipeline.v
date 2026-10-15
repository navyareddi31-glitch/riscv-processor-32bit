`timescale 1ns/1ps

module tb_riscv32_pipeline;
    reg clk = 0;
    reg rst = 1;
    wire halted;

    riscv32_pipeline dut(.clk(clk), .rst(rst), .halted(halted));
    always #5 clk = ~clk;

    integer cycles = 0;

    initial begin
        repeat (2) @(posedge clk);
        rst = 0;

        while (!halted && cycles < 100) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        // Allow pipeline writes to settle before checking.
        repeat (5) @(posedge clk);
        #1;

        $display("Cycles observed: %0d", cycles);
        $display("x3=%0d x4=%0d x5=%0d x6=%0d",
                 dut.u_rf.regs[3], dut.u_rf.regs[4],
                 dut.u_rf.regs[5], dut.u_rf.regs[6]);

        if (dut.u_rf.regs[3] == 12 &&
            dut.u_rf.regs[4] == 7  &&
            dut.u_rf.regs[5] == 12 &&
            dut.u_rf.regs[6] == 13) begin
            $display("PASS: learning processor test completed.");
            $finish;
        end else begin
            $display("FAIL: expected x3=12, x4=7, x5=12, x6=13.");
            $fatal(1);
        end
    end
endmodule
