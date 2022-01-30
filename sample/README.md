# Sample Project

Sample project used for regression tests when updating the main scripts.

This project implements a reaction timer, based on the 6.5.6 exercise of the
excelent *FPGA Prototyping By Verilog Examples* book by Pong P. Chu and it
is meant to be loaded on a Digilent  Basys 3 development board.

The project is structured in two different ways, to emulate two different
use-cases:
- **Pure HDL sources**: With all the Verilog code under the `src` directory.
- **Block design**, **IPs** and **RTL modules**:
    With packaged IPs under the `ips` directory.
