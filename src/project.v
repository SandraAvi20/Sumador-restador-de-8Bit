/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_adder_sub_8b_2load (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
// Control signals from uio_in
    wire       load_a   = uio_in[0];
    wire       load_b   = uio_in[1];
    wire       sub_mode = uio_in[2]; // 0: suma (A + B), 1: resta (A - B)

    // Internal registers for the two 8-bit loads
    reg  [7:0] reg_a;
    reg  [7:0] reg_b;

    always @(posedge clk) begin
        if (!rst_n) begin
            reg_a <= 8'd0;
            reg_b <= 8'd0;
        end else begin
            if (load_a) begin
                reg_a <= ui_in;
            end
            if (load_b) begin
                reg_b <= ui_in;
            end
        end
    end

    // Operating B inverted bit by bit if we are in subtraction mode (two's complement)
    wire [7:0] b_mux = sub_mode ? ~reg_b : reg_b;
    wire       cin   = sub_mode ? 1'b1   : 1'b0;

    // 9-bit sum to capture the carry/borrow in the MSB
    wire [8:0] alu_ext = {1'b0, reg_a} + {1'b0, b_mux} + {{8{1'b0}}, cin};

    assign uo_out         = alu_ext[7:0];
    assign uio_out        = {alu_ext[8], 7'b0000_000};
    assign uio_oe         = 8'b1000_0000; // Solo uio[7] es salida; uio[6:0] quedan como entradas

    // Avoid warnings for unused signals
    wire _unused = &{ena, uio_in[7:3], 1'b0};

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
