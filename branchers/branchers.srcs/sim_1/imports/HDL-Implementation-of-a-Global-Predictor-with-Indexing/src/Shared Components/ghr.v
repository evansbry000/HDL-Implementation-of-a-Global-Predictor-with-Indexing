module ghr (
    input clk,
    input reset,
    input branch_outcome,     // 1 for Taken, 0 for Not Taken
    output reg [3:0] ghr_val
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            ghr_val <= 4'b0000;
        else
            ghr_val <= {ghr_val[2:0], branch_outcome};  // Shift left and insert new outcome
    end
endmodule 