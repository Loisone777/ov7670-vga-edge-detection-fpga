# Module Guide

## Top Level

| Module | File | Instantiates |
|---|---|---|
| `ov` | `rtl/top/ov.v` | `key`, `SCCB_write`, `ov_config`, `pll`, `capture`, `gray`, `filter`, `bin`, `sobel`, `fifo`, `vga` |

## Camera and Configuration

| Module | File | Purpose |
|---|---|---|
| `capture` | `rtl/camera/capture.v` | Receives OV7670 byte stream and reconstructs RGB565 pixels. |
| `ov_config` | `rtl/camera/ov_config.v` | Provides the ordered list of OV7670 register address/data pairs. |
| `SCCB_write` | `rtl/camera/sccb/SCCB_write.v` | Serializes configuration data onto SCCB clock/data outputs. |
| `SCCB` | `rtl/camera/sccb/SCCB.v` | Wrapper intended to combine SCCB read/write paths. |
| `SCCB_read` | `rtl/camera/sccb/SCCB_read.v` | Intended SCCB read transaction block; not used by the top-level. |
| `key` | `rtl/control/key.v` | Detects a key-input falling edge to trigger configuration. |

## Image Processing

| Module | File | Purpose | Dependency |
|---|---|---|---|
| `gray` | `rtl/image_processing/gray.v` | RGB565 to 8-bit grayscale conversion. | None |
| `filter` | `rtl/image_processing/filter.v` | 3 × 3 weighted smoothing filter. | `shift_ram` |
| `bin` | `rtl/image_processing/bin.v` | Threshold-based binarization. | None |
| `sobel` | `rtl/image_processing/sobel.v` | Sobel-style edge map creation. | `sobel_shift` |

## Video Output and IP

| Module | File | Purpose |
|---|---|---|
| `fifo` | `rtl/video_output/fifo.v` | Pixel storage FIFO. |
| `vga` | `rtl/video_output/vga.v` | Horizontal/vertical timing and monochrome VGA output. |
| `pll` | `rtl/ip/pll/pll.v` | Quartus-generated PLL wrapper. |
| `shift_ram` | `rtl/ip/line_buffer/shift_ram.v` | Quartus-generated 8-bit image line-buffer wrapper. |
| `sobel_shift` | `rtl/ip/line_buffer/sobel_shift.v` | Quartus-generated 1-bit image line-buffer wrapper. |

## Testbenches

| Testbench | Scope |
|---|---|
| `sim/tb/config_testbench.v` | Key trigger, OV7670 configuration sequence, SCCB write timing |
| `sim/tb/capture_testbench.v` | Camera capture through all image-processing blocks and VGA |
| `sim/tb/vga_testbench.v` | Sobel, FIFO, and VGA path |
