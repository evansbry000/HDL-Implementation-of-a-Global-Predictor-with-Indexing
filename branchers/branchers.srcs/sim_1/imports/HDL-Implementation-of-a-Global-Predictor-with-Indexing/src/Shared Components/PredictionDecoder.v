module prediction_decoder (
    input [1:0] counter,
    output prediction
);
    assign prediction = counter[1];  // MSB == 1 → predict taken
endmodule
