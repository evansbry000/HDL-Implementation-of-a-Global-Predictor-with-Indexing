# run_sim_vivado.tcl - Xilinx Vivado-Compatible Simulation Script

# Get absolute paths
set script_dir [file normalize [file dirname [info script]]]
set trace_path [file join $script_dir branch_trace.txt]

# Generate branch trace
if {![file exists $trace_path]} {
    puts "Generating branch trace..."
    exec python [file join $script_dir loop_simulator.py] -o $trace_path
}

# Create project
create_project -force branch_predictor_sim ./branch_predictor_sim -part xc7a35tftg256-1
set_property target_language Verilog [current_project]

# Add design files
add_files -norecurse {
    ../src/Shared\ Components/ghr.v
    ../src/Shared\ Components/bht.v
    ../src/Shared\ Components/PredictionDecoder.v
    ../src/Shared\ Components/SaturatingCounter.v
    ../src/Shared\ Components/SaturatingCounterUpdater.v
    ../src/gpredict_index.v
    ../src/gselect_index.v
    ../src/gshare_index.v
    ../src/gpredict.v
    ../src/gselect.v
    ../src/gshare.v
}

# Add testbenches
add_files -fileset sim_1 -norecurse {
    tb_gpredict.v
    tb_gselect.v
    tb_gshare.v
}

# Set simulation properties
set_property generic "TRACE_FILE_PATH=$trace_path" [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Run simulations
foreach tb {tb_gpredict tb_gselect tb_gshare} {
    puts "\n----- Running $tb simulation -----"
    
    # Reset simulation
    close_sim -quiet
    set_property top $tb [get_filesets sim_1]
    launch_simulation -simset [get_filesets sim_1] -mode behavioral
    
    # Configure waveform viewing
    if {[info exists view_waves] && $view_waves == 1} {
        open_wave_config
        add_wave_divider "Signals"
        add_wave /$tb/dut/*
    }
    
    # Run simulation
    run all
    flush stdout
}

puts "\n----- Simulation Complete -----"
puts "Trace file used: $trace_path"
puts "To view waveforms: open_wave_db [get_property DIRECTORY [get_runs sim_1]]/behav.wdb"