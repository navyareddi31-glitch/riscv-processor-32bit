// Small ALU used by the learning CPU.
// op: 000 ADD, 001 SUB, 010 AND, 011 OR, 100 XOR, 101 SLT signed.
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  op,
    output reg  [31:0] result,
    output wire        eq,
    output wire        lt,
    output wire        ltu
);
    always @* begin
        case (op)
            3'b000: result = a + b;
            3'b001: result = a - b;
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            3'b101: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            default: result = 32'd0;
        endcase
    end

    assign eq  = (a == b);
    assign lt  = ($signed(a) < $signed(b));
    assign ltu = (a < b);
endmodule
