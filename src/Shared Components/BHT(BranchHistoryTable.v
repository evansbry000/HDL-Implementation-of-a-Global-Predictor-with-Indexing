module bht_table (
    input clk,
    input reset,
    input [3:0] index,
    input branch_outcome,
    output prediction
);
// Instantiate sat_counter logic per index
