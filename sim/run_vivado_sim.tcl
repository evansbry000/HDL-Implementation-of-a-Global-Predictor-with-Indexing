# run_vivado_sim.tcl - Vivado TCL script for simulating branch predictors

# Set up project - adjust path if needed
set project_directory [file normalize [file dirname [info script]]]
set project_name "BranchPredictors"

# Create project
create_project -force $project_name $project_directory/$project_name -part xc7a35tcpg236-1

# Generate branch trace if it doesn't exist
if {![file exists $project_directory/branch_trace.txt]} {
    puts "Generating branch trace using Python script..."
    exec python [file join $project_directory loop_simulator.py]
}

# Add branch trace file to project
add_files -fileset sim_1 $project_directory/branch_trace.txt
set_property file_type {{Text Files}} [get_files $project_directory/branch_trace.txt]

# Set up source files
set src_dir [file normalize [file join $project_directory "../src"]]
set shared_dir [file normalize [file join $src_dir "Shared Components"]]

# Add Shared Components
set shared_files [glob -nocomplain [file join $shared_dir "*.v"]]
foreach file $shared_files {
    add_files -norecurse $file
}

# Add index modules
set index_files [list \
    [file join $src_dir "gpredict_index.v"] \
    [file join $src_dir "gselect_index.v"] \
    [file join $src_dir "gshare_index.v"] \
]
add_files -norecurse $index_files

# Add predictor modules
set predictor_files [list \
    [file join $src_dir "gpredict.v"] \
    [file join $src_dir "gselect.v"] \
    [file join $src_dir "gshare.v"] \
]
add_files -norecurse $predictor_files

# Add testbenches
set testbench_files [list \
    [file join $project_directory "tb_gpredict.v"] \
    [file join $project_directory "tb_gselect.v"] \
    [file join $project_directory "tb_gshare.v"] \
]
add_files -fileset sim_1 -norecurse $testbench_files

# Set simulation properties
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]

# Run all three simulations and capture results
puts "\n----- Running GPREDICT simulation -----"
set_property top tb_gpredict [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
run all

puts "\n----- Running GSELECT simulation -----"
close_sim
set_property top tb_gselect [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
run all

puts "\n----- Running GSHARE simulation -----"
close_sim
set_property top tb_gshare [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
run all

puts "\n----- Simulation Complete -----"

# Display summary
puts "\nSimulation Summary:"
puts "Branch traces were read from branch_trace.txt"
puts "Predictor performance numbers are shown above"
puts "To view waveforms, use the Vivado GUI during simulation" 