module gselect (
    input clk,
    input reset,
    input predict_enable,
    input [7:0] branch_pc,
    input actual_outcome,
    output prediction
);

    wire [3:0] ghr_val;
    wire [3:0] index;
    wire [1:0] counter_val;

    // GHR logic
    ghr ghr_inst (
        .clk(clk),
        .reset(reset),
        .branch_outcome(actual_outcome),
        .ghr_val(ghr_val)
    );

    // Index = concat(PC[1:0], GHR[1:0])
    gselect_index idx (
        .pc(branch_pc),
        .ghr(ghr_val),
        .index(index)
    );

    // BHT access and update
    bht bht_inst (
        .clk(clk),
        .reset(reset),
        .predict_enable(predict_enable),
        .index(index),
        .actual_outcome(actual_outcome),
        .prediction(prediction),
        .counter_val(counter_val)
    );
    
endmodule

