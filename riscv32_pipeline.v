// Learning-focused 5-stage pipeline skeleton.
// Supported subset: ADD, SUB, AND, OR, XOR, ADDI, LW, SW, BEQ, JAL.
// Forwarding and branch prediction are deliberately omitted to keep the datapath
// readable. The hazard unit inserts a bubble for a load-use dependency.
module riscv32_pipeline (
    input wire clk,
    input wire rst,
    output reg halted
);
    wire [31:0] pc, pc_next, if_instr;
    wire pc_en, stall;
    wire [31:0] ifid_pc, ifid_instr;
    wire ifid_valid;

    wire [4:0] id_rs1 = ifid_instr[19:15];
    wire [4:0] id_rs2 = ifid_instr[24:20];
    wire [4:0] id_rd  = ifid_instr[11:7];
    wire [6:0] id_opcode = ifid_instr[6:0];

    wire id_reg_write, id_mem_read, id_mem_write, id_alu_src_imm, id_mem_to_reg;
    wire id_branch_eq, id_jump;
    wire [2:0] id_alu_op;
    wire [1:0] id_imm_kind;
    wire [31:0] rf_rs1, rf_rs2, id_imm;

    wire ex_reg_write, ex_mem_read, ex_mem_write, ex_alu_src_imm, ex_mem_to_reg;
    wire ex_branch_eq, ex_jump;
    wire [2:0] ex_alu_op;
    wire [31:0] ex_pc, ex_rs1, ex_rs2, ex_imm;
    wire [4:0] ex_rs1_addr, ex_rs2_addr, ex_rd;
    wire ex_valid;

    wire [31:0] ex_operand_b, ex_alu_result;
    wire ex_eq, ex_lt, ex_ltu;
    wire [31:0] ex_pc4 = ex_pc + 4;
    wire [31:0] ex_target = ex_pc + ex_imm;
    wire ex_taken = ex_branch_eq && ex_eq;
    wire [31:0] ex_redirect_pc = ex_jump ? ex_target : ex_target;
    wire ex_redirect = ex_valid && (ex_jump || ex_taken);

    wire mem_reg_write, mem_mem_read, mem_mem_write, mem_mem_to_reg;
    wire [31:0] mem_pc4, mem_alu_result, mem_store_data;
    wire [4:0] mem_rd;
    wire mem_valid;

    wire wb_reg_write, wb_mem_to_reg;
    wire [31:0] wb_pc4, wb_alu_result, wb_load_data;
    wire [4:0] wb_rd;
    wire wb_valid;
    wire [31:0] wb_data = wb_mem_to_reg ? wb_load_data : wb_alu_result;

    wire [31:0] dmem_load_data;
    reg [31:0] dmem [0:255];
    integer di;

    program_counter u_pc(.clk(clk), .rst(rst), .en(pc_en), .pc_next(pc_next), .pc(pc));
    instruction_memory u_imem(.addr(pc), .instr(if_instr));

    assign pc_en = ~stall;
    assign pc_next = ex_redirect ? ex_redirect_pc : pc + 4;

    if_id_reg u_ifid(
        .clk(clk), .rst(rst), .en(~stall), .flush(ex_redirect),
        .pc_in(pc), .instr_in(if_instr), .pc_out(ifid_pc), .instr_out(ifid_instr),
        .valid_out(ifid_valid)
    );

    register_file u_rf(
        .clk(clk), .rst(rst),
        .rs1(id_rs1), .rs2(id_rs2), .rd1(rf_rs1), .rd2(rf_rs2),
        .we(wb_reg_write && wb_valid), .wa(wb_rd), .wd(wb_data)
    );

    control_unit u_control(
        .instr(ifid_instr),
        .reg_write(id_reg_write), .mem_read(id_mem_read), .mem_write(id_mem_write),
        .alu_src_imm(id_alu_src_imm), .mem_to_reg(id_mem_to_reg),
        .branch_eq(id_branch_eq), .jump(id_jump), .alu_op(id_alu_op), .imm_kind(id_imm_kind)
    );

    // RV32I immediate extraction: sign-extend I/S/B/J formats.
    reg [31:0] imm_temp;
    always @* begin
        case (id_imm_kind)
            2'b00: imm_temp = {{20{ifid_instr[31]}}, ifid_instr[31:20]};
            2'b01: imm_temp = {{20{ifid_instr[31]}}, ifid_instr[31:25], ifid_instr[11:7]};
            2'b10: imm_temp = {{19{ifid_instr[31]}}, ifid_instr[31], ifid_instr[7],
                               ifid_instr[30:25], ifid_instr[11:8], 1'b0};
            2'b11: imm_temp = {{11{ifid_instr[31]}}, ifid_instr[31], ifid_instr[19:12],
                               ifid_instr[20], ifid_instr[30:21], 1'b0};
            default: imm_temp = 0;
        endcase
    end
    assign id_imm = imm_temp;

    wire id_uses_rs1 = (id_opcode == 7'b0110011) || (id_opcode == 7'b0010011) ||
                       (id_opcode == 7'b0000011) || (id_opcode == 7'b0100011) ||
                       (id_opcode == 7'b1100011);
    wire id_uses_rs2 = (id_opcode == 7'b0110011) || (id_opcode == 7'b0100011) ||
                       (id_opcode == 7'b1100011);

    hazard_unit u_hazard(
        .id_ex_mem_read(ex_mem_read), .id_ex_rd(ex_rd),
        .if_id_rs1(id_rs1), .if_id_rs2(id_rs2),
        .if_id_uses_rs1(id_uses_rs1), .if_id_uses_rs2(id_uses_rs2),
        .stall(stall)
    );

    id_ex_reg u_idex(
        .clk(clk), .rst(rst), .bubble(stall || ex_redirect),
        .pc_in(ifid_pc), .rs1_in(rf_rs1), .rs2_in(rf_rs2), .imm_in(id_imm),
        .rs1_addr_in(id_rs1), .rs2_addr_in(id_rs2), .rd_in(id_rd),
        .reg_write_in(id_reg_write && ifid_valid), .mem_read_in(id_mem_read && ifid_valid),
        .mem_write_in(id_mem_write && ifid_valid), .alu_src_imm_in(id_alu_src_imm),
        .mem_to_reg_in(id_mem_to_reg), .branch_eq_in(id_branch_eq), .jump_in(id_jump),
        .alu_op_in(id_alu_op),
        .pc_out(ex_pc), .rs1_out(ex_rs1), .rs2_out(ex_rs2), .imm_out(ex_imm),
        .rs1_addr_out(ex_rs1_addr), .rs2_addr_out(ex_rs2_addr), .rd_out(ex_rd),
        .reg_write_out(ex_reg_write), .mem_read_out(ex_mem_read), .mem_write_out(ex_mem_write),
        .alu_src_imm_out(ex_alu_src_imm), .mem_to_reg_out(ex_mem_to_reg),
        .branch_eq_out(ex_branch_eq), .jump_out(ex_jump), .alu_op_out(ex_alu_op), .valid_out(ex_valid)
    );

    assign ex_operand_b = ex_alu_src_imm ? ex_imm : ex_rs2;
    alu u_alu(.a(ex_rs1), .b(ex_operand_b), .op(ex_alu_op),
              .result(ex_alu_result), .eq(ex_eq), .lt(ex_lt), .ltu(ex_ltu));

    ex_mem_reg u_exmem(
        .clk(clk), .rst(rst), .pc4_in(ex_pc4), .alu_in(ex_alu_result), .store_data_in(ex_rs2),
        .rd_in(ex_rd), .reg_write_in(ex_reg_write), .mem_read_in(ex_mem_read),
        .mem_write_in(ex_mem_write), .mem_to_reg_in(ex_mem_to_reg),
        .pc4_out(mem_pc4), .alu_out(mem_alu_result), .store_data_out(mem_store_data),
        .rd_out(mem_rd), .reg_write_out(mem_reg_write), .mem_read_out(mem_mem_read),
        .mem_write_out(mem_mem_write), .mem_to_reg_out(mem_mem_to_reg), .valid_out(mem_valid)
    );

    // Word-addressed behavioral data RAM. The learning program uses aligned addresses.
    always @(posedge clk) begin
        if (rst) begin
            for (di = 0; di < 256; di = di + 1)
                dmem[di] <= 0;
        end else if (mem_mem_write && mem_valid) begin
            dmem[mem_alu_result[9:2]] <= mem_store_data;
        end
    end
    assign dmem_load_data = dmem[mem_alu_result[9:2]];

    mem_wb_reg u_memwb(
        .clk(clk), .rst(rst), .pc4_in(mem_pc4), .alu_in(mem_alu_result),
        .load_data_in(dmem_load_data), .rd_in(mem_rd),
        .reg_write_in(mem_reg_write), .mem_to_reg_in(mem_mem_to_reg),
        .pc4_out(wb_pc4), .alu_out(wb_alu_result), .load_data_out(wb_load_data),
        .rd_out(wb_rd), .reg_write_out(wb_reg_write), .mem_to_reg_out(wb_mem_to_reg),
        .valid_out(wb_valid)
    );

    // ECALL halts the learning simulation. This is a test convention, not full trap logic.
    always @(posedge clk) begin
        if (rst) halted <= 1'b0;
        else if (ifid_valid && ifid_instr == 32'h00000073)
            halted <= 1'b1;
    end
endmodule
