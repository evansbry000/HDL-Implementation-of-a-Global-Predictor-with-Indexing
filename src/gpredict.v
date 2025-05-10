module gpredict (
    input clk,
    input reset,
    input predict_enable,
    input [7:0] branch_pc,
    input actual_outcome,
    output prediction
);

    wire [3:0] ghr_val;
    wire [3:0] index;
    reg  [1:0] bht [15:0];
    reg  [1:0] current_counter;
    wire [1:0] updated_counter;
    wire prediction_bit;

    // GHR logic
    ghr ghr_inst (
        .clk(clk),
        .reset(reset),
        .branch_outcome(actual_outcome),
        .ghr_val(ghr_val)
    );

    // Index = GHR
    gpredict_index idx (
        .ghr(ghr_val),
        .index(index)
    );

    // Decode prediction
    prediction_decoder decode (
        .counter(bht[index]),
        .prediction(prediction_bit)
    );

    assign prediction = prediction_bit;

    // Update counter on posedge clk
    saturating_counter_updater updater (
        .current_val(bht[index]),
        .actual_outcome(actual_outcome),
        .updated_val(updated_counter)
    );

    always @(posedge clk) begin
        if (predict_enable)
            bht[index] <= updated_counter;
    end
endmodule

