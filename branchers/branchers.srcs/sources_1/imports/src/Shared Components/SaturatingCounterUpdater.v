module saturating_counter_updater (
    input [1:0] current_val,
    input actual_outcome,          // 1 = taken, 0 = not taken
    output reg [1:0] updated_val
);
    always @(*) begin
        case (actual_outcome)
            1'b1: begin  // Branch was taken → increment (up to 11)
                case (current_val)
                    2'b00: updated_val = 2'b01;
                    2'b01: updated_val = 2'b10;
                    2'b10: updated_val = 2'b11;
                    default: updated_val = 2'b11;
                endcase
            end
            1'b0: begin  // Branch not taken → decrement (down to 00)
                case (current_val)
                    2'b11: updated_val = 2'b10;
                    2'b10: updated_val = 2'b01;
                    2'b01: updated_val = 2'b00;
                    default: updated_val = 2'b00;
                endcase
            end
        endcase
    end
endmodule
