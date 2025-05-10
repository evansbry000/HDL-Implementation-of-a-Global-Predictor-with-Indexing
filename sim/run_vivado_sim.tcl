# run_vivado_sim.tcl - Vivado TCL script for simulating branch predictors

# Create a temporary directory on C: drive with short name to avoid path issues
set temp_dir "C:/temp_branch_sim"
file mkdir $temp_dir
puts "Created temporary working directory at $temp_dir"

# Set original project paths
set project_directory [file normalize [file dirname [info script]]]
set project_name "BranchPredictors"

# Create project in temporary directory
create_project -force $project_name $temp_dir -part xc7a35tcpg236-1

# Copy branch trace file to temp directory if it exists, otherwise generate it
set orig_trace_file [file join $project_directory "branch_trace.txt"]
set temp_trace_file [file join $temp_dir "branch_trace.txt"]

if {[file exists $orig_trace_file]} {
    puts "Copying branch trace file to temporary directory..."
    file copy -force $orig_trace_file $temp_trace_file
} else {
    puts "Generating branch trace using Python script..."
    set script_file [file join $project_directory "loop_simulator.py"]
    exec python $script_file
    file copy -force $orig_trace_file $temp_trace_file
}

# Add branch trace file to project
add_files -fileset sim_1 $temp_trace_file
set_property file_type {{Text Files}} [get_files $temp_trace_file]

# Set up source files
set src_dir [file normalize [file join $project_directory "../src"]]
set shared_dir [file normalize [file join $src_dir "Shared Components"]]

# Copy all source files to temp directory
set temp_src_dir [file join $temp_dir "src"]
file mkdir $temp_src_dir
set temp_shared_dir [file join $temp_src_dir "Shared_Components"]
file mkdir $temp_shared_dir

# Copy Shared Components
set shared_files [glob -nocomplain [file join $shared_dir "*.v"]]
foreach file $shared_files {
    set dest_file [file join $temp_shared_dir [file tail $file]]
    file copy -force $file $dest_file
    add_files -norecurse $dest_file
}

# Copy index modules
set index_files [list \
    [file join $src_dir "gpredict_index.v"] \
    [file join $src_dir "gselect_index.v"] \
    [file join $src_dir "gshare_index.v"] \
]
foreach file $index_files {
    set dest_file [file join $temp_src_dir [file tail $file]]
    file copy -force $file $dest_file
    add_files -norecurse $dest_file
}

# Copy predictor modules
set predictor_files [list \
    [file join $src_dir "gpredict.v"] \
    [file join $src_dir "gselect.v"] \
    [file join $src_dir "gshare.v"] \
]
foreach file $predictor_files {
    set dest_file [file join $temp_src_dir [file tail $file]]
    file copy -force $file $dest_file
    add_files -norecurse $dest_file
}

# Copy testbenches
set temp_tb_dir [file join $temp_dir "tb"]
file mkdir $temp_tb_dir
set testbench_files [list \
    [file join $project_directory "tb_gpredict.v"] \
    [file join $project_directory "tb_gselect.v"] \
    [file join $project_directory "tb_gshare.v"] \
]
foreach file $testbench_files {
    set dest_file [file join $temp_tb_dir [file tail $file]]
    file copy -force $file $dest_file
    add_files -fileset sim_1 -norecurse $dest_file
}

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

# Cleanup message
puts "\nNote: All simulation files were stored in $temp_dir"
puts "You can delete this directory when you're done." 