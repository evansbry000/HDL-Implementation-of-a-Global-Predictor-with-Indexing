module sat_counter (
    input clk,
    input update_enable,
    input taken,             // Actual branch outcome
    input [1:0] current_val,
    output reg [1:0] next_val,
    output prediction        // 1 if MSB == 1, else 0
);
    assign prediction = current_val[1];

    always @(*) begin
        if (!update_enable)
            next_val = current_val;
        else if (taken && current_val != 2'b11)
            next_val = current_val + 1;
        else if (!taken && current_val != 2'b00)
            next_val = current_val - 1;
        else
            next_val = current_val;
    end
endmodule
