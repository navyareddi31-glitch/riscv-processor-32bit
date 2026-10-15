// Pipeline registers for the learning CPU.
// Each register separates two stages and holds their values between clock edges.
module if_id_reg (
    input wire clk, rst, en, flush,
    input wire [31:0] pc_in, instr_in,
    output reg [31:0] pc_out, instr_out,
    output reg valid_out
);
    always @(posedge clk) begin
        if (rst || flush) begin
            pc_out <= 0; instr_out <= 32'h00000013; valid_out <= 1'b0;
        end else if (en) begin
            pc_out <= pc_in; instr_out <= instr_in; valid_out <= 1'b1;
        end
    end
endmodule

module id_ex_reg (
    input wire clk, rst, bubble,
    input wire [31:0] pc_in, rs1_in, rs2_in, imm_in,
    input wire [4:0] rs1_addr_in, rs2_addr_in, rd_in,
    input wire reg_write_in, mem_read_in, mem_write_in, alu_src_imm_in, mem_to_reg_in,
    input wire branch_eq_in, jump_in,
    input wire [2:0] alu_op_in,
    output reg [31:0] pc_out, rs1_out, rs2_out, imm_out,
    output reg [4:0] rs1_addr_out, rs2_addr_out, rd_out,
    output reg reg_write_out, mem_read_out, mem_write_out, alu_src_imm_out, mem_to_reg_out,
    output reg branch_eq_out, jump_out,
    output reg [2:0] alu_op_out,
    output reg valid_out
);
    always @(posedge clk) begin
        if (rst || bubble) begin
            pc_out <= 0; rs1_out <= 0; rs2_out <= 0; imm_out <= 0;
            rs1_addr_out <= 0; rs2_addr_out <= 0; rd_out <= 0;
            reg_write_out <= 0; mem_read_out <= 0; mem_write_out <= 0;
            alu_src_imm_out <= 0; mem_to_reg_out <= 0; branch_eq_out <= 0;
            jump_out <= 0; alu_op_out <= 0; valid_out <= 0;
        end else begin
            pc_out <= pc_in; rs1_out <= rs1_in; rs2_out <= rs2_in; imm_out <= imm_in;
            rs1_addr_out <= rs1_addr_in; rs2_addr_out <= rs2_addr_in; rd_out <= rd_in;
            reg_write_out <= reg_write_in; mem_read_out <= mem_read_in; mem_write_out <= mem_write_in;
            alu_src_imm_out <= alu_src_imm_in; mem_to_reg_out <= mem_to_reg_in;
            branch_eq_out <= branch_eq_in; jump_out <= jump_in; alu_op_out <= alu_op_in;
            valid_out <= 1'b1;
        end
    end
endmodule

module ex_mem_reg (
    input wire clk, rst,
    input wire [31:0] pc4_in, alu_in, store_data_in,
    input wire [4:0] rd_in,
    input wire reg_write_in, mem_read_in, mem_write_in, mem_to_reg_in,
    output reg [31:0] pc4_out, alu_out, store_data_out,
    output reg [4:0] rd_out,
    output reg reg_write_out, mem_read_out, mem_write_out, mem_to_reg_out,
    output reg valid_out
);
    always @(posedge clk) begin
        if (rst) begin
            pc4_out <= 0; alu_out <= 0; store_data_out <= 0; rd_out <= 0;
            reg_write_out <= 0; mem_read_out <= 0; mem_write_out <= 0;
            mem_to_reg_out <= 0; valid_out <= 0;
        end else begin
            pc4_out <= pc4_in; alu_out <= alu_in; store_data_out <= store_data_in; rd_out <= rd_in;
            reg_write_out <= reg_write_in; mem_read_out <= mem_read_in; mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in; valid_out <= 1'b1;
        end
    end
endmodule

module mem_wb_reg (
    input wire clk, rst,
    input wire [31:0] pc4_in, alu_in, load_data_in,
    input wire [4:0] rd_in,
    input wire reg_write_in, mem_to_reg_in,
    output reg [31:0] pc4_out, alu_out, load_data_out,
    output reg [4:0] rd_out,
    output reg reg_write_out, mem_to_reg_out,
    output reg valid_out
);
    always @(posedge clk) begin
        if (rst) begin
            pc4_out <= 0; alu_out <= 0; load_data_out <= 0; rd_out <= 0;
            reg_write_out <= 0; mem_to_reg_out <= 0; valid_out <= 0;
        end else begin
            pc4_out <= pc4_in; alu_out <= alu_in; load_data_out <= load_data_in; rd_out <= rd_in;
            reg_write_out <= reg_write_in; mem_to_reg_out <= mem_to_reg_in; valid_out <= 1'b1;
        end
    end
endmodule
