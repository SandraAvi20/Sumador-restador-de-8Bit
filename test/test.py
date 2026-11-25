# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


LOAD_A = 1 << 0    # uio_in[0]
LOAD_B = 1 << 1    # uio_in[1]
SUB_MODE = 1 << 2  # uio_in[2]


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    dut._log.info("Load A = 20 and B = 30, test addition (20 + 30 = 50)")
    # Load A = 20
    dut.ui_in.value = 20
    dut.uio_in.value = LOAD_A
    await ClockCycles(dut.clk, 1)

    # Load B = 30 (keep SUB_MODE = 0 for addition)
    dut.ui_in.value = 30
    dut.uio_in.value = LOAD_B
    await ClockCycles(dut.clk, 1)

    # Release load signals, keep SUB_MODE = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value.integer == 50, f"Expected 50, got {dut.uo_out.value.integer}"

    dut._log.info("Test subtraction (20 - 30)")
    # Enable SUB_MODE = 1
    dut.uio_in.value = SUB_MODE
    await ClockCycles(dut.clk, 1)

    # 20 - 30 in 8-bit two's complement is 246 (0xF6)
    assert dut.uo_out.value.integer == 246, f"Expected 246, got {dut.uo_out.value.integer}"

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
