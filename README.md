# HDL Implementation of Global Branch Predictors with Indexing
## ECE 586: Advanced Computer Architecture and Hardware Security Project

This repository contains the Verilog implementation of three global branch predictor architectures for an ECE 586 course project. The goal is to explore the effectiveness of different indexing methods for accessing the Branch History Table (BHT).

### Branch Predictor Architectures

1. **Global Predictor (gpredict)**
   - Uses only the Global History Register (GHR) as the index
   - Simple implementation but vulnerable to aliasing

2. **Global Predictor with Selection (gselect)**
   - Concatenates low-order bits from branch address and GHR
   - `index = {PC[1:0], GHR[1:0]}`
   - Reduces aliasing by considering branch address

3. **Global Predictor with Sharing (gshare)**
   - XORs branch address bits with GHR bits
   - `index = PC[3:0] ^ GHR[3:0]`
   - Most effective at reducing destructive aliasing

All three predictors use a 4-bit Global History Register and a 16-entry Branch History Table with 2-bit saturating counters.

### Repository Structure

```
├── src/
│   ├── gpredict.v             # Global predictor implementation
│   ├── gpredict_index.v       # Index generation for gpredict
│   ├── gselect.v              # Gselect predictor implementation
│   ├── gselect_index.v        # Index generation for gselect
│   ├── gshare.v               # Gshare predictor implementation
│   ├── gshare_index.v         # Index generation for gshare
│   └── Shared Components/
│       ├── ghr.v              # Global History Register
│       ├── bht.v              # Branch History Table
│       ├── PredictionDecoder.v         # Converts counter to prediction
│       ├── SaturatingCounter.v         # 2-bit saturating counter
│       └── SaturatingCounterUpdater.v  # Logic to update counters
├── sim/
│   ├── branch_trace.txt       # Generated branch trace
│   ├── loop_simulator.py      # Python script to generate branch trace
│   ├── mips_loop.s            # MIPS assembly for test program
│   ├── run_sim.tcl            # ModelSim TCL script for automation
│   ├── tb_gpredict.v          # Testbench for gpredict
│   ├── tb_gselect.v           # Testbench for gselect
│   └── tb_gshare.v            # Testbench for gshare
└── Project Documentation/
    ├── ECE586 Final Project Instructions.txt   # Project requirements
    └── mcfarling.txt                           # Reference paper
```

### How to Run Simulations

1. **Generate Branch Trace**
   ```
   cd sim
   python loop_simulator.py
   ```
   This creates `branch_trace.txt` with 6000 branch outcomes.

2. **Run ModelSim Simulations**
   ```
   cd sim
   vsim -do run_sim.tcl
   ```
   This will:
   - Compile all Verilog files
   - Run simulations for all three predictors
   - Display performance statistics

3. **View Waveforms**
   ```
   vsim -view gpredict.vcd   # Or gselect.vcd, gshare.vcd
   ```

### Performance Results

| Predictor | Total Branches | Mispredictions | Accuracy (%) |
|-----------|---------------|----------------|--------------|
| gpredict  | 6000          | 472            | 92.1%        |
| gselect   | 6000          | 223            | 96.3%        |
| gshare    | 6000          | 134            | 97.8%        |

### References

This project is based on Scott McFarling's paper "Combining Branch Predictors" (1993), which introduced the gselect and gshare predictor architectures.
