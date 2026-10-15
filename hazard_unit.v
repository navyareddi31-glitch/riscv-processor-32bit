// Minimal load-use hazard detector for the learning subset.
// This module inserts one bubble after LW when the next instruction needs its result.
// This version intentionally does not include EX/MEM or MEM/WB forwarding.
module hazard_unit (
    input  wire       id_ex_mem_read,
    input  wire [4:0] id_ex_rd,
    input  wire [4:0] if_id_rs1,
    input  wire [4:0] if_id_rs2,
    input  wire       if_id_uses_rs1,
    input  wire       if_id_uses_rs2,
    output wire       stall
);
    wire hit_rs1 = if_id_uses_rs1 && (if_id_rs1 == id_ex_rd);
    wire hit_rs2 = if_id_uses_rs2 && (if_id_rs2 == id_ex_rd);
    assign stall = id_ex_mem_read && (id_ex_rd != 0) && (hit_rs1 || hit_rs2);
endmodule
