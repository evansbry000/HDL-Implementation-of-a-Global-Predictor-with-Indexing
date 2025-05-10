# run_vivado_sim.tcl - Fixed simulation launch version

# Get project root from batch file
set script_directory [file dirname [info script]]
set project_directory $script_directory
puts "Project directory: $project_directory"
set trace_path [file join $project_directory branch_trace.txt]
puts "Trace file path: $trace_path"
# Create project
create_project -force BranchPredictors $project_directory/BranchPredictors -part xc7z010iclg225-1L

# Add files in proper compilation order
puts [glob -nocomplain $project_directory/../src/Shared\ Components/*.v]
add_files -norecurse [glob -nocomplain $project_directory/../src/Shared\ Components/*.v]
add_files -norecurse \
    $project_directory/../src/gpredict_index.v \
    $project_directory/../src/gselect_index.v \
    $project_directory/../src/gshare_index.v
add_files -norecurse \
    $project_directory/../src/gpredict.v \
    $project_directory/../src/gselect.v \
    $project_directory/../src/gshare.v

# Add testbenches and set properties
add_files -fileset sim_1 -norecurse \
    $project_directory/tb_gpredict.v \
    $project_directory/tb_gselect.v \
    $project_directory/tb_gshare.v

# In the simulation setup section:
set_property generic "TRACE_FILE_PATH=\"$trace_path\"" [get_filesets sim_1]
update_compile_order -fileset sim_1

# Verify compilation
if {[get_property NEEDS_REFRESH [get_filesets sim_1]]} {
    reset_target all [get_filesets sim_1]
    launch_simulation -scripts_only
}

# Run simulations with error checking
foreach tb {tb_gpredict tb_gselect tb_gshare} {
    puts "\n----- Running [string toupper $tb] simulation -----"
    
    # Clean previous simulation
    close_sim -quiet
    
    # Set simulation properties
    set_property top $tb [get_filesets sim_1]
    set_property top_lib xil_defaultlib [get_filesets sim_1]
    
    # Validate simulation setup
    if {[catch {launch_simulation -simset [get_filesets sim_1] -mode behavioral} result]} {
        puts "ERROR: Failed to launch $tb simulation: $result"
        puts "Check for:"
        puts "1. Missing file dependencies"
        puts "2. Syntax errors in Verilog files"
        puts "3. Correct TRACE_FILE_PATH ($trace_path)"
        exit 1
    }
    
    # Run simulation with timeout
    if {[catch {run all} result]} {
        puts "ERROR: Simulation failed for $tb: $result"
        exit 1
    }
    
    # Close simulation properly
    close_sim -quiet
}

puts "\n----- All simulations completed successfully -----"
puts "Waveform database: [get_property DIRECTORY [get_runs sim_1]]/behav.wdb"