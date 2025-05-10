module gselect_index (
    input [7:0] pc,
    input [3:0] ghr,
    output [3:0] index
);
    assign index = {pc[1:0], ghr[1:0]};
endmodule
