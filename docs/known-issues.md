# Known Integration Issues

These observations were made while organizing the supplied RTL. **No original functional source was modified in this repository.** Treat this file as a pre-synthesis checklist rather than a claim that the listed problems are the only problems.

## 1. Top-Level `ov.v` Is Not Self-Contained

The top module declares `wire clk0` but instantiates/uses `clk_0`. It also references camera signals `vsync`, `href`, and `din` without declaring them as input ports. The generated SCCB signals `sio_c` and `sio_d` are internal wires rather than declared top-level outputs.

**Recommended correction:** declare the intended camera/SCCB ports in the module interface and use one consistent pixel-clock signal name.

## 2. `SCCB_write.v` Port Widths Need Review

`subaddress_data` and `data` are declared as scalar inputs, while the body concatenates them as 8-bit fields. The configuration testbench connects 8-bit nets, which will be truncated by the current module declaration.

**Recommended correction:** declare both as `input [7:0]`.

## 3. `SCCB_read.v` Is Incomplete / Unused

`SCCB_read.v` references symbols such as `ID_data` and `subaddress_data` that are not declared in its module interface. It also declares output ports as scalar while internally using 8-bit registers. The top-level does not instantiate it directly.

**Recommended correction:** either complete and verify the read path, or omit it from the hardware build until it is needed.

## 4. FIFO Is Not Truly Parameterized

`fifo.v` declares `WIDTH` and `DEPTH` parameters but hard-codes pointer widths for an effective depth of 1024. The current `DEPTH=1280` declaration therefore does not match the pointer addressing range.

**Recommended correction:** derive pointer/address widths with `$clog2(DEPTH)` and decide whether one full 640×480 frame, a line buffer, or a different buffering strategy is intended.

## 5. VGA Read Scheduling Requires Hardware Review

In the top-level and supplied testbenches, FIFO `rd_en` is tied to Sobel output validity instead of being driven by VGA active-display timing. This may not provide the correct producer/consumer timing for camera-to-monitor streaming.

**Recommended correction:** define a clock-domain/frame-buffer architecture, then drive FIFO reads from VGA timing or use a dual-clock frame buffer.

## 6. Vendor IP Metadata Is Missing

Only the generated Verilog wrappers (`pll.v`, `shift_ram.v`, and `sobel_shift.v`) were supplied. Quartus project/IP metadata files were not provided.

**Recommended correction:** regenerate these IP blocks for the selected board/device and check their clock, width, depth, and tap-distance settings.
