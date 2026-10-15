# RV32I 5-Stage Pipelined Processor — Beginner Learning Edition

This package is a learning-friendly rewrite of the uploaded project structure. It is intentionally smaller and more heavily commented than the original project.

## Important before replacing your project

- **Make a backup of your original files first.**
- This is a teaching scaffold, not a verified drop-in replacement for the original full RV32I project. I could not run a simulator in this environment, so please compile and test it locally before relying on its output.
- It implements a small subset of RV32I instructions to make the datapath easier to learn: `ADD`, `SUB`, `AND`, `OR`, `ADDI`, `LW`, `SW`, `BEQ`, and `JAL`.
- It does **not** include the original project's forwarding network, branch history table, randomized verification, full RV32I instruction coverage, or original performance/synthesis flows. The demo program uses NOPs between dependent instructions to avoid needing general forwarding.
- Learn with this package separately first. Do not overwrite your original project until you understand the differences and have tested your setup.

## Tools

With Icarus Verilog installed:

```bash
iverilog -g2012 -o sim.vvp rtl/*.v tb/tb_riscv32_pipeline.v
vvp sim.vvp
```

The testbench prints `PASS` when the included short program reaches its expected register values.

## Files

- `rtl/program_counter.v` — PC register and next-PC input
- `rtl/instruction_memory.v` — small instruction ROM
- `rtl/register_file.v` — 32 × 32-bit register bank
- `rtl/alu.v` — arithmetic and logic
- `rtl/control_unit.v` — instruction decoding
- `rtl/pipeline_registers.v` — IF/ID, ID/EX, EX/MEM, MEM/WB registers
- `rtl/hazard_unit.v` — basic load-use stall detector (forwarding is not included)
- `rtl/riscv32_pipeline.v` — top-level processor wiring
- `tb/tb_riscv32_pipeline.v` — simple self-checking testbench
- `learning/LEARNING_GUIDE.md` — suggested order and exercises

## Design caveat

This starter implementation is designed for learning and discussion. Treat it as a scaffold to understand the architecture, not as a production CPU or a compliance-tested RISC-V implementation. Review the code, run the testbench, and add features one at a time.
