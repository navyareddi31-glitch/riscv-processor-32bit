// RV32I integer register file: 32 registers, each 32 bits wide.
// x0 is hardwired to zero. Two combinational read ports and one clocked write port.
module register_file (
    input  wire        clk,
    input  wire        rst,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    output wire [31:0] rd1,
    output wire [31:0] rd2,
    input  wire        we,
    input  wire [4:0]  wa,
    input  wire [31:0] wd
);
    reg [31:0] regs [0:31];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else if (we && (wa != 5'd0)) begin
            regs[wa] <= wd;
        end
    end

    // Explicit x0 behavior plus WB-to-read write-through bypass.
    assign rd1 = (rs1 == 5'd0) ? 32'd0 :
                 ((we && (wa == rs1)) ? wd : regs[rs1]);
    assign rd2 = (rs2 == 5'd0) ? 32'd0 :
                 ((we && (wa == rs2)) ? wd : regs[rs2]);
endmodule
