// Instruction decoder for the learning subset of RV32I.
// Unsupported encodings produce no side effects.
module control_unit (
    input  wire [31:0] instr,
    output reg         reg_write,
    output reg         mem_read,
    output reg         mem_write,
    output reg         alu_src_imm,
    output reg         mem_to_reg,
    output reg         branch_eq,
    output reg         jump,
    output reg  [2:0]  alu_op,
    output reg  [1:0]  imm_kind
);
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    // imm_kind: 00=I, 01=S, 10=B, 11=J
    always @* begin
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        alu_src_imm= 1'b0;
        mem_to_reg = 1'b0;
        branch_eq  = 1'b0;
        jump       = 1'b0;
        alu_op     = 3'b000;
        imm_kind   = 2'b00;

        case (opcode)
            7'b0110011: begin // R-type arithmetic/logical
                reg_write = 1'b1;
                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: alu_op = 3'b000; // ADD
                    {7'b0100000, 3'b000}: alu_op = 3'b001; // SUB
                    {7'b0000000, 3'b111}: alu_op = 3'b010; // AND
                    {7'b0000000, 3'b110}: alu_op = 3'b011; // OR
                    {7'b0000000, 3'b100}: alu_op = 3'b100; // XOR
                    default: begin reg_write = 1'b0; alu_op = 3'b000; end
                endcase
            end
            7'b0010011: begin // ADDI only in this learning subset
                reg_write   = (funct3 == 3'b000);
                alu_src_imm = 1'b1;
                alu_op      = 3'b000;
                imm_kind    = 2'b00;
            end
            7'b0000011: begin // LW only
                if (funct3 == 3'b010) begin
                    reg_write   = 1'b1;
                    mem_read    = 1'b1;
                    mem_to_reg  = 1'b1;
                    alu_src_imm = 1'b1;
                    imm_kind    = 2'b00;
                end
            end
            7'b0100011: begin // SW only
                if (funct3 == 3'b010) begin
                    mem_write   = 1'b1;
                    alu_src_imm = 1'b1;
                    imm_kind    = 2'b01;
                end
            end
            7'b1100011: begin // BEQ only
                if (funct3 == 3'b000) begin
                    branch_eq = 1'b1;
                    alu_op    = 3'b001;
                    imm_kind  = 2'b10;
                end
            end
            7'b1101111: begin // JAL
                reg_write = 1'b1;
                jump      = 1'b1;
                imm_kind  = 2'b11;
            end
            default: begin end
        endcase
    end
endmodule
