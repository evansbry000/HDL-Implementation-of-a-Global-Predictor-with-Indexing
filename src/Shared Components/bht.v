module bht (
    input clk,
    input reset,
    input predict_enable,
    input [3:0] index,
    input actual_outcome,
    output prediction,
    output [1:0] counter_val
);
    // 16 entry BHT table with 2-bit saturating counters
    reg [1:0] bht_entries [0:15];
    wire [1:0] updated_counter;
    integer i;
    
    // Initialize all entries to 00 (strongly not taken) on reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 16; i = i + 1) begin
                bht_entries[i] <= 2'b00;
            end
        end
        else if (predict_enable) begin
            bht_entries[index] <= updated_counter;
        end
    end
    
    // Get current counter value
    assign counter_val = bht_entries[index];
    
    // Decode the prediction
    prediction_decoder decoder (
        .counter(counter_val),
        .prediction(prediction)
    );
    
    // Update the counter based on actual outcome
    saturating_counter_updater updater (
        .current_val(counter_val),
        .actual_outcome(actual_outcome),
        .updated_val(updated_counter)
    );
    
endmodule 