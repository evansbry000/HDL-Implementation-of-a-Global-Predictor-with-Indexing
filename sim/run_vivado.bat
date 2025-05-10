@echo off
echo Running branch predictor simulations in Vivado...

REM Check if python has generated the branch trace
if not exist branch_trace.txt (
    echo Generating branch trace...
    python loop_simulator.py
)

REM Look for common Vivado installation paths
set VIVADO_PATH=

REM Try standard Xilinx installation paths
if exist "C:\Xilinx\Vivado\2024.2\bin\vivado.bat" (
    set VIVADO_PATH="C:\Xilinx\Vivado\2024.2\bin\vivado.bat"
) else if exist "C:\Xilinx\Vivado\2023.2\bin\vivado.bat" (
    set VIVADO_PATH="C:\Xilinx\Vivado\2023.2\bin\vivado.bat"
) else if exist "C:\Xilinx\Vivado\2023.1\bin\vivado.bat" (
    set VIVADO_PATH="C:\Xilinx\Vivado\2023.1\bin\vivado.bat"
) else if exist "C:\Xilinx\Vivado\2022.2\bin\vivado.bat" (
    set VIVADO_PATH="C:\Xilinx\Vivado\2022.2\bin\vivado.bat"
) else if exist "C:\Xilinx\Vivado\2022.1\bin\vivado.bat" (
    set VIVADO_PATH="C:\Xilinx\Vivado\2022.1\bin\vivado.bat"
)

REM If Vivado not found, ask user
if "%VIVADO_PATH%"=="" (
    echo Vivado installation not found in standard locations.
    echo Please enter the full path to your vivado.bat file:
    set /p VIVADO_PATH=
)

REM Run Vivado with the TCL script
echo Using Vivado at: %VIVADO_PATH%
%VIVADO_PATH% -mode tcl -source run_vivado_sim.tcl

echo Simulation complete.
pause 