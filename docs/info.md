<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a synchronous 8-bit adder and two's complement subtractor that loads two operands in two cycles for Tiny Tapeout:

- **Operand loading (`ui_in[7:0]`)**: On a rising clock edge (`clk`) with `rst_n = 1`, asserting `uio_in[0]` (`LOAD_A`) latches `ui_in[7:0]` into internal register `A`, and asserting `uio_in[1]` (`LOAD_B`) latches `ui_in[7:0]` into internal register `B`.
- **Arithmetic operation (`uio_in[2]`)**: When `SUB_MODE` (`uio_in[2]`) is `0`, it computes `A + B`; when `1`, it computes `A - B` using two's complement arithmetic.
- **Outputs (`uo_out[7:0]` and `uio_out[7]`)**: The 8-bit result appears on `uo_out[7:0]`, and the carry/borrow bit appears on `uio_out[7]` (`CARRY_OUT`).

## How to test

1. Assert `rst_n = 0` for at least one clock cycle to clear internal registers, then set `rst_n = 1`.
2. Place operand `A` on `ui_in[7:0]`, set `uio_in[0] = 1` for one clock cycle, and return `uio_in[0] = 0`.
3. Place operand `B` on `ui_in[7:0]`, set `uio_in[1] = 1` for one clock cycle, and return `uio_in[1] = 0`.
4. Set `uio_in[2] = 0` for addition or `uio_in[2] = 1` for subtraction, and read the 8-bit output on `uo_out[7:0]` and carry/borrow on `uio_out[7]`.

## External hardware

No external hardware is required. It can be driven with digital inputs/switches on `ui_in[7:0]` and `uio_in[2:0]`, and observed on `uo_out[7:0]` and `uio_out[7]` using LEDs or a logic analyzer.

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
