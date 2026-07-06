# Recommended Cleanup Roadmap

## Phase 1 — Make the Design Buildable

1. Rename or revise the system top module to expose all physical I/O.
2. Fix the `clk0` / `clk_0` naming mismatch.
3. Correct SCCB write data widths and validate one register write in simulation.
4. Decide whether SCCB read support is needed; otherwise remove it from the build list.
5. Regenerate Quartus IP and add the board `.qsf` file.

## Phase 2 — Make the Video Architecture Robust

1. Verify that the OV7670 output format and resolution match the capture logic.
2. Reset line-buffer state at each frame/line boundary where needed.
3. Replace the current FIFO with a defined line-buffer or frame-buffer strategy.
4. Synchronize camera/pixel clock and VGA clock domains if they are different.
5. Drive VGA pixel reads from the active-area timing, not directly from camera valid.

## Phase 3 — Make It Portfolio Ready

1. Rename modules with descriptive names (for example, `rgb565_to_gray`, `gaussian3x3`, `sobel3x3`, `vga_640x480`).
2. Add a clean block diagram and timing diagram.
3. Add self-checking testbenches or assertions.
4. Add a short demo video / image in `assets/`.
5. Document FPGA board, clock frequency, camera wiring, and VGA wiring.
