# Simulation Notes

The testbenches were retained as supplied and placed in `sim/tb/`.

## File Lists

Run from the repository root and select one source list:

| File list | Testbench top |
|---|---|
| `sim/filelists/config.f` | `config_testbench` |
| `sim/filelists/capture_pipeline.f` | `capture_testbench` |
| `sim/filelists/vga.f` | `vga_testbench` |

## Intel/Altera Library Requirement

`shift_ram.v`, `sobel_shift.v`, and `pll.v` instantiate Intel/Altera megafunctions (`altshift_taps` and `altpll`). Use the matching Quartus/ModelSim Intel FPGA libraries, or regenerate/rewrite these blocks as synthesizable RTL before using an open-source simulator.

Illustrative ModelSim/Questa flow:

```tcl
vlib work
vlog -work work -L altera_mf -f sim/filelists/config.f
vsim -L altera_mf work.config_testbench
run -all
```

The exact library path and library mapping depend on the installed Quartus version.
