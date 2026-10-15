// Program counter (PC): holds the byte address of the instruction being fetched.
// Reset is synchronous: the PC is reset on a rising clock edge when rst is high.
module program_counter (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);
    always @(posedge clk) begin
        if (rst)
            pc <= 32'd0;
        else if (en)
            pc <= pc_next;
    end
endmodule
