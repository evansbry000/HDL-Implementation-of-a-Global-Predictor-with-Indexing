module tb_gpredict();
    reg clk;
    reg reset;
    reg predict_enable;
    reg [7:0] branch_pc;
    reg actual_outcome;
    wire prediction;
    
    // Instantiate the gpredict module
    gpredict dut (
        .clk(clk),
        .reset(reset),
        .predict_enable(predict_enable),
        .branch_pc(branch_pc),
        .actual_outcome(actual_outcome),
        .prediction(prediction)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Variables for file reading and statistics
    integer file;
    integer scan_file;
    integer num_branches;
    integer num_mispredictions;
    
    // Testbench execution
    initial begin
        // Initialize
        reset = 1;
        predict_enable = 0;
        branch_pc = 0;
        actual_outcome = 0;
        num_branches = 0;
        num_mispredictions = 0;
        
        // Apply reset for a few cycles
        repeat (3) @(posedge clk);
        reset = 0;
        
        // Open the branch trace file
        file = $fopen("branch_trace.txt", "r");
        if (file == 0) begin
            $display("Error opening file 'branch_trace.txt'");
            $finish;
        end
        
        // Process each branch from the trace file
        while (!$feof(file)) begin
            // Read branch PC and outcome from file
            scan_file = $fscanf(file, "%d %d\n", branch_pc, actual_outcome);
            
            if (scan_file == 2) begin
                predict_enable = 1;
                
                // First cycle: make prediction 
                @(posedge clk);
                
                // Check if prediction matches actual outcome
                if (prediction != actual_outcome) begin
                    num_mispredictions = num_mispredictions + 1;
                    $display("Misprediction at PC=%d: predicted=%d, actual=%d", 
                             branch_pc, prediction, actual_outcome);
                end
                
                num_branches = num_branches + 1;
            end
        end
        
        // Display final statistics
        $display("\nGPREDICT Results:");
        $display("Total branches: %d", num_branches);
        $display("Mispredictions: %d", num_mispredictions);
        $display("Accuracy: %.2f%%", (num_branches - num_mispredictions) * 100.0 / num_branches);
        
        $fclose(file);
        $finish;
    end
    
    // Save waveform data
    initial begin
        $dumpfile("gpredict.vcd");
        $dumpvars(0, tb_gpredict);
    end
endmodule
