# OV7670 FPGA Real-Time Edge Detection Pipeline

An RTL project that captures an OV7670 camera stream, converts RGB565 pixels to grayscale, applies a 3×3 Gaussian-style filter, binarizes the image, detects edges with a Sobel operator, and displays the processed result through a 640×480 VGA interface.

> **Repository status:** This repository reorganizes the supplied RTL into a reviewable structure. The functional RTL was kept unchanged during organization. Several integration issues in the original top-level and SCCB-read code are documented in [`docs/known-issues.md`](docs/known-issues.md) and should be resolved before claiming hardware-ready operation.

## Data Path

```text
OV7670 camera
  VSYNC / HREF / D[7:0]
          │
          ▼
      capture
          │ RGB565 pixels
          ▼
        gray
          │ grayscale pixels
          ▼
       filter
          │ filtered pixels
          ▼
         bin
          │ binary pixels
          ▼
        sobel
          │ edge map
          ▼
         fifo
          │
          ▼
         vga ──► VGA monitor
```

The camera configuration path is:

```text
key → ov_config → SCCB_write → OV7670 SCCB interface
```

## Repository Layout

```text
.
├── rtl/
│   ├── top/                 # System integration top module
│   ├── control/             # Key input edge detection
│   ├── camera/              # Pixel capture and OV7670 configuration
│   ├── image_processing/    # Gray, filter, binarization, Sobel
│   ├── video_output/        # FIFO and VGA timing/output
│   └── ip/                  # Intel/Altera-generated PLL and line-buffer IP
├── sim/
│   ├── tb/                  # Testbenches
│   └── filelists/           # Simulation source lists
├── docs/                    # Architecture, module guide, known issues
├── constraints/             # Board-specific pin constraints go here
├── quartus/                 # Quartus .qpf/.qsf project files go here
└── assets/                  # Waveforms, block diagrams, board/demo photos
```

## Main Modules

| Stage | File | Responsibility |
|---|---|---|
| System integration | `rtl/top/ov.v` | Connects configuration, capture, processing, FIFO, and VGA blocks |
| Camera capture | `rtl/camera/capture.v` | Reconstructs RGB565 pixels from OV7670 8-bit output |
| Gray conversion | `rtl/image_processing/gray.v` | Converts RGB565 to 8-bit grayscale |
| Smoothing | `rtl/image_processing/filter.v` | Applies a 3×3 weighted filter using line-buffer IP |
| Thresholding | `rtl/image_processing/bin.v` | Converts grayscale pixels into binary pixels |
| Edge detection | `rtl/image_processing/sobel.v` | Applies a Sobel-based edge detector |
| Display buffer | `rtl/video_output/fifo.v` | Stores edge-map pixels prior to display |
| VGA output | `rtl/video_output/vga.v` | Generates 640×480 timing and black/white pixels |
| Sensor configuration | `rtl/camera/ov_config.v`, `rtl/camera/sccb/SCCB_write.v` | Streams OV7670 register configuration through SCCB |

See [`docs/module-guide.md`](docs/module-guide.md) for module dependencies and interfaces.

## Toolchain

The included IP wrapper files were generated for **Intel/Altera Quartus Prime 18.1** and instantiate `altpll` / `altshift_taps`. For synthesis or vendor-library simulation, create or open a Quartus project and regenerate/import the corresponding IP as needed.

The repository does **not** include a `.qpf`, `.qsf`, or board pin-constraint file because they were not supplied. Add them under `quartus/` and `constraints/`.

## Simulation

The supplied testbenches are located in `sim/tb/`:

- `capture_testbench.v`: camera capture through VGA pipeline
- `config_testbench.v`: key, OV7670 configuration sequence, and SCCB write behavior
- `vga_testbench.v`: Sobel → FIFO → VGA path

Source lists are in `sim/filelists/`. Vendor-generated line-buffer and PLL wrappers require the Intel FPGA simulation libraries. Refer to [`sim/README.md`](sim/README.md).

## Hardware Integration Checklist

Before board synthesis:

1. Resolve the top-level port/name issues listed in [`docs/known-issues.md`](docs/known-issues.md).
2. Add the actual board clock, reset, key, OV7670, SCCB, and VGA ports to the top-level design.
3. Regenerate `pll`, `shift_ram`, and `sobel_shift` IP for the selected device and clock plan.
4. Add board pin assignments and I/O standards under `constraints/`.
5. Verify SCCB register writes on a logic analyzer or SignalTap before enabling camera capture.
6. Validate image dimensions, FIFO read scheduling, and VGA frame synchronization on hardware.


No license has been selected yet. Add one only if you intend to make reuse permissions explicit.
