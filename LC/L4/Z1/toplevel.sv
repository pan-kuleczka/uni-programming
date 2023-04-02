module circuit(input [3:0]i, input l, r, output [3:0]o);
    logic [3:0] shl, shr;
    assign shl = {i[2:0], 1'b0};
    assign shr = {1'b0, i[3:1]};

    assign o =  ({4{!l}} & {4{!r}} & i)
            |   ({4{!l}} & {4{r}} & shr)
            |   ({4{l}} & {4{!r}} & shl);
endmodule
