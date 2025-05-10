# run_sims.tcl
open_project [glob *.xpr]

# Set absolute path to trace file
set trace_path [file normalize "branch_trace.txt"]

# Run simulations
foreach tb {tb_gpredict tb_gselect tb_gshare} {
    puts "\n----- Running $tb Simulation -----"
    close_sim -quiet
    # Pass trace path as generic
    set_property generic "TRACE_FILE_PATH=\"$trace_path\"" [get_filesets sim_1]
    
    # Configure and run simulation
    reset_simulation -mode "behavioral" -simset sim_1
    set_property top $tb [get_filesets sim_1]
    update_compile_order -fileset sim_1
    launch_simulation -simset sim_1
    puts "\n----- Running $tb -----"
    close_sim -force
    puts "----- Completed $tb Simulation -----"
}