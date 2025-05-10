@echo off
echo Running branch predictor simulations in Vivado...

REM Check if python has generated the branch trace
if not exist branch_trace.txt (
    echo Generating branch trace...
    python loop_simulator.py
)

REM Run Vivado with the TCL script
REM Update the path below if Vivado is installed in a different location
"C:\Xilinx\Vivado\2023.1\bin\vivado.bat" -mode tcl -source run_vivado_sim.tcl

echo Simulation complete.
pause 