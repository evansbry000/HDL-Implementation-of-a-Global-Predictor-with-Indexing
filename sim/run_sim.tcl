# run_sim.tcl - ModelSim TCL script for simulating branch predictors

# Create work library
if {[file exists work]} {
    vdel -all
}
vlib work

# Generate branch trace if it doesn't exist
if {![file exists branch_trace.txt]} {
    puts "Generating branch trace using Python script..."
    exec python loop_simulator.py
}

# Compilation of source files
puts "Compiling source files..."
# Shared components
vlog ../src/Shared\ Components/ghr.v
vlog ../src/Shared\ Components/bht.v
vlog ../src/Shared\ Components/PredictionDecoder.v
vlog ../src/Shared\ Components/SaturatingCounter.v
vlog ../src/Shared\ Components/SaturatingCounterUpdater.v

# Index generation modules
vlog ../src/gpredict_index.v
vlog ../src/gselect_index.v
vlog ../src/gshare_index.v

# Predictor modules
vlog ../src/gpredict.v
vlog ../src/gselect.v
vlog ../src/gshare.v

# Testbenches
vlog tb_gpredict.v
vlog tb_gselect.v
vlog tb_gshare.v

# Run simulations and collect results
puts "\n----- Running gpredict simulation -----"
vsim -novopt tb_gpredict
run -all

puts "\n----- Running gselect simulation -----"
vsim -novopt tb_gselect
run -all

puts "\n----- Running gshare simulation -----"
vsim -novopt tb_gshare
run -all

puts "\n----- Simulation Complete -----"

# Generate waveforms if requested
if {[info exists view_waves] && $view_waves == 1} {
    puts "Opening waveform viewer..."
    vsim -novopt tb_gshare
    add wave -position insertpoint sim:/tb_gshare/dut/*
    run 200ns
}

# Display summary
puts "\nSimulation Summary:"
puts "Branch traces were read from branch_trace.txt"
puts "Predictor performance numbers are shown above"
puts "To view detailed waveforms, use: vsim -view gpredict.vcd (or gselect.vcd, gshare.vcd)"
