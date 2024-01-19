# mips32

Project: Multi-Cycle MIPS Architecture Processor for FPGA
Description: Implemented a 32-bit MIPS processor with a multi-cycle architecture on an FPGA, featuring stages such as Instruction Fetch (IF), Instruction Decode (ID), Execution (EX), Memory (MEM), and Write Back (WB).

Key Contributions:

Developed Verilog module (mips_32.v) to define the MIPS processor and handle instruction execution.
Utilized pipeline registers for efficient data flow between pipeline stages.
Implemented a hazard detection unit to identify and handle data and control hazards.
Integrated a data memory module for simulating memory access in load and store instructions.
Included a forwarding unit to resolve data hazards through data forwarding.
Achievements:

Successfully simulated the design to validate functionality.
Conducted synthesis and implementation for a specific FPGA platform.
Tested the MIPS processor with sample programs, ensuring correct operation.
Technologies Used: Verilog, FPGA tools.

Outcome: Customizable and extensible multi-cycle MIPS processor suitable for integration into FPGA projects.
