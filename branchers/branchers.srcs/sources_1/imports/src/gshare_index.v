module gshare_index (
    input [7:0] pc,
    input [3:0] ghr,
    output [3:0] index
);
    assign index = pc[3:0] ^ ghr;
endmodule
